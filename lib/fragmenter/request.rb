module Fragmenter
  class Request
    attr_accessor :fragmenter, :headers, :resource

    def initialize(options = {})
      @body       = options.fetch(:body, StringIO.new(''))
      @fragmenter = options.fetch(:fragmenter, nil)
      @headers    = options.fetch(:headers, {})
      @resource   = options.fetch(:resource, nil)
    end

    def body
      if @body.respond_to?(:read)
        @body.read
      else
        @body
      end
    end
  end
end
