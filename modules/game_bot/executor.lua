function executeBot(config, storage, tabs, msgCallback)
  local context = {}
  context.tabs = tabs
  context.panel = context.tabs:addTab("Main", g_ui.createWidget('BotPanel')).tabPanel
  
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
    onCreatureHealthPercentChange = {}
  }

  -- basic functions & classes
  context.print = print
  context.pairs = pairs
  context.ipairs = ipairs
  context.tostring = tostring
  context.math = math
  context.table = table
  context.string = string
  context.tr = tr
  context.json = json
  context.regexMatch = regexMatch
  
  -- classes
  context.g_game = g_game
  context.g_map = g_map
  context.g_ui = g_ui
  context.StaticText = StaticText
  context.Position = Position
  context.HTTP = HTTP

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
          if macro.callback() then
              macro.lastExecution = context.now
          end
        end
      end
      
      while #context._scheduler > 0 and context._scheduler[1].execution <= g_clock.millis() do
        context._scheduler[1].callback()
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
      end
    }    
  }
end