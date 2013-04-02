require 'socket'
require 'json'

def sendEvent(sock)
  event_name = ARGV[2]
  event_value = ARGV[3]
  event = ["event", "spalla_id", event_name, event_value]
  dataToSend = "%06d"% event.to_json.length
  dataToSend += event.to_json
  puts dataToSend
  sock.write dataToSend
  sock.flush
end

def sendRegistration(sock)
  event = ["register", "spalla_id", 7833, ["speed", "rpm", "event3"], []]
  dataToSend = "%06d"% event.to_json.length
  dataToSend += event.to_json
  sock.write dataToSend
  sock.flush
end

def sendCheckinRegistration(sock)
  event = ["register", "spalla_id", 7833, [], ["checkin", "checkout"]]
  dataToSend = "%06d"% event.to_json.length
  dataToSend += event.to_json
  sock.write dataToSend
  sock.flush
end



ip = ARGV[0]
port = ARGV[1]
sock = TCPSocket.new(ip, port)

sendEvent sock
# sendCheckinRegistration sock
