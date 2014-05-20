require 'spec_helper'
require 'noam_server/other_guests_list'

describe NoamServer::OtherGuestsList do
  it "registers a callback on servers list" do
    server_repo = double(:servers)
    callback = nil
    server_repo.should_receive(:on_change) { |block| callback = block }
    described_class.new(server_repo)
  end
end
