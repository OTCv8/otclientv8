function executeBot(config, storage, tabs, msgCallback, saveConfigCallback, websockets)
  local context = {}
  context.tabs = tabs
  context.panel = context.tabs:addTab("Main", g_ui.createWidget('BotPanel')).tabPanel
  context.saveConfig = saveConfigCallback
  context._websockets = websockets
  
  context.storage = storage
  if context.storage._macros == nil then
    context.storage._macros = {} -- active macros
  end

  -- 
  context._macros = {}
  context._hotkeys = {}
  context._scheduler = {}
  context._callbacks = {
    onKeyDown = {},
    onKeyUp = {},
    onKeyPress = {},
    onTalk = {},
    onAddThing = {},
    onRemoveThing = {},
    onCreatureAppear = {},
    onCreatureDisappear = {},
    onCreaturePositionChange = {},
    onCreatureHealthPercentChange = {},
    onUse = {},
    onUseWith = {},
    onContainerOpen = {},
    onContainerClose = {},
    onContainerUpdateItem = {},
    onMissle = {},
    onChannelList = {},
    onOpenChannel = {},
    onCloseChannel = {},
    onChannelEvent = {}
  }
  
  -- basic functions & classes
  context.print = print
  context.pairs = pairs
  context.ipairs = ipairs
  context.tostring = tostring
  context.math = math
  context.table = table
  context.string = string
  context.tonumber = tonumber
  context.tr = tr
  context.json = json
  context.regexMatch = regexMatch
  context.getDistanceBetween = function(p1, p2)
    return math.max(math.abs(p1.x - p2.x), math.abs(p1.y - p2.y))
  end
  
  -- classes
  context.g_resources = g_resources
  context.g_game = g_game
  context.g_map = g_map
  context.g_ui = g_ui
  context.g_platform = g_platform
  context.g_sounds = g_sounds
  context.g_window = g_window
  context.g_mouse = g_mouse

  context.StaticText = StaticText
  context.Config = Config
  context.HTTP = HTTP
  context.modules = modules

  -- log functions
  context.info = function(text) return msgCallback("info", tostring(text)) end
  context.warn = function(text) return msgCallback("warn", tostring(text)) end
  context.error = function(text) return msgCallback("error", tostring(text)) end
  context.warning = context.warn      

  -- init context
  context.now = g_clock.millis()
  context.time = g_clock.millis()
  context.player = g_game.getLocalPlayer()

  -- init functions
  G.botContext = context
  dofiles("functions")
  context.Panels = {}
  dofiles("panels")
  G.botContext = nil

  -- run script
  assert(load(config, nil, nil, context))()

  return {
    script = function()      
      context.now = g_clock.millis()
      context.time = g_clock.millis()
      
      for i, macro in ipairs(context._macros) do
        if macro.lastExecution + macro.timeout <= context.now and (macro.name == nil or macro.name:len() < 1 or context.storage._macros[macro.name]) then
          local status, result = pcall(function()
            if macro.callback() then
                macro.lastExecution = context.now
            end
          end)
          if not status then
            context.error("Macro: " .. macro.name .. " execution error: " .. result)
          end
        end
      end
      
      while #context._scheduler > 0 and context._scheduler[1].execution <= g_clock.millis() do
        local status, result = pcall(function()
          context._scheduler[1].callback()
        end)
        if not status then
          context.error("Schedule execution error: " .. result)
        end
        table.remove(context._scheduler, 1)
      end
    end,
    callbacks = {
      onKeyDown = function(keyCode, keyboardModifiers)
        local keyDesc = determineKeyComboDesc(keyCode, keyboardModifiers)
        for i, macro in ipairs(context._macros) do
          if macro.switch and macro.hotkey == keyDesc then
            macro.switch:onClick()
          end
        end
        local hotkey = context._hotkeys[keyDesc]
        if hotkey then
          if hotkey.single then
            if hotkey.callback() then
              hotkey.lastExecution = context.now            
            end
          end
          if hotkey.switch then
            hotkey.switch:setOn(true)
          end
        end
        for i, callback in ipairs(context._callbacks.onKeyDown) do
          callback(keyDesc)
        end
      end,
      onKeyUp = function(keyCode, keyboardModifiers)
        local keyDesc = determineKeyComboDesc(keyCode, keyboardModifiers)
        local hotkey = context._hotkeys[keyDesc]
        if hotkey then        
          if hotkey.switch then
            hotkey.switch:setOn(false)
          end
        end
        for i, callback in ipairs(context._callbacks.onKeyUp) do
          callback(keyDesc)
        end
      end,
      onKeyPress = function(keyCode, keyboardModifiers, autoRepeatTicks)
        local keyDesc = determineKeyComboDesc(keyCode, keyboardModifiers)
        local hotkey = context._hotkeys[keyDesc]
        if hotkey and not hotkey.single then
          if hotkey.callback() then
            hotkey.lastExecution = context.now          
          end
        end
        for i, callback in ipairs(context._callbacks.onKeyPress) do
          callback(keyDesc, autoRepeatTicks)
        end
      end,
      onTalk = function(name, level, mode, text, channelId, pos)
        for i, callback in ipairs(context._callbacks.onTalk) do
          callback(name, level, mode, text, channelId, pos)
        end
      end,
      onAddThing = function(tile, thing)
        for i, callback in ipairs(context._callbacks.onAddThing) do
          callback(tile, thing)
        end      
      end,
      onRemoveThing = function(tile, thing)
        for i, callback in ipairs(context._callbacks.onRemoveThing) do
          callback(tile, thing)
        end      
      end,
      onCreatureAppear = function(creature)
        for i, callback in ipairs(context._callbacks.onCreatureAppear) do
          callback(creature)
        end      
      end,
      onCreatureDisappear = function(creature)
        for i, callback in ipairs(context._callbacks.onCreatureDisappear) do
          callback(creature)
        end
      end,
      onCreaturePositionChange = function(creature, newPos, oldPos)
        for i, callback in ipairs(context._callbacks.onCreaturePositionChange) do
          callback(creature, newPos, oldPos)
        end      
      end,
      onCreatureHealthPercentChange = function(creature, healthPercent)
        for i, callback in ipairs(context._callbacks.onCreatureHealthPercentChange) do
          callback(creature, healthPercent)
        end      
      end,
      onUse = function(pos, itemId, stackPos, subType)
        for i, callback in ipairs(context._callbacks.onUse) do
          callback(pos, itemId, stackPos, subType)
        end      
      end,
      onUseWith = function(pos, itemId, target, subType)
        for i, callback in ipairs(context._callbacks.onUseWith) do
          callback(pos, itemId, target, subType)
        end
      end,
      onContainerOpen = function(container, previousContainer)
        for i, callback in ipairs(context._callbacks.onContainerOpen) do
          callback(container, previousContainer)
        end
      end,
      onContainerClose = function(container)
        for i, callback in ipairs(context._callbacks.onContainerClose) do
          callback(container)
        end
      end,
      onContainerUpdateItem = function(container, slot, item)
        for i, callback in ipairs(context._callbacks.onContainerUpdateItem) do
          callback(container, slot, item)
        end
      end,
      onMissle = function(missle)
        for i, callback in ipairs(context._callbacks.onMissle) do
          callback(missle)
        end
      end,
      onChannelList = function(channels)
        for i, callback in ipairs(context._callbacks.onChannelList) do
          callback(channels)
        end      
      end,
      onOpenChannel = function(channelId, channelName)
        for i, callback in ipairs(context._callbacks.onOpenChannel) do
          callback(channels)
        end      
      end,
      onCloseChannel = function(channelId)
        for i, callback in ipairs(context._callbacks.onCloseChannel) do
          callback(channelId)
        end      
      end,
      onChannelEvent = function(channelId, name, event)
        for i, callback in ipairs(context._callbacks.onChannelEvent) do
          callback(channelId, name, event)
        end      
      end,
    }    
  }
end