-- [[ script made by Ruu ]] --
-- [[ http://otclient.net/showthread.php?tid=358 ]] --
-- [[  small mod, added many doors id's and diagonal walking and switch ]] --

local wsadWalking = modules.game_walking.wsadWalking
local doorsIds = { 5007, 8265, 1629, 1632, 5129, 6252, 6249, 7715, 7712, 7714, 7719, 6256, 1669, 1672, 5125, 5115, 5124, 17701, 17710, 1642, 6260, 5107, 4912, 6251, 5291, 1683, 1696, 1692, 5006, 2179, 5116, 11705, 30772, 30774 }

setDefaultTab("Tools")
local m = macro(1000, "Auto open doors", function() end)

function checkForDoors(pos)
  local tile = g_map.getTile(pos)
  if tile then
    local useThing = tile:getTopUseThing()
    if useThing and table.find(doorsIds, useThing:getId()) then
      g_game.use(useThing)
    end
  end
end

onKeyPress(function(keys)
  if m.isOff() then return end
  local pos = player:getPosition()
  if keys == 'Up' or (wsadWalking and keys == 'W') then
    pos.y = pos.y - 1
  elseif keys == 'Down' or (wsadWalking and keys == 'S') then
    pos.y = pos.y + 1
  elseif keys == 'Left' or (wsadWalking and keys == 'A') then
    pos.x = pos.x - 1
  elseif keys == 'Right' or (wsadWalking and keys == 'D') then
    pos.x = pos.x + 1
  elseif wsadWalking and keys == "Q" then
    pos.y = pos.y - 1
    pos.x = pos.x - 1
  elseif wsadWalking and keys == "E" then
    pos.y = pos.y - 1
    pos.x = pos.x + 1
  elseif wsadWalking and keys == "Z" then
    pos.y = pos.y + 1
    pos.x = pos.x - 1
  elseif wsadWalking and keys == "C" then
    pos.y = pos.y + 1
    pos.x = pos.x + 1
  end
  checkForDoors(pos)
end)