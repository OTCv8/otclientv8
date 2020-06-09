HOTKEY_MANAGER_USE = nil
HOTKEY_MANAGER_USEONSELF = 1
HOTKEY_MANAGER_USEONTARGET = 2
HOTKEY_MANAGER_USEWITH = 3

HotkeyColors = {
  text = '#888888',
  textAutoSend = '#FFFFFF',
  itemUse = '#8888FF',
  itemUseSelf = '#00FF00',
  itemUseTarget = '#FF0000',
  itemUseWith = '#F5B325',
  extraAction = '#FFAA00'
}

hotkeysManagerLoaded = false
hotkeysWindow = nil
configSelector = nil
hotkeysButton = nil
currentHotkeyLabel = nil
currentItemPreview = nil
itemWidget = nil
addHotkeyButton = nil
removeHotkeyButton = nil
hotkeyText = nil
hotKeyTextLabel = nil
sendAutomatically = nil
selectObjectButton = nil
clearObjectButton = nil
useOnSelf = nil
useOnTarget = nil
useWith = nil
defaultComboKeys = nil
perCharacter = true
mouseGrabberWidget = nil
useRadioGroup = nil
currentHotkeys = nil
boundCombosCallback = {}
hotkeysList = {}
hotkeyConfigs = {}
currentConfig = 1
configValueChanged = false

-- public functions
function init()
  if not g_app.isMobile() then
    hotkeysButton = modules.client_topmenu.addLeftGameButton('hotkeysButton', tr('Hotkeys') .. ' (Ctrl+K)', '/images/topbuttons/hotkeys', toggle, false, 7)
  end
  g_keyboard.bindKeyDown('Ctrl+K', toggle)
  hotkeysWindow = g_ui.displayUI('hotkeys_manager')
  hotkeysWindow:setVisible(false)
  
  configSelector = hotkeysWindow:getChildById('configSelector')
  currentHotkeys = hotkeysWindow:getChildById('currentHotkeys')
  currentItemPreview = hotkeysWindow:getChildById('itemPreview')
  addHotkeyButton = hotkeysWindow:getChildById('addHotkeyButton')
  removeHotkeyButton = hotkeysWindow:getChildById('removeHotkeyButton')
  hotkeyText = hotkeysWindow:getChildById('hotkeyText')
  hotKeyTextLabel = hotkeysWindow:getChildById('hotKeyTextLabel')
  sendAutomatically = hotkeysWindow:getChildById('sendAutomatically')
  selectObjectButton = hotkeysWindow:getChildById('selectObjectButton')
  clearObjectButton = hotkeysWindow:getChildById('clearObjectButton')
  useOnSelf = hotkeysWindow:getChildById('useOnSelf')
  useOnTarget = hotkeysWindow:getChildById('useOnTarget')
  useWith = hotkeysWindow:getChildById('useWith')

  useRadioGroup = UIRadioGroup.create()
  useRadioGroup:addWidget(useOnSelf)
  useRadioGroup:addWidget(useOnTarget)
  useRadioGroup:addWidget(useWith)
  useRadioGroup.onSelectionChange = function(self, selected) onChangeUseType(selected) end

  mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)
  mouseGrabberWidget.onMouseRelease = onChooseItemMouseRelease

  currentHotkeys.onChildFocusChange = function(self, hotkeyLabel) onSelectHotkeyLabel(hotkeyLabel) end
  g_keyboard.bindKeyPress('Down', function() currentHotkeys:focusNextChild(KeyboardFocusReason) end, hotkeysWindow)
  g_keyboard.bindKeyPress('Up', function() currentHotkeys:focusPreviousChild(KeyboardFocusReason) end, hotkeysWindow)

  if hotkeysWindow.action and setupExtraHotkeys then
    setupExtraHotkeys(hotkeysWindow.action)
  end

  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline
  })  
  
  for i = 1, configSelector:getOptionsCount() do
    hotkeyConfigs[i] = g_configs.create("/hotkeys_" .. i .. ".otml")
  end

  load()
end

function terminate()
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline
  })

  g_keyboard.unbindKeyDown('Ctrl+K')

  unload()

  hotkeysWindow:destroy()
  if hotkeysButton then
    hotkeysButton:destroy()
  end
  mouseGrabberWidget:destroy()
