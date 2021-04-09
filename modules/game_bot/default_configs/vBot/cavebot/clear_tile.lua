CaveBot.Extensions.ClearTile = {}

CaveBot.Extensions.ClearTile.setup = function()
  CaveBot.registerAction("ClearTile", "#00FFFF", function(value, retries)
    local pos = regexMatch(value, "\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+)")
    if not pos[1] then
      warn("CaveBot[ClearTile]: invalid value. It should be position (x,y,z), is: " .. value)
      return false
    end

    if retries >= 20 then
      print("CaveBot[ClearTile]: too many tries, can't open doors")
      return false -- tried 20 times, can't clear it
    end

    pos = {x=tonumber(pos[1][2]), y=tonumber(pos[1][3]), z=tonumber(pos[1][4])}  
    local tile = g_map.getTile(pos)
    if not tile then
      print("CaveBot[ClearTile]: can't find tile or tile is unreachable, skipping")
      return false
    end

    -- no items on tile and walkability means we are done
    if tile:isWalkable() and tile:getTopUseThing():isNotMoveable() and not tile:hasCreature() then
      print("CaveBot[ClearTile]: tile clear, proceeding")
      return true
    end

    local pPos = player:getPosition()
    local tPos = tile:getPosition()
    if math.max(math.abs(pPos.x - tPos.x), math.abs(pPos.y - tPos.y)) ~= 1 then
      CaveBot.walkTo(tPos, 20, {ignoreNonPathable = true, precision=3})
      delay(300)
      return "retry"
    end

    if retries > 0 then
      delay(1100)
    end

    -- but if not then first check for creatures
    if tile:hasCreature() then
      local c = tile:getCreatures()[1]
      if c:isMonster() then
        attack(c)

        -- ok here we will find tile to push player, random
      elseif c:isPlayer() then
        local candidates = {}
        for _, tile in ipairs(g_map.getTiles(posz())) do
          if getDistanceBetween(c:getPosition(), tile:getPosition()) == 1 and tile:getPosition() ~= pPos then
            table.insert(candidates, tile:getPosition())
          end
        end

        if #candidates == 0 then
          print("CaveBot[ClearTile]: can't find tile to push, cannot clear way, skipping")
          return false
        else
          print("CaveBot[ClearTile]: pushing player... " .. c:getName() .. " out of the way")
          g_game.move(c, candidates[math.random(1,#candidates)])
          return "retry"
        end
      end
    end
    if #tile:getItems() > 1 then
      local item = tile:getTopUseThing()
      print("CaveBot[ClearTile]: moving item... " .. item:getId().. " from tile")
      g_game.move(item, pPos, item:getCount())
      return "retry"
    end
  end)

  CaveBot.Editor.registerAction("cleartile", "clear tile", {
    value=function() return posx() .. "," .. posy() .. "," .. posz() end,
    title="position of tile to clear",
    description="tile position (x,y,z)",
    multiline=false,
    validation="^\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+)$"
})
end