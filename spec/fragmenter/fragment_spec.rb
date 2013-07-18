require 'fragmenter/fragment'

describe Fragmenter::Fragment do
  let(:blob) { '1010101' }

  describe '#number' do
    it 'defaults the number to 1' do
      Fragmenter::Fragment.new(blob, {}).number.should == 1
    end
  end

  describe '#total' do
    it 'defaults the total to 1' do
      Fragmenter::Fragment.new(blob, {}).total.should == 1
    end
  end

  describe '#content_type' do
    it 'defaults the content_type to a binary format' do
      Fragmenter::Fragment.new(blob, {}).content_type.should == 'application/octet-stream'
    end
  end

  describe '#padded_number' do
    it 'zero pads the number with as many zeros as the total has places' do
      Fragmenter::Fragment.new(blob, number: 1, total: 2000).padded_number.should == '0001'
    end
  end

  describe '#valid?' do
    it 'is valid with a complete blob and sensible options' do
      Fragmenter::Fragment.new(blob, number: 1, total: 2).should be_valid
    end

    it 'is not valid with an empty blob' do
      Fragmenter::Fragment.new('', number: 1, total: 2).should_not be_valid
    end

    it 'is not valid without an integer part number greater than 1' do
      Fragmenter::Fragment.new(blob, number: -1, total: 2).should_not be_valid
      Fragmenter::Fragment.new(blob, number: 'one', total: 2).should_not be_valid
    end

    it 'is not valid without an integer part total' do
      Fragmenter::Fragment.new(blob, number: 1, total: -2).should_not be_valid
      Fragmenter::Fragment.new(blob, number: 1, total: 'two').should_not be_valid
    end

    it 'is not valid when the number is greater the total' do
      Fragmenter::Fragment.new(blob, number: 2, total: 1).should_not be_valid
      Fragmenter::Fragment.new(blob, number: 2, total: 2).should be_valid
    end

    it 'is not valid without a content type resembling a mime type' do
      Fragmenter::Fragment.new(blob, content_type: 'jpg').should_not be_valid
    end
  end
end
