require 'progenitor/orchestra'
describe Progenitor::Orchestra do
  let(:orchestra) { described_class.new }
  it "should register a players" do
    player = mock("Player", :spalla_id => 1234)
    orchestra.register(player, ["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"])

    player.should_receive(:hear).with("listens_for_1", 12.42)
    orchestra.play("listens_for_1", 12.42)
  end

  it "replaces existing registration with a new one" do
    player1 = mock("Player1", :spalla_id => 1234)
    player2 = mock("Player2", :spalla_id => 1234)
    orchestra.register(player1, ["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"])

    player1.should_receive(:terminate)
    orchestra.register(player2, ["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"])

    player1.should_not_receive(:hear)
    player2.should_receive(:hear).with("listens_for_1", 12.42)
    orchestra.play("listens_for_1", 12.42)
  end

  it "implements a Singleton" do
    described_class.instance.should === described_class.instance
  end
end
