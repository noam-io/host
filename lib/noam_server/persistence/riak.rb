require 'riak'
require "riak/robject"
require "riak/failed_request"

module NoamServer
  module Persistence
    class Riak
      
      def initialize
        @client = ::Riak::Client.new
      end
      
      def save(bucket_name, data)
        bucket = get_bucket(bucket_name)
        object = ::Riak::RObject.new(bucket)        

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
