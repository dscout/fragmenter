require 'fragmenter/request'

describe Fragmenter::Request do
  describe '#body' do
    it 'attempts to read from the body if it is an IO object' do
      request = Fragmenter::Request.new(body: StringIO.new('blob'))
      expect(request.body).to eq('blob')
    end

    it 'does not attempt to read the body if it is not IO' do
      request = Fragmenter::Request.new(body: 'blob')
      expect(request.body).to eq('blob')
    end
  end
end
