require "lemma_verification/spec_helper"
require "test"

require "mocks/lemma_verification_test"
require "mocks/lemma_verification_test_behavior"

describe LemmaVerification::Test do

  describe "an echo test" do
    before(:each) do
      @test_behavior = Mocks::LemmaVerificationTestBehavior.factory({
        :original_message => "the original message",
        :expected_value => "the expected response"
      })
      @connection = double("Player Connection")
      @verification_test = LemmaVerification::Test.new("Sample", "spalla_id", @connection, @test_behavior)
    end

    it "implements the interface defined by Mocks::LemmaVerificationTest" do
      Mocks::LemmaVerificationTest.should be_substitutable_for(@verification_test.class)
    end

    it "has a name" do
      @verification_test.name.should == "Sample"
    end

    it "gets the expected response from the test behavior" do
      @connection.stub(:send_event)

      @verification_test.start

      @verification_test.expected_value.should == "the expected response"
    end

    describe "starting the test" do
      it "sends a message to the lemma" do
        @connection.should_receive(:send_event).
                    with("spalla_id", "Sample", "the original message")

        @verification_test.start
      end
    end

    describe "storing results" do
      it "is false before the results are returned" do
        @verification_test.should_not be_complete
      end

      it "is complete when the results are returned" do
        @verification_test.store_result("some results")
        @verification_test.should be_complete
      end

      it "stores the results" do
        @verification_test.store_result("some results")
        @verification_test.actual_value.should == "some results"
      end
    end
  end


end