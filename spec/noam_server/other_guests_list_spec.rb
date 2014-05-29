require 'spec_helper'
require 'noam_server/other_guests_list'

describe NoamServer::OtherGuestsList do
  let(:server_repo) { double(:servers, :on_change => nil) }
  it "registers a callback on servers list" do
    server_repo.should_receive(:on_change)
    described_class.new(server_repo)
  end

  it "adds guests from a server response" do
    list = described_class.new(server_repo)
    list.response_handler( {"name" => "server1"}, { "guests-owned" =>
                          {"ArduinoCertificationSuite"=>{"name"=>"ArduinoCertificationSuite", "device_type"=>"arduino", "last_activity"=>"2014-05-20T14:15:18:635-0500", "system_version"=>"0.3", "hears"=>["Echo", "PlusOne"], "plays"=>[], "ip"=>"10.0.1.127", "desired_room_name"=>"lemma_verification"}}})
    list.get_all.size.should == 1
  end

  it "add guests from multiple servers" do
    list = described_class.new(server_repo)
    list.response_handler( {:name => "server1"}, { "guests-owned" => {"Lemma1"=>{"name"=>"Lemma1"}}})
    list.response_handler( {:name => "server2"}, { "guests-owned" => {"Lemma2"=>{"name"=>"Lemma2"}}})
    list.get_all.size.should == 2
  end

  it "adds handler a change to the servers" do
    server_repo.stub(:on_change)
    EventMachine::Protocols::HttpClient.stub(:request).and_return(double(:http, :callback => nil))
    list = described_class.new(server_repo)
    server_repo.should_receive(:get_all).at_least(1).and_return({"server1" => {}, "server2" => {}})
    list.servers_changed
  end

  it "drops a lemma that is no longer on a list" do
    list = described_class.new(server_repo)
    list.response_handler( {"name" => "server1"}, { "guests-owned" => {"Lemma1"=>{"name"=>"Lemma1"}}})
    list.get_all.size.should == 1
    list.response_handler( {"name" => "server1"}, { "guests-owned" => {"Lemma4"=>{"name"=>"Lemma4"}}})
    list.get_all.should_not have_key("Lemma1")
    list.get_all.size.should == 1
  end

  it "drops a server's lemmas when the server no longer exists" do
    list = described_class.new(server_repo)
    list.response_handler( {:name => "server1"}, { "guests-owned" => {"Lemma1"=>{"name"=>"Lemma1"}}})
    list.response_handler( {:name => "server2"}, { "guests-owned" => {"Lemma4"=>{"name"=>"Lemma4"}}})

    server_repo.stub(:on_change)
    EventMachine::Protocols::HttpClient.stub(:request).and_return(double(:http, :callback => nil))
    server_repo.stub(:get_all).and_return({"server2" => {}})
    list.servers_changed

    list.get_all.size.should == 1
    list.get_all.should_not have_key("Lemma1")
    list.get_all.should have_key("Lemma4")
  end
end
