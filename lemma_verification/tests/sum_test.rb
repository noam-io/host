module LemmaVerification
  module Tests
    class SumTest

      def initialize(spalla_id, player_connection)
        self.spalla_id = spalla_id
        self.player_connection = player_connection
      end

      def name
        "Sum"
      end

      def start
        self.original_value = []
        4.times do
          original_value << Random.rand(10)
        end
        player_connection.send_event(spalla_id, name, original_value)
      end

      def store_result(event_value)
        self.complete = true
        self.result = event_value
      end

      def complete?
        complete
      end

      def expected_value
        original_value.reduce(:+)
      end

      def actual_value
        result
      end

      private

      attr_accessor :spalla_id, :player_connection, :result, :original_value, :complete

    end
  end
end
