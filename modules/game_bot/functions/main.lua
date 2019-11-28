local context = G.botContext

-- MAIN BOT FUNCTION
-- macro(timeout, callback)
-- macro(timeout, name, callback)
-- macro(timeout, name, callback, parent)
-- macro(timeout, name, hotkey, callback)
-- macro(timeout, name, hotkey, callback, parent)
context.macro = function(timeout, name, hotkey, callback, parent)
  if type(timeout) ~= 'number' or timeout < 1 then
    error("Invalid timeout for macro: " .. tostring(timeout))
  end
  if type(name) == 'function' then
    callback = name
    name = ""
    hotkey = ""
  elseif type(hotkey) == 'function' then
    parent = callback
    callback = hotkey
    hotkey = ""    
  elseif type(callback) ~= 'function' then
    error("Invalid callback for macro: " .. tostring(callback))
  end
  if hotkey == nil then
    hotkey = ""
  end
  if type(name) ~= 'string' or type(hotkey) ~= 'string' then
    error("Invalid name or hotkey for macro")
  end
  if not parent then
    parent = context.panel
  end  
  if hotkey:len() > 0 then
    hotkey = retranslateKeyComboDesc(hotkey)
  end
  
  local switch = nil
  if name:len() > 0 then
    if context.storage._macros[name] == nil then
      context.storage._macros[name] = false
    end
    switch = context._addMacroSwitch(name, hotkey, parent)
  end
  
  table.insert(context._macros, {
    timeout = timeout,
    name = name,
    lastExecution = context.now,
    hotkey = hotkey,
    switch = switch
  })
  
  local macroData = context._macros[#context._macros]
  macroData.callback = function()
    if not macroData.delay or macroData.delay < context.now then
      context._currentExecution = macroData   
      callback()
      context._currentExecution = nil    
      return true
    end
  end
  
  return macroData
end

-- hotkey(keys, callback)
-- hotkey(keys, callback, parent)
-- hotkey(keys, name, callback)
-- hotkey(keys, name, callback, parent)
context.hotkey = function(keys, name, callback, parent, single)
  if type(name) == 'function' then
    parent = callback
    callback = name
    name = ""
  end
  if not parent then
    parent = context.panel
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
    switch = context._addHotkeySwitch(name, keys, parent)
  end

  context._hotkeys[keys] = {
    name = name,
    lastExecution = context.now,
    switch = switch,
    single = single
  }
  
  local hotkeyData = context._hotkeys[keys]
  hotkeyData.callback = function()
    if not hotkeyData.delay or hotkeyData.delay < context.now then
      context._currentExecution = hotkeyData       
      callback()
      context._currentExecution = nil
      return true
    end
  end

  return hotkeyData
end

-- singlehotkey(keys, callback)
-- singlehotkey(keys, callback, parent)
-- singlehotkey(keys, name, callback)
-- singlehotkey(keys, name, callback, parent)
context.singlehotkey = function(keys, name, callback, parent)
  if type(name) == 'function' then
    parent = callback
    callback = name
    name = ""
  end
  return context.hotkey(keys, name, callback, parent, true) 
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

-- delay(duration) -- block execution of current macro/hotkey/callback for x milliseconds
context.delay = function(duration)
  if not context._currentExecution then
    return context.error("Invalid usage of delay function, it should be used inside callbacks")
  end
  context._currentExecution.delay = context.now + duration
end