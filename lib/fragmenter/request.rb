module Fragmenter
  class Request
    attr_accessor :body, :fragmenter, :headers, :resource

    def initialize(options = {})
      @body       = options.fetch(:body, '')
      @fragmenter = options.fetch(:fragmenter, nil)
      @headers    = options.fetch(:headers, {})
      @resource   = options.fetch(:resource, nil)
    end
  end
end
