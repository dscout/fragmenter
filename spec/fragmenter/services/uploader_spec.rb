require 'fragmenter/services/uploader'

describe Fragmenter::Services::Uploader do
  Uploader = Fragmenter::Services::Uploader

  describe '#store' do
    it 'attempts to store the fragments without any validators' do
      fragmenter = double(:fragmenter, complete?: false)
      request    = Fragmenter::Request.new(fragmenter: fragmenter)
      uploader   = Uploader.new(request)

      expect(uploader.storer).to receive(:store).and_return(true)
      expect(uploader.store).to be_true
    end

    it 'does not attempt to store fragments if any validators are invalid' do
      validator = Struct.new(:request) do
        def valid?
          false
        end
      end

      fragmenter = double(:fragmenter, complete?: false)
      request    = Fragmenter::Request.new(fragmenter: fragmenter)
      uploader   = Uploader.new(request, [validator])

      expect(uploader.storer).to_not receive(:store)

      expect(uploader.store).to be_false
    end

    it 'instructs the resource to rebuild if storage is complete' do
      resource   = double(:resource)
      fragmenter = double(:fragmenter, complete?: true)
      storer     = double(:storer, store: true)
      request    = Fragmenter::Request.new(resource: resource, fragmenter: fragmenter)
      uploader   = Uploader.new(request)

      uploader.storer = storer

      expect(resource).to receive(:rebuild_fragments)

      uploader.store
    end
  end

  describe '#complete?' do
    it 'is incomplete without store having been called' do
      uploader = Uploader.new(Object.new)

      expect(uploader).to_not be_complete
    end
  end

  describe '#errors' do
    it 'merges the errors from all validators' do
      validator_a = Struct.new(:request) do
        def valid?; false; end
        def errors; ['bad']; end
      end

      validator_b = Struct.new(:request) do
        def valid?; false; end
        def errors; ['invalid']; end
      end

      uploader = Uploader.new({}, [validator_a, validator_b])
      uploader.valid?

      expect(uploader.errors).to eq(%w[bad invalid])
    end
  end
end