#Copyright (c) 2014, IDEO

require 'noam_server/reapable_repository'
require 'noam_server/located_servers'

describe NoamServer::LocatedServers do
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
end

