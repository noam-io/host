require 'em/pure_ruby'
require 'noam_server/ear'

def wire_message(expected_message)
  "%06d" % expected_message.size + expected_message
end

describe NoamServer::Ear do
  let( :host ){ '127.0.0.1' }
  let( :port ){ 5663 }
  let( :ear ){ described_class.new( host, port )}

  it 'calls back on new connection' do
    times_called_back = 0
    callback = proc do |connection|
      times_called_back += 1
      EM::stop_event_loop
    end

    EM::run do
      ear.new_connection( &callback )
    end

    times_called_back.should == 1
  end

  describe "#send_data" do
    it 'does not send anything with no connection' do
      ear.terminate
      ear.send_data( 'sample data' ).should be_false
    end

    it 'does not try to make another connection when one is created' do
      times_called_back = 0

      module TestConnection
        def receive_data( data )
          message = wire_message( Orchestra::Messages.build_event( 'id', 'name', 'value' ))
          data.should == message
          EM::stop_event_loop
        end
      end

      EM::run do
        server = EventMachine::start_server( host, port, TestConnection )

        callback = proc do |connection|
          times_called_back += 1
          EM::stop_event_loop
        end

        ear.new_connection( &callback )
        ear.send_data( 'sample data' ).should be_true
        times_called_back.should == 1
      end
    end
  end

  describe "#active?" do
    before(:each) do
      @tcp_socket = double("TCP Socket", :signature => 1337,
        :parent= => nil, :close_connection_after_writing => nil)
      EventMachine.stub(:connect).
                   with(host, port, NoamServer::EarHandler).
                   and_yield(@tcp_socket)
      @ear = NoamServer::Ear.new(host, port)
    end

    it "is false when the connection pool does not include the TCP socket" do
      NoamServer::ConnectionPool.stub(:include?).with(@tcp_socket).and_return(false)
      @ear.should_not be_active
    end

    it "is true when the connection pool includes the TCP socket" do
      NoamServer::ConnectionPool.stub(:include?).with(@tcp_socket).and_return(true)
      @ear.should be_active
    end
  end

end
