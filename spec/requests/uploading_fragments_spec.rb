require 'spec_helper'
require 'json'
require 'rack/test'
require 'support/resource'
require 'support/uploads_app'

describe 'Uploading Fragments' do
  include Rack::Test::Methods

  let(:resource) { Resource.new(200) }
  let(:app)      { UploadsApp.new(resource) }

  around do |example|
    resource.fragmenter.clean!
    Fragmenter.logger = Logger.new('/dev/null')
    example.run
    Fragmenter.logger = nil
  end

  it 'Lists uploaded fragments' do
    get '/'

    expect(last_response.status).to eq(200)
    expect(decoded_response).to eq('fragments' => [])

    store_fragment(number: 1, total: 2)

    get '/'

    expect(last_response.status).to eq(200)
    expect(decoded_response).to eq(
      'content_type' => 'application/octet-stream',
      'fragments'    => %w[1],
      'total'        => '2'
    )

    clean_fragments!
  end

  it 'Stores uploaded fragments' do
    header 'Content-Type',      'image/gif'
    header 'X-Fragment-Number', '1'
    header 'X-Fragment-Total',  '2'

    put '/', file_data('micro.gif')

    expect(last_response.status).to eq(200)
    expect(decoded_response).to eq(
      'content_type' => 'image/gif',
      'fragments'    => %w[1],
      'total'        => '2'
    )

    header 'X-Fragment-Number', '2'
    header 'X-Fragment-Total',  '2'

    put '/', file_data('micro.gif')

    expect(last_response.status).to eq(202)
    expect(decoded_response).to eq('fragments' => [])
  end

  it 'Destroys uploaded fragments' do
    store_fragment(number: 1, total: 2)

    delete '/'

    expect(last_response.status).to eq(204)
    expect(last_response.body).to eq('')
    expect(fragmenter.fragments.length).to be_zero
  end

  private

  def file_data(file)
    IO.read("spec/fixtures/#{file}")
  end

  def decoded_response
    JSON.parse(last_response.body)
  end

  def fragmenter
    resource.fragmenter
  end

  def store_fragment(options = {})
    number = options[:number]
    total  = options[:total]

    fragmenter.store(
      '0101',
      content_type: 'application/octet-stream',
      number: number,
      total:  total
    )
  end

  def clean_fragments!
    resource.fragmenter.clean!
  end
end
