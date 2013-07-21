require 'fragmenter/rails/controller'
require 'sinatra/base'

class UploadsApp < Sinatra::Base
  include Fragmenter::Rails::Controller

  get('/')    { show }
  put('/')    { update }
  delete('/') { destroy }

  private

  def resource
    @resource ||= Resource.new(200)
  end

  def render(options)
    [options[:status], JSON.dump(options[:json])]
  end
end
