CaveBot.Extensions.ClearTile = {}

CaveBot.Extensions.ClearTile.setup = function()
  CaveBot.registerAction("ClearTile", "#00FFFF", function(value, retries)
    local data = string.split(value, ",")
    local pos = {x=tonumber(data[1]), y=tonumber(data[2]), z=tonumber(data[3])}
    local doors
    if #data == 4 then
      doors = true
    end
    if not #pos == 3 then
      warn("CaveBot[ClearTile]: invalid value. It should be position (x,y,z), is: " .. value)
      return false
    end

    if retries >= 20 then
      print("CaveBot[ClearTile]: too many tries, can't clear it")
      return false -- tried 20 times, can't clear it
    end

    if getDistanceBetween(player:getPosition(), pos) == 0 then
      print("CaveBot[ClearTile]: tile reached, proceeding")
      return true
    end
    local tile = g_map.getTile(pos)
    if not tile then
      print("CaveBot[ClearTile]: can't find tile or tile is unreachable, skipping")
      return false
    end

    -- no items on tile and walkability means we are done
    if tile:isWalkable() and tile:getTopUseThing():isNotMoveable() and not tile:hasCreature() and not doors then
      print("CaveBot[ClearTile]: tile clear, proceeding")
      return true
    end

    if not CaveBot.MatchPosition(tPos, 3) then
      CaveBot.GoTo(tPos, 3)
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
        return "retry"
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
    for i, item in ipairs(tile:getItems()) do
      if not item:isNotMoveable() then
        print("CaveBot[ClearTile]: moving item... " .. item:getId().. " from tile")
        g_game.move(item, pPos, item:getCount())
        return "retry"
      end
    end
    if doors then
      use(tile:getTopUseThing())
      return "retry"
    end
    return "retry"
  end)

  CaveBot.Editor.registerAction("cleartile", "clear tile", {
    value=function() return posx() .. "," .. posy() .. "," .. posz() end,
    title="position of tile to clear",
    description="tile position (x,y,z), optional true if open doors",
    multiline=false
})
end