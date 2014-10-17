#Copyright (c) 2014, IDEO

require 'noam/tcp_listener'
require 'noam_server/message_handler'
require 'noam_server/noam_logging'

module NoamServer
  module Listener
    attr_accessor :listener, :spalla_id

    def post_init
      port, @ip = Socket.unpack_sockaddr_in(get_peername)
      handler = MessageHandler.new(@ip)
      @listener = Noam::TcpListener.new do |msg|
        begin
          parsed_message = Noam::Messages.parse(msg)
          @spalla_id = parsed_message.spalla_id
          handler.message_received(parsed_message, self)
          if !Orchestra.instance.get_player(@spalla_id).in_right_room?
            close_connection_after_writing
          end
        rescue JSON::ParserError
          NoamLogging.error(self, "Invalid message received:  #{msg}")
        rescue => error
          stack_trace = error.backtrace.join("\n  == ")
          NoamLogging.warn(self, "Error: #{error.to_s}\n Stack Trace:\n == #{stack_trace}")
        end
      end
    end

    def unbind
      Orchestra.instance.fire_player(@spalla_id)
    end

    def receive_data data
      if NoamServer.on?
        listener.receive_data(data)
      end
    end
  end
end
