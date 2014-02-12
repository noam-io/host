require 'noam_server/unconnected_lemmas'

describe NoamServer::UnconnectedLemmas do
  before do
    @now = Time.now
  end

  after do
    NoamServer::UnconnectedLemmas.instance.clear
  end

  it "leaves unexpired lemmas alone" do
    seconds_ago = 2
    entry = { :last_activity_timestamp => @now - 2 }
    NoamServer::UnconnectedLemmas.instance["lemma #1"] = entry
    NoamServer::UnconnectedLemmas.reap
    NoamServer::UnconnectedLemmas.instance["lemma #1"].should == entry
  end

  it "reaps stale lemmas" do
    seconds_ago = 30
    entry = { :last_activity_timestamp => @now - 30 }
    NoamServer::UnconnectedLemmas.instance["lemma #1"] = entry
    NoamServer::UnconnectedLemmas.reap
    NoamServer::UnconnectedLemmas.instance.has_key?("lemma #1").should == false
  end
end

