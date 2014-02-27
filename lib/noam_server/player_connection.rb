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

    def hear( id_of_player, event_name, event_value )
      if ( !@ear.hear( id_of_player, event_name, event_value ) and @ear.active?)
        # TODO : We no longer want to buffer values
        # Instead we will only send the last value
        # This is neccessary because the first message sent wont have a connection.
        # Later, on reconnection it will get the last event if anything was sent
        # while it was disconnected
        @backlog = [[id_of_player, event_name, event_value]]
        @ear.new_connection do
          NoamLogging.debug(self, "Player reconnected for lemma '#{id_of_player}' sending '#{event_name}' = #{event_value}")
          on_connection
        end
      end
    end

    def on_connection
      @backlog.each { |message| @ear.hear( *message )}
      @backlog.clear
    end

    def terminate
      @ear.terminate
    end
  end
end
