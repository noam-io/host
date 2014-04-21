require "noam_server/ear"
require "noam_server/noam_logging"
require "noam_server/attenuated_player_connection"
require "noam_server/player_connection"

module LemmaVerification
  class TestMessageHandler

    def initialize(ip)
      self.ip = ip
    end

    def message_received(message, incoming_tcp_connection)
      if message.is_a?(Noam::Messages::RegisterMessage)
        register_test_participant(message, incoming_tcp_connection)
      else
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
        AttenuatedPlayerConnection.new(ear, 0.1)
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
        NoamServer::NoamLogging.info("TestMessageHandler", "Finished #{test.name} for #{message.spalla_id}: PASS")
      else
        NoamServer::NoamLogging.warn("TestMessageHandler", "Finished #{test.name} for #{message.spalla_id}: FAIL")
        NoamServer::NoamLogging.warn("TestMessageHandler", "  Expected: #{test.expected_value}")
        NoamServer::NoamLogging.warn("TestMessageHandler", "  Actual:   #{test.actual_value}")
      end
    end

    attr_accessor :ip

  end
end
