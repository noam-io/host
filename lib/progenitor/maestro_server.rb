require 'progenitor/tcp_listener'
module Progenitor
  module Listener
    attr_accessor :listener
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
      EventMachine::start_server(@host, @port, Listener) do |connection|
        connection.listener = TcpListener.new do |msg|
          message = Messages.parse(msg)
        end
      end
    end
  end
end
