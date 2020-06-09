local overlay
local touchStart = 0
local updateCursorEvent = nil
local zoomInButton
local zoomOutButton

-- public functions
function init()
  if not g_app.isMobile() then return end
  overlay = g_ui.displayUI('mobile')
  overlay:raise()
  
  zoomInButton = modules.client_topmenu.addLeftButton('zoomInButton', 'Zoom In', '/images/topbuttons/zoomin', function() g_app.scaleUp() end)
  zoomOutButton = modules.client_topmenu.addLeftButton('zoomOutButton', 'Zoom Out', '/images/topbuttons/zoomout', function() g_app.scaleDown() end)
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
end

function terminate()
  if not g_app.isMobile() then return end
  disconnect(overlay, { 
    onMousePress = onMousePress,
    onMouseRelease = onMouseRelease,
    onTouchPress = onMousePress,
    onTouchRelease = onMouseRelease,
    onMouseMove = onMouseMove 
  })
  zoomInButton:destroy()
  zoomOutButton:destroy()
  overlay:destroy()
  overlay = nil
end

function hide()
  overlay:hide()
end

function show()
  overlay:show()
end

function onMouseMove(widget, pos, offset)

end

function onMousePress(widget, pos, button)
  overlay:raise()
  if button == 4 then -- touch
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
  overlay.cursor:hide()
  removeEvent(updateCursorEvent)
end

function updateCursor()
  removeEvent(updateCursorEvent)
  local percent = 100 - math.max(0, math.min(100, (g_clock.millis() - touchStart) / 5)) -- 500 ms
  overlay.cursor:setPercent(percent)
  if percent > 0 then
    overlay.cursor:setOpacity(0.5)
    updateCursorEvent = scheduleEvent(updateCursor, 10)
  else
    overlay.cursor:setOpacity(0.8)
  end
end