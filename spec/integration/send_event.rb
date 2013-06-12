require 'socket'
require 'json'

def sendEvent(sock)
  spalla_id = ARGV[2]
  event_name = ARGV[3]
  event_value = ARGV[4]

  event = ["event", spalla_id, event_name, event_value]
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
  event = ["register", "spalla_id", 7833, [], ["in", "out"]]
  dataToSend = "%06d"% event.to_json.length
  dataToSend += event.to_json
  sock.write dataToSend
  sock.flush
end

ip = ARGV[0]
port = ARGV[1]
sock = TCPSocket.new(ip, port)

sendRegistration sock
sendEvent sock
