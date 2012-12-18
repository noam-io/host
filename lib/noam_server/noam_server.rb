require 'noam/tcp_listener'
require 'noam_server/message_handler'
require 'noam_server/listener'

module NoamServer
  class NoamServer
    def initialize(port)
      @port = port
      @host = "0.0.0.0"
    end

    def start
      EventMachine::start_server(@host, @port, Listener)
    end
  end
end
