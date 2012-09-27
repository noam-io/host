require 'progenitor/player'

describe Progenitor::Player do
  let(:spalla_id) { "Spalla ID" }
  let(:device_type) { "Device Type" }
  let(:system_version) { "System Version" }
  let(:hears) { %w(speed rpm cruise_target) }
  let(:plays) { %w(speed volume) }
  let(:player) { described_class.new( spalla_id, device_type, system_version, hears, plays )}

  it 'has spalla id' do
    player.spalla_id.should == spalla_id
  end

  it 'has device type' do
    player.device_type.should == device_type
  end

  it 'has system version' do
    player.system_version.should == system_version
  end

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

  it "adds notes to plays" do
    player.learn_to_play("window_state")
    player.plays?("window_state").should == true
  end

  it "does not duplicate notes" do
    player.learn_to_play("window_state")
    size = player.plays.size
    player.learn_to_play("window_state")
    player.plays.size.should == size
  end

  it 'is deployable only when device type is pi, PI, or Pi' do
    player = described_class.new( '', 'pi', '', [], [] )
    player.deployable?.should be_true
    player = described_class.new( '', 'PI', '', [], [] )
    player.deployable?.should be_true
    player = described_class.new( '', 'Pi', '', [], [] )
    player.deployable?.should be_true
  end

  it 'is not deployable in other cases' do
    player.deployable?.should be_false
  end
end
