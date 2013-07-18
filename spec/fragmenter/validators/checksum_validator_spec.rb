require 'fragmenter/validators/checksum_validator'

describe Fragmenter::Validators::ChecksumValidator do
  Validator = Fragmenter::Validators::ChecksumValidator

  describe '#valid?' do
    it 'is always valid if no expected checksum was given' do
      expect(Validator.new(double(headers: {}))).to be_valid
    end

    it 'is valid if the expected checksum matches the body checksum' do
      request = double(
        body:    '0010001000',
        headers: { 'HTTP_CONTENT_MD5' => '4ac8660969d304047daa9c3539f63682' }
      )

      expect(Validator.new(request)).to be_valid
    end

    it 'is not valid if the expected checksum does not match the body checksum' do
      request = double(
        body:    '0010001000',
        headers: { 'HTTP_CONTENT_MD5' => 'a9c3539f636824ac8660969d304047da' }
      )

      expect(Validator.new(request)).to_not be_valid
    end

    it 'records an error when the checksums do not match' do
      request = double(
        body:    '0010001000',
        headers: { 'HTTP_CONTENT_MD5' => 'a9c3539f636824ac8660969d304047da' }
      )

      validator = Validator.new(request)
      validator.valid?

      expect(validator.errors.length).to be_nonzero
    end
  end
end
