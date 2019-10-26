botWindow = nil
botButton = nil
botConfigFile = nil
botConfig = nil
contentsPanel = nil
configWindow = nil
configEditorText = nil
configList = nil
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
local tabs = {"main", "macros", "hotkeys", "callbacks", "other"}
local mainTab = nil
local activeTab = nil
local editorText = {"", ""}

function init()
  dofile("defaultconfig")
  dofile("executor")
  
  connect(g_game, { onGameStart = online, onGameEnd = offline, onTalk = botOnTalk})

  connect(rootWidget, { onKeyDown = botKeyDown,
                        onKeyUp = botKeyUp,
                        onKeyPress = botKeyPress })
                        
  connect(Tile, { onAddThing = botAddThing, onRemoveThing = botRemoveThing })
  
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

  botButton = modules.client_topmenu.addRightGameToggleButton('botButton',
    tr('Bot'), '/images/topbuttons/bot', toggle)
  botButton:setOn(false)
  botButton:hide()

  botWindow = g_ui.loadUI('bot', modules.game_interface.getRightPanel())
  botWindow:setup()

  contentsPanel = botWindow:getChildById('contentsPanel')
  configList = contentsPanel:getChildById('config')
  enableButton = contentsPanel:getChildById('enableButton')
  statusLabel = contentsPanel:getChildById('statusLabel')
  botMessages = contentsPanel:getChildById('messages')
  botPanel = contentsPanel:getChildById('botPanel')

  configWindow = g_ui.displayUI('config')
  configWindow:hide()
  
  configEditorText = configWindow:getChildById('text')
  configTab = configWindow:getChildById('configTab')
  
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
  botConfigFile:set("config", json.encode(botConfig))
  botConfigFile:save()
end

function terminate()
  saveConfig()
  clearConfig()

  disconnect(rootWidget, { onKeyDown = botKeyDown,
                        onKeyUp = botKeyUp,
                        onKeyPress = botKeyPress })

  disconnect(g_game, { onGameStart = online, onGameEnd = offline, onTalk = botOnTalk})
  
  disconnect(Tile, { onAddThing = botAddThing, onRemoveThing = botRemoveThing })

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
    scheduleEvent(refreshConfig, 1)
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
  configEditorText:setText(botConfig.configs[config].script)
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
  editorText = {editorText[1] .. "--#" .. activeTab:getText():lower() .. "\n" .. configEditorText:getText() .. editorText[2], ""}
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
  botPanel:destroyChildren()
  botMessages:destroyChildren()
  botMessages:updateLayout()
end

function refreshConfig()
  clearConfig()
  configWindow:hide()
  
  botConfig.selectedConfig = configList.currentIndex
  if not botConfig.enabled then
    return
  end

  saveConfig()
  
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
  local status, result = pcall(function() return executeBot(config.script, config.storage, botPanel, botMsgCallback) end)
  if not status then    
    errorOccured = true
    statusLabel:setText(tr("Error: " .. tostring(result)))
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
    statusLabel:setText(tr("Error: " .. result))
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

function botKeyDown(widget, keyCode, keyboardModifiers)
  if keyCode == KeyUnknown or compiledConfig == nil then return false end
  local status, result = pcall(function() compiledConfig.callbacks.onKeyDown(keyCode, keyboardModifiers) end)
  if not status then    
    errorOccured = true
    statusLabel:setText(tr("Error: " .. result))
  end
  return false
end

function botKeyUp(widget, keyCode, keyboardModifiers)
  if keyCode == KeyUnknown or compiledConfig == nil then return false end
  local status, result = pcall(function() compiledConfig.callbacks.onKeyUp(keyCode, keyboardModifiers) end)
  if not status then    
    errorOccured = true
    statusLabel:setText(tr("Error: " .. result))
  end
  return false
end

function botKeyPress(widget, keyCode, keyboardModifiers, autoRepeatTicks)
  if keyCode == KeyUnknown or compiledConfig == nil then return false end
  local status, result = pcall(function() compiledConfig.callbacks.onKeyPress(keyCode, keyboardModifiers, autoRepeatTicks) end)
  if not status then    
    errorOccured = true
    statusLabel:setText(tr("Error: " .. result))
  end
  return false
end

function botOnTalk(name, level, mode, text, channelId, pos)
  if compiledConfig == nil then return false end
  local status, result = pcall(function() compiledConfig.callbacks.onTalk(name, level, mode, text, channelId, pos) end)
  if not status then    
    errorOccured = true
    statusLabel:setText(tr("Error: " .. result))
  end
  return false  
end

function botAddThing(tile, thing, asd)
  if compiledConfig == nil then return false end
  local status, result = pcall(function() compiledConfig.callbacks.onAddThing(tile, thing) end)
  if not status then    
    errorOccured = true
    statusLabel:setText(tr("Error: " .. result))
  end
  return false 
end

function botRemoveThing(tile, thing)
  if compiledConfig == nil then return false end
  local status, result = pcall(function() compiledConfig.callbacks.onRemoveThing(tile, thing) end)
  if not status then    
    errorOccured = true
    statusLabel:setText(tr("Error: " .. result))
  end
  return false
end