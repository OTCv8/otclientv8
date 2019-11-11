botWindow = nil
botButton = nil
botConfigFile = nil
botConfig = nil
contentsPanel = nil
configWindow = nil
configEditorText = nil
configList = nil
botTabs = nil
botPanel = nil
local botMessages = nil
local configCopy = ""
local enableButton = nil
local executeEvent = nil
local checkMsgsEvent = nil
local errorOccured = false
local statusLabel = nil
local compiledConfig = nil
local configTab = nil
local tabs = {"main", "panels", "macros", "hotkeys", "callbacks", "other"}
local mainTab = nil
local activeTab = nil
local editorText = {"", ""}

function init()
  dofile("defaultconfig")
  dofile("executor")
  
  g_ui.importStyle("ui/basic.otui")
  g_ui.importStyle("ui/panels.otui")
  
  connect(g_game, { 
    onGameStart = online, 
    onGameEnd = offline, 
    onTalk = botOnTalk,
    onUse = botOnUse,
    onUseWith = botOnUseWith,
    onChannelList = botChannelList,
    onOpenChannel = botOpenChannel,
    onCloseChannel = botCloseChannel,
    onChannelEvent = botChannelEvent
  })

  connect(rootWidget, { onKeyDown = botKeyDown,
                        onKeyUp = botKeyUp,
                        onKeyPress = botKeyPress })
                        
  connect(Tile, { onAddThing = botAddThing, onRemoveThing = botRemoveThing })

  connect(Creature, {
    onAppear = botCreatureAppear,
    onDisappear = botCreatureDisappear,
    onPositionChange = botCreaturePositionChange,
    onHealthPercentChange = botCraetureHealthPercentChange
  })  
  connect(LocalPlayer, {
    onPositionChange = botCreaturePositionChange,
    onHealthPercentChange = botCraetureHealthPercentChange
  })  
  connect(Container, { onOpen = botContainerOpen,
                       onClose = botContainerClose,
                       onUpdateItem = botContainerUpdateItem })
  connect(g_map, { onMissle = botOnMissle })
  
  botConfigFile = g_configs.create("/bot.otml")
  local config = botConfigFile:get("config")
  if config ~= nil and config:len() > 10 then
    local status, result = pcall(function() return json.decode(config) end)
    if not status then
      g_logger.error("Error: bot config parse error: " .. result .. "\n" .. config)
    end
    botConfig = result
  else
    botConfig = botDefaultConfig
  end
  
  botConfig.configs[1].name = botDefaultConfig.configs[1].name
  botConfig.configs[1].script = botDefaultConfig.configs[1].script

  botButton = modules.client_topmenu.addRightGameToggleButton('botButton',
    tr('Bot'), '/images/topbuttons/bot', toggle)
  botButton:setOn(false)
  botButton:hide()

  botWindow = g_ui.loadUI('bot', modules.game_interface.getLeftPanel())
  botWindow:setup()

  contentsPanel = botWindow.contentsPanel
  configList = contentsPanel.config
  enableButton = contentsPanel.enableButton
  statusLabel = contentsPanel.statusLabel
  botMessages = contentsPanel.messages 
  botTabs = contentsPanel.botTabs
  botPanel = contentsPanel.botPanel
  botTabs:setContentWidget(botPanel)  
  
  configWindow = g_ui.displayUI('config')
  configWindow:hide()
  
  configEditorText = configWindow.text
  configTab = configWindow.configTab
  
  configTab.onTabChange = editorTabChanged
  
  for i=1,#botConfig.configs do 
    if botConfig.configs[i].name ~= nil then
      configList:addOption(botConfig.configs[i].name)
    else
      configList:addOption("Config #" .. i)
    end
  end
  if type(botConfig.selectedConfig) == 'number' then
    configList:setCurrentIndex(botConfig.selectedConfig)
  end
  configList.onOptionChange = modules.game_bot.refreshConfig
  
  mainTab = configTab:addTab("all")
  for k, v in ipairs(tabs) do
    configTab:addTab(v, nil, nil)  
  end
  
  if g_game.isOnline() then
    online()
  end
