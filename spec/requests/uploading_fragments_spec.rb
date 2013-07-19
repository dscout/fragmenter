require 'spec_helper'
require 'json'
require 'rack/test'
require 'sinatra/base'

Resource = Struct.new(:id) do
  include Fragmenter::Rails::Model

  def rebuild_fragments
    fragmenter.rebuild && fragmenter.clean!
  end
end

class Uploads < Sinatra::Base
  include Fragmenter::Rails::Controller

  put('/') { update }

  private

  def resource
    @resource ||= Resource.new(200)
  end

  def render(options)
    [options[:status], JSON.dump(options[:json])]
  end
end

describe 'Uploading Fragments' do
  include Rack::Test::Methods

  before(:all) do
    Fragmenter.configure do |config|
      config.logger = Logger.new('/dev/null')
    end
  end

  after(:all) do
    Fragmenter.configure do |config|
      config.logger = nil
    end
  end

  def app
    Uploads
  end

  it 'Stores uploaded fragments' do
    header 'Accept',            'application/json'
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

  private

  def file_data(file)
    IO.read("spec/fixtures/#{file}")
  end

  def decoded_response
    JSON.parse(last_response.body)
  end
end
