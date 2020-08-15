battleWindow = nil
battleButton = nil
battlePanel = nil
filterPanel = nil
toggleFilterButton = nil

mouseWidget = nil
updateEvent = nil

hoveredCreature = nil
newHoveredCreature = nil
prevCreature = nil

battleButtons = {}
local ageNumber = 1
local ages = {}

function init()  
  g_ui.importStyle('battlebutton')
  battleButton = modules.client_topmenu.addRightGameToggleButton('battleButton', tr('Battle') .. ' (Ctrl+B)', '/images/topbuttons/battle', toggle, false, 2)
  battleButton:setOn(true)
  battleWindow = g_ui.loadUI('battle', modules.game_interface.getRightPanel())
  g_keyboard.bindKeyDown('Ctrl+B', toggle)

  -- this disables scrollbar auto hiding
  local scrollbar = battleWindow:getChildById('miniwindowScrollBar')
  scrollbar:mergeStyle({ ['$!on'] = { }})

  battlePanel = battleWindow:recursiveGetChildById('battlePanel')

  filterPanel = battleWindow:recursiveGetChildById('filterPanel')
  toggleFilterButton = battleWindow:recursiveGetChildById('toggleFilterButton')

  if isHidingFilters() then
    hideFilterPanel()
  end

  local sortTypeBox = filterPanel.sortPanel.sortTypeBox
  local sortOrderBox = filterPanel.sortPanel.sortOrderBox

  mouseWidget = g_ui.createWidget('UIButton')
  mouseWidget:setVisible(false)
  mouseWidget:setFocusable(false)
  mouseWidget.cancelNextRelease = false

  battleWindow:setContentMinimumHeight(80)

  sortTypeBox:addOption('Name', 'name')
  sortTypeBox:addOption('Distance', 'distance')
  sortTypeBox:addOption('Total age', 'age')
  sortTypeBox:addOption('Screen age', 'screenage')
  sortTypeBox:addOption('Health', 'health')
  sortTypeBox:setCurrentOptionByData(getSortType())
  sortTypeBox.onOptionChange = onChangeSortType

  sortOrderBox:addOption('Asc.', 'asc')
  sortOrderBox:addOption('Desc.', 'desc')
  sortOrderBox:setCurrentOptionByData(getSortOrder())
  sortOrderBox.onOptionChange = onChangeSortOrder

  battleWindow:setup()
  
  for i=1,30 do
    local battleButton = g_ui.createWidget('BattleButton', battlePanel)
    battleButton:setup()
    battleButton:hide()
    battleButton.onHoverChange = onBattleButtonHoverChange
    battleButton.onMouseRelease = onBattleButtonMouseRelease
    table.insert(battleButtons, battleButton)
  end
  
  updateBattleList()
  
  connect(LocalPlayer, {
    onPositionChange = onPlayerPositionChange
  })
  connect(Creature, {
    onAppear = updateSquare,
    onDisappear = updateSquare
  })  
  connect(g_game, { 
    onAttackingCreatureChange = updateSquare,
    onFollowingCreatureChange = updateSquare 
  })
end

function terminate()
  if battleButton == nil then
    return
  end
  
  battleButtons = {}
  
  g_keyboard.unbindKeyDown('Ctrl+B')
  battleButton:destroy()
  battleWindow:destroy()
  mouseWidget:destroy()
	
  disconnect(LocalPlayer, {
    onPositionChange = onPlayerPositionChange
  })
  disconnect(Creature, {
    onAppear = onCreatureAppear,
    onDisappear = onCreatureDisappear
  })  
  disconnect(g_game, { 
    onAttackingCreatureChange = updateSquare,
    onFollowingCreatureChange = updateSquare 
  })

  removeEvent(updateEvent)
end

function toggle()
  if battleButton:isOn() then
    battleWindow:close()
    battleButton:setOn(false)
  else
    battleWindow:open()
    battleButton:setOn(true)
  end
end

function onMiniWindowClose()
  battleButton:setOn(false)
end

function getSortType()
  local settings = g_settings.getNode('BattleList')
  if not settings then
    if g_app.isMobile() then
      return 'distance'
    else
      return 'name'
    end
  end
  return settings['sortType']
end

function setSortType(state)
  settings = {}
  settings['sortType'] = state
  g_settings.mergeNode('BattleList', settings)

  checkCreatures()
end

function getSortOrder()
  local settings = g_settings.getNode('BattleList')
  if not settings then
    return 'asc'
  end
  return settings['sortOrder']
end

