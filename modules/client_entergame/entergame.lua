EnterGame = { }

-- private variables
local loadBox
local enterGame
local enterGameButton
local clientBox
local protocolLogin
local server = nil
local versionsFound = false

local newLogin = nil
local newLoginUrl = nil
local newLoginEvent

local customServerSelectorPanel
local serverSelectorPanel
local serverSelector
local clientVersionSelector
local serverHostTextEdit
local rememberPasswordBox
local protos = {"740", "760", "772", "800", "810", "854", "860", "1090", "1096", "1099"}


-- private functions
local function onProtocolError(protocol, message, errorCode)
  if errorCode then
    return EnterGame.onError(message)
  end
  return EnterGame.onLoginError(message)
end

local function onSessionKey(protocol, sessionKey)
  G.sessionKey = sessionKey
end

local function onCharacterList(protocol, characters, account, otui)
  if rememberPasswordBox:isChecked() then
    local account = g_crypt.encrypt(G.account)
    local password = g_crypt.encrypt(G.password)

    g_settings.set('account', account)
    g_settings.set('password', password)
  else
    EnterGame.clearAccountFields()
  end

  for _, characterInfo in pairs(characters) do
    if characterInfo.previewState and characterInfo.previewState ~= PreviewState.Default then
      characterInfo.worldName = characterInfo.worldName .. ', Preview'
    end
  end

  if loadBox then
    loadBox:destroy()
    loadBox = nil
  end
  
  CharacterList.create(characters, account, otui)
  CharacterList.show()

  g_settings.save()
end

local function onUpdateNeeded(protocol, signature)
  return EnterGame.onError(tr('Your client needs updating, try redownloading it.'))
end

local function parseFeatures(features)
  for feature_id, value in pairs(features) do
      if value == "1" or value == "true" or value == true then
        g_game.enableFeature(feature_id)
      else
        g_game.disableFeature(feature_id)
      end
  end  
end

local function validateThings(things)
  local incorrectThings = ""
  if things ~= nil then
    local thingsNode = {}
    for thingtype, thingdata in pairs(things) do
      thingsNode[thingtype] = thingdata[1]
      if not g_resources.fileExists("/data/things/" .. thingdata[1]) then
        correctThings = false
        incorrectThings = incorrectThings .. "Missing file: " .. thingdata[1] .. "\n"
      end
      local localChecksum = g_resources.fileChecksum("/data/things/" .. thingdata[1]):lower()
      if localChecksum ~= thingdata[2]:lower() and #thingdata[2] > 1 then
        if g_resources.isLoadedFromArchive() then -- ignore checksum if it's test/debug version
          incorrectThings = incorrectThings .. "Invalid checksum of file: " .. thingdata[1] .. " (is " .. localChecksum .. ", should be " .. thingdata[2]:lower() .. ")\n"
        end
      end
    end
    g_settings.setNode("things", thingsNode)
  else
    g_settings.setNode("things", {})
  end
  return incorrectThings
end

