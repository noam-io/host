module LemmaVerification
  class Test

    attr_reader :name, :actual_value

    def initialize(name, lemma_id, player_connection, test_behavior)
      self.name = name
      self.lemma_id = lemma_id
      self.player_connection = player_connection
      self.test_behavior = test_behavior
    end

    def start
      player_connection.send_event(lemma_id, name, test_behavior.original_message)
    end

    def complete?
      complete
    end

    def store_result(event_value)
      self.complete = true
      self.actual_value = event_value
    end

    def expected_value
      test_behavior.expected_value
    end

    private

    attr_writer :name, :actual_value
    attr_accessor :lemma_id, :player_connection, :complete, :test_behavior

  end
end
