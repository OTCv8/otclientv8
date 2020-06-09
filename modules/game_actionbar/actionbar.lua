actionPanel1 = nil
actionPanel2 = nil

local actionConfig
local hotkeyAssignWindow
local actionButtonsInPanel = 50

ActionTypes = {
  USE = 0,
  USE_SELF = 1,
  USE_TARGET = 2,
  USE_WITH = 3,
  EQUIP = 4
}

ActionColors = {
  empty = '#00000033',
  text = '#88888866',
  itemUse = '#8888FF66',
  itemUseSelf = '#00FF0066',
  itemUseTarget = '#FF000066',
  itemUseWith = '#F5B32566',
  itemEquip = '#FFFFFF66'
}

function init()
  local bottomPanel = modules.game_interface.getActionPanel()
  actionPanel1 = g_ui.loadUI('actionbar', bottomPanel)
  bottomPanel:moveChildToIndex(actionPanel1, 1)
  actionPanel2 = g_ui.loadUI('actionbar', bottomPanel)
  bottomPanel:moveChildToIndex(actionPanel2, 1)
  
  actionConfig = g_configs.create("/actionbar.otml")
    
  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onSpellGroupCooldown = onSpellGroupCooldown,
    onSpellCooldown = onSpellCooldown
  })
  
  if g_game.isOnline() then
    online()
  end
end

function terminate()
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onSpellGroupCooldown = onSpellGroupCooldown,
    onSpellCooldown = onSpellCooldown
  })  

  -- remove hotkeys, also saves config
  if actionPanel1.tabBar:getChildCount() > 0 and actionPanel2.tabBar:getChildCount() > 0 then
    offline()
  end
  
  actionPanel1:destroy()
  actionPanel2:destroy()
end

function show()
  if not g_game.isOnline() then return end
  actionPanel1:setOn(g_settings.getBoolean("actionBar1", false))
  actionPanel2:setOn(g_settings.getBoolean("actionBar2", false))
end

function hide()
  actionPanel1:setOn(false)
  actionPanel2:setOn(false)
end

function switchMode(newMode)
  if newMode then
    actionPanel1:setImageColor('#ffffff88')  
    actionPanel2:setImageColor('#ffffff88')  
  else
    actionPanel1:setImageColor('white')    
    actionPanel2:setImageColor('white')    
  end
end

function online()
  setupActionPanel(1, actionPanel1)
  setupActionPanel(2, actionPanel2)
  show()
end

function offline()
  hide()
  if hotkeyAssignWindow then
    hotkeyAssignWindow:destroy()
    hotkeyAssignWindow = nil
  end

  local gameRootPanel = modules.game_interface.getRootPanel()
  for index, panel in ipairs({actionPanel1, actionPanel2}) do
    local config = {}
    for i, child in ipairs(panel.tabBar:getChildren()) do
      if child.config then
        table.insert(config, child.config)
        if type(child.config.hotkey) == 'string' and child.config.hotkey:len() > 0 then
          g_keyboard.unbindKeyPress(child.config.hotkey, child.callback, gameRootPanel)
        end
      else
        table.insert(config, {})
      end
      if child.cooldownEvent then
        removeEvent(child.cooldownEvent)
      end
    end
    actionConfig:setNode('actions_' .. index, config)
    panel.tabBar:destroyChildren()
  end
  actionConfig:save()
end

function setupActionPanel(index, panel)
  local rawConfig = actionConfig:getNode('actions_' .. index) or {}
  local config = {}
  for i, buttonConfig in pairs(rawConfig) do -- sorting, because key in rawConfig is string
    config[tonumber(i)] = buttonConfig
  end
  
  for i=1,actionButtonsInPanel do
    local action = g_ui.createWidget('ActionButton', panel.tabBar)
    action.config = config[i] or {}
    setupAction(action)
  end  
  
  panel.nextButton.onClick = function()
    panel.tabBar:moveChildToIndex(panel.tabBar:getLastChild(), 1)  
  end
  panel.prevButton.onClick = function()
    panel.tabBar:moveChildToIndex(panel.tabBar:getFirstChild(), panel.tabBar:getChildCount())
  end
