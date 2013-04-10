module NoamServer
  module Persistence
    class Null

      def save(bucket_name, data)
      end

      def load(bucket_name, key)
        []
      end

      def get_bucket(bucket_name)
        nil
      end

      def clear(bucket_name)
      end
    end
  end
end

