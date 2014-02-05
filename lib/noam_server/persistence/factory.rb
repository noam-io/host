require 'noam_server/persistence/mongodb'
require 'noam_server/persistence/memory'
require 'noam_server/persistence/riak'

module NoamServer
	module Persistence
    	class Factory

    		def self.get(config)
				case config[:persistor_class]
				when :mongodb
					@type = MongoDB
				when :memory
					@type = Memory
				when :riak
					@type = Riak
				else
					@type = :nil
				end
				@type.instance(config[config[:persistor_class]])
    		end

	    end
	end
end


