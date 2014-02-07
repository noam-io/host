require 'em/pure_ruby'
require 'noam/messages'
require 'noam_server/noam_logging'
require 'singleton'
require 'socket'

module EventMachine
  class EvmaUDPSocket
    # We need to override this because the pure_ruby version returns a nil
    # peername by default - which makes sense since UDP is connectionless.
    # Calling this is really only meaningful in the context of #receive_data,
    # but EM's structure doesn't give us an easy way to scope it to that.
    def get_peername
      @return_address
    end
  end
end

module NoamServer
  class ServerLocator

    class UDPHandler < EM::Connection
      def get_response_port(data)
        data.split("@").last.to_i
      end

      def receive_data(data)
        peername = get_peername
        if peername
          port, ip = Socket.unpack_sockaddr_in(peername)
          response_port = get_response_port(data)
          server_id = "#{ip}:#{port}"
          ServerRepository.instance.add_server(server_id, {
            :ip => ip,
            :port => port,
            :data => data
          })
        else
          NoamLogging.info(self, "Got UDP data: #{data.inspect} - no idea who sent it")
        end
      end
    end

    class ServerRepository
      include Singleton

      def initialize
        @servers = {}
      end

      def add_server(id, data)
        @servers[id] = data.merge(:last_timestamp => Time.now.to_i)
        NoamLogging.info(self, "Upserted server id: #{id.inspect}")
        NoamLogging.info(self, "ServerRepository: #{@servers.inspect}")
      end
    end

    def initialize(port)
      @port = port
    end

    def start
      NoamLogging.info(self, "Listening for other servers on port #{@port}")
      begin
        EM.open_datagram_socket('0.0.0.0', @port, UDPHandler)
      rescue => e
        NoamLogging.fatal(self, "Failed to listen for other servers: #{e}")
      end
    end
  end
end
