local context = G.botContext

context.zoomIn = function() modules.game_interface.getMapPanel():zoomIn() end
context.zoomOut = function() modules.game_interface.getMapPanel():zoomOut() end

context.getSpectators = function(multifloor)
  if multifloor ~= true then
    multifloor = false
  end
  return g_map.getSpectators(context.player:getPosition(), multifloor)
end

context.getCreatureByName = function(name, multifloor)
  if not name then return nil end
  name = name:lower()
  if multifloor ~= true then
    multifloor = false
  end
  for i, spec in ipairs(g_map.getSpectators(context.player:getPosition(), multifloor)) do
     if spec:getName():lower() == name then
        return spec
     end
  end
  return nil
end

context.getPlayerByName = function(name, multifloor)
  if not name then return nil end
  name = name:lower()
  if multifloor ~= true then
    multifloor = false
  end
  for i, spec in ipairs(g_map.getSpectators(context.player:getPosition(), multifloor)) do
     if spec:isPlayer() and spec:getName():lower() == name then
        return spec
     end
  end
  return nil
end

context.findPath = function(startPos, destPos, maxDist, ignoreFields, ignoreCreatures)
  if type(maxDist) ~= 'number' then
    maxDist = 100
  end
  local complexity = math.min(10000, maxDist * maxDist)
  local flags = 0
  if ignoreFields then
    flags = flags + 4
  end
  if ignoreCreatures then
    flags = flags + 16
  end
  return g_map.findPath(startPos, destPos, complexity, flags)
end

context.autoWalk = function(destination, maxDist, ignoreFields, ignoreCreatures)
  if maxDist == nil then
    maxDist = 100
  end
  if ignoreFields == nil then
    ignoreFields = false
  end
  if ignoreCreatures == nil then
    ignoreCreatures = false
  end
  if context.player:getPosition().z ~= destination.z then
    return false
  end
  local path = context.findPath(context.player:getPosition(), destination, maxDist, ignoreFields, ignoreCreatures)
  if #path < 1 then
    return false
  end
  g_game.autoWalk(path, context.player:getPosition())
  return true
end