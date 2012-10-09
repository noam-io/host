require 'progenitor/tcp_listener'
require 'progenitor/message_handler'
module Progenitor
  module Listener
    attr_accessor :listener, :spalla_id

    def post_init
       @port, @ip = Socket.unpack_sockaddr_in(get_peername)
       handler = MessageHandler.new(@ip)
       @listener = TcpListener.new do |msg|
         begin
           parsed_message = Messages.parse(msg)
           @spalla_id = parsed_message.spalla_id
           handler.message_received(parsed_message)
         rescue JSON::ParserError
           puts "invalid message received:  #{msg}"
         end
       end
    end

    def unbind
      Orchestra.instance.fire_player( @spalla_id )
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
