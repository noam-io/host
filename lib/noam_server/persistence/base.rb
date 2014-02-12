module NoamServer
  module Persistence
    class Base

      attr_accessor :connected
      attr_reader :connected

      def self.instance(config)
        if @instance.nil?
          @instance = self.new(config)
        elsif not @instance.connected
          @instance.connect
        end
        @instance
      end

      def self.reset
        @instance = nil
      end

      def initialize(config)
        @connected = false
      end

      def connect
      end

      def save(event_name, event_value, player_spalla_id)
        # Do Nothing
      end

      def load(bucket_name, key)
      end

      def get_bucket(bucket_name)
        # Do Nothing
      end

      def clear(bucket_name)
      end
    end
  end
end
