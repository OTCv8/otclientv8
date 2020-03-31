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
  local bottomPanel = modules.game_interface.getBottomPanel()
  actionPanel1 = g_ui.loadUI('actionbar', bottomPanel)
  bottomPanel:moveChildToIndex(actionPanel1, 1)
  actionPanel2 = g_ui.loadUI('actionbar', bottomPanel)
  bottomPanel:moveChildToIndex(actionPanel2, 1)
  
  actionConfig = g_configs.create("/actionbar.otml")
    
  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline
  })  
  
  if g_game.isOnline() then
    online()
  end
end

function terminate()
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline
  })  

  saveConfig()

  -- remove hotkeys
  offline()

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
  saveConfig()
  
  for index, panel in ipairs({actionPanel1, actionPanel2}) do
    for i, child in ipairs(panel.tabBar:getChildren()) do
      local gameRootPanel = modules.game_interface.getRootPanel()
      if child.hotkey then
        g_keyboard.unbindKeyPress(child.hotkey, child.callback, gameRootPanel)
      end
    end
  end
end

function setupActionPanel(index, panel)
  local rawConfig = actionConfig:getNode('actions_' .. index) or {}
  local config = {}
  for i, buttonConfig in pairs(rawConfig) do -- sorting, because key in rawConfig is string
    config[tonumber(i)] = buttonConfig
  end
  panel.tabBar:destroyChildren()
  for i=1,actionButtonsInPanel do
    local action = g_ui.createWidget('ActionButton', panel.tabBar)
    setupAction(index, action, config[i])
  end  
  
  panel.nextButton.onClick = function()
    panel.tabBar:moveChildToIndex(panel.tabBar:getLastChild(), 1)  
  end
  panel.prevButton.onClick = function()
    panel.tabBar:moveChildToIndex(panel.tabBar:getFirstChild(), panel.tabBar:getChildCount())
  end
end

function saveConfig()
  for index, panel in ipairs({actionPanel1, actionPanel2}) do
    local config = {}
    for i, child in ipairs(panel.tabBar:getChildren()) do
      table.insert(config, {
        text = child.text:getText(),
        item = child.item:getItemId(),
        count = child.item:getItemCount(),
        action = child.actionType,
        hotkey = child.hotkey
      })
    end
    actionConfig:setNode('actions_' .. index, config)
  end
  actionConfig:save()
end

function setupAction(index, action, config)
  action.item:setShowCount(false)
  action.onMouseRelease = actionOnMouseRelease
  action.callback = function(k, c, ticks) executeAction(action, ticks) end

  if config then
    if type(config.text) == 'number' then
      config.text = tostring(config.text)
    end
    if type(config.hotkey) == 'number' then
      config.hotkey = tostring(config.hotkey)
    end
    action.hotkey = config.hotkey
    if type(action.hotkey) == 'string' and action.hotkey:len() > 0 then
      local gameRootPanel = modules.game_interface.getRootPanel()
      g_keyboard.bindKeyPress(action.hotkey, action.callback, gameRootPanel)
    end
    action.hotkeyLabel:setText(action.hotkey or "")
    action.text:setText(config.text)
    if action.text:getText():len() > 0 then
      action:setBorderColor(ActionColors.text)
    end
    if config.item > 0 then
      setupActionType(action, config.action)
    end
    action.item:setOn(config.item > 0)
    action.item:setItemId(config.item)
    action.item:setItemCount(config.count)
  end

  action.item.onItemChange = actionOnItemChange
end

function setupActionType(action, actionType)
  action.actionType = actionType
  if action.actionType == ActionTypes.USE then
    action:setBorderColor(ActionColors.itemUse)
  elseif action.actionType == ActionTypes.USE_SELF then
    action:setBorderColor(ActionColors.itemUseSelf)
  elseif action.actionType == ActionTypes.USE_TARGET then
    action:setBorderColor(ActionColors.itemUseTarget)
  elseif action.actionType == ActionTypes.USE_WITH then
    action:setBorderColor(ActionColors.itemUseWith)
  elseif action.actionType == ActionTypes.EQUIP then
    action:setBorderColor(ActionColors.itemEquip)
  end
end

