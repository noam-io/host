#Copyright (c) 2014, IDEO 

require "lemma_verification/spec_helper"
require "tests/plus_one"

require "mocks/lemma_verification_test_behavior"

describe LemmaVerification::Tests::PlusOne do

  it "implements the interface defined by Mocks::LemmaVerificationTest" do
    Mocks::LemmaVerificationTestBehavior.should be_substitutable_for(LemmaVerification::Tests::PlusOne)
  end

  describe "the original message" do
    it "sends a random number" do
      Random.stub(:rand).with(50).and_return(35)
      plus_one = LemmaVerification::Tests::PlusOne.new

      plus_one.original_message.should == 35
    end
  end

  describe "the expected value" do
    it "is the original message incremented" do
      Random.stub(:rand).with(50).and_return(35, 23)
      plus_one = LemmaVerification::Tests::PlusOne.new
      plus_one.original_message

      plus_one.expected_value.should == 36
    end
  end

end
