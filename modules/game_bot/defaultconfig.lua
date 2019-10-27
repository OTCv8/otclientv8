botDefaultConfig = {
  configs = {
    {name = "Example", script = [=[
--#Example
info("Tested on 10.99")

--#main
local widget = setupUI([[
Panel
  id: redPanel
  background: red
  margin-top: 10
  margin-bottom: 10
  height: 100
  
  Label
    anchors.fill: parent
    text: custom ui, otml based
    text-align: center
]])

--#macros
macro(5000, "macro send link", "f5", function()
  g_game.talk("macro test - https://github.com/OTCv8/otclient_bot")
  g_game.talk("bot is hiding 50% of effects as example, say exevo gran mas vis")
end)

macro(1000, "flag tiles", function()
  player:getTile():setText("Hello =)", "red")
end)

macro(25, "auto healing", function()
  if hppercent() < 80 then
    say("exura")
    delay(1000) -- not calling this macro for next 1s
  end
end)

addSeparator("spe0")

--#hotkeys
hotkey('y', 'test hotkey', function() g_game.talk('hotkey elo') end)
singlehotkey('x', 'single hotkey', function() g_game.talk('single hotkey') end)

singlehotkey('=', "Zoom in map", function () zoomIn() end)
singlehotkey('-', "Zoom out map", function () zoomOut() end)

--#callbacks
onAddThing(function(tile, thing)
  if thing:isItem() and thing:getId() == 2129 then
    local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
    if not storage[pos] or storage[pos] < now then 
      storage[pos] = now + 20000
    end
    tile:setTimer(storage[pos] - now)
  end
end)

-- hide 50% of effects
onAddThing(function(tile, thing)
  if thing:isEffect() and math.random(1, 2) == 1 then
    thing:hide()
  end
end)

listen(player:getName(), function(text)
  info("you said: " .. text)
end)

--#other
addLabel("label1", "Test label 1")
addSeparator("sep1")
addLabel("label2", "Test label 2")

storage.clicks = 0
addButton("button1", "Click me", function()
  storage.clicks = storage.clicks + 1
  ui.button1:setText("Clicks: " .. storage.clicks)
end)

HTTP.getJSON("https://api.ipify.org/?format=json", function(data, err)
    if err then
        warn("Whoops! Error occured: " .. err)
        return
    end
    info("HTTP: My IP is: " .. tostring(data['ip']))
end)

]=]},
  {name = "UI & Healing", script = [=[
-- UI & healing
info("Tested on 10.99")

--#main
local healthPanel = setupUI([[
Panel
  id: healingPanel
  height: 150
  margin-top: 3
  
  Label
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text: Use item if
    text-align: center
  
  BotItem
    id: item1
    anchors.left: parent.left
    anchors.top: prev.bottom

  Label
    id: label1  
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: prev.top
    margin: 0 5 0 5
    text-align: center
    
  HorizontalScrollBar
    id: scroll1
    anchors.left: prev.left
    anchors.right: prev.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 100
    step: 1
    
  BotItem
    id: item2
    anchors.left: parent.left
    anchors.top: item1.bottom
    margin-top: 3

  Label
    id: label2
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: prev.top
    margin: 0 5 0 5
    text-align: center
    
  HorizontalScrollBar
    id: scroll2
    anchors.left: label2.left
    anchors.right: label2.horizontalCenter
    anchors.top: label2.bottom
    margin-top: 5
    minimum: 0
    maximum: 100
    step: 1
    
  HorizontalScrollBar
    id: scroll3
    anchors.left: label2.horizontalCenter
    anchors.right: label2.right
    anchors.top: label2.bottom
    margin-top: 5
    minimum: 0
    maximum: 100
    step: 1
    
  Label
    anchors.top: item2.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 3
    text: Drag item to change it
    text-align: center
    
  HorizontalSeparator
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 3
]])

healthPanel.item1:setItemId(storage.healItem1 or 266)
healthPanel.item1.onItemChange = function(widget, item)
  storage.healItem1 = item:getId()
  widget:setItemId(storage.healItem1)
end

healthPanel.item2:setItemId(storage.healItem2 or 268)
healthPanel.item2.onItemChange = function(widget, item)
  storage.healItem2 = item:getId()
  widget:setItemId(storage.healItem2)
end

healthPanel.scroll1.onValueChange = function(scroll, value)
  storage.healPercent1 = value
  healthPanel.label1:setText("0% <= hp <= " .. storage.healPercent1 .. "%")
end
healthPanel.scroll1:setValue(storage.healPercent1 or 50)

healthPanel.scroll2.onValueChange = function(scroll, value)
  storage.healPercent2 = value
  healthPanel.label2:setText("" .. storage.healPercent2 .. "% <= mana <= " .. storage.healPercent3 .. "%")
end
healthPanel.scroll3.onValueChange = function(scroll, value)
  storage.healPercent3 = value
  healthPanel.label2:setText("" .. storage.healPercent2 .. "% <= mana <= " .. storage.healPercent3 .. "%")
end
healthPanel.scroll2:setValue(storage.healPercent2 or 40)
healthPanel.scroll3:setValue(storage.healPercent3 or 60)

macro(25, function()
  if not storage.healItem1 then
    return
  end
  if healthPanel.scroll1:getValue() >= hppercent() then
    useWith(storage.healItem1, player)      
    delay(500)
  end
end)
macro(25, function()
  if not storage.healItem2 then
    return
  end
  if storage.healPercent2 <= manapercent() and manapercent() <= storage.healPercent3 then
    useWith(storage.healItem2, player)      
    delay(500)
  end  
end)

--#macros

--#hotkeys

--#callbacks

--#other
]=]},
  {}, {}, {}
  },
  enabled = false,
  selectedConfig = 1
}