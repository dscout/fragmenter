module Fragmenter
  module Validators
    class ImageValidator
      attr_reader :errors, :request

      def initialize(request)
        @request = request
        @errors  = []
      end

      def part?
        false
      end

      def valid?
        return true unless fragmenter.complete?

        identifiable = identifiable?

        unless identifiable
          errors << 'Rebuilt fragments are not a valid image'
        end

        identifiable
      end

      private

      def fragmenter
        request.fragmenter
      end

      def identifiable?
        IO.popen('identify -', 'w', err: '/dev/null', out: '/dev/null') do |io|
          io << fragmenter.rebuild
        end

        $?.success?
      end
    end
  end
end
