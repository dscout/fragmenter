require 'fragmenter/request'

module Fragmenter
  module Services
    class Storer
      attr_reader :request, :errors

      def initialize(request)
        @request = request
        @errors  = []
      end

      def store
        stored = fragmenter.store(request.body, extracted_options)

        unless stored
          errors << 'Unable to store fragment'
        end

        stored
      end

      private

      def fragmenter
        request.fragmenter
      end

      def extracted_options
        headers = request.headers

        { content_type: headers.fetch('CONTENT_TYPE'),
          number:       headers.fetch('HTTP_X_FRAGMENT_NUMBER'),
          total:        headers.fetch('HTTP_X_FRAGMENT_TOTAL') }
      end
    end
  end
end
