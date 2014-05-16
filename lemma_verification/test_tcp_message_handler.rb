#Copyright (c) 2014, IDEO 

require "noam_server/ear"
require "noam_server/noam_logging"
require "noam_server/attenuated_player_connection"
require "noam_server/player_connection"

module LemmaVerification
  class TestTcpMessageHandler

    def initialize(ip)
      self.ip = ip
    end

    def message_received(message, incoming_tcp_connection)
      if message.is_a?(Noam::Messages::RegisterMessage)
        register_test_participant(message, incoming_tcp_connection)
      elsif message.is_a?(Noam::Messages::EventMessage)
        if message.event_name.end_with?("Verify")
          test_name = message.event_name.sub(/Verify$/, "")
          run_test(test_name, message)
        end
      end
    end

    private

    def register_test_participant(message, incoming_tcp_connection)
      port = message.callback_port
      ear = NoamServer::Ear.new(ip, port, incoming_tcp_connection)
      player_connection = if message.device_type == "arduino"
        NoamServer::AttenuatedPlayerConnection.new(ear, 0.1)
      else
        NoamServer::PlayerConnection.new(ear)
      end
      TestAudience.instance.register_connection(message.spalla_id, player_connection)
      TestAudience.instance.tests_for_viewer(message.spalla_id, message.hears)
    end

    def run_test(test_name, message)
      test = TestAudience.instance.get_test(
        message.spalla_id,
        test_name
      )
      test.store_result(message.event_value)
      if test.expected_value == test.actual_value
        NoamServer::NoamLogging.info("TestTcpMessageHandler", "Finished #{test.name} for #{message.spalla_id}: PASS")
      else
        NoamServer::NoamLogging.warn("TestTcpMessageHandler", "Finished #{test.name} for #{message.spalla_id}: FAIL")
        NoamServer::NoamLogging.warn("TestTcpMessageHandler", "  Expected: #{test.expected_value}")
        NoamServer::NoamLogging.warn("TestTcpMessageHandler", "  Actual:   #{test.actual_value}")
      end
    end

    attr_accessor :ip

  end
end
