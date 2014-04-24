require "surrogate/rspec"

module Mocks
  class LemmaVerificationTestBehavior

    Surrogate.endow(self)

    define(:original_message)
    define(:expected_value)

  end
end
