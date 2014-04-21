module LemmaVerification
  module Tests
    class EchoTest

      def initialize(spalla_id, player_connection)
        self.spalla_id = spalla_id
        self.player_connection = player_connection
      end

      def name
        "Echo"
      end

      def start
        self.original_message = Time.now.strftime("%F %T")
        player_connection.send_event(spalla_id, name, original_message)
      end

      def store_result(event_value)
        self.complete = true
        self.result = event_value
      end

      def complete?
        complete
      end

      def expected_value
        original_message
      end

      def actual_value
        result
      end

      private

      attr_accessor :spalla_id, :player_connection, :result, :original_message, :complete

    end
  end
end
