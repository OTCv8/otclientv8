function executeBot(config, storage, panel, msg)
  local context = {}
  context.panel = panel
  context.storage = storage
  if context.storage.macros == nil then
    context.storage.macros = {} -- active macros
  end

  -- 
  context.macros = {}
  context.hotkeys = {}
  context.scheduler = {}
  context.callbacks = {
    onKeyDown = {},
    onKeyUp = {},
    onKeyPress = {},
    onTalk = {},
  }
  context.ui = {}

  -- basic functions
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

  -- game functions
  context.say = g_game.talk
  context.talk = g_game.talk
  context.talkPrivate = context.talkPrivate
  context.sayPrivate = context.talkPrivate
  context.use = g_game.useInventoryItem
  context.usewith = g_game.useInventoryItemWith
  context.useWith = g_game.useInventoryItemWith
  context.findItem = g_game.findItemInContainers
  
  -- classes
  context.g_game = g_game
  context.g_map = g_map
  context.StaticText = StaticText
  context.HTTP = HTTP

  -- log functions
  context.info = function(text) return msg("info", text) end
  context.warn = function(text) return msg("warn", text) end
  context.error = function(text) return msg("error", text) end
  context.warning = context.warn
  
  -- UI
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
    
  context.addMacroSwitch = function(name, keys)
    local text = name
    if keys:len() > 0 then
      text = name .. " [" .. keys .. "]"
    end
    local switch = context.addSwitch("macro_" .. #context.macros, text, function(widget)
      context.storage.macros[name] = not context.storage.macros[name]
      widget:setOn(context.storage.macros[name])
    end)
    switch:setOn(context.storage.macros[name])
    return switch
  end
  
  context.addHotkeySwitch = function(name, keys)
    local text = name
    if keys:len() > 0 then
      text = name .. " [" .. keys .. "]"
    end
    local switch = context.addSwitch("hotkey_" .. #context.hotkeys, text, nil)
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
      if context.storage.macros[name] == nil then
        context.storage.macros[name] = true
      end
      switch = context.addMacroSwitch(name, hotkey)
    end
    
    table.insert(context.macros, {
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
    local switch = nil
    if name:len() > 0 then
      switch = context.addHotkeySwitch(name, keys)
    end    

    context.hotkeys[keys] = {
      name = name,
      callback = callback,
      lastExecution = context.now,
      switch = switch
    }
  end
  
  -- schedule(timeout, callback)
  context.schedule = function(timeout, callback)
    local extecute_time = g_clock.millis() + timeout
    table.insert(context.scheduler, {
      execution = extecute_time,
      callback = callback
    })
    table.sort(context.scheduler, function(a, b) return a.execution < b.execution end)
  end

  -- init context
  context.now = g_clock.millis()
  context.time = g_clock.millis()
  context.player = g_game.getLocalPlayer()
  
  -- run script
  assert(load(config, nil, nil, context))()

  return {
    script = function()      
      context.now = g_clock.millis()
      context.time = g_clock.millis()
      
      for i, macro in ipairs(context.macros) do
        if macro.lastExecution + macro.timeout <= context.now and (macro.name == nil or macro.name:len() < 1 or context.storage.macros[macro.name]) then
          macro.lastExecution = context.now
          macro.callback()
        end
      end
      
      while #context.scheduler > 0 and context.scheduler[1].execution <= g_clock.millis() do
        context.scheduler[1].callback()
        table.remove(context.scheduler, 1)
      end
    end,
    callbacks = {
      onKeyDown = function(keyCode, keyboardModifiers)
        local keyDesc = determineKeyComboDesc(keyCode, keyboardModifiers)
        for i, macro in ipairs(context.macros) do
          if macro.switch and macro.hotkey == keyDesc then
            macro.switch:onClick()
          end
        end
        local hotkey = context.hotkeys[keyDesc]
        if hotkey and hotkey.switch then
          hotkey.switch:setOn(true)
        end
        
      end,
      onKeyUp = function(keyCode, keyboardModifiers)
        local keyDesc = determineKeyComboDesc(keyCode, keyboardModifiers)
        local hotkey = context.hotkeys[keyDesc]
        if hotkey and hotkey.switch then
          hotkey.switch:setOn(false)
        end

      end,
      onKeyPress = function(keyCode, keyboardModifiers, autoRepeatTicks)
        local keyDesc = determineKeyComboDesc(keyCode, keyboardModifiers)
        local hotkey = context.hotkeys[keyDesc]
        if hotkey then
          hotkey.lastExecution = context.now
          hotkey.callback()
        end
        
      end,
      onTalk = function(name, level, mode, text, channelId, pos)

      end
    }    
  }
end