#Copyright (c) 2014, IDEO

require 'noam_server/reapable_repository'
require 'noam_server/located_servers'

describe NoamServer::LocatedServers do

	let(:callback) {lambda{}}

	let(:located_servers) { NoamServer::LocatedServers.instance }

	before(:each) do
		located_servers.clear
	end

	it "is a singleton" do
    x = NoamServer::LocatedServers.instance
    y = NoamServer::LocatedServers.instance
    x.should == y
    x.is_a?(NoamServer::ReapableRepository).should == true
	end

	it "checks last_modified to see if it is the same" do
		now = Time.now.getutc()
		servers = described_class.new
		servers.same?({:name => "doug"}, {:name => "doug"}).should be true
		servers.same?({:name => "doug", :last_modified => now}, {:name => "doug", :last_modified => now + 10}).should be false
	end

	it "should add 2 server2" do
		located_servers.add({:name => 'foobar', :last_modified => Time.now.getutc - 2})
		located_servers.add({:name => 'foobar1', :last_modified => Time.now.getutc})
		located_servers.get_all().length.should == 2
	end

	it "should not add a new element if it already exists (checks only by name)" do
		located_servers.add({:name => 'foobar', :last_modified => Time.now.getutc - 2})
		located_servers.add({:name => 'foobar', :last_modified => Time.now.getutc})
		located_servers.get_all().length.should == 1
	end

	it "should call callback when a new lemma is added on a paired server" do
		#last_modified will contained the time when the last lemma was added or removed from the server
		located_servers.add({:name => 'foobar', :last_activity_timestamp => Time.now.getutc - 10})
		located_servers.on_change &callback
		callback.should_receive(:call)
		located_servers.reap
	end

end

