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

  describe '.expiration' do
    it 'defaults expiration to one day' do
      Fragmenter.expiration.should == 86400
    end
  end

  describe '.expiration=' do
    it 'stoires the expiration value on the module' do
      Fragmenter.expiration = 10000
      Fragmenter.expiration.should eq(10000)
    end
  end

  describe '.configure' do
    let(:redis)  { mock(:redis) }
    let(:logger) { mock(:logger) }

    it 'allows customization via passing a block' do
      Fragmenter.configure do |config|
        config.redis  = redis
        config.logger = logger
      end

      Fragmenter.redis.should == redis
      Fragmenter.logger.should == logger
    end
  end
end
