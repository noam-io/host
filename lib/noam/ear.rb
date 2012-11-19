require 'orchestra/messages'

module Progenitor
  module EarHandler
    attr_accessor :parent
    def unbind
      parent.disconnect
    end
  end

  class Ear
    attr_accessor :host, :port

    def initialize(host, port)
      @conection_pending = false
      @host = host
      @port = port
    end


    def hear(id_of_player, event_name, event_value )
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
      unless @connection_pending
        @connection_pending = true
        EventMachine::connect(@host, @port, EarHandler) do |connection|
          @connection = connection
          @connection.parent = self
          yield(@connection) if block_given?
          @connection_pending = false
        end
      end
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
