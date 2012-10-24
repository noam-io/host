require 'progenitor/messages'

module Progenitor
  module PlayerHandler
    attr_accessor :parent
    def unbind
      parent.disconnect
    end
  end

  class PlayerConnection
    attr_accessor :host, :port

    def initialize(host, port)
      @host = host
      @port = port
      @backlog = []
    end

    def hear( id_of_player, event_name, event_value )
      message = Messages.build_event( id_of_player, event_name, event_value )
      send_message(message)
    end

    def new_connection
      EventMachine::connect(@host, @port, PlayerHandler) do |connection|
        @connection = connection
        @connection.parent = self
        @backlog.each { |message| send_data(message) }
        @backlog.clear
      end
    end

    def disconnect
      terminate
      @connection = nil
    end

    def terminate
      @connection.close_connection_after_writing if @connection
    end

    def send_message(message)
      if @connection
        send_data(message)
      else
        @backlog << message
        new_connection if @backlog.size == 1
      end
    end

    def send_data(data)
      @connection.send_data("%06d" % data.bytesize)
      @connection.send_data(data)
    end

  end
end
