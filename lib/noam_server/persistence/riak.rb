require 'riak'
require "riak/robject"
require "riak/failed_request"

require 'noam_server/config'

module NoamServer
  module Persistence
    class Riak
      
      def initialize
        @client = ::Riak::Client.new(CONFIG[:riak])
      end
      
      def save(event_name, event_value, player)
        bucket = get_bucket(event_name)
        object = ::Riak::RObject.new(bucket)
        
        data = {}
        data['user_id'] = event_value
        data['group_id'] = player.spalla_id
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
