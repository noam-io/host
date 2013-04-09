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
      
      def save(bucket_name, data)        
        bucket = get_bucket(bucket_name)
        object = ::Riak::RObject.new(bucket)
        
        parsed_data = parse(data)
        timestamped_data = set_timestamp(parsed_data)
        
        object.data = timestamped_data
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
      
      private
      
      def parse(data)
        begin
          JSON.parse(data)
        rescue
          data
        end
      end
      
      def set_timestamp(data)
        if data.is_a?(Hash)
          data["timestamp"] = Time.now
          data
        else
          data
        end
      end
      
    end
  end
end
