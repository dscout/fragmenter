module Fragmenter
  class Wrapper
    extend Forwardable

    attr_reader :object, :engine

    delegate clean!:    :engine
    delegate complete?: :engine
    delegate fragments: :engine
    delegate meta:      :engine
    delegate rebuild:   :engine
    delegate store:     :engine

    def initialize(object, engine_class = Fragmenter::Redis)
      @object = object
      @engine = engine_class.new(self)
    end

    def key
      [object.class.to_s.downcase, object.id].join('-')
    end

    def as_json
      engine.meta.merge('fragments' => engine.fragments)
    end
  end
end
