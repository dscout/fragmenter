module Fragmenter
  class Fragment
    attr_reader :blob, :options

    def initialize(blob, options)
      @blob    = blob
      @options = options
    end

    def number
      @number ||= options[:number] || 1
    end

    def total
      @total ||= options[:total] || 1
    end

    def content_type
      @content_type ||= options[:content_type] || 'application/octet-stream'
    end

    def padded_number
      digits = total.to_s.length

      "%0#{digits}d" % number.to_s
    end

    def valid?
      valid_blob? && valid_number? && valid_total? && valid_content_type?
    end

    private

    def valid_blob?
      blob.size > 0
    end

    def valid_number?
      number.kind_of?(Integer) && number > 0
    end

    def valid_total?
      total.kind_of?(Integer) && total > 0 && total >= number
    end

    def valid_content_type?
      content_type =~ /\w+\/\w+/
    end
  end
end
