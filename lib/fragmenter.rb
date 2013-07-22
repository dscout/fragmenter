require 'logger'
require 'redis'
require 'fragmenter/redis'
require 'fragmenter/version'
require 'fragmenter/dummy_io'
require 'fragmenter/wrapper'
require 'fragmenter/rails/controller'
require 'fragmenter/rails/model'
require 'fragmenter/services/uploader'
require 'fragmenter/services/storer'
require 'fragmenter/validators/checksum_validator'
require 'fragmenter/validators/image_validator'

module Fragmenter
  class << self
    def configure(&block)
      yield self
    end

    def logger
      @logger ||= Logger.new(STDOUT).tap do |logger|
        logger.level = Logger::INFO
      end
    end

    def logger=(logger)
      @logger = logger
    end

    def redis
      @redis ||= ::Redis.new
    end

    def redis=(redis)
      @redis = redis
    end

    def expiration=(expiration)
      @expiration = expiration
    end

    def expiration
      @expiration || 60 * 60 * 24
    end
  end
end
