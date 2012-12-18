
require 'noam/messages'

module NoamServer
  class WebSocketEar
    def initialize(web_socket)
      @web_socket = web_socket
    end

    def hear(id_of_player, event_name, event_value )
      message = Noam::Messages.build_event( id_of_player, event_name, event_value )
      send_data(message)
    end

    def send_data(data)
      @web_socket.send("%06d" % data.bytesize)
      @web_socket.send(data)
    end

    def terminate
      @web_socket.close_websocket
    end

    def new_connection
    end
  end
end
