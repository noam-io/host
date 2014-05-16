#Copyright (c) 2014, IDEO 

require 'em/pure_ruby'
require 'noam/messages'
require 'test_audience'

module LemmaVerification
  module TestUdpHandler
    attr_accessor :room_name, :tcp_listen_port

    def receive_data(message)
      message = Noam::Messages.parse(message)
      if message.message_type == "marco" && message.room_name == room_name
        TestAudience.instance.new_viewer(message.spalla_id)
        polo_message = Noam::Messages.build_polo(room_name, tcp_listen_port)
        send_data(polo_message)
      end
    end

  end

  class TestUdpReceiver

    def self.start(udp_listen_port, room_name, tcp_listen_port)
      EM.open_datagram_socket('0.0.0.0', udp_listen_port, TestUdpHandler) do |handler|
        handler.room_name = room_name
        handler.tcp_listen_port = tcp_listen_port
      end
    end

  end
end
