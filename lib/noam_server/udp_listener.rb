require 'noam/messages'
require 'noam_server/noam_logging'
require 'socket'
module NoamServer
  module UdpHandler
    attr_accessor :polo, :room_name

    def receive_data(message)
      message = Noam::Messages.parse(message)
      if message.message_type == "marco"
        if message.room_name == @room_name
          peername = get_peername
          port, ip = Socket.unpack_sockaddr_in(peername)
          NoamLogging.info(self, "Sending polo #{@polo.inspect} to #{ip}:#{port}")
          send_data(@polo)
        else
          NoamLogging.info(self, "UDP handler for room #{@room_name} not responding because of room name mismatch: #{message.room_name}")
        end
      else
        NoamLogging.info(self, "UDP handler dropped message because it was not a 'marco' message #{message.inspect}")
      end
    end

  end

  class UdpListener
    def start(udp_listen_port, tcp_listen_port, room_name)
      polo_message = Messages.build_polo(room_name, udp_listen_port)
      EM.open_datagram_socket('0.0.0.0', udp_listen_port, UdpHandler) do |handler|
        handler.polo = polo_message
        handler.room_name = room_name
      end
    end
  end
end
