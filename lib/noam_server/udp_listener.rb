require 'noam/messages'
require 'noam_server/noam_logging'
require 'noam_server/grabbed_lemmas'
require 'noam_server/unconnected_lemmas'
require 'socket'

module NoamServer
  module UdpHandler
    attr_accessor :polo, :room_name

    def receive_data(message)
      message = Noam::Messages.parse(message)
      if message.message_type == "marco"
        peername = get_peername
        port, ip = Socket.unpack_sockaddr_in(peername)
        if message.room_name == @room_name
          NoamLogging.debug(self, "Sending polo #{@polo.inspect} to #{ip}:#{port}")
          send_data(@polo)
        else
          remember_unconnected_lemma(ip, port, message)
          if grabbable_lemma?(message)
            NoamLogging.debug(self, "Sending polo #{@polo.inspect} to grabbed lemma: #{ip}:#{port}")
            send_data(@polo)
          end
        end
      else
        NoamLogging.info(self, "UDP handler dropped message because it was not a 'marco' message #{message.inspect}")
      end
    end

    def remember_unconnected_lemma(ip, port, message)
      UnconnectedLemmas.instance.add({
        :name => message.spalla_id,
        :desired_room_name => message.room_name,
        :device_type => message.device_type,
        :system_version => message.system_version,
        :ip => ip,
        :port => port,
        :last_activity_timestamp => Time.now.getutc
      })
    end

    def grabbable_lemma?(message)
      message.room_name.to_s == "" && GrabbedLemmas.instance.include?(message.spalla_id)
    end
  end

  class UdpListener
    def start(udp_listen_port, tcp_listen_port, room_name)
      NoamLogging.info(self, "Listening for lemmas; room name: #{room_name.inspect}")
      polo_message = Noam::Messages.build_polo(room_name, tcp_listen_port)
      EM.open_datagram_socket('0.0.0.0', udp_listen_port, UdpHandler) do |handler|
        handler.polo = polo_message
        handler.room_name = room_name
      end
    end
  end
end
