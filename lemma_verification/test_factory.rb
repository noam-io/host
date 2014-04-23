require "noam_server/noam_logging"
require "test"
require "tests/echo"
require "tests/sum"
require "tests/plus_one"
require "tests/name"

module LemmaVerification
  class TestFactory

    AVAILABLE_TESTS = {
      "Echo" => Tests::Echo,
      "Sum" => Tests::Sum,
      "PlusOne" => Tests::PlusOne,
      "Name" => Tests::Name
    }

    class NullTest
      def name;end
      def start;end
      def store_result(event_value);end
      def complete?;false;end
      def expected_value;end
      def actual_value;end
    end

    def self.build(test_name, spalla_id, connection)
      if AVAILABLE_TESTS.has_key?(test_name)
        Test.new(test_name, spalla_id, connection, AVAILABLE_TESTS[test_name].new)
      else
        NoamServer::NoamLogging.warn("TestFactory", "#{spalla_id} asked for unkown test name: #{test_name}")
        NullTest.new
      end
    end

  end
end
