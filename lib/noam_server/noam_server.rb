require 'noam/tcp_listener'
require 'noam_server/listener'
require 'noam_server/message_handler'
require 'noam_server/noam_logging'

module NoamServer
  class NoamServer

    @@name = self.to_s.split("::").last

    def initialize(port)
      @port = port
      @host = "0.0.0.0"
    end

    def start
      NoamLogging.info(@@name, "Starting Noam Server at #{@host}:#{@port}")
      begin
        EventMachine::start_server(@host, @port, Listener)
      rescue Errno::EADDRINUSE
        NoamLogging.fatal(@@name, "Unable to start Noam Server - Server port already in use.")
        raise
      end
    end
  end
end
