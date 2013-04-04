require "noam_server/persistence/riak"

describe NoamServer::Persistence::Riak do
  
  let(:persistence) { NoamServer::Persistence::Riak.new }
  let(:test_data) { {'id' => '1', 'timestamp' => 'timestamp'} }
  
  after(:each) do
    persistence.clear('bucket')
  end
  
  it "saves data" do
    result = persistence.save('bucket', test_data)
    key = result.key
    
    persistence.load('bucket', key).should == test_data
  end
  
  it "loads all data in a bucket" do
    result = persistence.save('bucket', test_data)
    key = result.key
    
    persistence.load('bucket', key).should == test_data
  end
  
  it "clears data" do
    result = persistence.save('bucket', test_data)    
    key = result.key
    
    persistence.clear('bucket')
    persistence.load('bucket', key).should == []    
  end
    
end