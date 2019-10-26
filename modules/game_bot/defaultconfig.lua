botDefaultConfig = {
  configs = {
    {name = "Example", script = [[
--#Example config

--#main
local widget = setupUI(%[%[
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
%]%])

--#macros
macro(5000, "macro send link", "f5", function()
  g_game.talk("macro test - https://github.com/OTCv8/otclient_bot")
  g_game.talk("bot is hiding 50% of effects as example, say exevo gran mas vis")
end)

macro(1000, "flag tiles", function()
  local staticText = StaticText.create()
  staticText:addMessage("t", 9, "xDDD")
  local tile = player:getTile()
  tile:setText("Hello =)", "red")
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

]]},
  {}, {}, {}, {}
  },
  enabled = false,
  selectedConfig = 1
}