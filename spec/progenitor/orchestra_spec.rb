require 'progenitor/orchestra'
describe Progenitor::Orchestra do
  let(:orchestra) { described_class.new }
  it "should register a players" do
    player = mock("Player")
    orchestra.register(player, ["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"])

    player.should_receive(:hear).with("listens_for_1", 12.42)
    orchestra.play("listens_for_1", 12.42)
  end
end