end

function setupAction(action)
  local config = action.config
  action.item:setShowCount(false)
  action.onMouseRelease = actionOnMouseRelease
  action.callback = function(k, c, ticks) executeAction(action, ticks) end
  action.item.onItemChange = nil -- disable callbacks for setup
  
  if config then
    if type(config.text) == 'number' then
      config.text = tostring(config.text)
    end
    if type(config.hotkey) == 'number' then
      config.hotkey = tostring(config.hotkey)
    end
    if type(config.hotkey) == 'string' and config.hotkey:len() > 0 then
      local gameRootPanel = modules.game_interface.getRootPanel()
      g_keyboard.bindKeyPress(config.hotkey, action.callback, gameRootPanel)
      action.hotkeyLabel:setText(config.hotkey)
    else
      action.hotkeyLabel:setText("")
    end

    action.text:setImageSource("")
    action.cooldownTill = 0
    action.cooldownStart = 0
    if type(config.text) == 'string' and config.text:len() > 0 then
      action.text:setText(config.text)
      action:setBorderColor(ActionColors.text)
      action.item:setOn(true) -- removes background
      action.item:setItemId(0)
      if Spells then
        local spell, profile = Spells.getSpellByWords(config.text:lower())
        action.spell = spell
        if action.spell and action.spell.icon and profile then
          action.text:setImageSource(SpelllistSettings[profile].iconFile)
          action.text:setImageClip(Spells.getImageClip(SpellIcons[action.spell.icon][1], profile))
          action.text:setText("")
        end
      end
    else      
      action.text:setText("")
      action.spell = nil
      if type(config.item) == 'number' and config.item > 100 then
        action.item:setOn(true)
        action.item:setItemId(config.item)
        action.item:setItemCount(config.count or 1)
        setupActionType(action, config.actionType)
      else
        action.item:setItemId(0)
        action.item:setOn(false)
        action:setBorderColor(ActionColors.empty)
      end    
    end
  end

  action.item.onItemChange = actionOnItemChange
end

function setupActionType(action, actionType)
  local item = action.item:getItem()
  if action.item:getItem():isMultiUse() then
    if not actionType or actionType <= ActionTypes.USE then
     actionType = ActionTypes.USE_WITH
    end
  elseif g_game.getClientVersion() >= 910 then
    if actionType ~= ActionTypes.USE and actionType ~= ActionTypes.EQUIP then
      actionType = ActionTypes.USE
    end
  else
    actionType = ActionTypes.USE
  end

  action.config.actionType = actionType
  if action.config.actionType == ActionTypes.USE then
    action:setBorderColor(ActionColors.itemUse)
  elseif action.config.actionType == ActionTypes.USE_SELF then
    action:setBorderColor(ActionColors.itemUseSelf)
  elseif action.config.actionType == ActionTypes.USE_TARGET then
    action:setBorderColor(ActionColors.itemUseTarget)
  elseif action.config.actionType == ActionTypes.USE_WITH then
    action:setBorderColor(ActionColors.itemUseWith)
  elseif action.config.actionType == ActionTypes.EQUIP then
    action:setBorderColor(ActionColors.itemEquip)
  end
end

function updateAction(action, newConfig)
  local config = action.config
  if type(config.hotkey) == 'string' and config.hotkey:len() > 0 then
    local gameRootPanel = modules.game_interface.getRootPanel()
    g_keyboard.unbindKeyPress(config.hotkey, action.callback, gameRootPanel)
  end
  for key, val in pairs(newConfig) do
    action.config[key] = val
  end
  setupAction(action)
end

