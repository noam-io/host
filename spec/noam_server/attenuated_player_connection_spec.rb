require 'noam_server/attenuated_player_connection'
require 'em/pure_ruby'

describe NoamServer::AttenuatedPlayerConnection do
  class AttenMockEar
    attr_accessor :times_heard, :message, :callback, :hear_returns, :id
    def initialize
      @times_heard = 0
      @hear_returns = [true, true, true]
    end

    def send_data( message )
      @times_heard += 1
      @message = message
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
    player.send_event( "id", "name", "value", now )
    sender.times_heard.should == 1
  end

  it 'sends second message if attenuate-time elapsed' do
    player.send_event( "id", "name", "value", now )
    player.send_event( "id", "name", "value", now + attenuate )
    sender.times_heard.should == 2
  end

  it 'should be able to send a heartbeat ack' do
    player.send_heartbeat_ack( "id", now )
    sender.times_heard.should == 1
    msg = Noam::Messages.build_heartbeat_ack( "id" )
    sender.message.should == msg
  end

  def wait_for(calls, timeout = attenuate*4)
    EM::tick_loop do
      if Time.now > (now + timeout) || sender.times_heard >= calls
        EM::stop
        :stop
      end
    end
  end

  it "should be able to send heartbeat acks while attenuating other messages" do
    EM::run do
      player.send_event( "id", "name", "value", now )
      sender.times_heard.should == 1
      player.send_event( "id", "name", "value", now )
      sender.times_heard.should == 1
      player.send_heartbeat_ack( "id", now )
      sender.times_heard.should == 2
      player.send_event( "id", "name", "value", now )
      sender.times_heard.should == 2
      wait_for(3)
    end
    sender.times_heard.should == 3
  end

  it "should time out and send the attenuated message" do
    EM::run do
      player.send_event( "id", "name", "value", now )
      sender.times_heard.should == 1
      player.send_event( "id", "name", "value", now )
      sender.times_heard.should == 1
      wait_for(2)
    end
    sender.times_heard.should == 2
  end

  it "should drop a message and send the latest value" do
    EM::run do
      player.send_event( "id", "name", "1", now )
      player.send_event( "id", "name", "2", now )
      player.send_event( "id", "name", "3", now )
      wait_for(2)
    end
    sender.times_heard.should == 2
    msg = Noam::Messages.build_event( "id", "name", "3" )
    sender.message.should == msg
  end

  it "should attenuate per event name" do
    sender.should_receive( :send_data ).once.with(
      Noam::Messages.build_event( "id", "name", "value" )
    ).and_return(true)
    sender.should_receive( :send_data ).once.with(
      Noam::Messages.build_event( "id", "name2", "value2" )
    ).and_return(true)
    player.send_event( "id", "name", "value", now )
    player.send_event( "id", "name2", "value2", now )
  end

  it "should reset the time sent when the timer expires" do
    EM::run do
      player.send_event( "id", "name", "value", now )
      sender.times_heard.should == 1
      player.send_event( "id", "name", "value", now )
      sender.times_heard.should == 1
      wait_for(2)
    end

    EM::run do
      player.send_event( "id", "name", "value", now + 4*attenuate/3 )
      EM::stop
    end

    sender.times_heard.should == 2
  end

  it "should handle hear failures" do
    sender.hear_returns = [false]
    sender.should_receive(:new_connection)
    player.send_event( "id", "name", "value", now )
  end

  it "should send out the last value when a connection is made" do
    sender.hear_returns = [false, true, true]

    player.send_event( "id", "name", "value", now )
    player.send_event( "id2", "name", "value2", now )
    sender.callback.call
    msg = Noam::Messages.build_event( "id2", "name", "value2" )
    sender.message.should == msg
  end

  it "should handle failure on timeout sends" do
    sender.hear_returns = [true, false, true]
    EM::run do
      player.send_event( "id", "name", "value", now )
      player.send_event( "id2", "name", "value2", now )
      wait_for(2)
    end
    sender.callback.call

    msg = Noam::Messages.build_event( "id2", "name", "value2" )
    sender.message.should == msg
    sender.times_heard.should == 3
  end

  it "terminates" do
    sender.should_receive(:terminate).once
    player.terminate
  end
end
