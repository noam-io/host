require 'progenitor/orchestra'
require 'progenitor/player'

describe Progenitor::Orchestra do
  let(:orchestra) { described_class.new }
  it "should register a players" do
    player = mock("Player", :spalla_id => 1234)
    orchestra.register(player, Progenitor::Player.new(["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"]))

    player.should_receive(:hear).with("listens_for_1", 12.42)
    orchestra.play("listens_for_1", 12.42)
  end

  it "plays a note noone has registered for" do
    -> {orchestra.play("listens_for_1", 12.42)}.should_not raise_error
  end

  it "replaces existing registration with a new one" do
    player1 = mock("Player1", :spalla_id => 1234)
    player2 = mock("Player2", :spalla_id => 1234)
    orchestra.register(player1, Progenitor::Player.new(["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"]))

    player1.should_receive(:terminate)
    orchestra.register(player2, Progenitor::Player.new(["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"]))

    player1.should_not_receive(:hear)
    player2.should_receive(:hear).with("listens_for_1", 12.42)
    orchestra.play("listens_for_1", 12.42)
  end

  it "implements a Singleton" do
    described_class.instance.should === described_class.instance
  end

  it "registers registration observers" do
    player = mock("Player1", :spalla_id => 1234)
    callback_run = false
    orchestra.on_register do |bplayer, hears, plays|
      callback_run = true
      bplayer.should == player
      hears.should == ["listens_for_1", "listens_for_2"]
      plays.should == ["plays_1", "plays_2"]
    end

    orchestra.register(player, Progenitor::Player.new(["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"]))

    callback_run.should == true
  end

  it "registers event observers" do
    callback_run = false

    orchestra.on_play do |name, value|
      callback_run = true
    end

    orchestra.play("food", "bard")

    callback_run.should == true
  end

  it "tracks players" do
    player_connection = mock("Connection", :spalla_id => "1234")
    player = Progenitor::Player.new(["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"])
    orchestra.register(player_connection, player)
    orchestra.players.size.should == 1
    orchestra.players["1234"].should == player
    orchestra.players["1234"].hears?("listens_for_1").should == true
    orchestra.players["1234"].hears?("listens_for_2").should == true
    orchestra.players["1234"].plays?("plays_1").should == true
    orchestra.players["1234"].plays?("plays_2").should == true
  end

  it "lists events" do
    player_connection = mock("Connection", :spalla_id => "1234")
    player = Progenitor::Player.new(["listens_for_1", "listens_for_2"], ["plays_1", "plays_2"])
    orchestra.register(player_connection, player)
    orchestra.events.size.should == 4
    %w(listens_for_1 listens_for_2 plays_1 plays_2).each do |event|
      orchestra.event_names.include?(event).should be_true
    end
  end
end
