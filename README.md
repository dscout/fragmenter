[![Build Status](https://travis-ci.org/dscout/fragmenter.png?branch=master)](https://travis-ci.org/dscout/fragmenter)
[![Code Climate](https://codeclimate.com/github/dscout/fragmenter.png)](https://codeclimate.com/github/dscout/fragmenter)

# Fragmenter

Fragmenter is a library for multipart upload support backed by Redis.
Fragmenter handles storing multiple parts of a larger binary and rebuilding it
back into the original after all parts have been stored.

## Why Fragment?

It alleviates the problems posed by uploading large blocks of data from slow
clients, notably mobile apps, by allowing the device to send multiple smaller
blocks of data independently. Once all of the smaller blocks have been received
they can quickly be rebuilt into the original file on the server.

Think of multipart uploading as blocky streaming. Nginx, Rack and Rails all
make it impossible to stream binary uploads. Breaking them into manageable
pieces is the simplest workaround.

Fragments are intended to be rather small, anywhere from 10-50k depending on
the underlying data size. There is a balance between connection overhead from
repeated server calls, being connection error tollerant, and not blocking the
server from handling other connections.

## Requirements

Fragmenter is tested on Ruby 2.0, but any ruby implementation with 1.9 syntax
should be supported.

Redis 2.0 or greater is required and version 2.6 is recommended.

## Installation

Add this to your Gemfile:

```ruby
gem 'fragmenter'
```

## Configuration

You can configure the following components of `Fragmenter`:

* **redis**      - Redis instance to use for IO. Defaults to a new instance connected to `localhost`.
* **logger**     - Logger instance to write out to. Defaults to `STDOUT` at the `INFO` level.
* **expiration** - The number of seconds until fragments will expire. Defaults to 86400, or 1 day.

```ruby
Fragmenter.configure do |config|
  config.redis      = $redis
  config.logger     = Rails.logger
  config.expiration = 2.days.to_i
end
```

## Using Fragmenter with Rails

However, it is designed to be used from within a Rails controller. Include the
provided `Fragmenter::Controller` module into any controller you wish to have
process uploads:

```ruby
class UploadControler < ApplicationController
  include Fragmenter::Rails::Controller

  private

  def resource
    @resource ||= Avatar.find(:avatar_id)
  end
end
```

The module adds methods for handling the GET, PUT, and DELETE requests needed
for handling fragment uploads. You must define a `resource` method that returns
an object implementing `fragmenter`. In the example above the `resource` is an
instance of the `Avatar` model, which could look something like this:

```ruby
class Avatar < ActiveRecord::Base
  include Fragmenter::Rails::Model

  def rebuild_fragments
    self.avatar = Fragmenter::DummyIO.new(fragmenter.rebuild).tap do |io|
      io.content_type = fragmenter.meta['content_type']
    end

    save!
  end
end
```

You **must** provide a concrete `rebuild_fragments` method that will perform
rebuilding, saving, persisting etc. Without overriding `rebuild_fragments` a
`Fragmenter::AbstractMethodError` will be raised when storage is complete and
it attempts to rebuild.

The example above synchronous storage using a mounted CarrierWave style
uploader. You may want to perform rebuilding with a background worker instead
to keep response times speedy.

After you have configured your routes to map `show`, `update` and `destroy` to
the uploads controller:

```ruby
MyApp::Application.routes.draw do
  resource :avatar do
    resource :upload, only: [:show, :update, :destroy]
  end
end
```

Then you can start sending `PUT` requests with successive fragments of data.
Each fragment will be stored uniquely to the parent object, an instance of
Avatar in this case. For each fragment that is stored the response will be the
JSON representation of the fragments along with a `200 OK` status code:

```bash
curl -i
     -X PUT                    /
     -H 'X-Fragment-Number: 1' /
     -H 'X-Fragment-Total: 2'  /
     --data-binary @blob-1     /
     http://example.com/avatar/1/upload

#=> HTTP/1.1 200 OK
#=> { "content_type": "image/jpeg", "fragments": [1], "total": 2 }
```

When the final part is uploaded the status code will be `202 Accepted` if the
fragment is valid and can be rebuilt:

```bash
curl -i
     -X PUT                    /
     -H 'X-Fragment-Number: 2' /
     -H 'X-Fragment-Total: 2'  /
     --data-binary @blob-2     /
     http://example.com/avatar/1/upload

#=> HTTP/1.1 202 Accepted
#=> { "content_type": "image/jpeg", "fragments": [1,2], "total": 2 }
```

### Validation

Often you will want to be sure that all of the data is being stored without any
bytes missing. A standard way to handle this is by sending a checksum that is
verified after transfer. Fragmenter handles checksum matching using a validator
that verifies each fragment that is uploaded. Validation is handled for any request
where the `Content-MD5` header has been sent:

```bash
curl -X PUT                                             /
     -H 'Content-MD5: ceba1b1ffc89e99abb54c1f8ab0c4157' /
     -H 'X-Fragment-Number: 1'                          /
     -H 'X-Fragment-Total: 1'                           /
     --data-binary @blob                                /
     http://example.com/avatar/1/upload
```

Failure to match the checksum will result in a `422 Unprocessable Entity`
response with an accompanying message and errors:

```json
{ "message": "Upload of part failed.",
  "errors":  [
    "Expected checksum {{expected}} to match {{calculated}}"
  ]
}
```
As images uploads are a common use-case for fragmented uploading an
ImageValidator is included, but not one of the default validators. You can
control with validators are used by overriding the `validators` method within
the controller:

```ruby
class AvatarUploader < ApplicationController
  ...

  private

  def validators
    super + [ImageValidator, CustomValidator]
  end
end
```

To add a custom validator you must add it at some point in the validator chain.
A validator can be any class that responds to `valid?` with a boolean value and
provides a list of errors. See the [ImageValidator][1] for an example validator
that only performs validation when all fragments are complete.

[1]:lib/fragmenter/validators/image
