botWindow = nil
botButton = nil
contentsPanel = nil
editWindow = nil

local checkEvent = nil

local botStorage = {}
local botStorageFile = nil
local botWebSockets = {}
local botMessages = nil
local botTabs = nil
local botExecutor = nil

local configList = nil
local enableButton = nil
local executeEvent = nil
local statusLabel = nil

function init()
  dofile("executor")
  
  g_ui.importStyle("ui/basic.otui")
  g_ui.importStyle("ui/panels.otui")
  g_ui.importStyle("ui/config.otui")
  g_ui.importStyle("ui/icons.otui")
  g_ui.importStyle("ui/container.otui")
  
  connect(g_game, { 
    onGameStart = online, 
    onGameEnd = offline, 
  })
  
  initCallbacks()  
  
  botButton = modules.client_topmenu.addRightGameToggleButton('botButton', tr('Bot'), '/images/topbuttons/bot', toggle, false, 99999)
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
  botTabs:setContentWidget(contentsPanel.botPanel)  
  
  editWindow = g_ui.displayUI('edit')
  editWindow:hide()
    
  if g_game.isOnline() then
    clear()
    online()
  end
end

function terminate()
  save()
  clear()

  disconnect(g_game, { 
    onGameStart = online, 
    onGameEnd = offline, 
  })
  
  terminateCallbacks()
  editWindow:destroy()

  botWindow:destroy()
  botButton:destroy()   
end

function clear()
  botExecutor = nil
  removeEvent(checkEvent)

  -- optimization, callback is not used when not needed
  g_game.enableTileThingLuaCallback(false)

  botTabs:clearTabs()  
  botTabs:setOn(false)
  
  botMessages:destroyChildren()
  botMessages:updateLayout()
  
  for i, socket in pairs(botWebSockets) do
    g_http.cancel(socket)
    botWebSockets[i] = nil
  end

  for i, widget in pairs(g_ui.getRootWidget():getChildren()) do
    if widget.botWidget then
      widget:destroy()
    end
  end
  for i, widget in pairs(modules.game_interface.gameMapPanel:getChildren()) do
    if widget.botWidget then
      widget:destroy()
    end
  end
  
  local gameMapPanel = modules.game_interface.getMapPanel()
  if gameMapPanel then
    gameMapPanel:unlockVisibleFloor()   
  end
  
  if g_sounds then
    g_sounds.getChannel(SoundChannels.Bot):stop()
  end  
end


function refresh()
  if not g_game.isOnline() then return end
  save()
  clear()
  
  -- create bot dir
  if not g_resources.directoryExists("/bot") then
    g_resources.makeDir("/bot")
    if not g_resources.directoryExists("/bot") then
      return onError("Can't create bot directory in " .. g_resources.getWriteDir())
    end
  end
  
  -- get list of configs
  createDefaultConfigs()
  local configs = g_resources.listDirectoryFiles("/bot", false, false)  
  
  -- clean
  configList.onOptionChange = nil
  enableButton.onClick = nil
  configList:clearOptions()  
     
  -- select active config based on settings
  local settings = g_settings.getNode('bot') or {}
  local index = g_game.getCharacterName() .. "_" .. g_game.getClientVersion()
  if settings[index] == nil then
    settings[index] = {
      enabled=false,
      config=""
    }
  end  
  
  -- init list and buttons
  for i=1,#configs do 
    configList:addOption(configs[i])
  end
  configList:setCurrentOption(settings[index].config)
  if configList:getCurrentOption().text ~= settings[index].config then
    settings[index].config = configList:getCurrentOption().text
    settings[index].enabled = false
  end
  
  enableButton:setOn(settings[index].enabled)
  
  configList.onOptionChange = function(widget)
    settings[index].config = widget:getCurrentOption().text
    g_settings.setNode('bot', settings)
    g_settings.save()
    refresh()
  end
  
  enableButton.onClick = function(widget)
    settings[index].enabled = not settings[index].enabled
    g_settings.setNode('bot', settings)
    g_settings.save()
    refresh()    
  end
  
  if not g_game.isOnline() or not settings[index].enabled then
    statusLabel:setOn(true)
    statusLabel:setText("Status: disabled\nPress off button to enable")
    return
  end
  
  local configName = settings[index].config

  -- storage
  botStorage = {}
  botStorageFile = "/bot/" .. configName .. "/storage.json"
  if g_resources.fileExists(botStorageFile) then
    local status, result = pcall(function() 
      return json.decode(g_resources.readFileContents(botStorageFile)) 
    end)
    if not status then
      return onError("Error while reading storage (" .. botStorageFile .. "). To fix this problem you can delete storage.json. Details: " .. result)
    end
    botStorage = result
  end

  -- run script
  local status, result = pcall(function() 
    return executeBot(configName, botStorage, botTabs, message, save, refresh, botWebSockets) end
  )
  if not status then
    return onError(result)
  end
  
  statusLabel:setOn(false)
  botExecutor = result
  check()
end

