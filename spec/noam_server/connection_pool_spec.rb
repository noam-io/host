#Copyright (c) 2014, IDEO 

require 'noam_server/connection_pool'
require 'mocks/reactor'

describe NoamServer::ConnectionPool do

  describe "#include?" do
    before(:each) do
      @connection = double("Connection", :signature => 1337)
      @reactor = Mocks::Reactor.new
      EventMachine::Reactor.stub(:instance).and_return(@reactor)
    end

    it "is false if the reactor does not know about the connection" do
      NoamServer::ConnectionPool.should_not include(@connection)
    end

    it "is true if the reactor is keeping track of the connection" do
      @reactor.connect_to(@connection)
      NoamServer::ConnectionPool.should include(@connection)
    end

    it "is false with no connection" do
      NoamServer::ConnectionPool.should_not include(nil)
    end
  end

end
