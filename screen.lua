local aqi=nil
local dth=nil
local weather=nil
local disp
local font
local m_dis={}

function dispatch(m,t,pl)
	if pl~=nil and m_dis[t] then
		m_dis[t](m,pl)
	end
end
function topic1func(m,pl)
    aqi=pl
    demoLoop()
end
function topic2func(m,pl)
    dth=pl
    demoLoop()
end
function topic3func(m,pl)
    weather=pl
    demoLoop()
end
m_dis["/aqi"]=topic1func
m_dis["/dth"]=topic2func
m_dis["/weather"]=topic3func
m=mqtt.Client("nodemcu2",60,"gxqsoryf","8pVyzw-FKMzZ")
m:on("connect",function(m) 
	m:subscribe("/aqi",0,function(m) print("sub done") end)
    m:subscribe("/dth",0,function(m) print("sub done") end)
    m:subscribe("/weather",0,function(m) print("sub done") end)
	end )
m:on("offline", function(conn)
    print("disconnect to broker...")
    m:connect("m11.cloudmqtt.com",17978,0,0)
end)
m:on("message",dispatch )
m:connect("m11.cloudmqtt.com",17978,0,0)

function init_display()
  local sda = 2
  local sdl = 1
  local sla = 0x3c
  i2c.setup(0,sda,sdl, i2c.SLOW)
  disp = u8g.ssd1306_128x64_i2c(sla)
  font = u8g.font_6x10
end

local function setLargeFont()
  disp:setFont(font)
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
  disp:setFontPosTop()
end

function updateDisplay(func)
  local function drawPages()
    func()
    if (disp:nextPage() == true) then
      node.task.post(drawPages)
    end
  end
  disp:firstPage()
  node.task.post(drawPages)
end

function drawAQI()
  setLargeFont()
  if aqi~=nil then
    saqi = string.match(aqi, ".*%;(.*)")
    disp:drawStr(0,0, "SY_AQI:"..string.match(saqi, ".*%:(.*)"))
  end
  if dth~=nil then
    stem,shum = string.match(dth, "(.*)%;(.*)")
    disp:drawStr(0,12, "TEM:"..string.format("%.2f",string.match(stem, ".*%:(.*)")).."C")
    disp:drawStr(0,24, "HUM:"..string.match(shum, ".*%:(.*)").."%")
  end
  if weather~=nil then
    disp:drawStr(0,36, weather)
  end
end

local drawDemo = { drawAQI }

function demoLoop()
  local f = table.remove(drawDemo,1)  
  updateDisplay(f)
  table.insert(drawDemo,f)
end
init_display()
demoLoop()
