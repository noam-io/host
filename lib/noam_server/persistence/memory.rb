module NoamServer
  module Persistence
    class Memory
      
      def initialize
        @data_store ||= {}
      end
      
      def save(bucket, value)
        init(bucket)
        @data_store[bucket] << value
      end
      
      def load(bucket)
        init(bucket)
        @data_store[bucket]
      end
      
      def init(bucket)
        clear(bucket) if @data_store[bucket].nil?
      end
      
      def clear(bucket)
        @data_store[bucket] = []
      end
    end
  end
end