function actionOnMouseRelease(action, mousePosition, mouseButton)
  if mouseButton == MouseRightButton or not action.item:isOn() then
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    if action.item:getItemId() > 0 then
      if action.item:getItem():isMultiUse() then
        menu:addOption(tr('Use on yourself'), function() return setupActionType(action, ActionTypes.USE_SELF) end)
        menu:addOption(tr('Use on target'), function() return setupActionType(action, ActionTypes.USE_TARGET) end)
        menu:addOption(tr('With crosshair'), function() return setupActionType(action, ActionTypes.USE_WITH) end)
      end
      if g_game.getClientVersion() >= 910 then
        if not action.item:getItem():isMultiUse() then
          menu:addOption(tr('Use'), function() return setupActionType(action, ActionTypes.USE) end)
        end
        menu:addOption(tr('Equip'), function() return setupActionType(action, ActionTypes.EQUIP) end)
      end
    else
      menu:addOption(tr('Select item'), function() return modules.game_itemselector.show(action.item) end)      
    end
    menu:addSeparator()
    menu:addOption(tr('Set text'), function() 
      modules.client_textedit.singlelineEditor(action.config.text or "", function(newText)
        updateAction(action, {text=newText, item=0})
      end)
    end)
    menu:addOption(tr('Set hotkey'), function()
      if hotkeyAssignWindow then
        hotkeyAssignWindow:destroy()
      end
      local assignWindow = g_ui.createWidget('ActionAssignWindow', rootWidget)
      assignWindow:grabKeyboard()
      assignWindow.comboPreview.keyCombo = ''
      assignWindow.onKeyDown = function(assignWindow, keyCode, keyboardModifiers)
        local keyCombo = determineKeyComboDesc(keyCode, keyboardModifiers)
        assignWindow.comboPreview:setText(tr('Current action hotkey: %s', keyCombo))
        assignWindow.comboPreview.keyCombo = keyCombo
        assignWindow.comboPreview:resizeToText()
        return true
      end
      assignWindow.onDestroy = function(widget)
        if widget == hotkeyAssignWindow then
          hotkeyAssignWindow = nil
        end
      end
      assignWindow.addButton.onClick = function()
        updateAction(action, {hotkey=tostring(assignWindow.comboPreview.keyCombo)})
        assignWindow:destroy()
      end
      hotkeyAssignWindow = assignWindow
    end)
    menu:addSeparator()
    menu:addOption(tr('Clear'), function()
      updateAction(action, {hotkey="", text="", item=0, count=1})
    end)
    menu:display(mousePosition)
    return true
  elseif mouseButton == MouseLeftButton then
    action.callback()
    return true
  end
  return false
end

function actionOnItemChange(widget)
  updateAction(widget:getParent(), {text="", item=widget:getItemId(), count=widget:getItemCountOrSubType()})
end

function onSpellCooldown(iconId, duration)
  for index, panel in ipairs({actionPanel1, actionPanel2}) do
    for i, child in ipairs(panel.tabBar:getChildren()) do
      if child.spell and child.spell.id == iconId then
        startCooldown(child, duration)
      end
    end
  end
end

function onSpellGroupCooldown(groupId, duration)
  for index, panel in ipairs({actionPanel1, actionPanel2}) do
    for i, child in ipairs(panel.tabBar:getChildren()) do
      if child.spell and child.spell.group then
        for group, duration in pairs(child.spell.group) do
          if groupId == group then
            startCooldown(child, duration)
          end
        end
      end
    end
  end
end

function startCooldown(action, duration)
  if type(action.cooldownTill) == 'number' and action.cooldownTill > g_clock.millis() + duration then
    return -- already has cooldown with greater duration
  end
  action.cooldownStart = g_clock.millis()
  action.cooldownTill = g_clock.millis() + duration
  updateCooldown(action)
end

function updateCooldown(action)
  if not action or not action.cooldownTill then return end
  local timeleft = action.cooldownTill - g_clock.millis()
  if timeleft <= 30 then
    action.cooldown:setPercent(100)
    action.cooldownEvent = nil    
    return
  end
  local duration = action.cooldownTill - action.cooldownStart
  action.cooldown:setPercent(100 - math.floor(100 * timeleft / duration))
  action.cooldownEvent = scheduleEvent(function() updateCooldown(action) end, 30)
end

