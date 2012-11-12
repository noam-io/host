require 'progenitor/player_connection'

describe Progenitor::PlayerConnection do
  class MockEar
    attr_accessor :hear_returns, :callback

    def initialize
      @args = []
    end

    def hear( *args )
      @args << args
      @hear_returns
    end

    def args_received
      @args
    end

    def new_connection( &callback )
      @callback = callback
    end
  end

  it "terminates" do
    ear = MockEar.new
    connection = described_class.new( ear )
    ear.should_receive(:terminate).once
    connection.terminate
  end

  it 'delegates hear to ear' do
    ear = MockEar.new
    ear.hear_returns = true

    connection = described_class.new( ear )
    connection.hear( 'id', 'name', 'value' )

    ear.args_received[ 0 ].should == [ 'id', 'name', 'value' ]
    ear.callback.should be_nil
  end

  it 'requests a new connection when ear does not hear' do
    ear = MockEar.new
    ear.hear_returns = false

    connection = described_class.new( ear )
    connection.hear( 'id', 'name', 'value' )

    ear.args_received[ 0 ].should == [ 'id', 'name', 'value' ]
    ear.callback.should_not be_nil
  end

  it 'when ear does not hear, piles up messages and sends them upon connection' do
    ear = MockEar.new
    ear.hear_returns = false

    connection = described_class.new( ear )
    connection.hear( 'id', 'name', 'value' )
    connection.hear( 'id 2', 'name 2', 'value 2' )

    ear.args_received.clear
    ear.callback.call

    ear.args_received.count.should == 2
    ear.args_received[ 0 ].should == [ 'id', 'name', 'value' ]
    ear.args_received[ 1 ].should == [ 'id 2', 'name 2', 'value 2' ]
  end
end

