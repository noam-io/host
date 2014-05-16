#Copyright (c) 2014, IDEO 

require 'em-websocket'
require 'noam/tcp_listener'
require 'test_websocket_message_handler'

module LemmaVerification
  class TestWebsocketServer

    def self.start(port)
      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => port) do |web_socket|
        handler = TestWebsocketMessageHandler.new(web_socket)
        listener = Noam::TcpListener.new do |message|
          parsed_message = Noam::Messages.parse(message)
          handler.message_received(parsed_message)
        end
        web_socket.onmessage do |message|
          listener.receive_data(message)
        end
      end
    end

  end
end
