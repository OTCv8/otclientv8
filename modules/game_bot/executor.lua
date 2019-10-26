function executeBot(config, storage, panel, msgCallback)
  local context = {}
  context.panel = panel
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
    onRemoveThing = {}
  }
  context.ui = {}

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
  
  -- UI
  context.setupUI = function(otml, parent)
    if parent == nil then      
      parent = context.panel
    end
    local widget = g_ui.loadUIFromString(otml, parent)
    if parent == context.panel and widget:getId() then
      context.ui[widget:getId()] = widget
    end
    return widget
  end
  
  context.addSwitch = function(id, text, onClickCallback)
    local switch = g_ui.createWidget('BotSwitch', context.panel)
    switch:setId(id)
    switch:setText(text)
    switch.onClick = onClickCallback
    context.ui[id] = switch
    return switch
  end
  
  context.addButton = function(id, text, onClickCallback)
    local button = g_ui.createWidget('BotButton', context.panel)
    button:setId(id)
    button:setText(text)
    button.onClick = onClickCallback
    context.ui[id] = button
    return button    
  end
  
  context.addLabel = function(id, text)
    local label = g_ui.createWidget('BotLabel', context.panel)
    label:setId(id)
    label:setText(text)
    context.ui[id] = label
    return label    
  end
  
  context.addSeparator = function(id)
    local separator = g_ui.createWidget('BotSeparator', context.panel)
    separator:setId(id)
    context.ui[id] = separator
    return separator    
  end
    
  context._addMacroSwitch = function(name, keys)
    local text = name
    if keys:len() > 0 then
      text = name .. " [" .. keys .. "]"
    end
    local switch = context.addSwitch("macro_" .. #context._macros, text, function(widget)
      context.storage._macros[name] = not context.storage._macros[name]
      widget:setOn(context.storage._macros[name])
    end)
    switch:setOn(context.storage._macros[name])
    return switch
  end
  
  context._addHotkeySwitch = function(name, keys)
    local text = name
    if keys:len() > 0 then
      text = name .. " [" .. keys .. "]"
    end
    local switch = context.addSwitch("hotkey_" .. #context._hotkeys, text, nil)
    switch:setOn(false)
    return switch
  end

  -- MAIN BOT FUNCTION
  -- macro(timeout, callback)
  -- macro(timeout, name, callback)
  -- macro(timeout, name, hotkey, callback)
  context.macro = function(timeout, name, hotkey, callback)
    if type(timeout) ~= 'number' or timeout < 1 then
      error("Invalid timeout for macro: " .. tostring(timeout))
    end
    if type(name) == 'function' then
      callback = name
      name = ""
      hotkey = ""
    elseif type(hotkey) == 'function' then
      callback = hotkey
      hotkey = ""
    elseif type(callback) ~= 'function' then
      error("Invalid callback for macro: " .. tostring(callback))
    end
    if type(name) ~= 'string' or type(hotkey) ~= 'string' then
      error("Invalid name or hotkey for macro")
    end
    if hotkey:len() > 0 then
      hotkey = retranslateKeyComboDesc(hotkey)
    end
    
    local switch = nil
    if name:len() > 0 then
      if context.storage._macros[name] == nil then
        context.storage._macros[name] = true
      end
      switch = context._addMacroSwitch(name, hotkey)
    end
    
    table.insert(context._macros, {
      timeout = timeout,
      name = name,
      callback = callback,
      lastExecution = context.now,
      hotkey = hotkey,
      switch = switch
    })
  end
  
  -- hotkey(keys, callback)
  -- hotkey(keys, name, callback)
  context.hotkey = function(keys, name, callback)
    if type(name) == 'function' then
      callback = name
      name = ""
    end
    keys = retranslateKeyComboDesc(keys)
    if not keys or #keys == 0 then
      return context.error("Invalid hotkey keys " .. tostring(name))
    end
    if context._hotkeys[keys] then
      return context.error("Duplicated hotkey: " .. keys)
    end

    local switch = nil
    if name:len() > 0 then
      switch = context._addHotkeySwitch(name, keys)
    end

    context._hotkeys[keys] = {
      name = name,
      callback = callback,
      lastExecution = context.now,
      switch = switch,
      single = false
    }
  end
  
  -- singlehotkey(keys, callback)
  -- singlehotkey(keys, name, callback)
  context.singlehotkey = function(keys, name, callback)
    if type(name) == 'function' then
      callback = name
      name = ""
    end
    keys = retranslateKeyComboDesc(keys)
    if not keys or #keys == 0 then
      return context.error("Invalid hotkey keys " .. tostring(name))
    end
    if context._hotkeys[keys] then
      return context.error("Duplicated hotkey: " .. keys)
    end

    local switch = nil
    if name:len() > 0 then
      switch = context._addHotkeySwitch(name, keys)
    end        

    context._hotkeys[keys] = {
      name = name,
      callback = callback,
      lastExecution = context.now,
      switch = switch,
      single = true
    }
  end  
  
  -- schedule(timeout, callback)
  context.schedule = function(timeout, callback)
    local extecute_time = g_clock.millis() + timeout
    table.insert(context._scheduler, {
      execution = extecute_time,
      callback = callback
    })
    table.sort(context._scheduler, function(a, b) return a.execution < b.execution end)
  end
  
  -- callback(callbackType, callback)
  context.callback = function(callbackType, callback)
    if not context._callbacks[callbackType] then
      return error("Wrong callback type: " .. callbackType)
    end
    if callbackType == "onAddThing" or callbackType == "onRemoveThing" then
      g_game.enableTileThingLuaCallback(true)
    end
    local callbackData = {}
    table.insert(context._callbacks[callbackType], function(...)
      if not callbackData.delay or callbackData.delay < context.now then
        context._currentExecution = callbackData       
        callback(...)
        context._currentExecution = nil
      end
    end)
  end
  
  -- onKeyDown(callback) -- callback = function(keys)
  context.onKeyDown = function(callback) 
    return context.callback("onKeyDown", callback)
  end

  -- onKeyPress(callback) -- callback = function(keys)
  context.onKeyPress = function(callback) 
    return context.callback("onKeyPress", callback)
  end
  
  -- onKeyUp(callback) -- callback = function(keys)
  context.onKeyUp = function(callback) 
    return context.callback("onKeyUp", callback)
  end
  
  -- onTalk(callback) -- callback = function(name, level, mode, text, channelId, pos)
  context.onTalk = function(callback) 
    return context.callback("onTalk", callback)
  end
  
  -- onAddThing(callback) -- callback = function(tile, thing)
  context.onAddThing = function(callback) 
    return context.callback("onAddThing", callback)
  end
  
  -- onRemoveThing(callback) -- callback = function(tile, thing)
  context.onRemoveThing = function(callback) 
    return context.callback("onRemoveThing", callback)
  end
  
  -- listen(name, callback) -- callback = function(text, channelId, pos)
  context.listen = function(name, callback)
    name = name:lower()
    context.onTalk(function(name2, level, mode, text, channelId, pos)
      if name == name2:lower() then
        callback(text, channelId, pos)
      end
    end)
  end
  
  -- delay(duration)
  context.delay = function(duration)
    if not context._currentExecution then
      return context.error("Invalid usage of delay function, it should be used inside callbacks")
    end
    context._currentExecution.delay = context.now + duration
  end

  -- init context
  context.now = g_clock.millis()
  context.time = g_clock.millis()
  context.player = g_game.getLocalPlayer()

  require("functions.lua")
  setupFunctions(context)
  
  -- run script
  assert(load(config, nil, nil, context))()

  return {
    script = function()      
      context.now = g_clock.millis()
      context.time = g_clock.millis()
      
      for i, macro in ipairs(context._macros) do
        if macro.lastExecution + macro.timeout <= context.now and (macro.name == nil or macro.name:len() < 1 or context.storage._macros[macro.name]) then
          if not macro.delay or macro.delay < context.now then
            macro.lastExecution = context.now
            context._currentExecution = context._macros[i]
            macro.callback()
            context._currentExecution = nil
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
            if not hotkey.delay or hotkey.delay < context.now then
              hotkey.lastExecution = context.now
              context._currentExecution = hotkey
              hotkey.callback()          
              context._currentExecution = nil
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
          if not hotkey.delay or hotkey.delay < context.now then
            hotkey.lastExecution = context.now
            context._currentExecution = hotkey
            hotkey.callback()
            context._currentExecution = nil
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
      end
    }    
  }
end