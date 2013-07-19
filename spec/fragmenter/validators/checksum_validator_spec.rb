require 'fragmenter/validators/checksum_validator'

describe Fragmenter::Validators::ChecksumValidator do
  let(:validator) do
    Fragmenter::Validators::ChecksumValidator
  end

  describe '#valid?' do
    it 'is always valid if no expected checksum was given' do
      expect(validator.new(double(headers: {}))).to be_valid
    end

    it 'is valid if the expected checksum matches the body checksum' do
      request = double(
        body:    '0010001000',
        headers: { 'HTTP_CONTENT_MD5' => '4ac8660969d304047daa9c3539f63682' }
      )

      expect(validator.new(request)).to be_valid
    end

    it 'is not valid if the expected checksum does not match the body checksum' do
      request = double(
        body:    '0010001000',
        headers: { 'HTTP_CONTENT_MD5' => 'a9c3539f636824ac8660969d304047da' }
      )

      expect(validator.new(request)).to_not be_valid
    end

    it 'records an error when the checksums do not match' do
      request = double(
        body:    '0010001000',
        headers: { 'HTTP_CONTENT_MD5' => 'a9c3539f636824ac8660969d304047da' }
      )

      instance = validator.new(request)
      instance.valid?

      expect(instance.errors.length).to be_nonzero
    end
  end
end
