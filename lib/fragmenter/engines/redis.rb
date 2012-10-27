require 'fragmenter/fragment'

module Fragmenter
  module Engines
    class Redis
      attr_reader :fragmenter, :options

      def defaults
        { expiration: 60 * 60 * 24 }
      end

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

      def expiration
        Fragmenter.expiration
      end

      def redis
        Fragmenter.redis
      end

      def persist_fragment(fragment)
        redis.multi do
          redis.hset store_key, fragment.padded_number, fragment.blob
          redis.hset meta_key, :content_type, fragment.content_type
          redis.hset meta_key, :total, fragment.total

          redis.expire store_key, expiration
          redis.expire meta_key, expiration
        end
      end
    end
  end
end
