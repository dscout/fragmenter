require 'digest/md5'

module Fragmenter
  module Validators
    class ChecksumValidator
      attr_reader :errors, :request

      def initialize(request)
        @request = request
        @errors  = []
      end

      def part?
        true
      end

      def valid?
        matches = expected.nil? || expected == calculated

        unless matches
          errors << "Expected checksum #{expected} to match #{calculated}"
        end

        matches
      end

      private

      def expected
        request.headers['HTTP_CONTENT_MD5']
      end

      def calculated
        @calculated ||= Digest::MD5.hexdigest(request.body)
      end
    end
  end
end
