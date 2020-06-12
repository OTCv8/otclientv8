UIGameMap = extends(UIMap, "UIGameMap")

function UIGameMap.create()
  local gameMap = UIGameMap.internalCreate()
  gameMap:setKeepAspectRatio(true)
  gameMap:setVisibleDimension({width = 15, height = 11})
  gameMap:setDrawLights(true)
  gameMap.markedThing = nil
  gameMap.blockNextRelease = 0
  gameMap:updateMarkedCreature()
  return gameMap
end

function UIGameMap:onDestroy()
  if self.updateMarkedCreatureEvent then
    removeEvent(self.updateMarkedCreatureEvent)
  end
end

function UIGameMap:markThing(thing, color)
  if self.markedThing == thing then
    return
  end
  if self.markedThing then
    self.markedThing:setMarked('')
  end
  
  self.markedThing = thing
  if self.markedThing and g_settings.getBoolean('highlightThingsUnderCursor') then
    self.markedThing:setMarked(color)
  end
end

function UIGameMap:onDragEnter(mousePos)
  local tile = self:getTile(mousePos)
  if not tile then return false end

  local thing = tile:getTopMoveThing()
  if not thing then return false end

  self.currentDragThing = thing

  g_mouse.pushCursor('target')
  self.allowNextRelease = false
  return true
end

function UIGameMap:onDragLeave(droppedWidget, mousePos)
  self.currentDragThing = nil
  self.hoveredWho = nil
  g_mouse.popCursor('target')
  return true
end

function UIGameMap:onDrop(widget, mousePos)
  if not self:canAcceptDrop(widget, mousePos) then return false end

  local tile = self:getTile(mousePos)
  if not tile then return false end

  local thing = widget.currentDragThing
  local toPos = tile:getPosition()

  local thingPos = thing:getPosition()
  if thingPos.x == toPos.x and thingPos.y == toPos.y and thingPos.z == toPos.z then return false end

  if thing:isItem() and thing:getCount() > 1 then
    modules.game_interface.moveStackableItem(thing, toPos)
  else
    g_game.move(thing, toPos, 1)
  end

  return true
end

function UIGameMap:onMouseMove(mousePos, mouseMoved)
  self.mousePos = mousePos
  return false
end

function UIGameMap:onDragMove(mousePos, mouseMoved)
  self.mousePos = mousePos
  return false
end

function UIGameMap:updateMarkedCreature()
  self.updateMarkedCreatureEvent = scheduleEvent(function() self:updateMarkedCreature() end, 100)
  if self.mousePos and g_game.isOnline() then
    self.markingMouseRelease = true
    self:onMouseRelease(self.mousePos, MouseRightButton)
    self.markingMouseRelease = false
  end
end

function UIGameMap:onMousePress()
  if not self:isDragging() and self.blockNextRelease < g_clock.millis() then
    self.allowNextRelease = true
    self.markingMouseRelease = false
  end
end

function UIGameMap:blockNextMouseRelease(postAction)
  self.allowNextRelease = false
  if postAction then
    self.blockNextRelease = g_clock.millis() + 150
  else
    self.blockNextRelease = g_clock.millis() + 250  
  end
end

function UIGameMap:onMouseRelease(mousePosition, mouseButton)
  if not self.allowNextRelease and not self.markingMouseRelease then
    return true
  end
  local autoWalkPos = self:getPosition(mousePosition)
  local positionOffset = self:getPositionOffset(mousePosition)

  -- happens when clicking outside of map boundaries
  if not autoWalkPos then 
    if self.markingMouseRelease then
      self:markThing(nil)
    end
    return false 
  end

  local localPlayerPos = g_game.getLocalPlayer():getPosition()
  if autoWalkPos.z ~= localPlayerPos.z then
    local dz = autoWalkPos.z - localPlayerPos.z
    autoWalkPos.x = autoWalkPos.x + dz
    autoWalkPos.y = autoWalkPos.y + dz
    autoWalkPos.z = localPlayerPos.z
  end

  local lookThing
  local useThing
  local creatureThing
  local multiUseThing
  local attackCreature

  local tile = self:getTile(mousePosition)
  if tile then
    lookThing = tile:getTopLookThingEx(positionOffset)
    useThing = tile:getTopUseThing()
    creatureThing = tile:getTopCreatureEx(positionOffset)
  end

  local autoWalkTile = g_map.getTile(autoWalkPos)
  if autoWalkTile then
    attackCreature = autoWalkTile:getTopCreatureEx(positionOffset)
  end

  if self.markingMouseRelease then
    if attackCreature then
      self:markThing(attackCreature, 'yellow')
    elseif creatureThing then
      self:markThing(creatureThing, 'yellow')
    elseif useThing and not useThing:isGround() then
      self:markThing(useThing, 'yellow')
    elseif lookThing and not lookThing:isGround() then
      self:markThing(lookThing, 'yellow')
    else
      self:markThing(nil, '')
    end
    return
  end

  local ret = modules.game_interface.processMouseAction(mousePosition, mouseButton, autoWalkPos, lookThing, useThing, creatureThing, attackCreature, self.markingMouseRelease)
  if ret then
    self.allowNextRelease = false
  end
  
  return ret
end

function UIGameMap:onTouchRelease(mousePosition, mouseButton)
  if mouseButton ~= MouseTouch then
    return self:onMouseRelease(mousePosition, mouseButton)
  end
end

function UIGameMap:canAcceptDrop(widget, mousePos)
  if not widget or not widget.currentDragThing then return false end

  local children = rootWidget:recursiveGetChildrenByPos(mousePos)
  for i=1,#children do
    local child = children[i]
    if child == self then
      return true
    elseif not child:isPhantom() then
      return false
    end
  end

  error('Widget ' .. self:getId() .. ' not in drop list.')
  return false
end
