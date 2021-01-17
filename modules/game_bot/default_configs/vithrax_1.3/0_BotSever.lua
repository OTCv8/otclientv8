setDefaultTab("Main")

BotPanelName = "BOTserver"
local ui = setupUI([[
Panel
  height: 18

  Button
    id: botServer
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    height: 18
    !text: tr('BotServer')
]])
ui:setId(BotPanelName)

if not storage[BotPanelName] then
storage[BotPanelName] = {
  manaInfo = true,
  mwallInfo = true
}
end

if not storage.BotServerChannel then
  storage.BotServerChannel = tostring(math.random(1000000000000,9999999999999))
end

local channel = tostring(storage.BotServerChannel)
BotServer.init(name(), channel)

rootWidget = g_ui.getRootWidget()
if rootWidget then
  botServerWindow = g_ui.createWidget('BotServerWindow', rootWidget)
  botServerWindow:hide()


  botServerWindow.Data.Channel:setText(storage.BotServerChannel)
  botServerWindow.Data.Channel.onTextChange = function(widget, text)
    storage.BotServerChannel = text
  end

  botServerWindow.Data.Random.onClick = function(widget)
    storage.BotServerChannel = tostring(math.random(1000000000000,9999999999999))
    botServerWindow.Data.Channel:setText(storage.BotServerChannel)
  end

  botServerWindow.Features.Feature1:setOn(storage[BotPanelName].manaInfo)
  botServerWindow.Features.Feature1.onClick = function(widget)
    storage[BotPanelName].manaInfo = not storage[BotPanelName].manaInfo
    widget:setOn(storage[BotPanelName].manaInfo)
  end

  botServerWindow.Features.Feature2:setOn(storage[BotPanelName].mwallInfo)
  botServerWindow.Features.Feature2.onClick = function(widget)
    storage[BotPanelName].mwallInfo = not storage[BotPanelName].mwallInfo
    widget:setOn(storage[BotPanelName].mwallInfo)
  end
end

function updateStatusText()
  if BotServer._websocket then 
    botServerWindow.Data.ServerStatus:setText("CONNECTED")
    if serverCount then
      botServerWindow.Data.Participants:setText(#serverCount)
    end
  else
    botServerWindow.Data.ServerStatus:setText("DISCONNECTED")
    botServerWindow.Data.Participants:setText("-")
  end
end

macro(2000, function()
  if BotServer._websocket then
    BotServer.send("list")
  end
  updateStatusText()
end)

local regex = [["(.*?)"]]
BotServer.listen("list", function(name, data)
  serverCount = regexMatch(json.encode(data), regex)  
  storage.serverMembers = json.encode(data) 
end)

ui.botServer.onClick = function(widget)
    botServerWindow:show()
    botServerWindow:raise()
    botServerWindow:focus()
end

botServerWindow.closeButton.onClick = function(widget)
    botServerWindow:hide()
end


-- scripts

storage[BotPanelName].mwalls = {}
BotServer.listen("mwall", function(name, message)
  if storage[BotPanelName].mwallInfo then
    if not storage[BotPanelName].mwalls[message["pos"]] or storage[BotPanelName].mwalls[message["pos"]] < now then
      storage[BotPanelName].mwalls[message["pos"]] = now + message["duration"] - 150 -- 150 is latency correction
    end
  end
end)

BotServer.listen("mana", function(name, message)
  if storage[BotPanelName].manaInfo then
    local creature = getPlayerByName(name)
    if creature then
      creature:setManaPercent(message["mana"])
    end
  end
end)

onAddThing(function(tile, thing)
  if storage[BotPanelName].mwallInfo then
    if thing:isItem() and thing:getId() == 2129 then
      local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
      if not storage[BotPanelName].mwalls[pos] or storage[BotPanelName].mwalls[pos] < now then
        storage[BotPanelName].mwalls[pos] = now + 20000
        BotServer.send("mwall", {pos=pos, duration=20000})
      end
      tile:setTimer(storage[BotPanelName].mwalls[pos] - now)
    end
  end
end)

local lastMana = 0
macro(100, function()
  if storage[BotPanelName].manaInfo then
    if manapercent() ~= lastMana then
      lastMana = manapercent()
      BotServer.send("mana", {mana=lastMana})
    end
  end
end)








addSeparator()