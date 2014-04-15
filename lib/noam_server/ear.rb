require 'noam/messages'
require 'noam_server/connection_pool'

module NoamServer
  module EarHandler
    attr_accessor :parent
    def unbind
      parent.terminate
    end
  end

  class Ear

    attr_accessor :host, :port

    def initialize(host, port)
      self.host = host
      self.port = port
      new_connection
    end

    def send_data(data)
      if active?
        connection.send_data("%06d" % data.bytesize)
        connection.send_data(data)
        return true
      else
        return false
      end
    end

    def new_connection
      EventMachine::connect(host, port, EarHandler) do |connection|
        self.connection = connection
        connection.parent = self
        yield(connection) if block_given?
      end
    end

    def active?
      ConnectionPool.include?(connection)
    end

    def terminate
      connection.close_connection_after_writing if connection
      self.connection = nil
    end

    private

    attr_accessor :connection

  end
end
