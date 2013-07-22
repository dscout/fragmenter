module Fragmenter
  class DummyIO < StringIO
    attr_writer   :content_type, :original_filename

    def original_filename
      @original_filename || ['dummy', content_type.split('/').last].join('.')
    end

    def content_type
      @content_type || 'application/octet-stream'
    end
  end
end