function setSortOrder(state)
  settings = {}
  settings['sortOrder'] = state
  g_settings.mergeNode('BattleList', settings)

  checkCreatures()
end

function isSortAsc()
    return getSortOrder() == 'asc'
end

function isSortDesc()
    return getSortOrder() == 'desc'
end

function isHidingFilters()
  local settings = g_settings.getNode('BattleList')
  if not settings then
    return false
  end
  return settings['hidingFilters']
end

function setHidingFilters(state)
  settings = {}
  settings['hidingFilters'] = state
  g_settings.mergeNode('BattleList', settings)
end

function hideFilterPanel()
  filterPanel.originalHeight = filterPanel:getHeight()
  filterPanel:setHeight(0)
  toggleFilterButton:getParent():setMarginTop(0)
  toggleFilterButton:setImageClip(torect("0 0 21 12"))
  setHidingFilters(true)
  filterPanel:setVisible(false)
end

function showFilterPanel()
  toggleFilterButton:getParent():setMarginTop(5)
  filterPanel:setHeight(filterPanel.originalHeight)
  toggleFilterButton:setImageClip(torect("21 0 21 12"))
  setHidingFilters(false)
  filterPanel:setVisible(true)
end

function toggleFilterPanel()
  if filterPanel:isVisible() then
    hideFilterPanel()
  else
    showFilterPanel()
  end
end

function onChangeSortType(comboBox, option, value)
  setSortType(value:lower())
end

function onChangeSortOrder(comboBox, option, value)
  -- Replace dot in option name
  setSortOrder(value:lower():gsub('[.]', ''))
end

-- functions
function updateBattleList() 
  removeEvent(updateEvent)
	updateEvent = scheduleEvent(updateBattleList, 100)
  checkCreatures()
end