end

function saveConfig()
  local status, result = pcall(function() 
    botConfigFile:set("config", json.encode(botConfig))
    botConfigFile:save()    
  end)
  if not status then    
    errorOccured = true
    -- try to fix it
    local extraInfo = ""
    for i = 1, #botConfig.configs do
      if botConfig.configs[i].storage then
        local status, result = pcall(function() json.encode(botConfig.configs[i].storage) end)
        if not status then
          botConfig.configs[i].storage = nil
          extraInfo = extraInfo .. "\nLocal storage of config " .. i .. " has been erased due to invalid data"
        end
      end
    end
    statusLabel:setText("Error while saving config and user storage:\n" .. result .. extraInfo .. "\n\n" .. "Try to restart bot")
    return false
  end
  return true
end

function terminate()
  saveConfig()
  clearConfig()

  disconnect(rootWidget, { onKeyDown = botKeyDown,
                        onKeyUp = botKeyUp,
                        onKeyPress = botKeyPress })

  disconnect(g_game, { 
    onGameStart = online, 
    onGameEnd = offline, 
    onTalk = botOnTalk,
    onUse = botOnUse,
    onUseWith = botOnUseWith,
    onChannelList = botChannelList,
    onOpenChannel = botOpenChannel,
    onCloseChannel = botCloseChannel,
    onChannelEvent = botChannelEvent
  })
  
  disconnect(Tile, { onAddThing = botAddThing, onRemoveThing = botRemoveThing })

  disconnect(Creature, {
    onAppear = botCreatureAppear,
    onDisappear =botCreatureDisappear,
    onPositionChange = botCreaturePositionChange,
    onHealthPercentChange = botCraetureHealthPercentChange
  })  
  disconnect(LocalPlayer, {
    onPositionChange = botCreaturePositionChange,
    onHealthPercentChange = botCraetureHealthPercentChange
  })  
  disconnect(Container, { onOpen = botContainerOpen,
                       onClose = botContainerClose,
                       onUpdateItem = botContainerUpdateItem })
  disconnect(g_map, { onMissle = botOnMissle })

  removeEvent(executeEvent)
  removeEvent(checkMsgsEvent)

  botWindow:destroy()
  botButton:destroy()  
  configWindow:destroy()
end

function onMiniWindowClose()
  botButton:setOn(false)
end

function toggle()
  if botButton:isOn() then
    botWindow:close()
    botButton:setOn(false)
  else
    botWindow:open()
    botButton:setOn(true)
  end
end

function online()
  botButton:show()
  updateEnabled()
  if botConfig.enabled then
    scheduleEvent(refreshConfig, 20)
  else 
    clearConfig()
  end
  if executeEvent == nil then
    executeEvent = scheduleEvent(executeConfig, 200)
    checkMsgsEvent = scheduleEvent(checkMsgs, 200)
  end
end

function offline()
  botButton:hide()
  configWindow:hide()
  clearConfig()
  removeEvent(executeEvent)
  removeEvent(checkMsgsEvent)
  executeEvent = nil
  checkMsgsEvent = nil
end

function toggleBot()
  botConfig.enabled = not botConfig.enabled
  if botConfig.enabled then
    refreshConfig()
  else 
    clearConfig()
  end
  updateEnabled()
end

function updateEnabled()
  if botConfig.enabled then
    enableButton:setText(tr('On'))
    enableButton:setColor('#00AA00FF')
  else
    enableButton:setText(tr('Off'))  
    enableButton:setColor('#FF0000FF')
    statusLabel:setText(tr("Status: disabled"))
  end
  errorOccured = false
end

