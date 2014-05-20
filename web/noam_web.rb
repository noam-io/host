# Copyright (c) 2014, IDEO

require 'sinatra/async'
require 'json'
require 'config'
require 'noam_server/config_manager'
require 'noam_server/noam_logging'
require 'noam_server/noam_server'
require 'noam_server/grabbed_lemmas'
require 'noam_server/unconnected_lemmas'
require 'noam_server/other_guests_list'
require 'helpers/refresh_helper.rb'


class Statabase
  @@values = {}
  @@timestamps = {}

  def self.set(name, value)
    @@values[name] = value
    @@timestamps[name] = DateTime.now
  end

  def self.get(name)
    @@values[name] || 0
  end

  def self.timestamp(name)
    @@timestamps[name]
  end
end

# Store value and time of last message per player for web interface
NoamServer::Orchestra.instance.on_play do |name, value, player|
  Statabase.set( name, value )
  $last_active_id = player.spalla_id if player
  $last_active_event = name
  RefreshQueue.instance.enqueue_response
end

NoamServer::Orchestra.instance.on_register do |player|
  $last_active_id = player.spalla_id if player
  $last_active_event = ""
  RefreshQueue.instance.enqueue_response
  FreeAgentQueue.instance.enqueue_response
end

NoamServer::Orchestra.instance.on_unregister do |player|
  RefreshQueue.instance.enqueue_response
  FreeAgentQueue.instance.enqueue_response
end

NoamServer::UnconnectedLemmas.instance.on_change do ||
  FreeAgentQueue.instance.enqueue_response
  NoamServer::NoamLogging.info(self, "UnconnectedLemmas change...")
end

NoamServer::GrabbedLemmas.instance.on_change do ||
  FreeAgentQueue.instance.enqueue_response
  NoamServer::NoamLogging.info(self, "GrabbedLemmas change...")
end

class RequestQueue
  def self.instance
    @instance ||= self.new
  end

  def initialize
    @instance = nil
    @r = Queue.new
    @pending_responses = false
    update
  end

  def update
    @last_updated = Time.now.to_ms
  end

  def pile(&callback)
    @r << [callback, Time.now.getutc]
  end

  def pile_time_check(time, &callback)
    if time < @last_updated
      callback.call :good, Time.now.to_ms
    else
      @r << [callback, Time.now.getutc]
    end
  end

  def enqueue_response
    @pending_responses = true
    update
  end

  def pending_responses?
    @pending_responses
  end

  def respond
    while !@r.empty?
      r = @r.pop
      begin
        r[0].call :good, Time.now.to_ms
      rescue RuntimeError => e
        # This error happens when a page that requested an asynchronous response
        # is no longer active / available to receive the response.
        NoamServer::NoamLogging.debug("Respond", "Queued Request has not receiver.")
      end
    end
    @pending_responses = false
  end

  def checktimeouts
    num_requests = @r.size
    timeout_time = CONFIG[:web_server][:time_to_timeout] || 10
    num_requests.times do |i|
      r = @r.pop
      if Time.now.getutc - r[1] > timeout_time
        begin
          r[0].call :timeout, Time.now.to_ms
        rescue RuntimeError => e
          # This error happens when a page that requested an asynchronous response
          # is no longer active / available to receive the response.
          NoamServer::NoamLogging.debug("Respond", "Queued Request has not receiver.")
        end
      else
        @r << r
      end
    end
  end
end


# Queue to manage aget /refresh requests
class RefreshQueue < RequestQueue
end

# Queue to manage aget /free-agents requests
class FreeAgentQueue < RequestQueue
end



$last_active_id = ""
$last_active_event = ""

