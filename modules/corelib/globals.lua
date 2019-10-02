-- @docvars @{

-- root widget
rootWidget = g_ui.getRootWidget()
modules = package.loaded

-- G is used as a global table to save variables in memory between reloads
G = G or {}

-- @}

-- @docfuncs @{

function scheduleEvent(callback, delay)
  local desc = "lua"
  local info = debug.getinfo(2, "Sl")
  if info then
    desc = info.short_src .. ":" .. info.currentline
  end
  local event = g_dispatcher.scheduleEvent(desc, callback, delay)
  -- must hold a reference to the callback, otherwise it would be collected
  event._callback = callback
  return event
end

function addEvent(callback, front)
  local desc = "lua"
  local info = debug.getinfo(2, "Sl")
  if info then
    desc = info.short_src .. ":" .. info.currentline
  end
  local event = g_dispatcher.addEvent(desc, callback, front)
  -- must hold a reference to the callback, otherwise it would be collected
  event._callback = callback
  return event
end

function cycleEvent(callback, interval)
  local desc = "lua"
  local info = debug.getinfo(2, "Sl")
  if info then
    desc = info.short_src .. ":" .. info.currentline
  end
  local event = g_dispatcher.cycleEvent(desc, callback, interval)
  -- must hold a reference to the callback, otherwise it would be collected
  event._callback = callback
  return event
end

function periodicalEvent(eventFunc, conditionFunc, delay, autoRepeatDelay)
  delay = delay or 30
  autoRepeatDelay = autoRepeatDelay or delay

  local func
  func = function()
    if conditionFunc and not conditionFunc() then
      func = nil
      return
    end
    eventFunc()
    scheduleEvent(func, delay)
  end

  scheduleEvent(function()
    func()
  end, autoRepeatDelay)
end

function removeEvent(event)
  if event then
    event:cancel()
    event._callback = nil
  end
end

-- @}