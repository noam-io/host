require 'web/spec_helper'
require 'json'

describe NoamApp do
  describe "POST /settings" do
    it "sets the name of the app" do
      post '/settings', {:name => 'foobar'}, {"HTTP_ACCEPT" => "application/json"}
      last_response.should be_ok
      resp = JSON.parse(last_response.body)
      resp['name'].should == 'foobar'
    end

    it "toggles the on value" do
      post '/settings', {:on => true}, {"HTTP_ACCEPT" => "application/json"}
      last_response.should be_ok
      resp = JSON.parse(last_response.body)
      resp['on'].should be_true

      post '/settings', {:on => false}, {"HTTP_ACCEPT" => "application/json"}
      last_response.should be_ok
      resp = JSON.parse(last_response.body)
      resp['on'].should be_false
    end
  end
end
