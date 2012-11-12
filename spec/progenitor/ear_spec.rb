require 'eventmachine'
require 'progenitor/ear'

def wire_message(expected_message)
  "%06d" % expected_message.size + expected_message
end

describe Progenitor::Ear do
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

  it 'does not send anything with no connection' do
      ear.hear( 'id', 'name', 'value' ).should be_false
  end

  it 'does not try to make another connection while one is pending' do
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
      ear.hear( 'id', 'name', 'value' ).should be_true
      times_called_back.should == 1
    end
  end
end

