require "noam_server/persistence/factory"
require "noam_server/persistence/memory"
require "noam_server/persistence/mongodb"
require "noam_server/persistence/null"
require "noam_server/persistence/riak"

describe NoamServer::Persistence::Factory do
  before do
    # clearing out singletons
    NoamServer::Persistence::Base.reset
    NoamServer::Persistence::Memory.reset
    NoamServer::Persistence::MongoDB.reset
    NoamServer::Persistence::Null.reset
    NoamServer::Persistence::Riak.reset
  end

  it "picks mongo when given mongodb" do
    NoamServer::Persistence::MongoDB.should_receive(:new)

    persistor = NoamServer::Persistence::Factory.get({
      :persistor_class => :mongodb
    })
  end

  it "picks riak when given riak" do
    NoamServer::Persistence::Riak.should_receive(:new)

    persistor = NoamServer::Persistence::Factory.get({
      :persistor_class => :riak
    })
  end

  it "picks memory when given memory" do
    NoamServer::Persistence::Memory.should_receive(:new)

    persistor = NoamServer::Persistence::Factory.get({
      :persistor_class => :memory
    })
  end

  it "picks memory when mongo fails" do
    NoamServer::Persistence::MongoDB.stub(:new).and_raise(StandardError)
    memory = double("memory persistor")
    NoamServer::Persistence::Memory.should_receive(:new).and_return(memory)

    persistor = NoamServer::Persistence::Factory.get({
      :persistor_class => :mongodb
    })

    persistor.should == memory
  end

  it "uses the base one when unconfigured" do
    persistor = NoamServer::Persistence::Factory.get({})
    persistor.class.should == NoamServer::Persistence::Null
  end
end
