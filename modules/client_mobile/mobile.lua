local overlay
local keypad
local touchStart = 0
local updateCursorEvent
local zoomInButton
local zoomOutButton
local keypadButton
local keypadEvent
local keypadMousePos = {x=0.5, y=0.5}
local keypadTicks = 0

-- public functions
function init()
  if not g_app.isMobile() then return end
  overlay = g_ui.displayUI('mobile')
  keypad = overlay.keypad
  overlay:raise()
  
  zoomInButton = modules.client_topmenu.addLeftButton('zoomInButton', 'Zoom In', '/images/topbuttons/zoomin', function() g_app.scaleUp() end)
  zoomOutButton = modules.client_topmenu.addLeftButton('zoomOutButton', 'Zoom Out', '/images/topbuttons/zoomout', function() g_app.scaleDown() end)
  keypadButton = modules.client_topmenu.addLeftGameToggleButton('keypadButton', 'Keypad', '/images/topbuttons/keypad', function()
    keypadButton:setChecked(not keypadButton:isChecked())
    if not g_game.isOnline() then
      keypad:setVisible(false)
      return
    end
    keypad:setVisible(keypadButton:isChecked())
  end)
  keypadButton:setChecked(true)
  
  scheduleEvent(function()
    g_app.scale(5.0)
  end, 10)
  
  connect(overlay, { 
    onMousePress = onMousePress,
    onMouseRelease = onMouseRelease,
    onTouchPress = onMousePress,
    onTouchRelease = onMouseRelease,
    onMouseMove = onMouseMove 
  })
  connect(keypad, {
    onTouchPress = onKeypadTouchPress,
    onTouchRelease = onKeypadTouchRelease,  
    onMouseMove = onKeypadTouchMove
  })
  connect(g_game, { 
    onGameStart = online,
    onGameEnd = offline 
  })
  if g_game.isOnline() then
    online()
  end
end

function terminate()
  if not g_app.isMobile() then return end
  removeEvent(updateCursorEvent)
  removeEvent(keypadEvent)
  keypadEvent = nil
  disconnect(overlay, { 
    onMousePress = onMousePress,
    onMouseRelease = onMouseRelease,
    onTouchPress = onMousePress,
    onTouchRelease = onMouseRelease,
    onMouseMove = onMouseMove 
  })
  disconnect(keypad, {
    onTouchPress = onKeypadTouchPress,
    onTouchRelease = onKeypadTouchRelease,  
    onMouseMove = onKeypadTouchMove
  })
  disconnect(g_game, { 
    onGameStart = online,
    onGameEnd = offline 
  })
  zoomInButton:destroy()
  zoomOutButton:destroy()
  keypadButton:destroy()
  overlay:destroy()
  overlay = nil
end

function hide()
  overlay:hide()
end

function show()
  overlay:show()
end

function online()
  if keypadButton:isChecked() then
    keypad:raise()
    keypad:show()
  end
end

function offline()
  keypad:hide()
end

function onMouseMove(widget, pos, offset)

end

function onMousePress(widget, pos, button)
  overlay:raise()
  if button == MouseTouch then -- touch
    overlay:raise()
    overlay.cursor:show()
    overlay.cursor:setPosition({x=pos.x - 32, y = pos.y - 32})  
    touchStart = g_clock.millis()
    updateCursor()
  else
    overlay.cursor:hide()
    removeEvent(updateCursorEvent)
  end
end

function onMouseRelease(widget, pos, button)
  if button == MouseTouch then
    overlay.cursor:hide()
    removeEvent(updateCursorEvent)
  end
end

function updateCursor()
  removeEvent(updateCursorEvent)
  if not g_mouse.isPressed(MouseTouch) then return end
  local percent = 100 - math.max(0, math.min(100, (g_clock.millis() - touchStart) / 5)) -- 500 ms
  overlay.cursor:setPercent(percent)
  if percent > 0 then
    overlay.cursor:setOpacity(0.5)
    updateCursorEvent = scheduleEvent(updateCursor, 10)
  else
    overlay.cursor:setOpacity(0.8)
  end
end

function onKeypadTouchMove(widget, pos, offset)
  keypadMousePos = {x=(pos.x - widget:getPosition().x) / widget:getWidth(), 
                    y=(pos.y - widget:getPosition().y) / widget:getHeight()}
  return true
end

function onKeypadTouchPress(widget, pos, button)
  if button ~= MouseTouch then return false end
  keypadTicks = 0
  keypadMousePos = {x=(pos.x - widget:getPosition().x) / widget:getWidth(), 
                    y=(pos.y - widget:getPosition().y) / widget:getHeight()}
  executeWalk()
  return true
end

function onKeypadTouchRelease(widget, pos, button)
  if button ~= MouseTouch then return false end
  keypadMousePos = {x=(pos.x - widget:getPosition().x) / widget:getWidth(), 
                    y=(pos.y - widget:getPosition().y) / widget:getHeight()}
  executeWalk()
  removeEvent(keypadEvent)
  keypad.pointer:setMarginTop(0)
  keypad.pointer:setMarginLeft(0)
  return true
end

function executeWalk()
  removeEvent(keypadEvent)
  keypadEvent = nil
  if not modules.game_walking or not g_mouse.isPressed(MouseTouch) then
    keypad.pointer:setMarginTop(0)
    keypad.pointer:setMarginLeft(0)
    return
  end
  keypadEvent = scheduleEvent(executeWalk, 20)
  keypadMousePos.x = math.min(1, math.max(0, keypadMousePos.x))
  keypadMousePos.y = math.min(1, math.max(0, keypadMousePos.y))
  local angle = math.atan2(keypadMousePos.x - 0.5, keypadMousePos.y - 0.5)
  local maxTop = math.abs(math.cos(angle)) * 75
  local marginTop = math.max(-maxTop, math.min(maxTop, (keypadMousePos.y - 0.5) * 150))
  local maxLeft = math.abs(math.sin(angle)) * 75
  local marginLeft = math.max(-maxLeft, math.min(maxLeft, (keypadMousePos.x - 0.5) * 150))
  keypad.pointer:setMarginTop(marginTop)
  keypad.pointer:setMarginLeft(marginLeft)
  local dir
  if keypadMousePos.y < 0.3 and keypadMousePos.x < 0.3 then
    dir = Directions.NorthWest     
  elseif keypadMousePos.y < 0.3 and keypadMousePos.x > 0.7 then
    dir = Directions.NorthEast
  elseif keypadMousePos.y > 0.7 and keypadMousePos.x < 0.3 then
    dir = Directions.SouthWest
  elseif keypadMousePos.y > 0.7 and keypadMousePos.x > 0.7 then
    dir = Directions.SouthEast
  end
  if not dir and (math.abs(keypadMousePos.y - 0.5) > 0.1 or math.abs(keypadMousePos.x - 0.5) > 0.1) then
    if math.abs(keypadMousePos.y - 0.5) > math.abs(keypadMousePos.x - 0.5) then
      if keypadMousePos.y < 0.5 then
        dir = Directions.North
      else
        dir = Directions.South
      end
    else
      if keypadMousePos.x < 0.5 then
        dir = Directions.West
      else
        dir = Directions.East
      end    
    end  
  end
  if dir then
    modules.game_walking.walk(dir, keypadTicks)
    if keypadTicks == 0 then
      keypadTicks = 100
    end
  end
end