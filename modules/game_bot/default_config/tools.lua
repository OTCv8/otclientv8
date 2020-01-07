local toolsTab = addTab("Tools")

macro(1000, "exchange money", function()
  local containers = getContainers()
  for i, container in pairs(containers) do
    for j, item in ipairs(container:getItems()) do
      if item:isStackable() and (item:getId() == 3035 or item:getId() == 3031) and item:getCount() == 100 then
        g_game.use(item)
        return
      end
    end
  end
end)

macro(1000, "this macro does nothing", "f7", function()

end)

macro(100, "debug pathfinding", nil, function()
  for i, tile in ipairs(g_map.getTiles(posz())) do
    tile:setText("")
  end
  local path = findEveryPath(pos(), 20, {
    ignoreNonPathable = false
  })
  local total = 0
  for i, p in pairs(path) do
    local s = i:split(",")
    local pos = {x=tonumber(s[1]), y=tonumber(s[2]), z=tonumber(s[3])}
    local tile = g_map.getTile(pos)
    if tile then
      tile:setText(p[2])
    end
     total = total + 1
  end
end)

macro(1000, "speed hack", nil, function()
  player:setSpeed(1000)
end)

hotkey("f5", "example hotkey", function()
  info("Wow, you clicked f5 hotkey")
end)

singlehotkey("ctrl+f6", "singlehotkey", function()
  info("Wow, you clicked f6 singlehotkey")
  usewith(268, player)
end)

singlehotkey("ctrl+f8", "play alarm", function()
  playAlarm()
end)

singlehotkey("ctrl+f9", "stop alarm", function()
  stopSound()
end)

local positionLabel = addLabel("positionLabel", "")
onPlayerPositionChange(function()
  positionLabel:setText("Pos: " .. posx() .. "," .. posy() .. "," .. posz())
end)

local s = addSwitch("sdSound", "Play sound when using sd", function(widget)
  storage.sdSound = not storage.sdSound
  widget:setOn(storage.sdSound)
end)
s:setOn(storage.sdSound)

onUseWith(function(pos, itemId)
  if storage.sdSound and itemId == 3155 then
    playSound("/sounds/magnum.ogg")
  end
end)

macro(100, "hide useless tiles", "", function()
  for i, tile in ipairs(g_map.getTiles(posz())) do
    if not tile:isWalkable(true) then
      tile:setFill('black')
    end
  end
end)

addLabel("mapinfo", "You can use ctrl + plus and ctrl + minus to zoom in / zoom out map")
