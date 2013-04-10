require "noam_server/persistence/memory"

describe NoamServer::Persistence::Memory do

  let(:persistence) { NoamServer::Persistence::Memory.new }

  it "saves data" do
    key = persistence.save('bucket', 'a')
    persistence.load('bucket', key).should == 'a'
  end

  it "queries on an unknown bucket is empty" do
    persistence.load('unknown_bucket', 'key').should == []
  end

  it "clears a bucket" do
    key = persistence.save('bucket', 'a')
    persistence.clear('bucket')
    persistence.load('bucket', key).should == []
  end

  it "gets a bucket" do
    persistence.save('bucket', 'a')
    persistence.get_bucket('bucket').should == {'a' => 'a'}
  end

end
