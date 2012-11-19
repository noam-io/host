require 'noam_server/attenuated_player_connection'
require 'eventmachine'

describe NoamServer::AttenuatedPlayerConnection do
  class AttenMockEar
    attr_accessor :times_heard, :value, :callback, :hear_returns, :id
    def initialize
      @times_heard = 0
      @hear_returns = [true, true, true]
    end

    def hear( id, name, value)
      @times_heard += 1
      @value = value
      @id = id
      @hear_returns.shift
    end

    def new_connection( &callback )
      @callback = callback
    end
  end

  let( :sender ){AttenMockEar.new}
  let( :attenuate ){ 0.01 }
  let( :player ){ described_class.new( sender, attenuate )}
  let( :now ){ Time.now }


  it 'does not attenuate first message' do
    player.hear( "id", "name", "value", now )
    sender.times_heard.should == 1
  end

  it 'sends second message if attenuate-time elapsed' do
    player.hear( "id", "name", "value", now )
    player.hear( "id", "name", "value", now + attenuate )
    sender.times_heard.should == 2
  end

  def wait_for(calls, timeout = attenuate*4)
    EM::tick_loop do
      if Time.now > (now + timeout) || sender.times_heard >= calls
        EM::stop
        :stop
      end
    end
  end

  it "should time out and send the attenuated message" do
    EM::run do
      player.hear( "id", "name", "value", now )
      sender.times_heard.should == 1
      player.hear( "id", "name", "value", now )
      sender.times_heard.should == 1
      wait_for(2)
    end
    sender.times_heard.should == 2
  end

  it "should drop a message and send the latest value" do
    EM::run do
      player.hear( "id", "name", "1", now )
      player.hear( "id", "name", "2", now )
      player.hear( "id", "name", "3", now )
      wait_for(2)
    end
    sender.times_heard.should == 2
    sender.value.should == "3"
  end

  it "should attenuate per event name" do
    sender.should_receive( :hear ).once.with( "id", "name", "value" ).and_return(true)
    sender.should_receive( :hear ).once.with( "id", "name2", "value2" ).and_return(true)
    player.hear( "id", "name", "value", now )
    player.hear( "id", "name2", "value2", now )
  end

  it "should reset the time sent when the timer expires" do
    EM::run do
      player.hear( "id", "name", "value", now )
      sender.times_heard.should == 1
      player.hear( "id", "name", "value", now )
      sender.times_heard.should == 1
      wait_for(2)
    end

    EM::run do
      player.hear( "id", "name", "value", now + 4*attenuate/3 )
      EM::stop
    end

    sender.times_heard.should == 2
  end

  it "should handle hear failures" do
    sender.hear_returns = [false]
    sender.should_receive(:new_connection)
    player.hear( "id", "name", "value", now )
  end

  it "should send out the last value when a connection is made" do
    sender.hear_returns = [false, true, true]

    player.hear( "id", "name", "value", now )
    player.hear( "id2", "name", "value2", now )
    sender.callback.call
    sender.value.should == "value2"
    sender.id.should == "id2"
  end

  it "should handle failure on timeout sends" do
    sender.hear_returns = [true, false, true]
    EM::run do
      player.hear( "id", "name", "value", now )
      player.hear( "id2", "name", "value2", now )
      wait_for(2)
    end
    sender.callback.call

    sender.value.should == "value2"
    sender.id.should == "id2"
    sender.times_heard.should == 3
  end

  it "terminates" do
    sender.should_receive(:terminate).once
    player.terminate
  end
end