function executeAction(action, ticks)
  if not action.config then return end
  if type(ticks) ~= 'number' then ticks = 0 end

  local actionDelay = 100  
  if ticks == 0 then
    actionDelay = 200 -- for first use
  elseif action.actionDelayTo ~= nil and g_clock.millis() < action.actionDelayTo then
    return
  end
  
  local actionType = action.config.actionType

  if type(action.config.text) == 'string' and action.config.text:len() > 0 then
    if g_app.isMobile() then -- turn to direction of targer
      local target = g_game.getAttackingCreature()
      if target then
        local pos = g_game.getLocalPlayer():getPosition()
        local tpos = target:getPosition()
        if pos and tpos then
          local offx = tpos.x - pos.x
          local offy = tpos.y - pos.y
          if offy < 0 and offx <= 0 and math.abs(offx) < math.abs(offy) then
            g_game.turn(Directions.North)
          elseif offy > 0 and offx >= 0 and math.abs(offx) < math.abs(offy) then
            g_game.turn(Directions.South)
          elseif offx < 0 and offy <= 0 and math.abs(offx) > math.abs(offy) then
            g_game.turn(Directions.West)
          elseif offx > 0 and offy >= 0 and math.abs(offx) > math.abs(offy) then
            g_game.turn(Directions.East)
          end
        end
      end
    end
    if modules.game_interface.isChatVisible() then
      modules.game_console.sendMessage(action.config.text)    
    else
      g_game.talk(action.config.text)
    end
    action.actionDelayTo = g_clock.millis() + actionDelay
  elseif action.item:getItemId() > 0 then    
    if actionType == ActionTypes.USE then
      if g_game.getClientVersion() < 780 then
        local item = g_game.findPlayerItem(action.item:getItemId(), action.item:getItemSubType() or -1)
        if item then
          g_game.use(item)
        end
      else
        g_game.useInventoryItem(action.item:getItemId())
      end
      action.actionDelayTo = g_clock.millis() + actionDelay
    elseif actionType == ActionTypes.USE_SELF then
      if g_game.getClientVersion() < 780 then
        local item = g_game.findPlayerItem(action.item:getItemId(), action.item:getItemSubType() or -1)
        if item then
          g_game.useWith(item, g_game.getLocalPlayer())
        end
      else
        g_game.useInventoryItemWith(action.item:getItemId(), g_game.getLocalPlayer(), action.item:getItemSubType() or -1)
      end
      action.actionDelayTo = g_clock.millis() + actionDelay
    elseif actionType == ActionTypes.USE_TARGET then
      local attackingCreature = g_game.getAttackingCreature()
      if not attackingCreature then
        local item = Item.create(action.item:getItemId())
        if g_game.getClientVersion() < 780 then
          local tmpItem = g_game.findPlayerItem(action.item:getItemId(), action.item:getItemSubType() or -1)
          if not tmpItem then return end
          item = tmpItem
        end

        modules.game_interface.startUseWith(item, action.item:getItemSubType() or - 1)
        return
      end

      if not attackingCreature:getTile() then return end
      if g_game.getClientVersion() < 780 then
        local item = g_game.findPlayerItem(action.item:getItemId(), action.item:getItemSubType() or -1)
        if item then
          g_game.useWith(item, attackingCreature, action.item:getItemSubType() or -1)
        end
      else
        g_game.useInventoryItemWith(action.item:getItemId(), attackingCreature, action.item:getItemSubType() or -1)
      end
      action.actionDelayTo = g_clock.millis() + actionDelay
    elseif actionType == ActionTypes.USE_WITH then
      local item = Item.create(action.item:getItemId())
      if g_game.getClientVersion() < 780 then
        local tmpItem = g_game.findPlayerItem(action.item:getItemId(), action.item:getItemSubType() or -1)
        if not tmpItem then return true end
        item = tmpItem
      end
      modules.game_interface.startUseWith(item, action.item:getItemSubType() or - 1)
    elseif actionType == ActionTypes.EQUIP then
      if g_game.getClientVersion() >= 910 then
        local item = Item.create(action.item:getItemId())
        g_game.equipItem(item)
        action.actionDelayTo = g_clock.millis() + actionDelay
      end
    end
  end
end