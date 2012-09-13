require 'progenitor/player'

describe Progenitor::Player do
  let(:hears) { %w(speed rpm cruise_target) }
  let(:plays) { %w(speed volume) }
  let(:player) { described_class.new(hears, plays) }

  it "hears" do
    hears.each do |event|
      player.hears?(event).should be_true
    end
  end

  it "does not hear" do
    player.hears?("volume").should be_false
  end

  it "does not play" do
    player.plays?("rpm").should be_false
  end

  it "plays" do
    plays.each do |event|
      player.plays?(event).should be_true
    end
  end
end