local function onHTTPResult(data, err)  
  if err then
    return EnterGame.onError(err)
  end
  if data['error'] and #data['error'] > 0 then
    return EnterGame.onLoginError(data['error'])
  end
  
  local characters = data["characters"]
  local account = data["account"]
  local session = data["session"]
 
  local version = data["version"]
  local things = data["things"]
  local customProtocol = data["customProtocol"]

  local features = data["features"]
  local settings = data["settings"]
  local rsa = data["rsa"]
  local proxies = data["proxies"]

  local incorrectThings = validateThings(things)
  if #incorrectThings > 0 then
    g_logger.info(incorrectThings)
    if Updater then
      return Updater.updateThings(things, incorrectThings)
    else
      return EnterGame.onError(incorrectThings)
    end
  end
  
  -- custom protocol
  g_game.setCustomProtocolVersion(0)
  if customProtocol ~= nil then
    customProtocol = tonumber(customProtocol)
    if customProtocol ~= nil and customProtocol > 0 then
      g_game.setCustomProtocolVersion(customProtocol)
    end
  end
  
  -- force player settings
  if settings ~= nil then
    for option, value in pairs(settings) do
      modules.client_options.setOption(option, value, true)
    end
  end
    
  -- version
  G.clientVersion = version
  g_game.setClientVersion(version)
  g_game.setProtocolVersion(g_game.getClientProtocolVersion(version))  
  g_game.setCustomOs(-1) -- disable
  
  if rsa ~= nil then
    g_game.setRsa(rsa)
  end

  if features ~= nil then
    parseFeatures(features)
  end

  if session ~= nil and session:len() > 0 then
    onSessionKey(nil, session)
  end
  
  -- proxies
  if g_proxy then
    g_proxy.clear()
    if proxies then
      for i, proxy in ipairs(proxies) do
        g_proxy.addProxy(tonumber(proxy["localPort"]), proxy["host"], tonumber(proxy["port"]), tonumber(proxy["priority"]))
      end
    end
  end
  
  onCharacterList(nil, characters, account, nil)  
end


