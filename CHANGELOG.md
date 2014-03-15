# 1.0.1

* Create a new uploader instance per request, avoiding unexpected caching
  behavior.

# 1.0.0

* Provide a convenience IO wrapper for rebuilt data with `Wrapper#to_io`.
* Add integration specs for testing against the rack request/response interface

# 1.0.0.rc2

* Automatically rewind IO objects between reads. This fixes the issue of
  multiple validations preventing storage.
* Expose storage errors along with validation errors when using the uploader.
* Make good on the documented `ImageValidator`. The implemented version has no
  additional gem dependencies, but does rely on ImageMagick for its `identify`
  command.

# 1.0.0.rc1

* Add modules for easiy integration with Rails controllers and models.
* Add validators for fragment storage.
* Add services to help handle requests.
* Add a request object that wraps the various resource, fragment, and rack
  request objects.
* Rename `Fragmenter::Base` to `Fragmenter::Wrapper`.
* Enhanced documentation so that people can actually see what to do with the
  libary.

# 0.5.1

* Initial release!
