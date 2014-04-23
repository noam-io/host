require "lemma_verification/spec_helper"
require "tests/name"

require "json"

require "mocks/lemma_verification_test_behavior"

describe LemmaVerification::Tests::Name do

  before(:each) do
    @name_test_behavior = LemmaVerification::Tests::Name.new
  end

  it "implements the interface defined by Mocks::LemmaVerificationTest" do
    Mocks::LemmaVerificationTestBehavior.should be_substitutable_for(LemmaVerification::Tests::Name)
  end

  describe "the original message" do
    it "has a first name" do
      @name_test_behavior.original_message.fetch("firstName").should_not be_nil
    end

    it "has a last name" do
      @name_test_behavior.original_message.fetch("lastName").should_not be_nil
    end
  end

  describe "the expected value" do
    it "expected the first name and last name joined with a space" do
      first_name = @name_test_behavior.original_message["firstName"]
      last_name = @name_test_behavior.original_message["lastName"]

      parsed_expected_value = JSON.parse(@name_test_behavior.expected_value)
      parsed_expected_value.should == {
        "fullName" => "#{first_name} #{last_name}"
      }
    end
  end

end
