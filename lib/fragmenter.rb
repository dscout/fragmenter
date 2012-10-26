require 'logger'
require 'redis'
require 'fragmenter/version'
require 'fragmenter/base'

module Fragmenter
  class RebuildError < StandardError; end
  class StoreError   < StandardError; end

  def self.configure(&block)
    yield self
  end

  def self.logger
    @logger ||= Logger.new(STDOUT).tap do |logger|
      logger.level = Logger::INFO
    end
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.redis
    @redis ||= Redis.new
  end

  def self.redis=(redis)
    @redis = redis
  end

  def self.expiration=(expiration)
    @expiration = expiration
  end

  def self.expiration
    @expiration || 60 * 60 * 24
  end
end
