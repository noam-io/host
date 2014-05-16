#Copyright (c) 2014, IDEO 

require 'em/pure_ruby'
require 'noam/tcp_listener'
require 'noam_server/config_manager'
require 'noam_server/grabbed_lemmas'
require 'noam_server/listener'
require 'noam_server/orchestra'
require 'noam_server/message_handler'
require 'noam_server/noam_logging'

module NoamServer
  class NoamServer
    @@on = false
    @@_room_name = nil

    def initialize(port)
      @port = port
      @host = "0.0.0.0"
    end

    def start
      NoamLogging.info(self, "Starting Noam Server at #{@host}:#{@port}")
      begin
        EventMachine::start_server(@host, @port, Listener)
        @@on = (@@_room_name != "")
      rescue Errno::EADDRINUSE
        NoamLogging.fatal(self, "Unable to start Noam Server - Server port already in use.")
        raise
      end
    end

    def self.room_name
      @@_room_name
    end

    # Rename the server
    #  This clears some internal state
    def self.room_name=set_room_name
      @@_room_name = set_room_name
      ConfigManager[:room_name] = @@_room_name
      Orchestra.instance.clear
      GrabbedLemmas.instance.clear
    end

    def self.on?
      @@on
    end

    def self.on=ison
      @@on = ison
    end
  end
end
