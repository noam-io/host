require "lemma_verification/spec_helper"
require "tests/sum"

require "mocks/lemma_verification_test_behavior"

describe LemmaVerification::Tests::Sum do

  it "implements the interface defined by Mocks::LemmaVerificationTestBehavior" do
    Mocks::LemmaVerificationTestBehavior.should be_substitutable_for(LemmaVerification::Tests::Sum)
  end

  describe "the original message" do
    it "is an array of 4 random numbers" do
      Random.stub(:rand).with(10).and_return(3, 2, 7, 8)
      sum = LemmaVerification::Tests::Sum.new
      sum.original_message.should == [3, 2, 7, 8]
    end

    it "expects the sum to be returned" do
      Random.stub(:rand).with(10).and_return(3, 2, 7, 8)
      sum = LemmaVerification::Tests::Sum.new
      sum.original_message
      sum.expected_value.should == 20
    end
  end

end
