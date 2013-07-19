module Fragmenter
  module Validators
    class ImageValidator
      attr_reader :request

      def initialize(request)
        @request = request
      end

      def part?
        false
      end

      def valid?
        return true unless fragmenter.complete?

        IO.popen('identify -', 'w', err: '/dev/null', out: '/dev/null') do |io|
          io << fragmenter.rebuild
        end

        $?.success?
      end

      private

      def fragmenter
        request.fragmenter
      end
    end
  end
end
