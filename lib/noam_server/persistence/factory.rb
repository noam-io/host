require 'noam_server/noam_logging'

module NoamServer
  module Persistence
    class Factory

      def self.get(config)
        case config[:persistor_class]
        when :mongodb
          require 'noam_server/persistence/mongodb'
          @type = MongoDB
        when :memory
          require 'noam_server/persistence/memory'
          @type = Memory
        when :riak
          require 'noam_server/persistence/riak'
          @type = Riak
        else
          require 'noam_server/persistence/null'
          @type = Null
        end
        return @type.instance(config[config[:persistor_class]])
      rescue Exception => e
        NoamLogging.error("Persistence::Factory", "Unable to instantiate persistence for #{config[:persistor_class]}: #{e}")
        require 'noam_server/persistence/memory'
        return Memory.instance({})
      end
    end
  end
end


