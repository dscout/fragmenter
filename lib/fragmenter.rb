require 'logger'
require 'redis'
require 'fragmenter/version'

module Fragmenter
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
end
