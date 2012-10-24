require 'fragmenter'

describe Fragmenter do
  describe '.logger' do
    it 'attempts to instantiate a standard logger to STDOUT' do
      Fragmenter.logger.should be_instance_of(Logger)
      Fragmenter.logger.level.should == Logger::INFO
    end
  end

  describe '.logger=' do
    it 'stores the logger instance on the module' do
      logger = mock(:logger)

      Fragmenter.logger = logger
      Fragmenter.logger.should be(logger)
    end
  end

  describe '.redis' do
    it 'attempts to create a redis connection with default values' do
      Fragmenter.redis.should be_instance_of(Redis)
    end
  end

  describe '.redis=' do
    it 'stores the redis instance on the module' do
      redis = mock(:redis)

      Fragmenter.redis = redis
      Fragmenter.redis.should be(redis)
    end
  end
end
