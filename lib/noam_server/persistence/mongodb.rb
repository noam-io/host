require 'noam_server/config'
require 'mongo'

module NoamServer
  module Persistence
    class MongoDB
      attr_accessor :connected, :ip, :port, :db
      attr_reader :connected

      def self.instance
        if @instance.nil?
          @instance = self.new
        elsif not @instance.connected
          @instance.connect
        end
        @instance
      end

      def initialize
        @connected = false
        @ip = CONFIG[:mongodb][:ip] || 'localhost'
        @port = CONFIG[:mongodb][:port] || 27017
        @db = CONFIG[:mongodb][:db] || 'noam-server-data'
        connect
      end

      def connect
        begin
          @client = ::Mongo::MongoClient.new(@ip, @port)          
          @db = @client.db(@db)
          @connected = true
          Logging.logger[self].info { "Connected to MongoDB database '#{@db}' at #{@ip}:#{@port}" }
        rescue Exception => e
          Logging.logger[self].fatal { "Unable to connect to MongoDB at #{@ip}:#{@port}" }
        end
      end

      def save(event_name, event_value, player_spalla_id)
        bucket = get_bucket(player_spalla_id + "." + event_name)

        unless bucket.nil?
          data = {}
          data['value'] = event_value
          data['timestamp'] = Time.now.to_i

          bucket.insert(data)
        end
      end

      def load(bucket_name, key)
      end

      def get_bucket(bucket_name)
        @db.create_collection(bucket_name, { :capped => true, :size => 10 * 1024, :max => 10 } ) unless @db.nil
      end

      def clear(bucket_name)

      end
      
    end
  end
end
