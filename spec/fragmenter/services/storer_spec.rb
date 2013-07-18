require 'fragmenter/services/storer'

describe Fragmenter::Services::Storer do
  Storer = Fragmenter::Services::Storer

  describe '#store' do
    it 'stores the request with the fragmenter' do
      fragmenter = double(:fragmenter)

      request = Fragmenter::Request.new(
        fragmenter: fragmenter,
        body: '00100',
        headers: {
          'CONTENT_TYPE'           => 'application/octet-stream',
          'HTTP_X_FRAGMENT_NUMBER' => 1,
          'HTTP_X_FRAGMENT_TOTAL'  => 2
        }
      )

      expect(fragmenter).to receive(:store).with(
        '00100',
        content_type: 'application/octet-stream',
        number: 1,
        total:  2
      ).and_return(true)

      expect(Storer.new(request).store).to be_true
    end

    it 'records an error if the body could not be stored' do
      fragmenter = double(:fragmenter, store: false)

      request = Fragmenter::Request.new(
        fragmenter: fragmenter,
        body: '00100',
        headers: {
          'CONTENT_TYPE'           => 'application/octet-stream',
          'HTTP_X_FRAGMENT_NUMBER' => 1,
          'HTTP_X_FRAGMENT_TOTAL'  => 2
        }
      )

      storer = Storer.new(request)

      expect(storer.store).to be_false
      expect(storer.errors.length).to be_nonzero
    end
  end
end