end

function online()
  reload()
  hide()
end

function offline()
  unload()
  hide()
end

function show()
  if not g_game.isOnline() then
    return
  end
  hotkeysWindow:show()
  hotkeysWindow:raise()
  hotkeysWindow:focus()
end

function hide()
  hotkeysWindow:hide()
end

function toggle()
  if not hotkeysWindow:isVisible() then
    show()
  else
    hide()
  end
end

function ok()
  save()
  hide()
end

function cancel()
  reload()
  hide()
end

function load(forceDefaults)
  hotkeysManagerLoaded = false
  currentConfig = 1
  
  local hotkeysNode = g_settings.getNode('hotkeys') or {}
  local index = g_game.getCharacterName() .. "_" .. g_game.getClientVersion()
  if hotkeysNode[index] ~= nil and hotkeysNode[index] > 0 and hotkeysNode[index] <= #hotkeyConfigs then
    currentConfig = hotkeysNode[index]
  end  
  
  configSelector:setCurrentIndex(currentConfig, true)

  local hotkeySettings = hotkeyConfigs[currentConfig]:getNode('hotkeys')
  local hotkeys = {}

  if not table.empty(hotkeySettings) then hotkeys = hotkeySettings end

  hotkeyList = {}
  if not forceDefaults then
    if not table.empty(hotkeys) then
      for keyCombo, setting in pairs(hotkeys) do
        keyCombo = tostring(keyCombo)
        addKeyCombo(keyCombo, setting)
        hotkeyList[keyCombo] = setting
      end
    end
  end

  if currentHotkeys:getChildCount() == 0 then
    loadDefautComboKeys()
  end
  
  configValueChanged = false
  hotkeysManagerLoaded = true
end

function unload()
  local gameRootPanel = modules.game_interface.getRootPanel()
  for keyCombo,callback in pairs(boundCombosCallback) do
    g_keyboard.unbindKeyPress(keyCombo, callback, gameRootPanel)
  end
  boundCombosCallback = {}
  currentHotkeys:destroyChildren()
  currentHotkeyLabel = nil
  updateHotkeyForm(true)
  hotkeyList = {}
end

function reset()
  unload()
  load(true)
end

function reload()
  unload()
  load()
end

function save()
  if not configValueChanged then
    return
  end
  
  local hotkeySettings = hotkeyConfigs[currentConfig]:getNode('hotkeys') or {}  
  
  table.clear(hotkeySettings)

  for _,child in pairs(currentHotkeys:getChildren()) do
    hotkeySettings[child.keyCombo] = {
      autoSend = child.autoSend,
      itemId = child.itemId,
      subType = child.subType,
      useType = child.useType,
      value = child.value,
      action = child.action
    }
  end

  hotkeyList = hotkeySettings
  hotkeyConfigs[currentConfig]:setNode('hotkeys', hotkeySettings)
  hotkeyConfigs[currentConfig]:save()
  
  local index = g_game.getCharacterName() .. "_" .. g_game.getClientVersion()
  local hotkeysNode = g_settings.getNode('hotkeys') or {}
  hotkeysNode[index] = currentConfig
  g_settings.setNode('hotkeys', hotkeysNode)  
  g_settings.save()
end

function onConfigChange()
  if not configSelector then return end
  local index = g_game.getCharacterName() .. "_" .. g_game.getClientVersion()
  local hotkeysNode = g_settings.getNode('hotkeys') or {}
  hotkeysNode[index] = configSelector.currentIndex
  g_settings.setNode('hotkeys', hotkeysNode)  
  reload()  
end

function loadDefautComboKeys()
  if not defaultComboKeys then
    for i=1,12 do
      addKeyCombo('F' .. i)
    end
    for i=1,4 do
      addKeyCombo('Shift+F' .. i)
    end
  else
    for keyCombo, keySettings in pairs(defaultComboKeys) do
      addKeyCombo(keyCombo, keySettings)
    end
  end
end

function setDefaultComboKeys(combo)
  defaultComboKeys = combo
end

