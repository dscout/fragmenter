require 'fragmenter/fragment'

module Fragmenter
  class Redis
    extend Forwardable

    delegate expiration: Fragmenter
    delegate logger:     Fragmenter
    delegate redis:      Fragmenter

    attr_reader :fragmenter

    def initialize(fragmenter)
      @fragmenter = fragmenter
    end

    def store_key
      fragmenter.key
    end

    def meta_key
      [store_key, 'options'].join('-')
    end

    def store(blob, options)
      fragment = Fragmenter::Fragment.new(blob, options)

      raise Fragmenter::StoreError unless fragment.valid?

      persist_fragment(fragment)
    end

    def meta
      redis.hgetall meta_key
    end

    def fragments
      redis.hkeys(store_key).sort
    end

    def complete?
      redis.hlen(store_key).to_s == redis.hget(meta_key, :total)
    end

    def rebuild
      redis.hmget(store_key, *fragments).join('')
    rescue ::Redis::CommandError
      raise Fragmenter::RebuildError
    end

    def clean!
      redis.del store_key, meta_key
    end

    private

    def persist_fragment(fragment)
      benchmark_persistence(fragment) do
        redis.multi do
          redis.hset store_key, fragment.padded_number, fragment.blob
          redis.hset meta_key, :content_type, fragment.content_type
          redis.hset meta_key, :total, fragment.total

          redis.expire store_key, expiration
          redis.expire meta_key, expiration
        end
      end
    end

    def benchmark_persistence(fragment, &block)
      logger.info "Fragmenter: Storing #{fragment.number}/#{fragment.total}..."
      start_time = Time.now

      yield

      end_time = Time.now
      logger.info "Fragmenter: Stored (#{end_time - start_time}) #{fragment.number}/#{fragment.total} #{fragment.blob.size}bytes"
    end
  end
end
