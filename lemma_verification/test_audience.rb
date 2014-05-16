#Copyright (c) 2014, IDEO 

require "test_factory"

module LemmaVerification
  class TestAudience

    def self.instance
      @instance ||= new
    end

    def initialize
      @viewer = {}
    end

    def new_viewer(lemma_id)
      @viewer[lemma_id] = {}
    end

    def tests_for_viewer(lemma_id, test_names)
      @viewer[lemma_id][:tests] = test_names.each.with_object({}) do |test_name, tests|
        tests[test_name] = TestFactory.build(test_name, lemma_id, @viewer[lemma_id][:connection])
      end
      @viewer[lemma_id][:tests].values.each(&:start)
    end

    def get_test(lemma_id, test_name)
      @viewer[lemma_id][:tests][test_name]
    end

    def register_connection(lemma_id, connection)
      @viewer[lemma_id][:connection] = connection
    end

    def complete?(lemma_id)
      tests(lemma_id).all?(&:complete?)
    end

    def failing_tests(lemma_id)
      tests(lemma_id).select do |test|
        test.complete? &&
        (test.expected_value != test.actual_value)
      end
    end

    def to_hash
      @viewer.each.with_object({}) do |(lemma_id, lemma_data), hashified|
        hashified[lemma_id] = lemma_data[:tests].values.collect do |test|
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

    def tests(lemma_id)
      @viewer[lemma_id][:tests].values
    end

  end
end
