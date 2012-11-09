require 'progenitor/attenuated_player_connection'
require 'eventmachine'

describe Progenitor::AttenuatedPlayerConnection do
  class MockSender
    attr_accessor :times_heard, :value
    def initialize
      @times_heard = 0
    end

    def hear( id, name, value)
      @times_heard += 1
      @value = value
    end
  end

  let( :sender ){MockSender.new}
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
    sender.should_receive( :hear ).once.with( "id", "name", "value" )
    sender.should_receive( :hear ).once.with( "id", "name2", "value2" )
    player.hear( "id", "name", "value", now )
    player.hear( "id", "name2", "value2", now )
  end

  it "should set the wait time base on the time remaining" do
    EM::run do
      player.hear( "id", "name", "value", now )
      player.hear( "id", "name", "value", now + (1023*attenuate/1024) )
      sender.times_heard.should == 1
      wait_for(2, 2*attenuate/256)
    end
    sender.times_heard.should == 2
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
      player.hear( "id", "name", "value", now + 16*attenuate/12 )
      EM::stop
    end

    sender.times_heard.should == 2
  end

end
