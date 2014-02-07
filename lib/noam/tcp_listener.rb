require 'noam_server/noam_logging'

module Noam
  class TcpListener
    attr_accessor :message_length, :message_payload

    def initialize(&callback)
      @length_string = ""
      @message_payload = ""
      @on_message_received = callback
    end

    def receive_data(data)
      enum = data.each_byte
      while true
        read_length(enum) if self.message_length.nil?
        read_payload(enum) unless self.message_length.nil?
      end
    rescue StopIteration
    end

    def read_length(enum)
      while @length_string.size != 6
        @length_string << enum.next
      end
      length_complete
    end

    def length_complete
      self.message_length = @length_string.to_i
      self.message_payload = ""
    end

    def read_payload(enum)
      while self.message_payload.size < self.message_length
        self.message_payload << enum.next
      end
      message_complete
    end

    def message_complete
      self.message_length = nil
      @length_string = ""
      @on_message_received.call(message_payload) if @on_message_received
    end

  end
end
