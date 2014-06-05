# Copyright (c) 2014, IDEO

require 'noam_server/orchestra'
require 'noam_server/orchestra_state'
require 'noam_server/statabase'

describe NoamServer::OrchestraState do
  let(:orchestra) { NoamServer::Orchestra.instance }
  let(:statabase) { NoamServer::Statabase.instance }

  after(:each) { orchestra.clear }

  context "including registered players" do
    let(:player_state) { subject[:players] }

    it "player :spalla_id is the player's #spalla_id" do
      player = create_and_register_player(spalla_id: 123)
      player_state[123][:spalla_id].should == 123
    end

    it "player :device_type is the player's #device_type" do
      player = create_and_register_player(device_type: "example_type")
      player_state[player.spalla_id][:device_type].should == "example_type"
    end

    it "player :last_activity is the player's #last_activity, formatted to UTC" do
      now = DateTime.now
      player = create_and_register_player(last_activity: now)
      player_state[player.spalla_id][:last_activity].should == format_utc(now)
    end

    it "player :system_version is the player's #system_version" do
      player = create_and_register_player(system_version: "example_version")
      player_state[player.spalla_id][:system_version].should == "example_version"
    end

    it "player :hears is the player's #hears" do
      player = create_and_register_player(hears: ["example_message"])
      player_state[player.spalla_id][:hears].should == ["example_message"]
    end

    it "player :plays is the player's #plays" do
      player = create_and_register_player(plays: ["example_message"])
      player_state[player.spalla_id][:plays].should == ["example_message"]
    end

    it "player :ip is the player's #host" do
      player = create_and_register_player(host: "example_host")
      player_state[player.spalla_id][:ip].should == "example_host"
    end

    it "player :desired_room_name is the player's #room_name" do
      player = create_and_register_player(room_name: "example_room")
      player_state[player.spalla_id][:desired_room_name].should == "example_room"
    end
  end

  context "including registered players' events" do
    let(:event_state) { subject[:events] }

    it "event :value_escaped is the event's value as an HTML-safe string" do
      orchestra.stub(:event_names) { ["example_event"] }
      statabase.set("example_event", "example_value!")
      event_state["example_event"][:value_escaped].should == "example_value%21"
    end

    it "event :timestamp is the event's #timestamp, formatted to utc" do
      orchestra.stub(:event_names) { ["example_event"] }
      statabase.set("example_event", "example_value!")
      event_state["example_event"][:timestamp].should == format_utc(statabase.timestamp("example_event"))
    end
  end

  it ":number-played-messages is the total count of messages played" do
    create_and_register_players({plays: ["example_event"]}, {plays: ["sample_event"]})
    subject[:"number-played-messages"].should == 2
  end

  def create_and_register_players(*attrs)
    players = attrs.map {|attr| create_player(attr)}
    orchestra.stub(:players) { players.reduce({}) {|hash, player| hash[player.spalla_id] = player; hash} }
    players
  end

  def create_and_register_player(attrs = {})
    player = create_player(attrs)
    orchestra.stub(:players) { {player.spalla_id => player} }
    player
  end

  def create_player(attrs = {})
    double(:player, {
      spalla_id:      next_id,
      hears:          [],
      plays:          [],
      device_type:    "example_type",
      last_activity:  DateTime.now,
      system_version: "example_version",
      host:           "example_host",
      room_name:      "example_room"
    }.merge(attrs))
  end

  def format_utc(date)
    date.new_offset(0).strftime("%Y-%m-%dT%H:%M:%S.%LZ")
  end

  def next_id
    @example_id ||= 0
    @example_id += 1
    @example_id
  end
end
