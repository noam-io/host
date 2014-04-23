module LemmaVerification
  module Tests
    class Name

      def original_message
        @original_message ||= {
          "firstName" => random_first_name,
          "lastName"  => random_last_name
        }
      end

      def expected_value
        {
          "fullName" => full_name
        }.to_json
      end

      private

      def full_name
        "#{original_message["firstName"]} #{original_message["lastName"]}"
      end

      def random_first_name
        ["Bob", "Sally", "Michael", "Emma", "William", "Elizabeth"].sample
      end

      def random_last_name
        ["Smith", "Johnson", "Williams", "Jones", "Brown", "Davis"].sample
      end

    end
  end
end
