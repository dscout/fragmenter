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
        stored    = parts_valid? && storer.store && rebuilt_valid?
        @complete = fragmenter.complete?

        if stored && complete?
          rebuild_fragments
        end

        stored
      end

      def errors
        [validator_instances.map(&:errors), storer.errors].flatten
      end

      def complete?
        !!@complete
      end

      def parts_valid?
        validator_instances.select(&:part?).all?(&:valid?)
      end

      def rebuilt_valid?
        validator_instances.reject(&:part?).all?(&:valid?)
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