function checkCreatures()
  if not battlePanel or not g_game.isOnline() then
    return
  end

  local player = g_game.getLocalPlayer()
  if not player then
    return
  end
  
  local dimension = modules.game_interface.getMapPanel():getVisibleDimension()
  local spectators = g_map.getSpectatorsInRangeEx(player:getPosition(), false, math.floor(dimension.width / 2), math.floor(dimension.width / 2), math.floor(dimension.height / 2), math.floor(dimension.height / 2))
  local maxCreatures = battlePanel:getChildCount()
  
  local creatures = {}
  local now = g_clock.millis()
  local resetAgePoint = now - 250
  for _, creature in ipairs(spectators) do
    if doCreatureFitFilters(creature) and #creatures < maxCreatures then
      if not creature.lastSeen or creature.lastSeen < resetAgePoint then
        creature.screenAge = now        
      end      
      creature.lastSeen = now
      if not ages[creature:getId()] then
        if ageNumber > 1000 then
          ageNumber = 1
          ages = {}
        end
        ages[creature:getId()] = ageNumber
        ageNumber = ageNumber + 1
      end
      table.insert(creatures, creature)	
    end
  end
  
  updateSquare()
  sortCreatures(creatures)
  battlePanel:getLayout():disableUpdates()
  
  -- sorting
  local ascOrder = isSortAsc()
  for i=1,#creatures do  
	  local creature = creatures[i]
	  if ascOrder then
      creature = creatures[#creatures - i + 1]
	  end
    local battleButton = battleButtons[i]      
    battleButton:creatureSetup(creature)
    battleButton:show()
    battleButton:setOn(true)
  end
  
  if g_app.isMobile() and #creatures > 0 then
    onBattleButtonHoverChange(battleButtons[1], true)
  end
    
  for i=#creatures + 1,maxCreatures do
    if battleButtons[i]:isHidden() then break end
    battleButtons[i]:hide()
    battleButton:setOn(false)
  end

  battlePanel:getLayout():enableUpdates()
  battlePanel:getLayout():update()
end

function doCreatureFitFilters(creature)
  if creature:isLocalPlayer() then
    return false
  end
  if creature:getHealthPercent() <= 0 then
    return false
  end

  local pos = creature:getPosition()
  if not pos then return false end

  local localPlayer = g_game.getLocalPlayer()
  if pos.z ~= localPlayer:getPosition().z or not creature:canBeSeen() then return false end

  local hidePlayers = filterPanel.buttons.hidePlayers:isChecked()
  local hideNPCs = filterPanel.buttons.hideNPCs:isChecked()
  local hideMonsters = filterPanel.buttons.hideMonsters:isChecked()
  local hideSkulls = filterPanel.buttons.hideSkulls:isChecked()
  local hideParty = filterPanel.buttons.hideParty:isChecked()

  if hidePlayers and creature:isPlayer() then
    return false
  elseif hideNPCs and creature:isNpc() then
    return false
  elseif hideMonsters and creature:isMonster() then
    return false
  elseif hideSkulls and creature:isPlayer() and creature:getSkull() == SkullNone then
    return false
  elseif hideParty and creature:getShield() > ShieldWhiteBlue then
    return false
  end

  return true
end

local function getDistanceBetween(p1, p2)
    return math.max(math.abs(p1.x - p2.x), math.abs(p1.y - p2.y))
end

function sortCreatures(creatures)
  local player = g_game.getLocalPlayer()
  
  if getSortType() == 'distance' then
    local playerPos = player:getPosition()
    table.sort(creatures, function(a, b) 
      if getDistanceBetween(playerPos, a:getPosition()) == getDistanceBetween(playerPos, b:getPosition()) then
        return ages[a:getId()] > ages[b:getId()]
      end
      return getDistanceBetween(playerPos, a:getPosition()) > getDistanceBetween(playerPos, b:getPosition()) 
    end)
  elseif getSortType() == 'health' then
    table.sort(creatures, function(a, b) 
      if a:getHealthPercent() == b:getHealthPercent() then
        return ages[a:getId()] > ages[b:getId()]
      end
      return a:getHealthPercent() > b:getHealthPercent() 
    end)
  elseif getSortType() == 'age' then
    table.sort(creatures, function(a, b) return ages[a:getId()] > ages[b:getId()] end)
  elseif getSortType() == 'screenage' then
    table.sort(creatures, function(a, b) return a.screenAge > b.screenAge end)
  else -- name
    table.sort(creatures, function(a, b)
      if a:getName():lower() == b:getName():lower() then
        return ages[a:getId()] > ages[b:getId()]
      end
      return a:getName():lower() > b:getName():lower() 
    end)
  end
end

-- other functions
function onBattleButtonMouseRelease(self, mousePosition, mouseButton)
  if mouseWidget.cancelNextRelease then
    mouseWidget.cancelNextRelease = false
    return false
  end
  if not self.creature then
    return false
  end
  if ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton)
    or (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
    mouseWidget.cancelNextRelease = true
    g_game.look(self.creature, true)
    return true
  elseif mouseButton == MouseLeftButton and g_keyboard.isShiftPressed() then
    g_game.look(self.creature, true)
    return true
  elseif mouseButton == MouseRightButton and not g_mouse.isPressed(MouseLeftButton) then
    modules.game_interface.createThingMenu(mousePosition, nil, nil, self.creature)
    return true
  elseif mouseButton == MouseLeftButton and not g_mouse.isPressed(MouseRightButton) then
    if self.isTarget then
      g_game.cancelAttack()
    else
      g_game.attack(self.creature)
    end
    return true
  end
  return false
end

function onBattleButtonHoverChange(battleButton, hovered)
  if not hovered then
    newHoveredCreature = nil    
  else
    newHoveredCreature = battleButton.creature
  end
  if battleButton.isHovered ~= hovered then
    battleButton.isHovered = hovered
    battleButton:update()
  end
  updateSquare()
end

function onPlayerPositionChange(creature, newPos, oldPos)
  addEvent(checkCreatures)
end

local CreatureButtonColors = {
  onIdle = {notHovered = '#888888', hovered = '#FFFFFF' },
  onTargeted = {notHovered = '#FF0000', hovered = '#FF8888' },
  onFollowed = {notHovered = '#00FF00', hovered = '#88FF88' }
}

function updateSquare()
  local following = g_game.getFollowingCreature()
  local attacking = g_game.getAttackingCreature()
    
  if newHoveredCreature == nil then
    if hoveredCreature ~= nil then
      hoveredCreature:hideStaticSquare()
      hoveredCreature = nil
    end
  else
    if hoveredCreature ~= nil then
      hoveredCreature:hideStaticSquare()
    end
    hoveredCreature = newHoveredCreature
    hoveredCreature:showStaticSquare(CreatureButtonColors.onIdle.hovered)
  end
  
  local color = CreatureButtonColors.onIdle
  local creature = nil
  if attacking then
    color = CreatureButtonColors.onTargeted
    creature = attacking
  elseif following then
    color = CreatureButtonColors.onFollowed
    creature = following
  end

  if prevCreature ~= creature then
    if prevCreature ~= nil then
      prevCreature:hideStaticSquare()
    end
    prevCreature = creature
  end
  
  if not creature then
    return
  end
  
  color = creature == hoveredCreature and color.hovered or color.notHovered
  creature:showStaticSquare(color)
end