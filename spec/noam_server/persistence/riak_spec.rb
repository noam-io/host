require "noam_server/persistence/riak"

describe NoamServer::Persistence::Riak, :integration => true do
  
  let(:persistence) { NoamServer::Persistence::Riak.new }
  let(:test_data) { '{"user_id": "1", "group_id": "3"}' }
  
  after(:each) do
    persistence.clear('bucket')
  end
  
  it "saves data" do
    result = persistence.save('bucket', test_data)
    key = result.key
    
    data = persistence.load('bucket', key)
    data['user_id'].should == '1'
    data['group_id'].should == '3'
    data['timestamp'].should_not be(nil) 
  end
  
  it "clears data" do
    result = persistence.save('bucket', test_data)    
    key = result.key
    
    persistence.clear('bucket')
    persistence.load('bucket', key).should == []    
  end
    
end