function editConfig()
  local config = configList.currentIndex
  configWindow:show()
  configWindow:raise()
  configWindow:focus()
  editorText = {botConfig.configs[config].script or "", ""}
  if #editorText[1] <= 2 then
    editorText[1] = "--config name\n\n"
    for k, v in ipairs(tabs) do
      editorText[1] = editorText[1] .. "--#" .. v .. "\n\n"  
    end    
  end
  configEditorText:setText(editorText[1])
  configEditorText:setEditable(true)
  activeTab = mainTab
  configTab:selectTab(mainTab)
end

local function split2(str, delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( str, delimiter, from, true)
  if delim_from then
    table.insert( result, string.sub( str, from , delim_from - 1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( str, delimiter, from )
    table.insert( result, string.sub( str, from  ) )
  else
    table.insert(result, str)
    table.insert(result, "")
  end
  return result
end

function restoreMainTab()
  if activeTab == mainTab then
    editorText = {configEditorText:getText(), ""}
    return
  end
  local currentText = configEditorText:getText()
  if #currentText > 0 and currentText:sub(#currentText, #currentText) ~= '\n' then
    currentText = currentText .. '\n'
  end
  editorText = {editorText[1] .. "--#" .. activeTab:getText():lower() .. "\n" .. currentText .. editorText[2], ""}
  configEditorText:setText(editorText[1])
end

function editorTabChanged(holder, tab)
  if activeTab == tab then
    return
  end
  restoreMainTab()
  activeTab = tab
  if tab == mainTab then
    return
  end
  
  local splitted = split2(editorText[1], "--#" .. activeTab:getText():lower() .. "\n")
  local splitted2 = split2(splitted[2], "--#")
  if splitted2[2]:len() > 1 then
    splitted2[2] = "--#" .. splitted2[2]
  end
  editorText = {splitted[1], splitted2[2]}
  configEditorText:setText(splitted2[1])  
end

function saveEditedConfig()
  restoreMainTab()
  local config = configList.currentIndex
  local text = configEditorText:getText()
  configWindow:hide()
  botConfig.configs[config].script = text
  if text:len() > 3 and text:sub(1,2) == '--' and text:sub(3,3) ~= '#' then
    local delim_from, delim_to = string.find( text, "\n", 3, true)
    if delim_from then
      botConfig.configs[config].name = string.sub( text, 3 , delim_from - 1 ):trim()
      configList:updateCurrentOption(botConfig.configs[config].name)
    end
  end  
  refreshConfig()
end

function clearConfig()
  compiledConfig = nil
  
  botTabs:clearTabs()  
  botTabs:setOn(false)
  
  botMessages:destroyChildren()
  botMessages:updateLayout()

  for i, widget in pairs(g_ui.getRootWidget():getChildren()) do
    if widget.botWidget then
      widget:destroy()
    end
  end
  local gameMapPanel = modules.game_interface.getMapPanel()
  if gameMapPanel then
    gameMapPanel:unlockVisibleFloor()   
  end
  if g_sounds then
    local botSoundChannel = g_sounds.getChannel(SoundChannels.Bot)
    botSoundChannel:stop()
  end
end

function refreshConfig()
  configWindow:hide()
  
  botConfig.selectedConfig = configList.currentIndex
  if not botConfig.enabled then
    return
  end

  if not saveConfig() then
    clearConfig()
    return
  end
  
  clearConfig()

  local config = botConfig.configs[configList.currentIndex]
  if not config.storage then
    config.storage = {}
  end
  if config.script == nil or config.script:len() < 5 then
    errorOccured = true
    statusLabel:setText(tr("Error: empty config"))  
    return
  end
  errorOccured = false
  g_game.enableTileThingLuaCallback(false)
  local status, result = pcall(function() return executeBot(config.script, config.storage, botTabs, botMsgCallback, saveConfig) end)
  if not status then    
    errorOccured = true
    statusLabel:setText("Error: " .. tostring(result))
    return
  end
  compiledConfig = result
  statusLabel:setText(tr("Status: working"))
end

function executeConfig()
  executeEvent = scheduleEvent(executeConfig, 25)   
  if compiledConfig == nil then
    return
  end
  if not botConfig.enabled or errorOccured then
    if not errorOccured then
      statusLabel:setText(tr("Status: disabled"))
    end
    return
  end
  local status, result = pcall(function() return compiledConfig.script() end)
  if not status then    
    errorOccured = true
    statusLabel:setText("Error: " .. result)
    return
  end 
end

function botMsgCallback(category, msg)
  local widget = g_ui.createWidget('BotLabel', botMessages)
  widget.added = g_clock.millis()
  if category == 'error' then
    widget:setText(msg)
    widget:setColor("red")
  elseif category == 'warn' then
    widget:setText(msg)        
    widget:setColor("yellow")
  elseif category == 'info' then
    widget:setText(msg)        
    widget:setColor("white")
  end
  
  if botMessages:getChildCount() > 5 then
    botMessages:getFirstChild():destroy()
  end
end

function checkMsgs()
  checkMsgsEvent = scheduleEvent(checkMsgs, 200)  
  local widget = botMessages:getFirstChild()
  if widget and widget.added + 5000 < g_clock.millis() then
    widget:destroy()
  end
end

function safeBotCall(func)
  local status, result = pcall(func)
  if not status then    
    errorOccured = true
    statusLabel:setText("Error: " .. result)
  end
  return false
end

function botKeyDown(widget, keyCode, keyboardModifiers)
  if compiledConfig == nil then return false end
  if keyCode == KeyUnknown then return end
  safeBotCall(function() compiledConfig.callbacks.onKeyDown(keyCode, keyboardModifiers) end)
end

function botKeyUp(widget, keyCode, keyboardModifiers)
  if compiledConfig == nil then return false end
  if keyCode == KeyUnknown then return end
  safeBotCall(function() compiledConfig.callbacks.onKeyUp(keyCode, keyboardModifiers) end)
end

function botKeyPress(widget, keyCode, keyboardModifiers, autoRepeatTicks)
  if compiledConfig == nil then return false end
  if keyCode == KeyUnknown then return end
  safeBotCall(function() compiledConfig.callbacks.onKeyPress(keyCode, keyboardModifiers, autoRepeatTicks) end)
end

function botOnTalk(name, level, mode, text, channelId, pos)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onTalk(name, level, mode, text, channelId, pos) end)
end

function botAddThing(tile, thing)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onAddThing(tile, thing) end)
end

function botRemoveThing(tile, thing)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onRemoveThing(tile, thing) end)
end

