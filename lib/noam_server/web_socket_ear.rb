
require 'noam/messages'

module NoamServer
  class WebSocketEar
    def initialize(web_socket)
      @web_socket = web_socket
      @terminated = false
    end

    def send_data(data)
      if active?
        @web_socket.send("%06d" % data.bytesize)
        @web_socket.send(data)
      end
    end

    def active?
      not @terminated
    end

    def terminate
      if active?
        @terminated = true
        @web_socket.close_websocket
      end
    end

    def new_connection
    end
  end
end
