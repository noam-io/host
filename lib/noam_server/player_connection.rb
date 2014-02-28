require 'noam_server/noam_logging'

module NoamServer
  class PlayerConnection
    attr_reader :ear

    def port
      @ear.port
    end

    def host
      @ear.host
    end

    def initialize( ear )
      @ear = ear
      @backlog = []
    end

    def send_message(id_of_player, msg)
      if ( !@ear.send_data(msg) and @ear.active?)
        # TODO : We no longer want to buffer values
        # Instead we will only send the last value
        # This is neccessary because the first message sent wont have a connection.
        # Later, on reconnection it will get the last event if anything was sent
        # while it was disconnected
        @backlog = [msg]
        @ear.new_connection do
          NoamLogging.debug(self, "Player '#{id_of_player}' reconnected sending '#{msg}'")
          on_connection
        end
      end
    end

    def send_event( id_of_player, event_name, event_value )
      msg = Noam::Messages.build_event( id_of_player, event_name, event_value )
      send_message(id_of_player, msg)
    end

    def send_heartbeat_ack( id_of_player )
      msg = Noam::Messages.build_heartbeat_ack( id_of_player )
      send_message(id_of_player, msg)
    end

    def on_connection
      @backlog.each { |message| @ear.send_data( *message )}
      @backlog.clear
    end

    def terminate
      @ear.terminate
    end
  end
end
