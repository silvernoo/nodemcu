local pin = 3
local m_dis={}
local is_connected=false
function dispatch(m,t,pl)
	if pl~=nil and m_dis[t] then
		m_dis[t](m,pl)
	end
end
function topic1func(m,pl)
	print("aqi : "..pl)
end
function topic2func(m,pl)
	print("dth : "..pl)
end
function topic3func(m,pl)
	print("weather : "..pl)
end
m_dis["/aqi"]=topic1func
m_dis["/dth"]=topic2func
m_dis["/weather"]=topic3func
m=mqtt.Client("nodemcu1",60,"gxqsoryf","8pVyzw-FKMzZ")
m:on("connect",function(m) 
	print("connect done") 
	m:subscribe("/aqi",0,function(m) print("sub done") end)
    m:subscribe("/dth",0,function(m) print("sub done") end)
    m:subscribe("/weather",0,function(m) print("sub done") end)
    is_connected=true
	end )
m:on("offline", function(conn)
    is_connected=false
    print("disconnect to broker...")
    m:connect("m11.cloudmqtt.com",17978,0,0)
end)
m:on("message",dispatch)
m:connect("m11.cloudmqtt.com",17978,0,0)

local query_aqi = function(query)
    http.get("http://api.waqi.info/feed/@462/?token=todo", nil, function(code, data)  -- todo token
        if query~=nil then
            query();
        end
        if (code == 200) then
            mt = {}
            t = {metatable = mt}
            decoder = sjson.decoder(t)
            decoder:write(data)
            if decoder:result() and decoder:result()["data"] and decoder:result()["data"]["aqi"] then
                m:publish("/aqi", "HTTP code:"..code..";".."AQI:"..decoder:result()["data"]["aqi"], 0, 0)
            end
        else
            print("HTTP error :"..code)
        end
    end)
end

local query_weather = function(query)
    http.get("http://d7.weather.com.cn/fishing/api/v1/tab?stationId=101010400", nil, function(code, data)
        if query~=nil then
            query();
        end
        if (code == 200) then
            t = {metatable = mt}
            decoder = sjson.decoder(t)
            decoder:write(data)
            result=decoder:result()
            if result["result"] and result["result"]["dayTemp"] and result["result"]["nightTemp"] then
                m:publish("/weather", result["result"]["dayTemp"].."-"..result["result"]["nightTemp"], 0, 0)
            end
        else
            print("HTTP error :"..code)
        end
    end)
end

function queryDHT()
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
        if temp > 100 then
            temp = temp / 25.6
        end
        if humi > 100 then
            humi = humi / 25.6
        end
        m:publish("/dth", "DHT Temperature:"..temp..";".."Humidity:"..humi, 0, 0)
    end
end

function seq(query1,query2)
    query1(query2)
end

tmr.alarm(0,5 * 1000,1,function()
    print(is_connected)
    if is_connected then
        queryDHT()
        seq(query_aqi,query_weather)
    end
end)
