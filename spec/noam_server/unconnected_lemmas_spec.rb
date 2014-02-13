require 'noam_server/unconnected_lemmas'

describe NoamServer::UnconnectedLemmas do
  before do
    @now = Time.now
  end

  after do
    NoamServer::UnconnectedLemmas.instance.clear
  end

  it "leaves unexpired lemmas alone" do
    entry = { :name => "lemma #1", :last_activity_timestamp => @now - 2 }
    NoamServer::UnconnectedLemmas.instance.add(entry)
    NoamServer::UnconnectedLemmas.reap
    NoamServer::UnconnectedLemmas.instance.get("lemma #1").should == entry
  end

  it "reaps stale lemmas" do
    entry = { :name => "lemma #1", :last_activity_timestamp => @now - 30 }
    NoamServer::UnconnectedLemmas.instance.add(entry)
    NoamServer::UnconnectedLemmas.reap
    NoamServer::UnconnectedLemmas.instance.get("lemma #1").should == nil
  end
end

