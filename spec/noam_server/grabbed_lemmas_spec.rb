require 'noam_server/grabbed_lemmas'

describe NoamServer::GrabbedLemmas do
  before do
    @now = Time.now
    @lemmas = NoamServer::GrabbedLemmas.instance
  end

  after do
    NoamServer::GrabbedLemmas.instance.clear
  end

  it "allows adding to the list & retrieving" do
    @lemmas.add({:name => "Lemma #1"})
    @lemmas.add({:name => "Lemma #2"})

    @lemmas.include?("Lemma #1").should == true
    @lemmas.include?("Lemma #2").should == true
  end

  it "allows releasing from the list" do
    @lemmas.add({:name => "Lemma #1"})
    @lemmas.add({:name => "Lemma #2"})

    @lemmas.delete("Lemma #1")

    @lemmas.include?("Lemma #1").should == false
    @lemmas.include?("Lemma #2").should == true
  end
end

