CaveBot.Extensions.OpenDoors = {}

CaveBot.Extensions.OpenDoors.setup = function()
  CaveBot.registerAction("OpenDoors", "#00FFFF", function(value, retries)
    local pos = regexMatch(value, "\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+)")
    if not pos[1] then
      error("CaveBot[OpenDoors]: invalid value. It should be position (x,y,z), is: " .. value)
      return false
    end

    if retries >= 5 then
      print("CaveBot[OpenDoors]: too many tries, can't open doors")
      return false -- tried 5 times, can't open
    end

    pos = {x=tonumber(pos[1][2]), y=tonumber(pos[1][3]), z=tonumber(pos[1][4])}  

    local doorTile
    if not doorTile then
      for i, tile in ipairs(g_map.getTiles(posz())) do
        if tile:getPosition().x == pos.x and tile:getPosition().y == pos.y and tile:getPosition().z == pos.z then
          doorTile = tile
        end
      end
    end

    if not doorTile then
      return false
    end
  
    if not doorTile:isWalkable() then
      use(doorTile:getTopUseThing())
      return "retry"
    else
      print("CaveBot[OpenDoors]: possible to cross, proceeding")
      return true
    end
  end)

  CaveBot.Editor.registerAction("opendoors", "open doors", {
    value=function() return posx() .. "," .. posy() .. "," .. posz() end,
    title="Door position",
    description="doors position (x,y,z)",
    multiline=false,
    validation="^\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+)$"
})
end