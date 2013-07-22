require 'fragmenter/dummy_io'

describe Fragmenter::DummyIO do
  it 'provies IO like access' do
    io = Fragmenter::DummyIO.new

    expect(io).to respond_to(:read)
    expect(io).to respond_to(:length)
  end

  describe '#content_type' do
    it 'defaults to application/octet-stream' do
      expect(Fragmenter::DummyIO.new.content_type).to eq('application/octet-stream')
    end

    it 'can be overridden' do
      io = Fragmenter::DummyIO.new
      io.content_type = 'image/png'

      expect(io.content_type).to eq('image/png')
    end
  end

  describe '#original_filename' do
    it 'defaults to a fake mime comprised of dummy and the content type' do
      io = Fragmenter::DummyIO.new
      io.content_type = 'image/png'

      expect(io.original_filename).to eq('dummy.png')
    end

    it 'can be overriden' do
      io = Fragmenter::DummyIO.new
      io.original_filename = 'wonderful.png'

      expect(io.original_filename).to eq('wonderful.png')
    end
  end
end
