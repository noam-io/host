#Copyright (c) 2014, IDEO 

module LemmaVerification
  module Tests
    class PlusOne

      def original_message
        @original_message ||= Random.rand(50)
      end

      def expected_value
        original_message + 1
      end

    end
  end
end
