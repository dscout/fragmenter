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

      if fragment.valid?
        persist_fragment(fragment)
      else
        false
      end
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
      benchmark_rebuilding do
        redis.hmget(store_key, *fragments).join('')
      end
    rescue ::Redis::CommandError
      log 'Failure rebuilding, most likely there are no fragments to rebuild'

      ''
    end

    def clean!
      redis.del store_key, meta_key
    end

    private

    def log(message)
      logger.info "Fragmenter: #{message}"
    end

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
      log %(Storing #{fragment.number}/#{fragment.total}...)
      start_time = Time.now

      yield

      end_time = Time.now
      log %(Stored (#{end_time - start_time}) #{fragment.number}/#{fragment.total} #{fragment.blob.size} bytes)
    end

    def benchmark_rebuilding(&block)
      log %(Rebuilding #{fragments.length} fragments...)
      start_time = Time.now

      rebuilt = yield

      end_time = Time.now
      log %(Rebuilt (#{end_time - start_time}) #{fragments.length} fragments #{rebuilt.size} bytes)

      rebuilt
    end
  end
end
