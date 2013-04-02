require "noam_server/persistence/riak"


describe NoamServer::Persistence::Riak do
  
  let(:persistence) { NoamServer::Persistence::Riak.new }
  
  before(:each) do
    persistence.clear('bucket'  )
  end
  
  it "saves data" do
    persistence.save('bucket', '1', 'timestamp')
    persistence.load('bucket', '1').should == ['timestamp']
  end
  
  it "saves mulitiple datas" do
    persistence.save('bucket', '1', 'timestamp')
    persistence.save('bucket', '1', 'timestamp2')
    persistence.load('bucket', '1').should == ['timestamp', 'timestamp2']
  end
  
  it "loads all data in a bucket data" do
    persistence.save('bucket', '1', 'timestamp')
    persistence.load('bucket', '1').should == ['timestamp']
  end
  
  it "clears data" do
    persistence.save('bucket', '1', 'timestamp')
    persistence.clear('bucket')
    persistence.load('bucket', '1').should == []    
  end
    
end