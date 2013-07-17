require 'fragmenter/base'

describe Fragmenter::Base do
  let(:object)       { double(:object, id: 1001) }
  let(:engine_class) { double(:engine_class, new: engine) }
  let(:engine)       { double(:engine) }

  subject { described_class.new(object, engine_class) }

  describe '#key' do
    it 'composes a key from the object class and id value' do
      subject.key.should match(/[a-z]+-\d+/)
    end
  end

  describe 'engine delegation' do
    let(:blob)    { '0101' }
    let(:headers) { {} }

    it 'delegates #store to the storage engine' do
      engine.should_receive(:store).with(blob, headers)

      subject.store(blob, headers)
    end

    it 'delegates #fragments to the storage engine' do
      engine.should_receive(:fragments)
      subject.fragments
    end
  end

  describe '#as_json' do
    it 'merges the stored meta and fragments' do
      engine.stub('meta' => { 'content_type' => 'application/octet-stream' },
                  'fragments' => ['1', '2'])

      subject.as_json.tap do |json|
        json.should have_key('content_type')
        json.should have_key('fragments')
      end
    end
  end
end
