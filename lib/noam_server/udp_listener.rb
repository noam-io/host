require 'noam/messages'
require 'noam_server/noam_logging'
require 'noam_server/grabbed_lemmas'
require 'noam_server/located_servers'
require 'noam_server/unconnected_lemmas'
require 'socket'

module NoamServer
  module UdpHandler
    attr_accessor :polo, :room_name

    def receive_data(message)
      # If the server is off, ignore marco-polo
      if not NoamServer.on?
        NoamLogging.debug(self, "Ignoring message - server off.")
        return
      end
      
      message = Noam::Messages.parse(message)
      if message.message_type == "marco"
        port, ip = get_port_and_ip
        if message.room_name == NoamServer.room_name and NoamServer.room_name != ""
          NoamLogging.debug(self, "Sending polo #{@polo.inspect} to #{ip}:#{port}")
          remember_connected_lemma(ip, port, message)
          send_data(UdpListener.makeMarco(ip, port))
        else
          remember_unconnected_lemma(ip, port, message)
          if grabbable_lemma?(message)
            NoamLogging.debug(self, "Sending polo #{@polo.inspect} to grabbed lemma: #{ip}:#{port}")
            send_data(UdpListener.makeMarco(ip, port))
          end
        end
      elsif message.message_type == "server_beacon"
        port, ip = get_port_and_ip
        remember_server(ip, port, message)
      else
        NoamLogging.info(self, "UDP handler dropped message because it was not a 'marco' message #{message.inspect}")
      end
    end

    def get_port_and_ip
      peername = get_peername
      Socket.unpack_sockaddr_in(peername)
    end

    def remember_connected_lemma(ip, port, message)
      GrabbedLemmas.instance.add({
        :name => message.spalla_id,
        :desired_room_name => message.room_name,
        :device_type => message.device_type,
        :system_version => message.system_version,
        :ip => ip,
        :port => port,
        :last_activity_timestamp => Time.now.getutc
      })
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

    def remember_server(ip, port, message)
      LocatedServers.instance.add({
        :name => message.room_name,
        :http_port => message.http_port,
        :ip => ip,
        :beacon_port => port,
        :last_activity_timestamp => Time.now.getutc
      })
    end

    def grabbable_lemma?(message)
      message.room_name.to_s == "" && GrabbedLemmas.instance.include?(message.spalla_id)
    end
  end

  class UdpListener
    def start(udp_listen_port, tcp_listen_port, room_name)
      @@_room_name = room_name
      @@_tcp_listen_port = tcp_listen_port
      NoamLogging.info(self, "Listening for lemmas; room name: #{room_name.inspect}")
      EM.open_datagram_socket('0.0.0.0', udp_listen_port, UdpHandler) do |handler|
      end
    end

    def self.makeMarco(ip, port)
      Noam::Messages.build_polo(NoamServer.name, @@_tcp_listen_port)
    end

    def self.sendMaro(ip, port)
      polo_message = makeMarco(ip, port)
      socket = UDPSocket.new
      socket.bind("0.0.0.0", @@_tcp_listen_port)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      socket.connect(ip, port)
      socket.send(polo_message, 0)
      socket.close()
    end
  end
end
