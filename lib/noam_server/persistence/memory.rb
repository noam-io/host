require 'noam_server/persistence/base'

module NoamServer
  module Persistence
    class Memory < Base
      
      def initialize(config)
        @data_store ||= {}
        @connected = true
        NoamLogging.info(self, "Using Memory as Persistent Store")
      end
      
      def save(event_name, event_value, player_id)
        init(event_name)
        key = event_value.to_s
        get_bucket(event_name)[key] = [event_value, player_id]
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
