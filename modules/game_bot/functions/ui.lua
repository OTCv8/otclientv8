local context = G.botContext

context.setupUI = function(otml, parent)
  if parent == nil then      
    parent = context.panel
  end
  local widget = g_ui.loadUIFromString(otml, parent)
  widget.botWidget = true
  return widget
end

context.addTab = function(name)
  context.tabs:setOn(true)
  return context.tabs:addTab(name, g_ui.createWidget('BotPanel')).tabPanel
end

context.addSwitch = function(id, text, onClickCallback, parent)
  if not parent then
    parent = context.panel
  end
  local switch = g_ui.createWidget('BotSwitch', parent)
  switch:setId(id)
  switch:setText(text)
  switch.onClick = onClickCallback
  return switch
end

context.addButton = function(id, text, onClickCallback, parent)
  if not parent then
    parent = context.panel
  end
  local button = g_ui.createWidget('BotButton', parent)
  button:setId(id)
  button:setText(text)
  button.onClick = onClickCallback
  return button    
end

context.addLabel = function(id, text, parent)
  if not parent then
    parent = context.panel
  end
  local label = g_ui.createWidget('BotLabel', parent)
  label:setId(id)
  label:setText(text)
  return label    
end

context.addTextEdit = function(id, text, onTextChangeCallback, parent)
  if not parent then
    parent = context.panel
  end
  local widget = g_ui.createWidget('BotTextEdit', parent)
  widget:setId(id)
  widget.onTextChange = onTextChangeCallback
  widget:setText(text)
  return widget    
end

context.addSeparator = function(id, parent)
  if not parent then
    parent = context.panel
  end
  local separator = g_ui.createWidget('BotSeparator', parent)
  separator:setId(id)
  return separator    
end

context._addMacroSwitch = function(name, keys, parent)
  if not parent then
    parent = context.panel
  end
  local text = name
  if keys:len() > 0 then
    text = name .. " [" .. keys .. "]"
  end
  local switch = context.addSwitch("macro_" .. #context._macros, text, function(widget)
    context.storage._macros[name] = not context.storage._macros[name]
    widget:setOn(context.storage._macros[name])
  end, parent)
  switch:setOn(context.storage._macros[name])
  return switch
end

context._addHotkeySwitch = function(name, keys, parent)
  if not parent then
    parent = context.panel
  end
  local text = name
  if keys:len() > 0 then
    text = name .. " [" .. keys .. "]"
  end
  local switch = context.addSwitch("hotkey_" .. #context._hotkeys, text, nil, parent)
  switch:setOn(false)
  return switch
end