function save()
  if not botExecutor then
    return
  end
  
  local settings = g_settings.getNode('bot') or {}
  local index = g_game.getCharacterName() .. "_" .. g_game.getClientVersion()
  if settings[index] == nil then
    return
  end
  
  local status, result = pcall(function() 
    return json.encode(botStorage, 2) 
  end)
  if not status then
    return onError("Error while saving bot storage. Storage won't be saved. Details: " .. result)
  end
  
  if result:len() > 100 * 1024 * 1024 then
    return onError("Storage file is too big, above 100MB, it won't be saved")
  end
  
  g_resources.writeFileContents(botStorageFile, result)
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
  scheduleEvent(refresh, 20)
end

function offline()
  save()
  clear()
  botButton:hide()
  editWindow:hide()
end

function onError(message)
  statusLabel:setOn(true)
  statusLabel:setText("Error:\n" .. message)
  g_logger.error("[BOT] " .. message)
end

function edit()
  editWindow:show()
  editWindow:focus()
  editWindow:raise()
end

function createDefaultConfigs()
  local defaultConfigFiles = g_resources.listDirectoryFiles("default_configs", false, false)
  for i, config_name in ipairs(defaultConfigFiles) do
    if not g_resources.directoryExists("/bot/" .. config_name) then
      g_resources.makeDir("/bot/" .. config_name)
      if not g_resources.directoryExists("/bot/" .. config_name) then
        return onError("Can't create /bot/" .. config_name .. " directory in " .. g_resources.getWriteDir())
      end
    end

    local defaultConfigFiles = g_resources.listDirectoryFiles("default_configs/" .. config_name, true, false)
    for i, file in ipairs(defaultConfigFiles) do
      local baseName = file:split("/")
      baseName = baseName[#baseName]
      if g_resources.directoryExists(file) then
        g_resources.makeDir("/bot/" .. config_name .. "/" .. baseName)
        if not g_resources.directoryExists("/bot/" .. config_name .. "/" .. baseName) then
          return onError("Can't create /bot/" .. config_name  .. "/" .. baseName .. " directory in " .. g_resources.getWriteDir())
        end
        local defaultConfigFiles2 = g_resources.listDirectoryFiles("default_configs/" .. config_name .. "/" .. baseName, true, false)
        for i, file in ipairs(defaultConfigFiles2) do
          local baseName2 = file:split("/")
          baseName2 = baseName2[#baseName2]
          local contents = g_resources.fileExists(file) and g_resources.readFileContents(file) or ""
          if contents:len() > 0 then
            g_resources.writeFileContents("/bot/" .. config_name .. "/" .. baseName .. "/" .. baseName2, contents)
          end  
        end
      else
        local contents = g_resources.fileExists(file) and g_resources.readFileContents(file) or ""
        if contents:len() > 0 then
          g_resources.writeFileContents("/bot/" .. config_name .. "/" .. baseName, contents)
        end
      end
    end
  end
end

-- Executor
function message(category, msg)
  local widget = g_ui.createWidget('BotLabel', botMessages)
  widget.added = g_clock.millis()
  if category == 'error' then
    widget:setText(msg)
    widget:setColor("red")
    g_logger.error("[BOT] " .. msg)
  elseif category == 'warn' then
    widget:setText(msg)        
    widget:setColor("yellow")
    g_logger.warning("[BOT] " .. msg)
  elseif category == 'info' then
    widget:setText(msg)        
    widget:setColor("white")
    g_logger.info("[BOT] " .. msg)
  end
  
  if botMessages:getChildCount() > 5 then
    botMessages:getFirstChild():destroy()
  end
end

function check()
  removeEvent(checkEvent)
  if not botExecutor then
    return
  end

  checkEvent = scheduleEvent(check, 25)  
  
  local status, result = pcall(function() 
    return botExecutor.script() 
  end)
  if not status then  
    botExecutor = nil -- critical
    return onError(result)
  end 
  
  -- remove old messages
  local widget = botMessages:getFirstChild()
  if widget and widget.added + 5000 < g_clock.millis() then
    widget:destroy()
  end
end

-- Callbacks
function initCallbacks()
  connect(rootWidget, {
    onKeyDown = botKeyDown,
    onKeyUp = botKeyUp,
    onKeyPress = botKeyPress 
  })

  connect(g_game, { 
    onTalk = botOnTalk,
    onTextMessage = botOnTextMessage,
    onUse = botOnUse,
    onUseWith = botOnUseWith,
    onChannelList = botChannelList,
    onOpenChannel = botOpenChannel,
    onCloseChannel = botCloseChannel,
    onChannelEvent = botChannelEvent
  })
  
  connect(Tile, {
    onAddThing = botAddThing,
    onRemoveThing = botRemoveThing 
  })

  connect(Creature, {
    onAppear = botCreatureAppear,
    onDisappear = botCreatureDisappear,
    onPositionChange = botCreaturePositionChange,
    onHealthPercentChange = botCraetureHealthPercentChange,
    onTurn = botCreatureTurn
  })  
  
  connect(LocalPlayer, {
    onPositionChange = botCreaturePositionChange,
    onHealthPercentChange = botCraetureHealthPercentChange
  })
  
  connect(Container, {
    onOpen = botContainerOpen,
    onClose = botContainerClose,
    onUpdateItem = botContainerUpdateItem 
  })
  
  connect(g_map, { 
    onMissle = botOnMissle,
    onAnimatedText = botOnAnimatedText,
    onStaticText = botOnStaticText
  })
end

function terminateCallbacks()
  disconnect(rootWidget, {
    onKeyDown = botKeyDown,
    onKeyUp = botKeyUp,
    onKeyPress = botKeyPress 
  })
                        
  disconnect(g_game, { 
    onTalk = botOnTalk,
    onTextMessage = botOnTextMessage,
    onUse = botOnUse,
    onUseWith = botOnUseWith,
    onChannelList = botChannelList,
    onOpenChannel = botOpenChannel,
    onCloseChannel = botCloseChannel,
    onChannelEvent = botChannelEvent
  })
  
  disconnect(Tile, {
    onAddThing = botAddThing,
    onRemoveThing = botRemoveThing 
  })

  disconnect(Creature, {
    onAppear = botCreatureAppear,
    onDisappear = botCreatureDisappear,
    onPositionChange = botCreaturePositionChange,
    onHealthPercentChange = botCraetureHealthPercentChange,
    onTurn = botCreatureTurn
  })  
  
  disconnect(LocalPlayer, {
    onPositionChange = botCreaturePositionChange,
    onHealthPercentChange = botCraetureHealthPercentChange
  })
  
  disconnect(Container, {
    onOpen = botContainerOpen,
    onClose = botContainerClose,
    onUpdateItem = botContainerUpdateItem 
  })
  
  disconnect(g_map, { 
    onMissle = botOnMissle,
    onAnimatedText = botOnAnimatedText,
    onStaticText = botOnStaticText
  })
end

function safeBotCall(func)
  local status, result = pcall(func)
  if not status then    
    onError(result)
  end
end

function botKeyDown(widget, keyCode, keyboardModifiers)
  if botExecutor == nil then return false end
  if keyCode == KeyUnknown then return end
  safeBotCall(function() botExecutor.callbacks.onKeyDown(keyCode, keyboardModifiers) end)
end

function botKeyUp(widget, keyCode, keyboardModifiers)
  if botExecutor == nil then return false end
  if keyCode == KeyUnknown then return end
  safeBotCall(function() botExecutor.callbacks.onKeyUp(keyCode, keyboardModifiers) end)
end

function botKeyPress(widget, keyCode, keyboardModifiers, autoRepeatTicks)
  if botExecutor == nil then return false end
  if keyCode == KeyUnknown then return end
  safeBotCall(function() botExecutor.callbacks.onKeyPress(keyCode, keyboardModifiers, autoRepeatTicks) end)
end

function botOnTalk(name, level, mode, text, channelId, pos)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onTalk(name, level, mode, text, channelId, pos) end)
end

function botOnTextMessage(mode, text)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onTextMessage(mode, text) end)
end

