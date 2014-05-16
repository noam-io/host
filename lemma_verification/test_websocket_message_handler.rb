#Copyright (c) 2014, IDEO 

require 'noam/messages'
require 'noam_server/web_socket_ear'
require 'noam_server/player_connection'

module LemmaVerification
  class TestWebsocketMessageHandler

    def initialize(web_socket)
      self.web_socket = web_socket
    end

    def message_received(message)
      if message.is_a?(Noam::Messages::RegisterMessage)
        register_test_participant(message)
      else
        if message.event_name.end_with?("Verify")
          test_name = message.event_name.sub(/Verify$/, "")
          run_test(test_name, message)
        end
      end
    end

    private

    def register_test_participant(message)
      ear = NoamServer::WebSocketEar.new(web_socket)
      player_connection = NoamServer::PlayerConnection.new(ear)
      TestAudience.instance.new_viewer(message.spalla_id)
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
        NoamServer::NoamLogging.info("TestWebsocketMessageHandler", "Finished #{test.name} for #{message.spalla_id}: PASS")
      else
        NoamServer::NoamLogging.warn("TestWebsocketMessageHandler", "Finished #{test.name} for #{message.spalla_id}: FAIL")
        NoamServer::NoamLogging.warn("TestWebsocketMessageHandler", "  Expected: #{test.expected_value}")
        NoamServer::NoamLogging.warn("TestWebsocketMessageHandler", "  Actual:   #{test.actual_value}")
      end
    end

    attr_accessor :web_socket

  end
end
