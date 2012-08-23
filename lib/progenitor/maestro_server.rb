module Progenitor
  module Listener
    def receive_data data
      send_data ">>> you sent: #{data}"
    end
  end

  class MaestroServer
    def start
      EventMachine::start_server(@host, @port, Listener)
    end
  end
end
