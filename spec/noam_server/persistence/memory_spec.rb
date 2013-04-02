require "noam_server/persistence/memory"


describe NoamServer::Persistence::Memory do
  
  let(:persistence) { NoamServer::Persistence::Memory.new }
  
  it "saves data" do
    persistence.save('bucket', 'a')
    persistence.load('bucket').should == ['a']
  end
  
  it "queries on an unknown bucket is empty" do
    persistence.load('unknown_bucket').should == []
  end
  
  it "clears a bucket" do
    persistence.save('bucket', 'a')
    persistence.clear('bucket')
    persistence.load('bucket').should == []
  end
  
end