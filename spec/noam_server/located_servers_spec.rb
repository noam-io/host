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
end

