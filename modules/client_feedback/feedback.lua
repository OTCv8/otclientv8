local feedbackWindow
local textEdit
local okButton
local cancelButton
local postId = 0
local tries = 0
local replyEvent = nil

function init()
  feedbackWindow = g_ui.displayUI('feedback')
  feedbackWindow:hide()

  textEdit = feedbackWindow:getChildById('text')
  okButton = feedbackWindow:getChildById('okButton')
  cancelButton = feedbackWindow:getChildById('cancelButton')

  okButton.onClick = send
  cancelButton.onClick = hide
  feedbackWindow.onEscape = hide    
end

function terminate()
  feedbackWindow:destroy()
  removeEvent(replyEvent)
end

function show()
  if not Services or not Services.feedback or Services.feedback:len() < 4 then
    return
  end

  feedbackWindow:show()
  feedbackWindow:raise()
  feedbackWindow:focus()
  
  textEdit:setMaxLength(8192)
  textEdit:setText('')
  textEdit:setEditable(true)
  textEdit:setCursorVisible(true)
  feedbackWindow:focusChild(textEdit, KeyboardFocusReason)
  
  tries = 0
end

function hide()
  feedbackWindow:hide()
  textEdit:setEditable(false)
  textEdit:setCursorVisible(false)
end

function send()
  local text = textEdit:getText()
  if text:len() > 1 then
    local localPlayer = g_game.getLocalPlayer()
    local playerData = nil
    if localPlayer ~= nil then
      playerData = {
        name = localPlayer:getName(),
        position = localPlayer:getPosition()
      }
    end
    local details = {
      report_delay = sendInterval,
      os = g_app.getOs(),
      graphics_vendor = g_graphics.getVendor(),
      graphics_renderer = g_graphics.getRenderer(),
      graphics_version = g_graphics.getVersion(),
      fps = g_app.getFps(),
      maxFps = g_app.getMaxFps(),
      atlas = g_atlas.getStats(),
      classic = tostring(g_settings.getBoolean("classicView")),
      fullscreen = tostring(g_window.isFullscreen()),
      vsync = tostring(g_settings.getBoolean("vsync")),
      window_width = g_window.getWidth(),
      window_height = g_window.getHeight(),
      player_name = g_game.getCharacterName(),
      world_name = g_game.getWorldName(),
      otserv_host = G.host,
      otserv_protocol = g_game.getProtocolVersion(),
      otserv_client = g_game.getClientVersion(),
      build_version = g_app.getVersion(),
      build_revision = g_app.getBuildRevision(),
      build_commit = g_app.getBuildCommit(),
      build_date = g_app.getBuildDate(),
      display_width = g_window.getDisplayWidth(),
      display_height = g_window.getDisplayHeight(),
      cpu = g_platform.getCPUName(),
      mem = g_platform.getTotalSystemMemory(),
      os_name = g_platform.getOSName()
    } 
    local data = json.encode({
      text = text,
      version = g_app.getVersion(),
      host = g_settings.get('host'),
      player = playerData,
      details = details
    })
    
    postId = HTTP.post(Services.feedback, data, function(ret, err) 
      if err then
        tries = tries + 1
        if tries < 3 then 
          replyEvent = scheduleEvent(send, 1000)
        end
      end
    end)
  end 
  hide()
end