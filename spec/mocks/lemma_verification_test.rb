require "surrogate/rspec"

module Mocks
  class LemmaVerificationTest

    Surrogate.endow(self)

    define(:name)
    define(:start)
    define(:store_result) {|event_value| }
    define(:complete?)
    define(:expected_value)
    define(:actual_value)

  end
end
