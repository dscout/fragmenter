# Fragmenter

Fragmenter stores and rebuilds binary data in a distributed fashion. The only
engine currently provided is Redis.

# Why?

It alleviates the problems posed by uploading large blocks of data from slow
clients, notably mobile apps, by allowing the device to send multiple smaller
blocks of data independently. Once all of the smaller blocks have been received
they can quickly be rebuilt into the original file on the server.

## Requirements

Fragmenter is tested on Ruby 1.9.3, but any ruby implementation with 1.9 syntax
should be supported.

Redis 2.0 or greater is required and version 2.6 is recommended.

## Installation

    $ gem install fragmenter

## Getting Started

### Configuration

    Fragmenter.configure do |config|
      config.redis      = $redis
      config.logger     = Rails.logger
      config.expiration = 2.days.to_i
    end

### Usage

    fragmenter = Fragmenter::Base.new(record)

    fragmenter.store(binary_data, number: 1, total: 12, content_type: 'image/jpeg')
    fragmenter.complete? # => false

    fragmenter.store(binary_data, number: 12, total: 12, content_type: 'image/jpeg')
    fragmenter.complete? # => true

    rebuilt = fragmenter.rebuild # => binary data
    fragmenter.clean!

More detailed examples will be added soon.

## License

Please see LICENSE for licensing details.
