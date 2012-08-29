require 'progenitor/messages'

module Progenitor
  module PlayerHandler
    attr_accessor :parent
    def unbind
      parent.disconnect
    end
  end

  class Player
    attr_accessor :spalla_id, :remote_client_ip, :remote_port

    def initialize(id,  host, port)
      @spalla_id = id
      @host = host
      @port = port
    end

    def hear(event_name, event_value)
      message = Messages.build_event(@spalla_id, event_name, event_value)
      send_message(message)
    end

    def new_connection(message)
      EventMachine::connect(@host, @port, PlayerHandler) do |connection|
        @connection = connection
        @connection.parent = self
        @connection.send_data(message)
      end
    end

    def disconnect
      @connection = nil
    end

    def send_message(message)
      if @connection
        @connection.send_data(message)
      else
        new_connection(message)
      end
    end

  end
end