class NoamApp < Sinatra::Base
  register Sinatra::Async

  set :bind, '0.0.0.0'
  set :server, 'thin'
  set :public_folder, File.dirname(__FILE__)
  set :port, CONFIG[:web_server_port]

  def self.log_info
    NoamServer::NoamLogging.info("NoamApp", "Start Web Server: localhost@#{CONFIG[:web_server_port]}")
  end

  def self.broadcast_port=( value )
    @@broadcast_port = value
  end

  def self.run!
    EM::set_timer_quantum(30)
    EM::add_periodic_timer do
      if RefreshQueue.instance.pending_responses?
        RefreshQueue.instance.respond
      end
      if FreeAgentQueue.instance.pending_responses?
        FreeAgentQueue.instance.respond
      end
    end

    EM::add_periodic_timer(1) do
      RefreshQueue.instance.checktimeouts
      FreeAgentQueue.instance.checktimeouts
    end

    @@ips = `ifconfig | grep 'inet ' | awk '{ print $2}'`

    super
  end

  before do
    # Prevent Thin Logging since we will do our own
    Thin::Logging.silent = true
    @broadcast_port = CONFIG[:broadcast_port]
  end

  get '/' do
    @server_name = CONFIG[:server_name]
    @ips = @@ips ||= "0.0.0.0"
    @orchestra = NoamServer::Orchestra.instance
    @values = Statabase
    erb :indexBootstrap
  end

  get '/settings' do
    content_type :json
    body({
      :on=>NoamServer::NoamServer.on?,
      :name=>NoamServer::NoamServer.room_name
    }.to_json)
  end

  post '/settings', :provides => :json do
    if params.include?('name') and NoamServer::NoamServer.room_name != params['name']
      NoamServer::NoamServer.room_name = params['name']
    end

    if params.include?('on')
      toggle = (params['on'] == true) || (params['on'] == 'true')
      if(toggle != NoamServer::NoamServer.on?)
        NoamServer::NoamServer.on=toggle
      end
    end

    content_type :json
    body({
      :set=>true,
      :on=>NoamServer::NoamServer.on?,
      :name=>NoamServer::NoamServer.room_name
    }.to_json)
  end

  aget '/arefresh' do
    response.headers['Cache-Control'] = 'no-cache'
    requestTime = request['time'] || 0
    RefreshQueue.instance.pile_time_check(requestTime.to_i) do |type, time|
      state = get_orchestra_state
      state[:type] = type
      state[:time] = time
      content_type :json
      body(state.to_json)
    end
  end

  get '/refresh' do
    response.headers['Cache-Control'] = 'no-cache'
    newtime = Time.now.to_ms
    state = get_orchestra_state
    state[:time] = newtime
    state[:type] = :good
    content_type :json
    body(state.to_json)
  end

  post '/play-event', :provides => :json do
    response.headers['Cache-Control'] = 'no-cache'
    NoamServer::Orchestra.instance.play( params["name"], params["value"], :web_ui_lemma )
    content_type :json
    body({"result" => "ok"}.to_json)
  end

  get '/guests' do
    response.headers['Cache-Control'] = 'no-cache'
    newtime = Time.now.to_ms
    response = get_guests(request['types'], {'guests-free-order' => request['guests-free-order'], 'guests-owned-order' => request['guests-owned-order']})
    response[:time] = newtime
    content_type :json
    body(response.to_json)
  end

  aget '/aguests' do
    response.headers['Cache-Control'] = 'no-cache'
    requestType = request['types']
    requestTime = request['time'] || 0
    FreeAgentQueue.instance.pile_time_check(requestTime.to_i) do |type, time|
      response = get_guests(requestType, {'guests-free-order' => request['guests-free-order'], 'guests-owned-order' => request['guests-owned-order']})
      response[:type] = type
      response[:time] = time
      content_type :json
      body(response.to_json)
    end
  end

  post '/guests/join' do
    response.headers['Cache-Control'] = 'no-cache'
    lemma_id = request.body.read
    response = {}
    free_agent_lemma = NoamServer::UnconnectedLemmas.instance.get(lemma_id)
    unless free_agent_lemma.nil?
      NoamServer::GrabbedLemmas.instance.add(free_agent_lemma)
      response[:lemma] = free_agent_lemma
      response[:status] = 'ok'
    else
      response[:status] = 'nolemma'
    end
    content_type :json
    body(response.to_json)
  end

  post '/guests/free' do
    response.headers['Cache-Control'] = 'no-cache'
    lemma_id = request.body.read
    response = {}
    lemma_to_free = NoamServer::GrabbedLemmas.instance.get(lemma_id)
    if lemma_to_free
      NoamServer::GrabbedLemmas.instance.delete(lemma_id)
      NoamServer::Orchestra.instance.fire_player(lemma_id)
      response[:status] = 'ok'
    else
      response[:status] = 'fail'
    end
    content_type :json
    body(response.to_json)
  end


  post '/stop-server' do
    response.headers['Cache-Control'] = 'no-cache'
    NoamServer::NoamLogging.info(self, "Stopping server from web interface...")
    EM.next_tick do
      EM.stop
    end
    body("ok")
  end

  def get_guests(types, order)
    types = types || ['free', 'owned', 'other']
    response = {}
    if types.include?('free')
      response['guests-free'] = {}
      NoamServer::UnconnectedLemmas.instance.get_all(order['guests-free-order']).dup.each do |spalla_id, object|
        if object[:desired_room_name] == "" or object[:desired_room_name] == NoamServer::ConfigManager[:room_name]
          response['guests-free'][spalla_id] = object
        end
      end
    end

    if types.include?('other')
      response['guests-other'] = NoamServer::OtherGuestsList.instance.get_all()
    end

    if types.include?('owned')
      response['guests-owned'] = {}
      NoamServer::Orchestra.instance.get_players(order['guests-owned-order']).dup.each do |spalla_id, player|
        response['guests-owned'][spalla_id] = {
          :name => spalla_id,
          :device_type => player.device_type,
          :last_activity => format_date( player.last_activity ),
          :system_version => player.system_version,
          :hears => player.hears,
          :plays => player.plays,
          :ip => player.host,
          :desired_room_name => player.room_name
        }
      end
    end
    return response
  end





  ####
  # Helper function to return dict of the players and events in the Orchestra
  #
  # {
  #   'player' => players in orchestra,
  #   'events' => events in orchestra
  # }
  #
  ####
  def get_orchestra_state
    @orchestra = NoamServer::Orchestra.instance
    @values = Statabase

    players = {}
    events = {}
		number_of_played_messages = 0

    @orchestra.players.dup.each do |spalla_id, player|
      players[spalla_id] = {
        :spalla_id => spalla_id,
        :device_type => player.device_type,
        :last_activity => format_date( player.last_activity ),
        :system_version => player.system_version,
        :hears => player.hears,
        :plays => player.plays,
        :ip => player.host,
        :desired_room_name => player.room_name
      }
			number_of_played_messages += player.plays.length
    end

    @orchestra.event_names.dup.each do |event|
      events[event.to_s] = {
        :value_escaped => value_escaped(@values.get(event)),
        :timestamp => format_date( @values.timestamp(event) )
      }
    end

    result = {
      :players => players,
      :events => events,
			:'number-played-messages' => number_of_played_messages
    }
  end


end