function botCreatureAppear(creature)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onCreatureAppear(creature) end)
end

function botCreatureDisappear(creature)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onCreatureDisappear(creature) end)
end

function botCreaturePositionChange(creature, newPos, oldPos)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onCreaturePositionChange(creature, newPos, oldPos) end)
end

function botCraetureHealthPercentChange(creature, healthPercent)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onCreatureHealthPercentChange(creature, healthPercent) end)
end

function botOnUse(pos, itemId, stackPos, subType)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onUse(pos, itemId, stackPos, subType) end)
end

function botOnUseWith(pos, itemId, target, subType)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onUseWith(pos, itemId, target, subType) end)
end

function botContainerOpen(container, previousContainer)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onContainerOpen(container, previousContainer) end)
end

function botContainerClose(container)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onContainerClose(container) end)
end

function botContainerUpdateItem(container, slot, item)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onContainerUpdateItem(container, slot, item) end)
end

function botOnMissle(missle)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onMissle(missle) end)
end

function botOnMissle(missle)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onMissle(missle) end)
end

function botChannelList(channels)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onChannelList(channels) end)
end

function botOpenChannel(channelId, name)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onOpenChannel(channelId, name) end)
end

function botCloseChannel(channelId)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onCloseChannel(channelId) end)
end

function botChannelEvent(channelId, name, event)
  if compiledConfig == nil then return false end
  safeBotCall(function() compiledConfig.callbacks.onChannelEvent(channelId, name, event) end)
end
