require "noam_server/persistence/riak"

describe NoamServer::Persistence::Riak, :integration => true do
  
  let(:persistence) { NoamServer::Persistence::Riak.new }
  let(:bucket) {'in' }
  let(:user_id) { '2' }
  let(:group_id) { '1' }
  
  before(:each) do
    CONFIG[:riak] = {:host => 'localhost'}
  end
  
  after(:each) do
    persistence.clear('bucket')
  end
  
  it "saves data" do
    result = persistence.save(bucket, user_id, group_id)
    key = result.key
    
    data = persistence.load(bucket, key)
    data['user_id'].should == '2'
    data['group_id'].should == '1'
    data['timestamp'].should_not be(nil) 
  end
  
  it "clears data" do
    result = persistence.save(bucket, user_id, group_id)    
    key = result.key
    
    persistence.clear('bucket')
    persistence.load('bucket', key).should == []    
  end
    
end