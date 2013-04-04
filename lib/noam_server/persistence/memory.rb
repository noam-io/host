module NoamServer
  module Persistence
    class Memory
      
      def initialize
        @data_store ||= {}
      end
      
      def save(bucket_name, data)
        init(bucket_name)
        key = data.to_s
        get_bucket(bucket_name)[key] = data
        return key
      end
      
      def load(bucket_name, key)
        init(bucket_name)
        data = get_bucket(bucket_name)[key]
        data.nil? ? [] : data
      end
      
      def get_bucket(bucket_name)
        @data_store[bucket_name]
      end
      
      def clear(bucket_name)
        @data_store[bucket_name] = {}
      end
      
      private
      
      def init(bucket_name)
        clear(bucket_name) if get_bucket(bucket_name).nil?
      end
    end
  end
end
