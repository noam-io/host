require "test_factory"

module LemmaVerification
  class TestAudience

    def self.instance
      @instance ||= new
    end

    def initialize
      @viewer = {}
    end

    def new_viewer(spalla_id)
      @viewer[spalla_id] = {}
    end

    def tests_for_viewer(spalla_id, test_names)
      @viewer[spalla_id][:tests] = test_names.each.with_object({}) do |test_name, tests|
        tests[test_name] = TestFactory.build(test_name, spalla_id, @viewer[spalla_id][:connection])
      end
      @viewer[spalla_id][:tests].values.each(&:start)
    end

    def get_test(spalla_id, test_name)
      @viewer[spalla_id][:tests][test_name]
    end

    def register_connection(spalla_id, connection)
      @viewer[spalla_id][:connection] = connection
    end

    def complete?(spalla_id)
      tests(spalla_id).all?(&:complete?)
    end

    def failing_tests(spalla_id)
      tests(spalla_id).select do |test|
        test.complete? &&
        (test.expected_value != test.actual_value)
      end
    end

    def to_hash
      @viewer.each.with_object({}) do |(spalla_id, lemma_data), hashified|
        hashified[spalla_id] = lemma_data[:tests].values.collect do |test|
          pass = test.expected_value == test.actual_value
          result = {
            :name => test.name,
            :pass => pass
          }
          if !pass
            result[:expected] = test.expected_value
            result[:actual] = test.actual_value
          end
          result
        end
      end
    end

    private

    def tests(spalla_id)
      @viewer[spalla_id][:tests].values
    end

  end
end
