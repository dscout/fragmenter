module Fragmenter
  class AbstractMethodError < StandardError; end

  module Rails
    module Model
      def fragmenter
        @fragmenter ||= Fragmenter::Wrapper.new(self)
      end

      def rebuild_fragments
        raise Fragmenter::AbstractMethodError.new('This must be overriden on your model')
      end
    end
  end
end
