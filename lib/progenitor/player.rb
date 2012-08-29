require 'progenitor/messages'

module Progenitor
  module PlayerHandler
    attr_accessor :parent
    def unbind
      parent.disconnect
    end
  end

  class Player
    attr_accessor :spalla_id, :host, :port

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
        send_data(message)
      end
    end

    def disconnect
      @connection = nil
    end

    def terminate
      @connection.close_connection_after_writing
    end

    def send_message(message)
      #TODO:   multiple sends before a connect
      if @connection
        send_data(message)
      else
        new_connection(message)
      end
    end

    def send_data(data)
      @connection.send_data("%06d" % data.length)
      @connection.send_data(data)
    end

  end
end
