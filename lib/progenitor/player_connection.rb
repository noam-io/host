require 'orchestra/messages'
require 'progenitor/ear'

module Progenitor
  module PlayerHandler
    attr_accessor :parent
    def unbind
      parent.disconnect
    end
  end

  class PlayerConnection
    def port
      @ear.port
    end

    def host
      @ear.host
    end

    def initialize(player)
      @ear = Progenitor::Ear.new(player.host, player.port)
      @backlog = []
    end

    def hear( id_of_player, event_name, event_value )
      if ( !@ear.send_message( id_of_player, event_name, event_value ) )
        @backlog << [id_of_player, event_name, event_value]
        @ear.new_connection { on_connection }
      end
    end

    def on_connection
      @backlog.each { |message| @ear.send_message(*message) }
      @backlog.clear
    end
  end
end
