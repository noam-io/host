#Copyright (c) 2014, IDEO

require 'noam_server/reapable_repository'

describe NoamServer::ReapableRepository do
  before do
    @now = Time.now
    Time.stub(:now).and_return(@now)
    @repository = NoamServer::ReapableRepository.new
  end

  it "updates last-modified" do
    entry = { :name => "element #1", :last_activity_timestamp => @now - 30 }
    @repository.add(entry)
    @repository.last_modified.should == @now
  end

  it "fires callbacks on add" do
    calls = 0
    @repository.on_change { calls += 1 }
    entry = { :name => "element #1", :last_activity_timestamp => @now - 30 }
    @repository.add(entry)

    calls.should == 1
  end

  it "doesn't fire callback when the entry is already there" do
    entry = { :name => "element #1", :last_activity_timestamp => @now - 30 }
    @repository.add(entry)

    calls = 0
    @repository.on_change { calls += 1 }

    @repository.add(entry)
    calls.should == 0
  end

  it "runs callbacks on delete" do
    entry = { :name => "element #1", :last_activity_timestamp => @now - 30 }
    @repository.add(entry)

    calls = 0
    @repository.on_change { calls += 1 }

    @repository.delete("element #1")

    calls.should == 1
  end

  it "doesn't run callbacks when delete doesn't do anything" do
    calls = 0
    @repository.on_change { calls += 1 }

    @repository.delete("element #1")

    calls.should == 0
  end

  it "runs callbacks on clear" do
    calls = 0
    @repository.on_change { calls += 1 }

    @repository.clear

    calls.should == 1
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

  it "runs callbacks if anything gets reaped" do
    entry = { :name => "element #1", :last_activity_timestamp => @now - 30 }
    @repository.add(entry)

    calls = 0
    @repository.on_change { calls += 1 }

    @repository.reap

    calls.should == 1
  end

  it "doesn't run callbacks when nothing gets reaped" do
    entry = { :name => "element #1", :last_activity_timestamp => @now - 5 }
    @repository.add(entry)

    calls = 0
    @repository.on_change { calls += 1 }

    @repository.reap

    calls.should == 0
  end

end

