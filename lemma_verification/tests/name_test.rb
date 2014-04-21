module LemmaVerification
  module Tests
    class NameTest

      def initialize(spalla_id, player_connection)
        self.spalla_id = spalla_id
        self.player_connection = player_connection
      end

      def name
        "Name"
      end

      def start
        self.original_first_name = random_first_name
        self.original_last_name = random_last_name
        player_connection.send_event(spalla_id, name, {"firstName" => original_first_name,
                                                       "lastName"  => original_last_name})
      end

      def store_result(event_value)
        self.complete = true
        self.result = event_value
      end

      def complete?
        complete
      end

      def expected_value
        {"fullName" => "#{original_first_name} #{original_last_name}"}.to_json
      end

      def actual_value
        result
      end

      private

      def random_first_name
        ["Bob", "Sally", "Michael", "Emma", "William", "Elizabeth"].sample
      end

      def random_last_name
        ["Smith", "Johnson", "Williams", "Jones", "Brown", "Davis"].sample
      end

      attr_accessor :spalla_id, :player_connection, :result, :original_first_name, :original_last_name, :complete

    end
  end
end
