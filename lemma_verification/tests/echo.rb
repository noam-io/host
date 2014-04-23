module LemmaVerification
  module Tests
    class Echo

      def original_message
        @original_message ||= Time.now.strftime("%F %T")
      end

      def expected_value
        original_message
      end

    end
  end
end
