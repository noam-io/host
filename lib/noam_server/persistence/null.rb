#Copyright (c) 2014, IDEO 

require 'noam_server/persistence/base'

module NoamServer
  module Persistence
    class Null < Base
      def initialize(config)
        @connected = true
      end
    end
  end
end

