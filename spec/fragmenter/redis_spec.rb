require 'fragmenter'
require 'fragmenter/redis'

describe Fragmenter::Redis do
  let(:blob_1)     { '00010110' }
  let(:blob_2)     { '11101110' }
  let(:fragmenter) { double(:fragmenter, key: 'abcdefg') }
  let(:redis)      { Fragmenter.redis }

  subject(:engine) { Fragmenter::Redis.new(fragmenter) }

  before do
    Fragmenter.logger = Logger.new('/dev/null')
  end

  after do
    redis.del engine.store_key, engine.meta_key
  end

  describe '#store_key' do
    it 'delegates store key to the fragmenter key' do
      engine.store_key.should == fragmenter.key
    end
  end

  describe '#meta_key' do
    it 'combines the base store key with options' do
      engine.meta_key.should include(fragmenter.key)
      engine.meta_key.should include('options')
    end
  end

  describe '#store' do
    it 'does not store empty blobs' do
      engine.store('', number: 1, total: 2).should be_false
    end

    it 'writes the provided blob to the fragmenter key and the provided number' do
      engine.store(blob_1, number: 1, total: 48)

      redis.hget(fragmenter.key, '01').should == blob_1
    end

    it 'overwrites existing data at the key + number location' do
      engine.store(blob_1, number: 1, total: 48)
      engine.store(blob_2, number: 1, total: 48)

      redis.hget(fragmenter.key, '01').should == blob_2
    end

    it 'sets the fragment to expire' do
      engine.store(blob_1, number: 1, total: 48)

      redis.ttl(engine.store_key).should == Fragmenter.expiration
    end

    it 'stores meta-data in a spearate key' do
      subject.store(blob_1, number: 1, total: 48)

      redis.exists(engine.meta_key).should be_true
    end

    it 'sets the meta to expire' do
      engine.store(blob_1, number: 1, total: 48)

      redis.ttl(engine.meta_key).should == Fragmenter.expiration
    end

    it 'defaults the stored content-type to application/octet-stream' do
      subject.store(blob_1, number: 1, total: 48)

      redis.hget(engine.meta_key, :content_type).should == 'application/octet-stream'
    end
  end

  describe '#meta' do
    it 'returns an empty hash when nothing has been stored' do
      engine.meta.should == {}
    end

    it 'returns the accumulated metadata when data has been stored' do
      engine.store(blob_1, content_type: 'image/jpeg', number: 1, total: 2)
      engine.meta.should eq(
        'content_type' => 'image/jpeg',
        'total' => '2'
      )
    end
  end

  describe '#fragments' do
    context 'without any fragments' do
      it 'returns an empty array' do
        engine.fragments.should == []
      end
    end

    context 'when fragments have been stored' do
      before do
        engine.store(blob_2, number: 3, total: 30)
        engine.store(blob_1, number: 1, total: 30)
      end

      it 'returns an array of the stored fragment indecies' do
        engine.fragments.should == ['01', '03']
      end
    end
  end

  describe '#complete?' do
    it 'is incomplete if the number of stored fragments does not match the total' do
      engine.store(blob_1, number: 1, total: 2)

      engine.should_not be_complete
    end

    it 'is complete if the stored fragments matches all values between 1 and the total' do
      engine.store(blob_1, number: 1, total: 2)
      engine.store(blob_2, number: 2, total: 2)

      engine.should be_complete
    end
  end

  describe '#rebuild' do
    before do
      engine.store(blob_1, number: 1, total: 2)
      engine.store(blob_2, number: 2, total: 2)
    end

    it 'returns the aggregated values from all stored fragments' do
      engine.rebuild.should == [blob_1, blob_2].join('')
    end

    it 'returns nothing when no fragments are present' do
      redis.del engine.store_key

      engine.rebuild.should == ''
    end
  end

  describe '#clean!' do
    before do
      engine.store(blob_1, number: 1, total: 2)
    end

    it 'deletes the storage and meta data' do
      engine.clean!

      redis.exists(engine.meta_key).should be_false
      redis.exists(engine.store_key).should be_false
    end
  end
end
