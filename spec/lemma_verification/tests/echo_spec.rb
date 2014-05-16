#Copyright (c) 2014, IDEO 

require "lemma_verification/spec_helper"
require "tests/echo"

require "mocks/lemma_verification_test_behavior"

describe LemmaVerification::Tests::Echo do

  before(:each) do
    now = Time.now
    Time.stub(:now).and_return(now)
    @formatted_time = now.strftime("%F %T")
  end

  it "implements the interface defined by Mocks::LemmaVerificationTest" do
    Mocks::LemmaVerificationTestBehavior.should be_substitutable_for(LemmaVerification::Tests::Echo)
  end

  it "dynamically generates a message to send" do
    LemmaVerification::Tests::Echo.new.original_message.should == @formatted_time
  end

  it "expects the original message to be returned" do
    echo = LemmaVerification::Tests::Echo.new
    echo.original_message
    echo.expected_value.should == @formatted_time
  end

end
