local context = G.botContext

context.zoomIn = function() modules.game_interface.getMapPanel():zoomIn() end
context.zoomOut = function() modules.game_interface.getMapPanel():zoomOut() end

context.getSpectators = function(multifloor)
  if multifloor ~= true then
    multifloor = false
  end
  return g_map.getSpectators(context.player:getPosition(), multifloor)
end

context.getCreatureById = function(id, multifloor)
  if type(id) ~= 'number' then return nil end
  if multifloor ~= true then
    multifloor = false
  end
  for i, spec in ipairs(g_map.getSpectators(context.player:getPosition(), multifloor)) do
     if spec:getId() == id then
        return spec
     end
  end
  return nil
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

context.findAllPaths = function(start, maxDist, params)
  --[[
    Available params:
      ignoreLastCreature
      ignoreCreatures
      ignoreNonPathable
      ignoreNonWalkable
      ignoreStairs
      ignoreCost
      allowUnseen
      allowOnlyVisibleTiles
  ]]--
  if type(params) ~= 'table' then
    params = {}
  end
  for key, value in pairs(params) do
    if value == nil or value == false then
      params[key] = 0
    elseif value == true then
      params[key] = 1    
    end
  end
  return g_map.findEveryPath(start, maxDist, params)
end
context.findEveryPath = context.findAllPaths

context.translateAllPathsToPath = function(paths, destPos)
  local predirections = {}
  local directions = {}
  local destPosStr = destPos
  if type(destPos) ~= 'string' then
    destPosStr = destPos.x .. "," .. destPos.y .. "," .. destPos.z
  end
  
  while destPosStr:len() > 0 do
    local node = paths[destPosStr]
    if not node then
      break
    end
    if node[3] < 0 then
      break
    end
    table.insert(predirections, node[3])
    destPosStr = node[4]
  end
  -- reverse
  for i=#predirections,1,-1 do
    table.insert(directions, predirections[i])
  end
  return directions
end
context.translateEveryPathToPath = context.translateAllPathsToPath


context.findPath = function(startPos, destPos, maxDist, params)
  --[[
    Available params:
      ignoreLastCreature
      ignoreCreatures
      ignoreNonPathable
      ignoreNonWalkable
      ignoreStairs
      ignoreCost
      allowUnseen
      allowOnlyVisibleTiles
      precision
      marginMin
      marginMax
  ]]--
  if startPos.z ~= destPos.z then
    return
  end
  if type(maxDist) ~= 'number' then
    maxDist = 100
  end
  if type(params) ~= 'table' then
    params = {}
  end
  local destPosStr = destPos.x .. "," .. destPos.y .. "," .. destPos.z
  params["destination"] = destPosStr
  local paths = context.findAllPaths(startPos, maxDist, params)
  
  local marginMin = params.marginMin or params.minMargin
  local marginMax = params.marginMax or params.maxMargin
  if type(marginMin) == 'number' and type(marginMax) == 'number' then
    local bestCandidate = nil
    local bestCandidatePos = nil    
    for x = -marginMax, marginMax do
      for y = -marginMax, marginMax do
        if math.abs(x) >= marginMin or math.abs(y) >= marginMin then
          local dest = (destPos.x + x) .. "," .. (destPos.y + y) .. "," .. destPos.z
          local node = paths[dest]
          if node and (not bestCandidate or bestCandidate[1] > node[1]) then
            bestCandidate = node
            bestCandidatePos = dest
          end          
        end
      end
    end
    if bestCandidate then
      return context.translateAllPathsToPath(paths, bestCandidatePos)      
    end
    return
  end

  if not paths[destPosStr] then  
    local precision = params.precision
    if type(precision) == 'number' then
      for p = 1, precision do
        local bestCandidate = nil
        local bestCandidatePos = nil
        for x = -p, p do
          for y = -p, p do
            local dest = (destPos.x + x) .. "," .. (destPos.y + y) .. "," .. destPos.z
            local node = paths[dest]
            if node and (not bestCandidate or bestCandidate[1] > node[1]) then
              bestCandidate = node
              bestCandidatePos = dest
            end
          end
        end
        if bestCandidate then
          return context.translateAllPathsToPath(paths, bestCandidatePos)      
        end
      end
    end
    return nil
  end
  
  return context.translateAllPathsToPath(paths, destPos)
end
context.getPath = context.findPath

context.autoWalk = function(destination, maxDist, params) 
  -- Available params same as for findPath
  local path = context.findPath(context.player:getPosition(), destination, maxDist, params)
  if not path then
    return false
  end
  -- autowalk without prewalk animation
  g_game.autoWalk(path, {x=0,y=0,z=0})
  return true
end

