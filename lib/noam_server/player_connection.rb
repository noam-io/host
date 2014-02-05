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
      if ( !@ear.hear( id_of_player, event_name, event_value ) )
        @backlog << [id_of_player, event_name, event_value]
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
