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