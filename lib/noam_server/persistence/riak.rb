require "riak"
require "riak/robject"
require "riak/failed_request"

require 'noam_server/persistence/base'

module NoamServer
  module Persistence
    class Riak < Base

      def initialize(config)
        @client = ::Riak::Client.new(config)
        if @client.ping
          @connected = true
          NoamLogging.info(self, "Using Riak as Persistent Store")
          NoamLogging.info(self, "Settings: #{config}")
        else
          @connected = false
          NoamLogging.info(self, "Uable to connect to Riak Server")
          NoamLogging.info(self, "Riak Settings: #{config}")
        end
      end

      def save(event_name, event_value, player_spalla_id)
        bucket = get_bucket(event_name)
        object = ::Riak::RObject.new(bucket)
        #object = bucket.new('testKey')

        data = {}
        data['user_id'] = event_value
        data['group_id'] = player_spalla_id
        data['timestamp'] = Time.now.to_i

        object.data = data
        object.content_type = "application/json"

        object.store
      end

      def load(bucket_name, key)
        @client[bucket_name][key].data
      rescue ::Riak::HTTPFailedRequest
        []
      end

      def get_bucket(bucket_name)
        return @client.bucket(bucket_name)
      end

      def clear(bucket_name)
        bucket = get_bucket(bucket_name)

        bucket.keys.each do |key|
          bucket[key].delete if bucket.exists?(key)
        end
      end
      
    end
  end
end