function onChooseItemMouseRelease(self, mousePosition, mouseButton)
  local item = nil
  if mouseButton == MouseLeftButton then
    local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIGameMap' then
        local tile = clickedWidget:getTile(mousePosition)
        if tile then
          local thing = tile:getTopMoveThing()
          if thing and thing:isItem() then
            item = thing
          end
        end
      elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        item = clickedWidget:getItem()
      end
    end
  end

  if item and currentHotkeyLabel then
    currentHotkeyLabel.itemId = item:getId()
    if item:isFluidContainer() then
        currentHotkeyLabel.subType = item:getSubType()
    end
    if item:isMultiUse() then
      currentHotkeyLabel.useType = HOTKEY_MANAGER_USEWITH
    else
      currentHotkeyLabel.useType = HOTKEY_MANAGER_USE
    end
    currentHotkeyLabel.value = nil
    currentHotkeyLabel.autoSend = false
    updateHotkeyLabel(currentHotkeyLabel)
    updateHotkeyForm(true)
  end

  show()

  g_mouse.popCursor('target')
  self:ungrabMouse()
  return true
end

function startChooseItem()
  if g_ui.isMouseGrabbed() then return end
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
  hide()
end

function clearObject()
  currentHotkeyLabel.action = nil
  currentHotkeyLabel.itemId = nil
  currentHotkeyLabel.subType = nil
  currentHotkeyLabel.useType = nil
  currentHotkeyLabel.autoSend = nil
  currentHotkeyLabel.value = nil
  updateHotkeyLabel(currentHotkeyLabel)
  updateHotkeyForm(true)
end

function addHotkey()
  local assignWindow = g_ui.createWidget('HotkeyAssignWindow', rootWidget)
  assignWindow:grabKeyboard()

  local comboLabel = assignWindow:getChildById('comboPreview')
  comboLabel.keyCombo = ''
  assignWindow.onKeyDown = hotkeyCapture
end

