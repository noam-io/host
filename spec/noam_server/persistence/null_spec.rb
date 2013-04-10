require "noam_server/persistence/null"

describe NoamServer::Persistence::Null do

  let(:persistence) { NoamServer::Persistence::Memory.new }

  it "saves data to a black hole and doesn't fail" do
    persistence.save('bucket', 'object')
  end

  it "query result is empty" do
    persistence.load('bucket', 'key').should == []
  end

  it "clears a bucket without failing" do
    persistence.clear('bucket')
  end

  it "gets nil for bucket lookup" do
    persistence.get_bucket('bucket').should == nil
  end

end

