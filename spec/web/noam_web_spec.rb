#Copyright (c) 2014, IDEO

require 'web/spec_helper'
require 'json'

describe NoamApp do
	let(:id_1) { 'Arduino1' }
	let(:id_2) { 'Raspberry2' }
	let(:ip_1) { '10.0.3.2' }
	let(:ip_2) { '192.168.3.2' }
	let(:player_1 ) { NoamServer::Player.new( id_1, 'Virtual Machine', 'System Version',
																						["listens_for_1", "listens_for_2"],
																						["plays_1", "plays_2"] ,
																						ip_1,
																						111,
																						"RoomName",
																						{"heartbeat" => 2}) }

	let(:player_2) { NoamServer::Player.new( id_2,
																					 'Pi',
																					 'System Version',
																					 [],
																					 [],
																					 ip_2,
																					 222,
																					 "RoomName",
																					 { "heartbeat" => 1,
																						 "heartbeat_ack" => true } ) }

  describe "POST /settings" do
    it "sets the name of the app" do
      post '/settings', {:name => 'foobar'}, {"HTTP_ACCEPT" => "application/json"}
      last_response.should be_ok
      resp = JSON.parse(last_response.body)
      resp['name'].should == 'foobar'
    end

    it "toggles the on value" do
      post '/settings', {:on => true}, {"HTTP_ACCEPT" => "application/json"}
      last_response.should be_ok
      resp = JSON.parse(last_response.body)
      resp['on'].should be_true

      post '/settings', {:on => false}, {"HTTP_ACCEPT" => "application/json"}
      last_response.should be_ok
      resp = JSON.parse(last_response.body)
      resp['on'].should be_false
		end

	end

  describe "GET /guests for other guests" do

    before(:each) do
      NoamServer::OtherGuestsList.instance(double(:serverlist, :on_change => nil))
    end

		it "returns 1 lemma" do
      NoamServer::OtherGuestsList.instance.response_handler( {"name" => "server1"}, { "guests-owned" => {"Lemma1"=>{"name"=>"Lemma1"}}})
			get '/guests', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-other'][resp['guests-other'].keys[0]]["name"].should == "Lemma1"
		end

		it "returns lemma that points to a roomName that does not exist" do
			NoamServer::UnconnectedLemmas.stub_chain(:instance, :get_all).and_return({"Lemma2"=>{"name"=>"Lemma2"}})
			NoamServer::OtherGuestsList.instance.response_handler( {"name" => "server1"}, { "guests-owned" => {}})
			get '/guests', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-other'][resp['guests-other'].keys[0]]["name"].should == "Lemma2"
		end

		it "returns 2 lemmas, one that points to a roomName that does not exist and the other connected to another roomName" do
			NoamServer::UnconnectedLemmas.stub_chain(:instance, :get_all).and_return({"Lemma2"=>{"name"=>"Lemma2"}})
			NoamServer::OtherGuestsList.instance.response_handler( {"name" => "server1"}, { "guests-owned" => {"Lemma1"=>{"name"=>"Lemma1"}}})
			get '/guests', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-other'][resp['guests-other'].keys[0]]["name"].should == "Lemma2"
			resp['guests-other'][resp['guests-other'].keys[1]]["name"].should == "Lemma1"
		end

		it "should differentiate these 2 lemmas by other guest type" do
			NoamServer::UnconnectedLemmas.stub_chain(:instance, :get_all).and_return({"Lemma2"=>{"name"=>"Lemma2"}})
			NoamServer::OtherGuestsList.instance.response_handler( {"name" => "server1"}, { "guests-owned" => {"Lemma1"=>{"name"=>"Lemma1"}}})
			get '/guests', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-other'][resp['guests-other'].keys[0]]["otherguesttype"].should == "Free"
			resp['guests-other'][resp['guests-other'].keys[1]]["otherguesttype"].should == "Grabbed"
		end

	end

	describe "GET /guests for free agents" do

		before(:each) do
			@unconnected_lemmas = NoamServer::UnconnectedLemmas.instance
			elem1 = {
					:name => "SendLemma",
					:desired_room_name => "",
					:device_type => "java",
					:system_version => "1.0",
					:ip => "127.0.0.1"
			}
			@unconnected_lemmas.add(elem1)
			elem2 = {
					:name => "RunAllTypes",
					:desired_room_name => "",
					:device_type => "java",
					:system_version => "1.0",
					:ip => "127.0.0.1"
			}
			@unconnected_lemmas.add(elem2)
		end

		after(:each) do
			@unconnected_lemmas.clear
		end

		it "returns 2 lemmas order by time of creation" do
			get '/guests', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-free'][resp['guests-free'].keys[0]]["name"].should == "SendLemma"
			resp['guests-free'][resp['guests-free'].keys[1]]["name"].should == "RunAllTypes"
		end

		it "returns 2 lemmas order by name" do
			get '/guests?guests-free-order=asc', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-free'][resp['guests-free'].keys[0]]["name"].should == "RunAllTypes"
			resp['guests-free'][resp['guests-free'].keys[1]]["name"].should == "SendLemma"
		end

		it "returns 2 lemmas order by name in descending order" do
			get '/guests?guests-free-order=desc', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-free'][resp['guests-free'].keys[0]]["name"].should == "SendLemma"
			resp['guests-free'][resp['guests-free'].keys[1]]["name"].should == "RunAllTypes"
		end

	end

	describe 'GET /guests for owned agents' do

		it "returns 2 lemmas order by time of registration" do
			NoamServer::Orchestra.any_instance.stub(:players).and_return({:Arduino1 => player_1, :Raspberry2 => player_2})
			get '/guests', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-owned'][resp['guests-owned'].keys[0]]["name"].should == "Arduino1"
			resp['guests-owned'][resp['guests-owned'].keys[1]]["name"].should == "Raspberry2"
		end


		it "returns 2 lemmas order by name" do
			NoamServer::Orchestra.any_instance.stub(:players).and_return({:Raspberry2 => player_2, :Arduino1 => player_1})
			get '/guests?guests-owned-order=asc', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-owned'][resp['guests-owned'].keys[0]]["name"].should == "Arduino1"
			resp['guests-owned'][resp['guests-owned'].keys[1]]["name"].should == "Raspberry2"
		end

		it "returns 2 lemmas order by name in descending order" do
			NoamServer::Orchestra.any_instance.stub(:players).and_return({:Arduino1 => player_1, :Raspberry2 => player_2})
			get '/guests?guests-owned-order=desc', {"HTTP_ACCEPT" => "application/json"}
			last_response.should be_ok
			resp = JSON.parse(last_response.body)
			resp['guests-owned'][resp['guests-owned'].keys[0]]["name"].should == "Raspberry2"
			resp['guests-owned'][resp['guests-owned'].keys[1]]["name"].should == "Arduino1"
		end


	end

	describe 'GET /refresh for owned agents' do

		it "returns 2 as the quantity of messages that can be played" do
			NoamServer::Orchestra.any_instance.stub(:players).and_return({:Arduino1 => player_1, :Raspberry2 => player_2})
			get '/refresh', {"HTTP_ACCEPT" => "application/json"}
			resp = JSON.parse(last_response.body)
			resp["number-played-messages"].should == 2
		end

	end

end
