#Copyright (c) 2014, IDEO 

require 'noam_server/reapable_repository'
require 'noam_server/unconnected_lemmas'

describe NoamServer::UnconnectedLemmas do
  it "is a singleton" do
    x = NoamServer::UnconnectedLemmas.instance
    y = NoamServer::UnconnectedLemmas.instance
    x.should == y
    x.is_a?(NoamServer::ReapableRepository).should == true
  end
end

