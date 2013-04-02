require 'riak'
require "riak/robject"
require "riak/failed_request"

RIAK = Riak::Client

module NoamServer
  module Persistence
    class Riak
      
      def initialize
        @client = RIAK.new
      end
      
      def save(bucket_name, user_id, value)
        bucket = get_bucket(bucket_name)
        
        object = bucket.get_or_new(user_id)
        if !bucket.exists?(user_id)
          object.data = []
        end
          
        object.data << value
        object.store
      end

      def load(bucket, user_id)
        @client[bucket][user_id].data
      rescue ::Riak::HTTPFailedRequest
        []
      end
      
      def get_bucket(bucket)
        return @client.bucket(bucket)
      end
      
      def clear(bucket_name)
        bucket = get_bucket(bucket_name)
        bucket.keys.each {|k| bucket[k].delete }        
      end
      
    end
  end
end