function botAddThing(tile, thing)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onAddThing(tile, thing) end)
end

function botRemoveThing(tile, thing)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onRemoveThing(tile, thing) end)
end

function botCreatureAppear(creature)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onCreatureAppear(creature) end)
end

function botCreatureDisappear(creature)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onCreatureDisappear(creature) end)
end

function botCreaturePositionChange(creature, newPos, oldPos)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onCreaturePositionChange(creature, newPos, oldPos) end)
end

function botCraetureHealthPercentChange(creature, healthPercent)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onCreatureHealthPercentChange(creature, healthPercent) end)
end

function botOnUse(pos, itemId, stackPos, subType)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onUse(pos, itemId, stackPos, subType) end)
end

function botOnUseWith(pos, itemId, target, subType)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onUseWith(pos, itemId, target, subType) end)
end

function botContainerOpen(container, previousContainer)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onContainerOpen(container, previousContainer) end)
end

function botContainerClose(container)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onContainerClose(container) end)
end

function botContainerUpdateItem(container, slot, item)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onContainerUpdateItem(container, slot, item) end)
end

function botOnMissle(missle)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onMissle(missle) end)
end

function botOnAnimatedText(thing, text)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onAnimatedText(thing, text) end)
end

function botOnStaticText(thing, text)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onStaticText(thing, text) end)
end

function botChannelList(channels)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onChannelList(channels) end)
end

function botOpenChannel(channelId, name)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onOpenChannel(channelId, name) end)
end

function botCloseChannel(channelId)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onCloseChannel(channelId) end)
end

function botChannelEvent(channelId, name, event)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onChannelEvent(channelId, name, event) end)
end

function botCreatureTurn(creature, direction)
  if botExecutor == nil then return false end
  safeBotCall(function() botExecutor.callbacks.onTurn(creature, direction) end)
end