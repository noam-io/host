require 'socket'
require 'json'

socket = UDPSocket.new
socket.bind("0.0.0.0", 1031)
socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
socket.connect('10.3.255.255', 1030)
message = ["marco", "lemma_id", "#{Socket.gethostname} - Noam Moderator",
           "ruby", "1.1"].to_json
socket.send(message, 0)
puts socket.recvfrom(64)
