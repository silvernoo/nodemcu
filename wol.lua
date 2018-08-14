broadcast_ip="192.168.9.255"
port=9
hardware_mac="00:11:22:33:44:55"

local mac = ""
for w in string.gmatch(hardware_mac, "[0-9A-Za-z][0-9A-Za-z]") do
  mac = mac .. string.char(tonumber(w, 16))
end

udpSocket = net.createUDPSocket()
udpSocket:send(port, broadcast_ip, string.char(0xff):rep(6)..mac:rep(16))

srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,payload) 
      print(payload) 
      conn:send("<h1> Hello, NodeMcu.</h1>")
    end) 
end)