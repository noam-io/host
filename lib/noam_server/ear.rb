#Copyright (c) 2014, IDEO 

require 'em/pure_ruby'
require 'noam/messages'

module NoamServer
  module EarHandler
    attr_accessor :callback_delegate
    def unbind
      callback_delegate.terminate
    end
  end

  class Ear

    attr_accessor :host, :port, :incoming_connection

    def initialize(host, port, incoming_connection)
      self.host = host
      self.port = port
      self.incoming_connection = incoming_connection
      make_new_outgoing_connection
    end

    def send_data(data)
      if outgoing_connection
        send_formatted_data(data)
      elsif connection_pending
        # drop data
      else
        make_new_outgoing_connection(data)
      end
    end

    def terminate
      safely_close(incoming_connection)
      safely_close(outgoing_connection)
      self.incoming_connection = nil
      self.outgoing_connection = nil
    end

    private

    attr_accessor :data_to_send, :connection_pending, :outgoing_connection

    def make_new_outgoing_connection(data = nil)
      self.connection_pending = true
      EventMachine::connect(host, port, EarHandler) do |connection|
        self.outgoing_connection = connection
        outgoing_connection.callback_delegate = self
        self.connection_pending = false
        send_formatted_data(data) if data
      end
    end

    def send_formatted_data(data)
      outgoing_connection.send_data("%06d%s" % [data.bytesize, data])
    end

    def safely_close(connection)
      connection.close_connection_after_writing if connection
    rescue RuntimeError => e
      stack_trace = e.backtrace.join("\n  == ")
      NoamLogging.warn(self, "Error: #{e.to_s}\n Stack Trace:\n == #{stack_trace}")
    end

  end
end
