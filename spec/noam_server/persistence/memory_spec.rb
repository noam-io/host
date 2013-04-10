require "noam_server/persistence/memory"

describe NoamServer::Persistence::Memory do

  let(:persistence) { NoamServer::Persistence::Memory.new }

  it "saves data" do
    key = persistence.save('bucket', 'user_id', 'group_id')
    persistence.load('bucket', key).should == ['user_id', 'group_id']
  end

  it "queries on an unknown bucket is empty" do
    persistence.load('unknown_bucket', 'key').should == []
  end

  it "clears a bucket" do
    key = persistence.save('bucket', 'user_id', 'group_id')
    persistence.clear('bucket')
    persistence.load('bucket', key).should == []
  end

  it "gets a bucket" do
    persistence.save('bucket', 'user_id', 'group_id')
    persistence.get_bucket('bucket').should == {'user_id' => ['user_id', 'group_id']}
  end

end
