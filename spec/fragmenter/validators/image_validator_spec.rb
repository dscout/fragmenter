require 'fragmenter/request'
require 'fragmenter/validators/image_validator'

describe Fragmenter::Validators::ImageValidator do
  Validator = Fragmenter::Validators::ImageValidator

  describe '#valid?' do
    it 'bypasses validation checking if the fragmenter is incomplete' do
      fragmenter = double(:fragmenter, complete?: false)
      request    = Fragmenter::Request.new(fragmenter: fragmenter)

      expect(Validator.new(request)).to be_valid
    end

    it 'is invalid with a body that can not be parsed as an image' do
      fragmenter = double(:fragmenter, complete?: true, rebuild: '01010101')
      request    = Fragmenter::Request.new(fragmenter: fragmenter)

      expect(Validator.new(request)).to_not be_valid
    end

    it 'is valid with a body that can be parsed as an image' do
      image = IO.read('spec/fixtures/micro.gif')
      fragmenter = double(:fragmenter, complete?: true, rebuild: image)
      request    = Fragmenter::Request.new(fragmenter: fragmenter)

      expect(Validator.new(request)).to be_valid
    end
  end
end
