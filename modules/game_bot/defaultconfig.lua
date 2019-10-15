botDefaultConfig = {
  configs = {
    {name = "Example", script = [[
--#Example config

--#macros
macro(5000, "macro send link", "f5", function()
  g_game.talk("macro test - https://github.com/OTCv8/otclient_bot")
end)

macro(1000, "flag tiles", function()
  local staticText = StaticText.create()
  staticText:addMessage("t", 9, "xDDD")
  local tile = player:getTile()
  tile:clearTexts()
  tile:addText(staticText)
  for i = 1, 10 do 
    schedule(1000 * i, function()
      staticText:setText(i)
    end)
  end
  schedule(11000, function()
    tile:clearTexts()
  end)
end)


addSeparator("spe0")

--#hotkeys
hotkey('y', 'test hotkey', function() g_game.talk('hotkey elo') end)

--#callbacks

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

info("Bot started")


]]},
  {}, {}, {}, {}
  },
  enabled = false,
  selectedConfig = 1
}