require 'fragmenter/request'
require 'fragmenter/validators/image_validator'

describe Fragmenter::Validators::ImageValidator do
  let(:validator) do
    Fragmenter::Validators::ImageValidator
  end

  describe '#valid?' do
    it 'bypasses validation checking if the fragmenter is incomplete' do
      fragmenter = double(:fragmenter, complete?: false)
      request    = Fragmenter::Request.new(fragmenter: fragmenter)

      expect(validator.new(request)).to be_valid
    end

    it 'is invalid with a body that can not be parsed as an image' do
      fragmenter = double(:fragmenter, complete?: true, rebuild: '01010101')
      request    = Fragmenter::Request.new(fragmenter: fragmenter)

      instance = validator.new(request)

      expect(instance).to_not be_valid
      expect(instance.errors.length).to be_nonzero
    end

    it 'is valid with a body that can be parsed as an image' do
      image = IO.read('spec/fixtures/micro.gif')
      fragmenter = double(:fragmenter, complete?: true, rebuild: image)
      request    = Fragmenter::Request.new(fragmenter: fragmenter)

      expect(validator.new(request)).to be_valid
    end
  end
end
