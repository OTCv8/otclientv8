local musicFilename = "/sounds/startup"
local musicChannel = nil

function setMusic(filename)
  musicFilename = filename

  if not g_game.isOnline() and musicChannel ~= nil then
    musicChannel:stop()
    musicChannel:enqueue(musicFilename, 3)
  end
end

function reloadScripts()
  if g_game.getFeature(GameNoDebug) then
    return
  end
  
  g_textures.clearCache()
  g_modules.reloadModules()

  local script = '/' .. g_app.getCompactName() .. 'rc.lua'
  if g_resources.fileExists(script) then
    dofile(script)
  end

  local message = tr('All modules and scripts were reloaded.')

  modules.game_textmessage.displayGameMessage(message)
  print(message)
end

function startup()
  if g_sounds ~= nil then
    musicChannel = g_sounds.getChannel(1)
  end
  
  G.UUID = g_settings.getString('report-uuid')
  if not G.UUID or #G.UUID ~= 36 then
    G.UUID = g_crypt.genUUID()
    g_settings.set('report-uuid', G.UUID)
  end
  
  -- Play startup music (The Silver Tree, by Mattias Westlund)
  --musicChannel:enqueue(musicFilename, 3)
  connect(g_game, { onGameStart = function() if musicChannel ~= nil then musicChannel:stop(3) end end })
  connect(g_game, { onGameEnd = function()
      if g_sounds ~= nil then
        g_sounds.stopAll()
        --musicChannel:enqueue(musicFilename, 3)
      end
  end })
end

function init()
  connect(g_app, { onRun = startup,
                   onExit = exit })
  connect(g_game, { onGameStart = onGameStart,
                    onGameEnd = onGameEnd })

  if g_sounds ~= nil then
    --g_sounds.preload(musicFilename)
  end

  if not Updater then
    if g_resources.getLayout() == "mobile" then
      g_window.setMinimumSize({ width = 640, height = 360 })
    else
      g_window.setMinimumSize({ width = 800, height = 640 })  
    end

    -- window size
    local size = { width = 1024, height = 600 }
    size = g_settings.getSize('window-size', size)
    g_window.resize(size)

    -- window position, default is the screen center
    local displaySize = g_window.getDisplaySize()
    local defaultPos = { x = (displaySize.width - size.width)/2,
                         y = (displaySize.height - size.height)/2 }
    local pos = g_settings.getPoint('window-pos', defaultPos)
    pos.x = math.max(pos.x, 0)
    pos.y = math.max(pos.y, 0)
    g_window.move(pos)

    -- window maximized?
    local maximized = g_settings.getBoolean('window-maximized', false)
    if maximized then g_window.maximize() end
  end

  g_window.setTitle(g_app.getName())
  g_window.setIcon('/images/clienticon')

  g_keyboard.bindKeyDown('Ctrl+Shift+R', reloadScripts)

  -- generate machine uuid, this is a security measure for storing passwords
  if not g_crypt.setMachineUUID(g_settings.get('uuid')) then
    g_settings.set('uuid', g_crypt.getMachineUUID())
    g_settings.save()
  end
end

function terminate()
  disconnect(g_app, { onRun = startup,
                      onExit = exit })
  disconnect(g_game, { onGameStart = onGameStart,
                       onGameEnd = onGameEnd })
  -- save window configs
  g_settings.set('window-size', g_window.getUnmaximizedSize())
  g_settings.set('window-pos', g_window.getUnmaximizedPos())
  g_settings.set('window-maximized', g_window.isMaximized())
end

function exit()
  g_logger.info("Exiting application..")
end

function onGameStart()
  local player = g_game.getLocalPlayer()
  if not player then return end
  g_window.setTitle(g_app.getName() .. " - " .. player:getName())  
end

function onGameEnd()
  g_window.setTitle(g_app.getName())
end
