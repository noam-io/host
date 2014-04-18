require 'noam_server/player_connection'

describe NoamServer::PlayerConnection do
  class MockEar

    def initialize
      @args = []
    end

    def send_data( *args )
      @args << args
    end

    def args_received
      @args
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

    connection = described_class.new( ear )
    connection.send_event( 'id', 'name', 'value' )

    ear.args_received[ 0 ].should == [Noam::Messages.build_event( 'id', 'name', 'value' )]
  end

end

