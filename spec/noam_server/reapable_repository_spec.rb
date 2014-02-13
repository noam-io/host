require 'noam_server/reapable_repository'

describe NoamServer::ReapableRepository do
  before do
    @now = Time.now
    @repository = NoamServer::ReapableRepository.new
  end

  it "leaves unexpired elements alone" do
    entry = { :name => "element #1", :last_activity_timestamp => @now - 2 }
    @repository.add(entry)
    @repository.reap
    @repository.get("element #1").should == entry
  end

  it "reaps stale elements" do
    entry = { :name => "element #1", :last_activity_timestamp => @now - 30 }
    @repository.add(entry)
    @repository.reap
    @repository.get("element #1").should == nil
  end
end

