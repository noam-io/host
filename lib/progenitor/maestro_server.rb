require 'progenitor/tcp_listener'
require 'progenitor/message_handler'
module Progenitor
  module Listener
    attr_accessor :listener
    def post_init
       @port, @ip = Socket.unpack_sockaddr_in(get_peername)
       handler = MessageHandler.new(@ip)
        @listener = TcpListener.new do |msg|
          handler.message_received(Messages.parse(msg))
        end
    end

    def receive_data data
      listener.receive_data(data)
    end
  end

  class MaestroServer
    def initialize(port)
      @port = port
      @host = "0.0.0.0"
    end

    def start
      EventMachine::start_server(@host, @port, Listener)
    end
  end
end
