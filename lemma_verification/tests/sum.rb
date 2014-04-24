module LemmaVerification
  module Tests
    class Sum

      def original_message
        self.original_value = []
        4.times do
          original_value << Random.rand(10)
        end
        original_value
      end

      def expected_value
        original_value.reduce(:+)
      end

      private

      attr_accessor :original_value

    end
  end
end
