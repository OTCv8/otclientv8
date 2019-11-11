local context = G.botContext

-- callback(callbackType, callback)
context.callback = function(callbackType, callback)
  if not context._callbacks[callbackType] then
    return error("Wrong callback type: " .. callbackType)
  end
  if callbackType == "onAddThing" or callbackType == "onRemoveThing" then
    g_game.enableTileThingLuaCallback(true)
  end
  local callbackData = {}
  table.insert(context._callbacks[callbackType], function(...)
    if not callbackData.delay or callbackData.delay < context.now then
      local prevExecution = context._currentExecution
      context._currentExecution = callbackData       
      callback(...)
      context._currentExecution = prevExecution
    end
  end)
end

-- onKeyDown(callback) -- callback = function(keys)
context.onKeyDown = function(callback) 
  return context.callback("onKeyDown", callback)
end

-- onKeyPress(callback) -- callback = function(keys)
context.onKeyPress = function(callback) 
  return context.callback("onKeyPress", callback)
end

-- onKeyUp(callback) -- callback = function(keys)
context.onKeyUp = function(callback) 
  return context.callback("onKeyUp", callback)
end

-- onTalk(callback) -- callback = function(name, level, mode, text, channelId, pos)
context.onTalk = function(callback) 
  return context.callback("onTalk", callback)
end

-- onAddThing(callback) -- callback = function(tile, thing)
context.onAddThing = function(callback) 
  return context.callback("onAddThing", callback)
end

-- onRemoveThing(callback) -- callback = function(tile, thing)
context.onRemoveThing = function(callback) 
  return context.callback("onRemoveThing", callback)
end

-- onCreatureAppear(callback) -- callback = function(creature)
context.onCreatureAppear = function(callback)
  return context.callback("onCreatureAppear", callback)
end

-- onCreatureDisappear(callback) -- callback = function(creature)
context.onCreatureDisappear = function(callback)
  return context.callback("onCreatureDisappear", callback)
end

-- onCreaturePositionChange(callback) -- callback = function(creature, newPos, oldPos)
context.onCreaturePositionChange = function(callback)
  return context.callback("onCreaturePositionChange", callback)
end

-- onCreatureHealthPercentChange(callback) -- callback = function(creature, healthPercent)
context.onCreatureHealthPercentChange = function(callback)
  return context.callback("onCreatureHealthPercentChange", callback)
end

-- onUse(callback) -- callback = function(pos, itemId, stackPos, subType)
context.onUse = function(callback)
  return context.callback("onUse", callback)
end

-- onUseWith(callback) -- callback = function(pos, itemId, target, subType)
context.onUseWith = function(callback)
  return context.callback("onUseWith", callback)
end

-- onContainerOpen -- callback = function(container, previousContainer)
context.onContainerOpen = function(callback)
  return context.callback("onContainerOpen", callback)
end

-- onContainerClose -- callback = function(container)
context.onContainerClose = function(callback)
  return context.callback("onContainerClose", callback)
end

-- onContainerUpdateItem -- callback = function(container, slot, item)
context.onContainerUpdateItem = function(callback)
  return context.callback("onContainerUpdateItem", callback)
end

-- onMissle -- callback = function(missle)
context.onMissle = function(callback)
  return context.callback("onMissle", callback)
end

-- onChannelList -- callback = function(channels)
context.onChannelList = function(callback)
  return context.callback("onChannelList", callback)
end

-- onOpenChannel -- callback = function(channelId, name)
context.onOpenChannel = function(callback)
  return context.callback("onOpenChannel", callback)
end

-- onCloseChannel -- callback = function(channelId)
context.onCloseChannel = function(callback)
  return context.callback("onCloseChannel", callback)
end

-- onChannelEvent -- callback = function(channelId, name, event)
context.onChannelEvent = function(callback)
  return context.callback("onChannelEvent", callback)
end



-- CUSTOM CALLBACKS

-- listen(name, callback) -- callback = function(text, channelId, pos)
context.listen = function(name, callback)
  if not name then return context.error("listen: invalid name") end
  name = name:lower()
  context.onTalk(function(name2, level, mode, text, channelId, pos)
    if name == name2:lower() then
      callback(text, channelId, pos)
    end
  end)
end

-- onPlayerPositionChange(callback) -- callback = function(newPos, oldPos)
context.onPlayerPositionChange = function(callback)
  context.onCreaturePositionChange(function(creature, newPos, oldPos)
    if creature == context.player then
      callback(newPos, oldPos)
    end
  end)
end

-- onPlayerHealthChange(callback) -- callback = function(healthPercent)
context.onPlayerHealthChange = function(callback)
  context.onCreatureHealthPercentChange(function(creature, healthPercent)
    if creature == context.player then
      callback(healthPercent)
    end
  end)
end