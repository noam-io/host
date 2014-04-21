require "noam_server/noam_logging"
require "tests/echo_test"
require "tests/sum_test"
require "tests/plus_one_test"
require "tests/name_test"

module LemmaVerification
  class TestFactory

    class NullTest
      def name;end
      def start;end
      def store_result(event_value);end
      def complete?;false;end
      def expected_value;end
      def actual_value;end
    end

    def self.build(test_name, spalla_id, connection)
      case test_name
      when "Echo"
        Tests::EchoTest.new(spalla_id, connection)
      when "Sum"
        Tests::SumTest.new(spalla_id, connection)
      when "PlusOne"
        Tests::PlusOneTest.new(spalla_id, connection)
      when "Name"
        Tests::NameTest.new(spalla_id, connection)
      else
        NoamServer::NoamLogging.warn("TestFactory", "#{spalla_id} asked for unkown test name: #{test_name}")
        NullTest.new
      end
    end

  end
end
