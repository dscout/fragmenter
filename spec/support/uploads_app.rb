require 'fragmenter/rails/controller'
require 'rack/request'
require 'rack/response'

class UploadsApp
  include Fragmenter::Rails::Controller

  attr_reader :request, :resource

  def initialize(resource)
    @resource = resource
  end

  def call(env)
    @request = Rack::Request.new(env)

    case request.request_method
    when 'GET'    then show
    when 'PUT'    then update
    when 'DELETE' then destroy
    end
  end

  private

  def render(options)
    body = if options[:json]
      JSON.dump(options[:json])
    else
      ''
    end

    Rack::Response.new(body, options[:status], {}).finish do
      @uploader = nil
    end
  end
end
