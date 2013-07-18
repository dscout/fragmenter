require 'fragmenter/services/storer'

module Fragmenter
  module Services
    class Uploader
      attr_reader :request, :validators
      attr_writer :storer

      def initialize(request, validators = [])
        @request    = request
        @validators = validators
      end

      def storer
        @storer ||= Fragmenter::Services::Storer.new(request)
      end

      def store
        stored    = valid? && storer.store
        @complete = fragmenter.complete?

        if stored && complete?
          rebuild_fragments
        end

        stored
      end

      def errors
        validator_instances.map(&:errors).flatten
      end

      def complete?
        !!@complete
      end

      def valid?
        validator_instances.all?(&:valid?)
      end

      private

      def fragmenter
        request.fragmenter
      end

      def rebuild_fragments
        request.resource.rebuild_fragments
      end

      def validator_instances
        @validator_instances ||= validators.map do |validator|
          validator.new(request)
        end
      end
    end
  end
end
