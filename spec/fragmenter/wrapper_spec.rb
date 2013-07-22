require 'fragmenter'

describe Fragmenter::Wrapper do
  let(:object)       { double(:object, id: 1001) }
  let(:engine_class) { double(:engine_class, new: engine) }
  let(:engine)       { double(:engine) }

  subject(:wrapper) do
    Fragmenter::Wrapper.new(object, engine_class)
  end

  describe '#key' do
    it 'composes a key from the object class and id value' do
      expect(wrapper.key).to match(/[a-z]+-\d+/)
    end
  end

  describe 'engine delegation' do
    let(:blob)    { '0101' }
    let(:headers) { {} }

    it 'delegates #store to the storage engine' do
      expect(engine).to receive(:store).with(blob, headers)

      wrapper.store(blob, headers)
    end

    it 'delegates #fragments to the storage engine' do
      expect(engine).to receive(:fragments)
      wrapper.fragments
    end
  end

  describe '#as_json' do
    it 'merges the stored meta and fragments' do
      engine.stub('meta' => { 'content_type' => 'application/octet-stream' },
                  'fragments' => ['1', '2'])

      wrapper.as_json.tap do |json|
        expect(json).to have_key('content_type')
        expect(json).to have_key('fragments')
      end
    end
  end

  describe '#to_io' do
    it 'wraps the rebuilt data in a Rack::Multipart::UploadedFile compatible IO object' do
      engine.stub(meta: { 'content_type' => 'image/png' }, rebuild: '0101010')

      wrapper.to_io.tap do |io|
        expect(io).to be_instance_of(Fragmenter::DummyIO)
        expect(io.read).to eq('0101010')
        expect(io.content_type).to eq('image/png')
        expect(io.original_filename).to eq('dummy.png')
      end
    end
  end
end
