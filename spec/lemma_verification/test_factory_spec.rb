#Copyright (c) 2014, IDEO 

require "lemma_verification/spec_helper"
require "test_factory"

require "mocks/lemma_verification_test"
require "mocks/lemma_verification_test_behavior"

describe LemmaVerification::TestFactory do

  describe "building each type of test" do
    LemmaVerification::TestFactory::AVAILABLE_TESTS.each do |test_name, test_behavior_class|
      it "builds a #{test_name} test" do
        connection = "Player Connection"
        test_behavior = Mocks::LemmaVerificationTestBehavior.factory
        test_behavior_class.stub(:new).and_return(test_behavior)

        LemmaVerification::Test.should_receive(:new).
          with(test_name, "spalla_id", connection, test_behavior)

        LemmaVerification::TestFactory.build(test_name, "spalla_id", connection)
      end
    end
  end

  describe "a test with created with an unknown name" do
    it "implements the interface defined by Mocks::LemmaVerificationTest" do
      unknown_test = LemmaVerification::TestFactory.build("WAT", nil, nil)
      Mocks::LemmaVerificationTest.should be_substitutable_for(unknown_test.class)
    end

    it "is not complete" do
      unknown_test = LemmaVerification::TestFactory.build("WAT", nil, nil)
      unknown_test.should_not be_complete
    end
  end

end
