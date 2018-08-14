print("Setting up WIFI...")
wifi.setmode(wifi.STATION)
wifi.sta.config{ssid="netis_2.4G", pwd="todo"}  -- todo password
wifi.sta.autoconnect(1)
ledPin=4

tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() == nil then
        print("Waiting for IP ...")
    else
        print("IP is " .. wifi.sta.getip())
        gpio.mode(ledPin, gpio.OUTPUT)
        dofile("mqtt.lua");
        dofile("screen.lua");
        dofile("wol.lua")
    tmr.stop(1)
    end
end)
