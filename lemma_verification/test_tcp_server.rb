#Copyright (c) 2014, IDEO 

require 'noam/tcp_listener'
require 'test_tcp_message_handler'

module LemmaVerification
  module TestListener

    attr_accessor :listener

    def post_init
      port, ip = Socket.unpack_sockaddr_in(get_peername)
      handler = TestTcpMessageHandler.new(ip)
      @listener = Noam::TcpListener.new do |msg|
        parsed_message = Noam::Messages.parse(msg)
        handler.message_received(parsed_message, self)
      end
    end

    def receive_data(data)
      @listener.receive_data(data)
    end

  end

  class TestTcpServer

    def self.start(port)
      EventMachine::start_server('0.0.0.0', port, TestListener)
    end

  end
end
