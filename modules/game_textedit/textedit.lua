local activeWindow

function init()
  g_ui.importStyle('textedit')

  connect(g_game, { onGameEnd = destroyWindow })
end

function terminate()
  disconnect(g_game, { onGameEnd = destroyWindow })

  destroyWindow()
end

function destroyWindow()
  if activeWindow then
    activeWindow:destroy()
    activeWindow = nil
  end
end

function show(widget)
  if not widget then
    return
  end
  if activeWindow then
    destroyWindow()
  end
  local window = g_ui.createWidget('TextEditWindow', rootWidget)
  
  local destroy = function()
    window:destroy()
    if window == activeWindow then
      activeWindow = nil
    end
  end
  local doneFunc = function()
    widget:setText(window.text:getText())
    destroy()
  end

  window.okButton.onClick = doneFunc
  window.cancelButton.onClick = destroy
  window.onEnter = doneFunc
  window.onEscape = destroy
  
  window.text:setText(widget:getText())
  
  activeWindow = window
  activeWindow:raise()
  activeWindow:focus()
end

function singlelineEditor(text, callback)
  if activeWindow then
    destroyWindow()
  end
  local window = g_ui.createWidget('TextEditWindow', rootWidget)
  
  local destroy = function()
    window:destroy()
    if window == activeWindow then
      activeWindow = nil
    end
  end

  window.okButton.onClick = function() 
    local text = window.text:getText()
    destroy() 
    callback(text) 
  end
  window.cancelButton.onClick = destroy
  window.onEscape = destroy
  window.onEnter = window.okButton.onClick
    
  window.text:setText(text)
    
  activeWindow = window
  activeWindow:raise()
  activeWindow:focus()
end

function multilineEditor(description, text, callback)
  if activeWindow then
    destroyWindow()
  end
  local window = g_ui.createWidget('TextEditMultilineWindow', rootWidget)
  
  local destroy = function()
    window:destroy()
    if window == activeWindow then
      activeWindow = nil
    end
  end

  window.okButton.onClick = function() 
    local text = window.text:getText()
    destroy() 
    callback(text) 
  end
  window.cancelButton.onClick = destroy
  window.onEscape = destroy
  
  window.description:setText(description)
  window.text:setText(text)
  
  activeWindow = window
  activeWindow:raise()
  activeWindow:focus()
end

function hide()
  destroyWindow()
end