function addKeyCombo(keyCombo, keySettings, focus)
  if keyCombo == nil or #keyCombo == 0 then return end
  if not keyCombo then return end
  local hotkeyLabel = currentHotkeys:getChildById(keyCombo)
  if not hotkeyLabel then
    hotkeyLabel = g_ui.createWidget('HotkeyListLabel')
    hotkeyLabel:setId(keyCombo)

    local children = currentHotkeys:getChildren()
    children[#children+1] = hotkeyLabel
    table.sort(children, function(a,b)
      if a:getId():len() < b:getId():len() then
        return true
      elseif a:getId():len() == b:getId():len() then
        return a:getId() < b:getId()
      else
        return false
      end
    end)
    for i=1,#children do
      if children[i] == hotkeyLabel then
        currentHotkeys:insertChild(i, hotkeyLabel)
        break
      end
    end

    if keySettings then
      currentHotkeyLabel = hotkeyLabel
      hotkeyLabel.keyCombo = keyCombo
      hotkeyLabel.autoSend = toboolean(keySettings.autoSend)
      hotkeyLabel.action = keySettings.action
      hotkeyLabel.itemId = tonumber(keySettings.itemId)
      hotkeyLabel.subType = tonumber(keySettings.subType)
      hotkeyLabel.useType = tonumber(keySettings.useType)
      if keySettings.value then hotkeyLabel.value = tostring(keySettings.value) end
    else
      hotkeyLabel.keyCombo = keyCombo
      hotkeyLabel.autoSend = false
      hotkeyLabel.itemId = nil
      hotkeyLabel.subType = nil
      hotkeyLabel.useType = nil
      hotkeyLabel.action = nil
      hotkeyLabel.value = ''
    end

    updateHotkeyLabel(hotkeyLabel)

    local gameRootPanel = modules.game_interface.getRootPanel()
    if keyCombo:lower():find("ctrl") then
      if boundCombosCallback[keyCombo] then
        g_keyboard.unbindKeyPress(keyCombo, boundCombosCallback[keyCombo], gameRootPanel)      
      end
    end

    boundCombosCallback[keyCombo] = function(k, c, ticks) prepareKeyCombo(keyCombo, ticks) end
    g_keyboard.bindKeyPress(keyCombo, boundCombosCallback[keyCombo], gameRootPanel)
        
    if not keyCombo:lower():find("ctrl") then
      local keyComboCtrl = "Ctrl+" .. keyCombo
      if not boundCombosCallback[keyComboCtrl] then
        boundCombosCallback[keyComboCtrl] = function(k, c, ticks) prepareKeyCombo(keyComboCtrl, ticks) end
        g_keyboard.bindKeyPress(keyComboCtrl, boundCombosCallback[keyComboCtrl], gameRootPanel)   
      end
    end
  end

  if focus then
    currentHotkeys:focusChild(hotkeyLabel)
    currentHotkeys:ensureChildVisible(hotkeyLabel)
    updateHotkeyForm(true)
  end
  configValueChanged = true
end

function prepareKeyCombo(keyCombo, ticks)
    local hotKey = hotkeyList[keyCombo]
    if (keyCombo:lower():find("ctrl") and not hotKey) or (hotKey and hotKey.itemId == nil and (not hotKey.value or #hotKey.value == 0) and not hotKey.action) then
      keyCombo = keyCombo:gsub("Ctrl%+", "")
      keyCombo = keyCombo:gsub("ctrl%+", "")
      hotKey = hotkeyList[keyCombo]
    end
    if not hotKey then
      return
    end
    
    if hotKey.itemId == nil and hotKey.action == nil then -- say
      scheduleEvent(function() doKeyCombo(keyCombo, ticks >= 5) end, g_settings.getNumber('hotkeyDelay'))
    else
      doKeyCombo(keyCombo, ticks >= 5)
    end
end

function doKeyCombo(keyCombo, repeated)
  if not g_game.isOnline() then return end
  if modules.game_console and modules.game_console.isChatEnabled() then
    if keyCombo:len() == 1 then 
      return
    end
  end
  if modules.game_walking then
    modules.game_walking.checkTurn()
  end
  
  local hotKey = hotkeyList[keyCombo]
  if not hotKey then return end

  local hotkeyDelay = 100  
  if hotKey.hotkeyDelayTo == nil or g_clock.millis() > hotKey.hotkeyDelayTo + hotkeyDelay then
    hotkeyDelay = 200 -- for first use
  end
  if hotKey.hotkeyDelayTo ~= nil and g_clock.millis() < hotKey.hotkeyDelayTo then
    return
  end
  if hotKey.action then
    executeExtraHotkey(hotKey.action, repeated)  
  elseif hotKey.itemId == nil then
    if not hotKey.value or #hotKey.value == 0 then return end
    if hotKey.autoSend then
      modules.game_console.sendMessage(hotKey.value)
    else
      modules.game_console.setTextEditText(hotKey.value)
    end
    hotKey.hotkeyDelayTo = g_clock.millis() + hotkeyDelay
  elseif hotKey.useType == HOTKEY_MANAGER_USE then
    if g_game.getClientVersion() < 780 then
      local item = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
      if item then
        g_game.use(item)
      end
    else
      g_game.useInventoryItem(hotKey.itemId)
    end
    hotKey.hotkeyDelayTo = g_clock.millis() + hotkeyDelay
  elseif hotKey.useType == HOTKEY_MANAGER_USEONSELF then
    if g_game.getClientVersion() < 780 then
      local item = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
      if item then
        g_game.useWith(item, g_game.getLocalPlayer())
      end
    else
      g_game.useInventoryItemWith(hotKey.itemId, g_game.getLocalPlayer(), hotKey.subType or -1)
    end
    hotKey.hotkeyDelayTo = g_clock.millis() + hotkeyDelay
  elseif hotKey.useType == HOTKEY_MANAGER_USEONTARGET then
    local attackingCreature = g_game.getAttackingCreature()
    if not attackingCreature then
      local item = Item.create(hotKey.itemId)
      if g_game.getClientVersion() < 780 then
        local tmpItem = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
        if not tmpItem then return end
        item = tmpItem
      end

      modules.game_interface.startUseWith(item, hotKey.subType or - 1)
      return
    end

    if not attackingCreature:getTile() then return end
    if g_game.getClientVersion() < 780 then
      local item = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
      if item then
        g_game.useWith(item, attackingCreature, hotKey.subType or -1)
      end
    else
      g_game.useInventoryItemWith(hotKey.itemId, attackingCreature, hotKey.subType or -1)
    end
    hotKey.hotkeyDelayTo = g_clock.millis() + hotkeyDelay
  elseif hotKey.useType == HOTKEY_MANAGER_USEWITH then
    local item = Item.create(hotKey.itemId)
    if g_game.getClientVersion() < 780 then
      local tmpItem = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
      if not tmpItem then return true end
      item = tmpItem
    end
    modules.game_interface.startUseWith(item, hotKey.subType or - 1)
  end
end

function updateHotkeyLabel(hotkeyLabel)
  if not hotkeyLabel then return end
  if hotkeyLabel.action ~= nil then  
    hotkeyLabel:setText(tr('%s: (Action: %s)', hotkeyLabel.keyCombo, getActionDescription(hotkeyLabel.action)))
    hotkeyLabel:setColor(HotkeyColors.extraAction)    
  elseif hotkeyLabel.useType == HOTKEY_MANAGER_USEONSELF then
    hotkeyLabel:setText(tr('%s: (use object on yourself)', hotkeyLabel.keyCombo))
    hotkeyLabel:setColor(HotkeyColors.itemUseSelf)
  elseif hotkeyLabel.useType == HOTKEY_MANAGER_USEONTARGET then
    hotkeyLabel:setText(tr('%s: (use object on target)', hotkeyLabel.keyCombo))
    hotkeyLabel:setColor(HotkeyColors.itemUseTarget)
  elseif hotkeyLabel.useType == HOTKEY_MANAGER_USEWITH then
    hotkeyLabel:setText(tr('%s: (use object with crosshair)', hotkeyLabel.keyCombo))
    hotkeyLabel:setColor(HotkeyColors.itemUseWith)
  elseif hotkeyLabel.itemId ~= nil then
    hotkeyLabel:setText(tr('%s: (use object)', hotkeyLabel.keyCombo))
    hotkeyLabel:setColor(HotkeyColors.itemUse)
  else
    local text = hotkeyLabel.keyCombo .. ': '
    if hotkeyLabel.value then
      text = text .. hotkeyLabel.value
    end
    hotkeyLabel:setText(text)
    if hotkeyLabel.autoSend then
      hotkeyLabel:setColor(HotkeyColors.autoSend)
    else
      hotkeyLabel:setColor(HotkeyColors.text)
    end
  end
end

function updateHotkeyForm(reset)
  configValueChanged = true
  if hotkeysWindow.action then
    if currentHotkeyLabel then
      hotkeysWindow.action:enable()
      if currentHotkeyLabel.action then
        hotkeysWindow.action:setCurrentIndex(translateActionToActionComboboxIndex(currentHotkeyLabel.action), true)      
      else
        hotkeysWindow.action:setCurrentIndex(1, true)
      end
    else
      hotkeysWindow.action:disable()    
      hotkeysWindow.action:setCurrentIndex(1, true)
    end
  end
  local hasCustomAction = hotkeysWindow.action and hotkeysWindow.action.currentIndex > 1
  if currentHotkeyLabel and not hasCustomAction then
    removeHotkeyButton:enable()
    if currentHotkeyLabel.itemId ~= nil then
      hotkeyText:clearText()
      hotkeyText:disable()
      hotKeyTextLabel:disable()
      sendAutomatically:setChecked(false)
      sendAutomatically:disable()
      selectObjectButton:disable()
      clearObjectButton:enable()
      currentItemPreview:setItemId(currentHotkeyLabel.itemId)
      if currentHotkeyLabel.subType then
        currentItemPreview:setItemSubType(currentHotkeyLabel.subType)
      end
      if currentItemPreview:getItem():isMultiUse() then
        useOnSelf:enable()
        useOnTarget:enable()
        useWith:enable()
        if currentHotkeyLabel.useType == HOTKEY_MANAGER_USEONSELF then
          useRadioGroup:selectWidget(useOnSelf)
        elseif currentHotkeyLabel.useType == HOTKEY_MANAGER_USEONTARGET then
          useRadioGroup:selectWidget(useOnTarget)
        elseif currentHotkeyLabel.useType == HOTKEY_MANAGER_USEWITH then
          useRadioGroup:selectWidget(useWith)
        end
      else
        useOnSelf:disable()
        useOnTarget:disable()
        useWith:disable()
        useRadioGroup:clearSelected()
      end
    else
      useOnSelf:disable()
      useOnTarget:disable()
      useWith:disable()
      useRadioGroup:clearSelected()
      hotkeyText:enable()
      hotkeyText:focus()
      hotKeyTextLabel:enable()
      if reset then
        hotkeyText:setCursorPos(-1)
      end
      hotkeyText:setText(currentHotkeyLabel.value)
      sendAutomatically:setChecked(currentHotkeyLabel.autoSend)
      sendAutomatically:setEnabled(currentHotkeyLabel.value and #currentHotkeyLabel.value > 0)
      selectObjectButton:enable()
      clearObjectButton:disable()
      currentItemPreview:clearItem()
    end
  else
    removeHotkeyButton:disable()
    hotkeyText:disable()
    sendAutomatically:disable()
    selectObjectButton:disable()
    clearObjectButton:disable()
    useOnSelf:disable()
    useOnTarget:disable()
    useWith:disable()
    hotkeyText:clearText()
    useRadioGroup:clearSelected()
    sendAutomatically:setChecked(false)
    currentItemPreview:clearItem()
  end
end

function removeHotkey()
  if currentHotkeyLabel == nil then return end
  local gameRootPanel = modules.game_interface.getRootPanel()
  configValueChanged = true
  g_keyboard.unbindKeyPress(currentHotkeyLabel.keyCombo, boundCombosCallback[currentHotkeyLabel.keyCombo], gameRootPanel)
  boundCombosCallback[currentHotkeyLabel.keyCombo] = nil
  currentHotkeyLabel:destroy()
  currentHotkeyLabel = nil
end

function updateHotkeyAction()
  if not hotkeysManagerLoaded then return end
  if currentHotkeyLabel == nil then return end
  configValueChanged = true
  currentHotkeyLabel.action = translateActionComboboxIndexToAction(hotkeysWindow.action.currentIndex)
  updateHotkeyLabel(currentHotkeyLabel)
  updateHotkeyForm()
end

function onHotkeyTextChange(value)
  if not hotkeysManagerLoaded then return end
  if currentHotkeyLabel == nil then return end
  currentHotkeyLabel.value = value
  if value == '' then
    currentHotkeyLabel.autoSend = false
  end
  configValueChanged = true
  updateHotkeyLabel(currentHotkeyLabel)
  updateHotkeyForm()
end

function onSendAutomaticallyChange(autoSend)
  if not hotkeysManagerLoaded then return end
  if currentHotkeyLabel == nil then return end
  if not currentHotkeyLabel.value or #currentHotkeyLabel.value == 0 then return end
  configValueChanged = true
  currentHotkeyLabel.autoSend = autoSend
  updateHotkeyLabel(currentHotkeyLabel)
  updateHotkeyForm()
end

function onChangeUseType(useTypeWidget)
  if not hotkeysManagerLoaded then return end
  if currentHotkeyLabel == nil then return end
  configValueChanged = true
  if useTypeWidget == useOnSelf then
    currentHotkeyLabel.useType = HOTKEY_MANAGER_USEONSELF
  elseif useTypeWidget == useOnTarget then
    currentHotkeyLabel.useType = HOTKEY_MANAGER_USEONTARGET
  elseif useTypeWidget == useWith then
    currentHotkeyLabel.useType = HOTKEY_MANAGER_USEWITH
  else
    currentHotkeyLabel.useType = HOTKEY_MANAGER_USE
  end
  updateHotkeyLabel(currentHotkeyLabel)
  updateHotkeyForm()
end

function onSelectHotkeyLabel(hotkeyLabel)
  currentHotkeyLabel = hotkeyLabel
  updateHotkeyForm(true)
end

function hotkeyCapture(assignWindow, keyCode, keyboardModifiers)
  local keyCombo = determineKeyComboDesc(keyCode, keyboardModifiers)
  local comboPreview = assignWindow:getChildById('comboPreview')
  comboPreview:setText(tr('Current hotkey to add: %s', keyCombo))
  comboPreview.keyCombo = keyCombo
  comboPreview:resizeToText()
  assignWindow:getChildById('addButton'):enable()
  return true
end

function hotkeyCaptureOk(assignWindow, keyCombo)
  addKeyCombo(keyCombo, nil, true)
  assignWindow:destroy()
end
