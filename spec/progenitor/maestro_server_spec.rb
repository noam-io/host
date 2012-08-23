require "progenitor/maestro_server"
describe Progenitor::MaestroServer do
  let(:server) {described_class.new}
  let(:port) { 5534 }
  xit "should start" do
    EM::run do
      server.start(port)
    end

  end
end
