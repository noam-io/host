require 'sinatra/async'
require 'json'
require 'config'
require 'noam_server/noam_logging'
require 'noam_server/noam_server'
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
  Request.enqueue_response
end

NoamServer::Orchestra.instance.on_register do |player|
  $last_active_id = player.spalla_id if player
  $last_active_event = ""
  Request.enqueue_response
end

NoamServer::Orchestra.instance.on_unregister do |player|
  Request.enqueue_response
end

class Request
  @@r = Queue.new
  @@pending_responses = false

  def self.pile(&callback)
    @@r << [callback, Time.now.getutc]
  end

  def self.enqueue_response
    @@pending_responses = true
  end

  def self.pending_responses?
    @@pending_responses
  end

  def self.respond
    while !@@r.empty?
      r = @@r.pop
      begin
        r[0].call :good
      rescue RuntimeError => e
        # This error happens when a page that requested an asynchronous response
        # is no longer active / available to receive the response.
        NoamServer::NoamLogging.debug("Respond", "Queued Request has not receiver.")
      end
    end
    @@pending_responses = false
  end

  def self.checktimeouts
    num_requests = @@r.size
    timeout_time = CONFIG[:web_server][:time_to_timeout] || 10
    num_requests.times do |i|
      r = @@r.pop
      if Time.now.getutc - r[1] > timeout_time
        begin
          r[0].call :timeout
        rescue RuntimeError => e
          # This error happens when a page that requested an asynchronous response
          # is no longer active / available to receive the response.
          NoamServer::NoamLogging.debug("Respond", "Queued Request has not receiver.")
        end
      else
        @@r << r
      end
    end

  end

end

$last_active_id = ""
$last_active_event = ""

class NoamApp < Sinatra::Base
  register Sinatra::Async

  set :server, 'thin'
  set :public_folder, File.dirname(__FILE__)
  set :port, CONFIG[:web_server_port]

  def self.log_info() 
    NoamServer::NoamLogging.info("NoamApp", "Start Web Server: localhost@#{CONFIG[:web_server_port]}")
  end

  def self.broadcast_port=( value )
    @@broadcast_port = value
  end

  def self.run!
    EM::set_timer_quantum(30)
    EM::add_periodic_timer do
      if Request.pending_responses?
        Request.respond
      end
    end

    EM::add_periodic_timer(1) do
      Request.checktimeouts
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
    @ips = @@ips.split("\n").join(",")
    @orchestra = NoamServer::Orchestra.instance
    @values = Statabase
    erb :indexBootstrap
  end

  aget '/arefresh' do
    Request.pile do |type|
      state = getOrchestraState()
      state[:type] = type
      content_type :json
      body(state.to_json)
    end
  end

  get '/refresh' do
    state = getOrchestraState()
    state[:type] = :good
    content_type :json
    body(state.to_json)
  end

  post '/play-event' do
    puts params
    NoamServer::Orchestra.instance.play( params["name"], params["value"], "Maestro Web" )
    body("ok")
  end

  post '/stop-server' do
    NoamServer::NoamLogging.info(self, "Stopping server from web interface...")
    EM.next_tick do
      EM.stop
    end
    body("ok")
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
  def getOrchestraState()
    @orchestra = NoamServer::Orchestra.instance
    @values = Statabase

    players = {}
    events = {}

    @orchestra.players.each do |spalla_id, player|
      players[spalla_id] = {
        :spalla_id => spalla_id,
        :device_type => player.device_type,
        :last_activity => format_date( player.last_activity ),
        :system_version => player.system_version,
        :hears => player.hears,
        :plays => player.plays
      }
    end

    @orchestra.event_names.each do |event|
      events[event.to_s] = {
        :value_escaped => value_escaped(@values.get(event)),
        :timestamp => format_date( @values.timestamp(event) )
      }
    end

    result = {
      :players => players,
      :events => events,
    }
  end


end
