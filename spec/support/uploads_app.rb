require 'fragmenter/rails/controller'
require 'sinatra/base'

class UploadsApp < Sinatra::Base
  include Fragmenter::Rails::Controller

  class << self
    attr_accessor :resource
  end

  get('/')    { show }
  put('/')    { update }
  delete('/') { destroy }

  private

  def resource
    self.class.resource
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
