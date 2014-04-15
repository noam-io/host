require 'noam/messages'
require 'noam_server/connection_pool'

module NoamServer
  class WebSocketEar

    def initialize(web_socket)
      self.web_socket = web_socket
    end

    def send_data(data)
      if active?
        web_socket.send("%06d" % data.bytesize)
        web_socket.send(data)
      end
    end

    def active?
      ConnectionPool.include?(web_socket)
    end

    def terminate
      web_socket.close_websocket if active?
    end

    def new_connection
    end

    private

    attr_accessor :web_socket

  end
end
