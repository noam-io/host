require 'orchestra/messages'

module Progenitor
  module PlayerHandler
    attr_accessor :parent
    def unbind
      parent.disconnect
    end
  end

  class PlayerConnection
    attr_accessor :host, :port

    def initialize(player)
      @host = player.host
      @port = player.port
      @backlog = []
      @conection_pending = false
    end

    def hear( id_of_player, event_name, event_value )
      if ( !send_message( id_of_player, event_name, event_value ) )
        @backlog << [id_of_player, event_name, event_value]
        new_connection unless @connection_pending
      end
    end

    def send_message(id_of_player, event_name, event_value )
      message = ::Orchestra::Messages.build_event( id_of_player, event_name, event_value )
      if @connection
        send_data(message)
        return true
      else
        return false
      end
    end

    def send_data(data)
      @connection.send_data("%06d" % data.bytesize)
      @connection.send_data(data)
    end

    def new_connection
      @connection_pending = true
      EventMachine::connect(@host, @port, PlayerHandler) do |connection|
        @connection = connection
        @connection.parent = self
        on_connection
        @connection_pending = false
      end
    end

    def on_connection
      @backlog.each { |message| send_message(*message) }
      @backlog.clear
    end

    def disconnect
      terminate
      @connection = nil
      @connection_pending = false
    end

    def terminate
      @connection.close_connection_after_writing if @connection
    end

  end
end
