require 'logger'
require 'redis'
require 'fragmenter/version'

module Fragmenter
  DEFAULTS = {
    log_level: 4
  }

  def self.options
    @options ||= DEFAULTS
  end

  def self.options=(options)
    @options = options
  end

  def self.logger
    @logger ||= Logger.new(STDOUT).tap do |logger|
      logger.level = options[:log_level]
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
