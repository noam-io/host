#Copyright (c) 2014, IDEO 

require 'noam_server/persistence/base'
require 'mongo'

module NoamServer
  module Persistence
    class MongoDB < Base

      attr_accessor :ip, :port, :db

      def initialize(config)
        @connected = false
        @ip = config[:ip] || 'localhost'
        @port = config[:port] || 27017
        @db = config[:db] || 'noam-server-data'
        NoamLogging.info(self, "Using MongoDB database '#{@db}' as Persistent Store")
        NoamLogging.info(self,  "config: #{config.inspect}")
        NoamLogging.info(self, "Server at #{@ip}:#{@port}")
        connect
      end

      def connect
        begin
          @client = ::Mongo::MongoClient.new(@ip, @port)
          @db = @client.db(@db)
          @connected = true
          NoamLogging.info(self, "Connected to MongoDB database '#{@db}' at #{@ip}:#{@port}")
        rescue Exception => e
          NoamLogging.error(self, "Unable to connect to MongoDB at #{@ip}:#{@port}")
          raise
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
        @db.create_collection(bucket_name, { :capped => true, :size => 10 * 1024, :max => 10 } ) unless @db.nil?
      end

      def clear(bucket_name)

      end

    end
  end
end
