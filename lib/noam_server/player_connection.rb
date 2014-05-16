#Copyright (c) 2014, IDEO 

require 'noam_server/noam_logging'

module NoamServer
  class PlayerConnection

    attr_reader :ear

    def initialize( ear )
      self.ear = ear
    end

    def port
      ear.port
    end

    def host
      ear.host
    end

    def send_message(id_of_player, message)
      ear.send_data(message)
    end

    def send_event( id_of_player, event_name, event_value )
      message = Noam::Messages.build_event( id_of_player, event_name, event_value )
      send_message(id_of_player, message)
    end

    def send_heartbeat_ack( id_of_player )
      message = Noam::Messages.build_heartbeat_ack( id_of_player )
      send_message(id_of_player, message)
    end

    def terminate
      @ear.terminate
    end

    private

    attr_writer :ear

  end
end