function executeAction(action, ticks)
  if type(ticks) ~= 'number' then ticks = 0 end

  local actionDelay = 100  
  if ticks == 0 then
    actionDelay = 200 -- for first use
  elseif action.actionDelayTo ~= nil and g_clock.millis() < action.actionDelayTo then
    return
  end

  if action.text:getText():len() > 0 then
    modules.game_console.sendMessage(action.text:getText())
    action.actionDelayTo = g_clock.millis() + actionDelay
  elseif action.item:getItemId() > 0 then    
    if action.actionType == ActionTypes.USE then
      if g_game.getClientVersion() < 740 then
        local item = g_game.findPlayerItem(action.item:getItemId(), hotKey.subType or -1)
        if item then
          g_game.use(item)
        end
      else
        g_game.useInventoryItem(action.item:getItemId())
      end
      action.actionDelayTo = g_clock.millis() + actionDelay
    elseif action.actionType == ActionTypes.USE_SELF then
      if g_game.getClientVersion() < 740 then
        local item = g_game.findPlayerItem(action.item:getItemId(), hotKey.subType or -1)
        if item then
          g_game.useWith(item, g_game.getLocalPlayer())
        end
      else
        g_game.useInventoryItemWith(action.item:getItemId(), g_game.getLocalPlayer(), action.item:getItemSubType() or -1)
      end
      action.actionDelayTo = g_clock.millis() + actionDelay
    elseif action.actionType == ActionTypes.USE_TARGET then
      local attackingCreature = g_game.getAttackingCreature()
      if not attackingCreature then
        local item = Item.create(action.item:getItemId())
        if g_game.getClientVersion() < 740 then
          local tmpItem = g_game.findPlayerItem(action.item:getItemId(), action.item:getItemSubType() or -1)
          if not tmpItem then return end
          item = tmpItem
        end

        modules.game_interface.startUseWith(item, action.item:getItemSubType() or - 1)
        return
      end

      if not attackingCreature:getTile() then return end
      if g_game.getClientVersion() < 740 then
        local item = g_game.findPlayerItem(action.item:getItemId(), action.item:getItemSubType() or -1)
        if item then
          g_game.useWith(item, attackingCreature, action.item:getItemSubType() or -1)
        end
      else
        g_game.useInventoryItemWith(action.item:getItemId(), attackingCreature, action.item:getItemSubType() or -1)
      end
      action.actionDelayTo = g_clock.millis() + actionDelay
    elseif action.actionType == ActionTypes.USE_WITH then
      local item = Item.create(action.item:getItemId())
      if g_game.getClientVersion() < 740 then
        local tmpItem = g_game.findPlayerItem(action.item:getItemId(), action.item:getItemSubType() or -1)
        if not tmpItem then return true end
        item = tmpItem
      end
      modules.game_interface.startUseWith(item, action.item:getItemSubType() or - 1)
    elseif action.actionType == ActionTypes.EQUIP then
      if g_game.getClientVersion() >= 910 then
        local item = Item.create(action.item:getItemId())
        g_game.equipItem(item)
        action.actionDelayTo = g_clock.millis() + actionDelay
      end
    end
  end
end

function actionOnMouseRelease(action, mousePosition, mouseButton)
  if mouseButton == MouseRightButton then
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
    end
    menu:addSeparator()
    menu:addOption(tr('Set text'), function() 
      modules.game_textedit.singlelineEditor(action.text:getText(), function(newText)
        action.item:setOn(false)
        action.item:setItemId(0)
        action.text:setText(newText)
        if action.text:getText():len() > 0 then
          action:setBorderColor(ActionColors.text)
        end
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
      assignWindow.onDestroy = function()
        hotkeyAssignWindow = nil
      end
      assignWindow.addButton.onClick = function()
        local gameRootPanel = modules.game_interface.getRootPanel()
        if action.hotkey and action.hotkey:len() > 0 then
          g_keyboard.unbindKeyPress(action.hotkey, action.callback, gameRootPanel)
        end
        action.hotkey = tostring(assignWindow.comboPreview.keyCombo)
        if action.hotkey and action.hotkey:len() > 0 then
          g_keyboard.bindKeyPress(action.hotkey, action.callback, gameRootPanel)
        end
        action.hotkeyLabel:setText(action.hotkey or "")
        assignWindow:destroy()
      end
      hotkeyAssignWindow = assignWindow
    end)
    menu:addSeparator()
    menu:addOption(tr('Clear'), function()
      action.item:setItem(nil)
      action.text:setText("")
      action.hotkeyLabel:setText("")
      local gameRootPanel = modules.game_interface.getRootPanel()
      if action.hotkey and action.hotkey:len() > 0 then
        g_keyboard.unbindKeyPress(action.hotkey, action.callback, gameRootPanel)
      end
      action.hotkey = nil
      action.actionType = nil
      action:setBorderColor(ActionColors.empty)
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
  local action = widget:getParent()
  if action.item:getItemId() > 0 then
    action.text:setText("")
    action.item:setOn(true)
    if action.item:getItem():isMultiUse() then
      if not action.actionType or action.actionType <= 1 then
        setupActionType(action, ActionTypes.USE_WITH)
      end
    else
      if g_game.getClientVersion() >= 910 then
        if not action.actionType or action.actionType <= ActionTypes.EQUIP then
          setupActionType(action, ActionTypes.USE)
        end
      else
        setupActionType(action, ActionTypes.USE)      
      end
    end
  end
end