-- public functions
function EnterGame.init()
  enterGame = g_ui.displayUI('entergame')
  newLogin = g_ui.displayUI('entergame_new')
  
  serverSelectorPanel = enterGame:getChildById('serverSelectorPanel')
  customServerSelectorPanel = enterGame:getChildById('customServerSelectorPanel')
  
  serverSelector = serverSelectorPanel:getChildById('serverSelector')
  rememberPasswordBox = enterGame:getChildById('rememberPasswordBox')
  serverHostTextEdit = customServerSelectorPanel:getChildById('serverHostTextEdit')
  clientVersionSelector = customServerSelectorPanel:getChildById('clientVersionSelector')
  
  if Servers ~= nil then 
    for name,server in pairs(Servers) do
      serverSelector:addOption(name)
    end
  end
  if serverSelector:getOptionsCount() == 0 or ALLOW_CUSTOM_SERVERS then
    serverSelector:addOption(tr("Another"))    
  end  
  for i,proto in pairs(protos) do
    clientVersionSelector:addOption(proto)
  end

  if serverSelector:getOptionsCount() == 1 then
    enterGame:setHeight(enterGame:getHeight() - serverSelectorPanel:getHeight())
    serverSelectorPanel:setOn(false)
  end
  
  local account = g_crypt.decrypt(g_settings.get('account'))
  local password = g_crypt.decrypt(g_settings.get('password'))
  local server = g_settings.get('server')
  local host = g_settings.get('host')
  local clientVersion = g_settings.get('client-version')
  local hdSprites = g_settings.getBoolean('hdSprites', false)

  if serverSelector:isOption(server) then
    serverSelector:setCurrentOption(server, false)
    if Servers == nil or Servers[server] == nil then
      serverHostTextEdit:setText(host)
    end
    clientVersionSelector:setOption(clientVersion)
  else
    server = ""
    host = ""
  end
  
  enterGame:getChildById('accountPasswordTextEdit'):setText(password)
  enterGame:getChildById('accountNameTextEdit'):setText(account)
  rememberPasswordBox:setChecked(#account > 0)
  
  if enterGame.hdSprites then
    enterGame.hdSprites:setChecked(hdSprites)
  end
  
  g_keyboard.bindKeyDown('Ctrl+G', EnterGame.openWindow)

  if g_game.isOnline() then
    return EnterGame.hide()
  end

  scheduleEvent(function()
    EnterGame.show()
  end, 100)
end

function EnterGame.terminate()
  g_keyboard.unbindKeyDown('Ctrl+G')
  
  removeEvent(newLoginEvent)
  
  enterGame:destroy()
  if newLogin then
    newLogin:destroy()
  end
  if loadBox then
    loadBox:destroy()
    loadBox = nil
  end
  if protocolLogin then
    protocolLogin:cancelLogin()
    protocolLogin = nil
  end
  EnterGame = nil
end

function EnterGame.show()
  if Updater and Updater.isVisible() or g_game.isOnline() then
    return EnterGame.hide()
  end
  enterGame:show()
  enterGame:raise()
  enterGame:focus()
  enterGame:getChildById('accountNameTextEdit'):focus()
  EnterGame.checkNewLogin()
end

function EnterGame.hide()
  enterGame:hide()
  newLogin:hide()
end

function EnterGame.openWindow()
  if g_game.isOnline() then
    CharacterList.show()
  elseif not g_game.isLogging() and not CharacterList.isVisible() then
    EnterGame.show()
  end
end

function EnterGame.clearAccountFields()
  enterGame:getChildById('accountNameTextEdit'):clearText()
  enterGame:getChildById('accountPasswordTextEdit'):clearText()
  --enterGame:getChildById('authenticatorTokenTextEdit'):clearText()
  enterGame:getChildById('accountNameTextEdit'):focus()
  g_settings.remove('account')
  g_settings.remove('password')
end

function EnterGame.hideNewLogin()
  newLogin:hide()
  newLoginUrl = nil
end

function EnterGame.checkNewLoginEvent()
  newLoginEvent = scheduleEvent(function() EnterGame.checkNewLoginEvent() end, 1000)
  EnterGame.checkNewLogin()
end

function EnterGame.checkNewLogin()
  if not newLoginUrl then
    return
  end
  local url = newLoginUrl  
  HTTP.postJSON(newLoginUrl, { quick = 1 }, function(data, err)
    if url ~= newLoginUrl then return end
    if err then return end
    if not data["qrcode"] then return end
    if newLogin:isHidden() then
      newLogin:show()
      enterGame:raise()
    end
    newLogin.qrcode:setImageSourceBase64(data["qrcode"])
    newLogin.code:setText(data["code"])
  end)
end

function EnterGame.onServerChange()
  server = serverSelector:getText()
  EnterGame.hideNewLogin()
  if server == tr("Another") then
    if not customServerSelectorPanel:isOn() then
      serverHostTextEdit:setText("")
      customServerSelectorPanel:setOn(true)  
      enterGame:setHeight(enterGame:getHeight() + customServerSelectorPanel:getHeight())
    end
  elseif customServerSelectorPanel:isOn() then
    enterGame:setHeight(enterGame:getHeight() - customServerSelectorPanel:getHeight())
    customServerSelectorPanel:setOn(false)
  end
  if Servers and Servers[server] ~= nil then
    serverHostTextEdit:setText(Servers[server])
    newLoginUrl = Servers[server]
    EnterGame.checkNewLogin()
  end
end

function EnterGame.doLogin()
  if Updater and Updater.isVisible() then
    return
  end
  if g_game.isOnline() then
    local errorBox = displayErrorBox(tr('Login Error'), tr('Cannot login while already in game.'))
    connect(errorBox, { onOk = EnterGame.show })
    return
  end
  
  G.account = enterGame:getChildById('accountNameTextEdit'):getText()
  G.password = enterGame:getChildById('accountPasswordTextEdit'):getText()
  --G.authenticatorToken = enterGame:getChildById('authenticatorTokenTextEdit'):getText()
  G.authenticatorToken = ""
  G.hdSprites = enterGame.hdSprites and enterGame.hdSprites:isChecked()
  G.stayLogged = true
  G.server = serverSelector:getText():trim()
  G.host = serverHostTextEdit:getText()
  G.clientVersion = tonumber(clientVersionSelector:getText())  
 
  if not rememberPasswordBox:isChecked() then
    g_settings.set('account', G.account)
    g_settings.set('password', G.password)  
  end
  g_settings.set('host', G.host)
  g_settings.set('server', G.server)
  g_settings.set('client-version', G.clientVersion)
  g_settings.set('hdSprites', G.hdSprites)
  g_settings.save()

  if G.host:find("http") ~= nil then
    return EnterGame.doLoginHttp()      
  end
  
  local server_params = G.host:split(":")
  if #server_params < 2 then
    return EnterGame.onError("Invalid server, it should be in format IP:PORT or it should be http url to login script")
  end
  local server_ip = server_params[1]
  local server_port = tonumber(server_params[2])
  if #server_params >= 3 then
    G.clientVersion = tonumber(server_params[3])
  end
  if not server_port or not G.clientVersion then
    return EnterGame.onError("Invalid server, it should be in format IP:PORT or it should be http url to login script")  
  end
  
  local things = {
    data = {G.clientVersion .. "/Tibia.dat", ""},
    sprites = {G.clientVersion .. "/Tibia.spr", ""},
  }
  
  if G.hdSprites then
    things.sprites_hd = {G.clientVersion .. "/Tibia_hd.spr", ""}
  end
  
  local incorrectThings = validateThings(things)
  if #incorrectThings > 0 then
    g_logger.info(incorrectThings)
    if Updater then
      return Updater.updateThings(things, incorrectThings)
    else
      return EnterGame.onError(incorrectThings)
    end
  end

  protocolLogin = ProtocolLogin.create()
  protocolLogin.onLoginError = onProtocolError
  protocolLogin.onSessionKey = onSessionKey
  protocolLogin.onCharacterList = onCharacterList
  protocolLogin.onUpdateNeeded = onUpdateNeeded

  EnterGame.hide()
  loadBox = displayCancelBox(tr('Please wait'), tr('Connecting to login server...'))
  connect(loadBox, { onCancel = function(msgbox)
                                  loadBox = nil
                                  protocolLogin:cancelLogin()
                                  EnterGame.show()
                                end })

  -- if you have custom rsa or protocol edit it here
  g_game.setClientVersion(G.clientVersion)
  g_game.setProtocolVersion(g_game.getClientProtocolVersion(G.clientVersion))
  g_game.setCustomProtocolVersion(0)
  g_game.chooseRsa(G.host)
  g_game.setCustomOs(2) -- windows

  -- you can add custom features here
  g_game.enableFeature(GameBot)
  
  -- proxies
  if g_proxy then
    g_proxy.clear()
  end
  
  if modules.game_things.isLoaded() then
    g_logger.info("Connection to: " .. server_ip .. ":" .. server_port)
    protocolLogin:login(server_ip, server_port, G.account, G.password, G.authenticatorToken, G.stayLogged)
  else
    loadBox:destroy()
    loadBox = nil
    EnterGame.show()
  end
end

function EnterGame.doLoginHttp()
  if G.host == nil or G.host:len() < 10 then
    return EnterGame.onError("Invalid server url: " .. G.host)    
  end

  loadBox = displayCancelBox(tr('Please wait'), tr('Connecting to login server...'))
  connect(loadBox, { onCancel = function(msgbox)
                                  loadBox = nil
                                  EnterGame.show()
                                end })                                
                                  
  local data = {
    account = G.account,
    password = G.password,
    token = G.authenticatorToken,
    hdSprites = G.hdSprites,
    version = APP_VERSION,
    uid = G.UUID
  }          
  HTTP.postJSON(G.host, data, onHTTPResult)
  EnterGame.hide()
end

function EnterGame.onError(err)
  if loadBox then
    loadBox:destroy()
    loadBox = nil
  end
  local errorBox = displayErrorBox(tr('Login Error'), err)
  errorBox.onOk = EnterGame.show
end

function EnterGame.onLoginError(err)
  if loadBox then
    loadBox:destroy()
    loadBox = nil
  end
  local errorBox = displayErrorBox(tr('Login Error'), err)
  errorBox.onOk = EnterGame.show
  EnterGame.clearAccountFields()
end
