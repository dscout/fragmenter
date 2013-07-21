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
    body = if options[:json]
      JSON.dump(options[:json])
    else
      nil
    end

    [options[:status], body]
  end
end
