EnterGame = { }

-- private variables
local loadBox
local enterGame
local enterGameButton
local clientBox
local protocolLogin
local server = nil
local versionsFound = false

local customServerSelectorPanel
local serverSelectorPanel
local serverSelector
local clientVersionSelector
local serverHostTextEdit
local rememberPasswordBox
local protos = {"740", "760", "772", "792", "800", "810", "854", "860", "870", "910", "961", "1000", "1077", "1090", "1096", "1098", "1099", "1100", "1200", "1220"}

local checkedByUpdater = {}
local waitingForHttpResults = 0

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

local function onProxyList(protocol, proxies)
  for _, proxy in ipairs(proxies) do
    g_proxy.addProxy(proxy["host"], proxy["port"], proxy["priority"])
  end
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
  local missingFiles = false
  local versionForMissingFiles = 0
  if things ~= nil then
    local thingsNode = {}
    for thingtype, thingdata in pairs(things) do
      thingsNode[thingtype] = thingdata[1]
      if not g_resources.fileExists("/things/" .. thingdata[1]) then
        incorrectThings = incorrectThings .. "Missing file: " .. thingdata[1] .. "\n"
        missingFiles = true
        versionForMissingFiles = thingdata[1]:split("/")[1]
      else
        local localChecksum = g_resources.fileChecksum("/things/" .. thingdata[1]):lower()
        if localChecksum ~= thingdata[2]:lower() and #thingdata[2] > 1 then
          if g_resources.isLoadedFromArchive() then -- ignore checksum if it's test/debug version
            incorrectThings = incorrectThings .. "Invalid checksum of file: " .. thingdata[1] .. " (is " .. localChecksum .. ", should be " .. thingdata[2]:lower() .. ")\n"
          end
        end
      end
    end
    g_settings.setNode("things", thingsNode)
  else
    g_settings.setNode("things", {})
  end
  if missingFiles then
    incorrectThings = incorrectThings .. "\nYou should open data/things and create directory " .. versionForMissingFiles .. 
    ".\nIn this directory (data/things/" .. versionForMissingFiles .. ") you should put missing\nfiles (Tibia.dat and Tibia.spr/Tibia.cwm) " ..
    "from correct Tibia version."
  end
  return incorrectThings
end

local function onTibia12HTTPResult(session, playdata)
  local characters = {}
  local worlds = {}
  local account = {
    status = 0,
    subStatus = 0,
    premDays = 0
  }
  if session["status"] ~= "active" then
    account.status = 1
  end
  if session["ispremium"] then
    account.subStatus = 1 -- premium
  end
  if session["premiumuntil"] > g_clock.seconds() then
    account.subStatus = math.floor((session["premiumuntil"] - g_clock.seconds()) / 86400)
  end
    
  local things = {
    data = {G.clientVersion .. "/Tibia.dat", ""},
    sprites = {G.clientVersion .. "/Tibia.cwm", ""},
  }

  local incorrectThings = validateThings(things)
  if #incorrectThings > 0 then
    things = {
      data = {G.clientVersion .. "/Tibia.dat", ""},
      sprites = {G.clientVersion .. "/Tibia.spr", ""},
    }  
    incorrectThings = validateThings(things)
  end
  
  if #incorrectThings > 0 then
    g_logger.error(incorrectThings)
    if Updater and not checkedByUpdater[G.clientVersion] then
      checkedByUpdater[G.clientVersion] = true
      return Updater.check({
        version = G.clientVersion,
        host = G.host
      })
    else
      return EnterGame.onError(incorrectThings)
    end
  end
  
  onSessionKey(nil, session["sessionkey"])
  
  for _, world in pairs(playdata["worlds"]) do
    worlds[world.id] = {
      name = world.name,
      port = world.externalportunprotected or world.externalportprotected or world.externaladdress,
      address = world.externaladdressunprotected or world.externaladdressprotected or world.externalport
    }
  end
  
  for _, character in pairs(playdata["characters"]) do
    local world = worlds[character.worldid]
    if world then
      table.insert(characters, {
        name = character.name,
        worldName = world.name,
        worldIp = world.address,
        worldPort = world.port
      })
    end
  end
  
  -- proxies
  if g_proxy then
    g_proxy.clear()
    if playdata["proxies"] then
      for i, proxy in ipairs(playdata["proxies"]) do
        g_proxy.addProxy(proxy["host"], tonumber(proxy["port"]), tonumber(proxy["priority"]))
      end
    end
  end
  
  g_game.setCustomProtocolVersion(0)
  g_game.chooseRsa(G.host)
  g_game.setClientVersion(G.clientVersion)
  g_game.setProtocolVersion(g_game.getClientProtocolVersion(G.clientVersion))
  g_game.setCustomOs(-1) -- disable
  if not g_game.getFeature(GameExtendedOpcode) then
    g_game.setCustomOs(5) -- set os to windows if opcodes are disabled
  end
  
  onCharacterList(nil, characters, account, nil)  
end

local function onHTTPResult(data, err)
  if waitingForHttpResults == 0 then
    return
  end
  
  waitingForHttpResults = waitingForHttpResults - 1
  if err and waitingForHttpResults > 0 then
    return -- ignore, wait for other requests
  end

  if err then
    return EnterGame.onError(err)
  end
  waitingForHttpResults = 0 
  if data['error'] and data['error']:len() > 0 then
    return EnterGame.onLoginError(data['error'])
  elseif data['errorMessage'] and data['errorMessage']:len() > 0 then
    return EnterGame.onLoginError(data['errorMessage'])
  end
  
  if type(data["session"]) == "table" and type(data["playdata"]) == "table" then
    return onTibia12HTTPResult(data["session"], data["playdata"])
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
    return EnterGame.onError(incorrectThings)
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
        g_proxy.addProxy(proxy["host"], tonumber(proxy["port"]), tonumber(proxy["priority"]))
      end
    end
  end
  
  onCharacterList(nil, characters, account, nil)  
end


-- public functions
function EnterGame.init()
  if USE_NEW_ENERGAME then return end
  enterGame = g_ui.displayUI('entergame')
  
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
    
  g_keyboard.bindKeyDown('Ctrl+G', EnterGame.openWindow)

  if g_game.isOnline() then
    return EnterGame.hide()
  end

  scheduleEvent(function()
    EnterGame.show()
  end, 100)
end

function EnterGame.terminate()
  if not enterGame then return end
  g_keyboard.unbindKeyDown('Ctrl+G')
  
  enterGame:destroy()
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
  if not enterGame then return end
  enterGame:show()
  enterGame:raise()
  enterGame:focus()
  enterGame:getChildById('accountNameTextEdit'):focus()
end

function EnterGame.hide()
  if not enterGame then return end
  enterGame:hide()
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
  enterGame:getChildById('accountTokenTextEdit'):clearText()
  enterGame:getChildById('accountNameTextEdit'):focus()
  g_settings.remove('account')
  g_settings.remove('password')
end

function EnterGame.onServerChange()
  server = serverSelector:getText()
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
    if type(Servers[server]) == "table" then
      serverHostTextEdit:setText(Servers[server][1])
    else
      serverHostTextEdit:setText(Servers[server])
    end
  end
end

function EnterGame.doLogin(account, password, token, host)
  if g_game.isOnline() then
    local errorBox = displayErrorBox(tr('Login Error'), tr('Cannot login while already in game.'))
    connect(errorBox, { onOk = EnterGame.show })
    return
  end
  
  G.account = account or enterGame:getChildById('accountNameTextEdit'):getText()
  G.password = password or enterGame:getChildById('accountPasswordTextEdit'):getText()
  G.authenticatorToken = token or enterGame:getChildById('accountTokenTextEdit'):getText()
  G.stayLogged = true
  G.server = serverSelector:getText():trim()
  G.host = host or serverHostTextEdit:getText()
  G.clientVersion = tonumber(clientVersionSelector:getText())  
 
  if not rememberPasswordBox:isChecked() then
    g_settings.set('account', G.account)
    g_settings.set('password', G.password)  
  end
  g_settings.set('host', G.host)
  g_settings.set('server', G.server)
  g_settings.set('client-version', G.clientVersion)
  g_settings.save()

  local server_params = G.host:split(":")
  if G.host:lower():find("http") ~= nil then
    if #server_params >= 4 then
      G.host = server_params[1] .. ":" .. server_params[2] .. ":" .. server_params[3] 
      G.clientVersion = tonumber(server_params[4])
    elseif #server_params >= 3 then
      if tostring(tonumber(server_params[3])) == server_params[3] then
        G.host = server_params[1] .. ":" .. server_params[2] 
        G.clientVersion = tonumber(server_params[3])
      end
    end
    return EnterGame.doLoginHttp()      
  end
  
  local server_ip = server_params[1]
  local server_port = 7171
  if #server_params >= 2 then
    server_port = tonumber(server_params[2])
  end
  if #server_params >= 3 then
    G.clientVersion = tonumber(server_params[3])
  end
  if type(server_ip) ~= 'string' or server_ip:len() <= 3 or not server_port or not G.clientVersion then
    return EnterGame.onError("Invalid server, it should be in format IP:PORT or it should be http url to login script")  
  end
  
  local things = {
    data = {G.clientVersion .. "/Tibia.dat", ""},
    sprites = {G.clientVersion .. "/Tibia.cwm", ""},
  }
  
  local incorrectThings = validateThings(things)
  if #incorrectThings > 0 then
    things = {
      data = {G.clientVersion .. "/Tibia.dat", ""},
      sprites = {G.clientVersion .. "/Tibia.spr", ""},
    }  
    incorrectThings = validateThings(things)
  end
  if #incorrectThings > 0 then
    g_logger.error(incorrectThings)
    if Updater and not checkedByUpdater[G.clientVersion] then
      checkedByUpdater[G.clientVersion] = true
      return Updater.check({
        version = G.clientVersion,
        host = G.host
      })
    else
      return EnterGame.onError(incorrectThings)
    end
  end

  protocolLogin = ProtocolLogin.create()
  protocolLogin.onLoginError = onProtocolError
  protocolLogin.onSessionKey = onSessionKey
  protocolLogin.onCharacterList = onCharacterList
  protocolLogin.onUpdateNeeded = onUpdateNeeded
  protocolLogin.onProxyList = onProxyList

  EnterGame.hide()
  loadBox = displayCancelBox(tr('Please wait'), tr('Connecting to login server...'))
  connect(loadBox, { onCancel = function(msgbox)
                                  loadBox = nil
                                  protocolLogin:cancelLogin()
                                  EnterGame.show()
                                end })

  if G.clientVersion == 1000 then -- some people don't understand that tibia 10 uses 1100 protocol
    G.clientVersion = 1100
  end
  -- if you have custom rsa or protocol edit it here
  g_game.setClientVersion(G.clientVersion)
  g_game.setProtocolVersion(g_game.getClientProtocolVersion(G.clientVersion))
  g_game.setCustomProtocolVersion(0)
  g_game.setCustomOs(-1) -- disable
  g_game.chooseRsa(G.host)
  if #server_params <= 3 and not g_game.getFeature(GameExtendedOpcode) then
    g_game.setCustomOs(2) -- set os to windows if opcodes are disabled
  end

  -- extra features from init.lua
  for i = 4, #server_params do
    g_game.enableFeature(tonumber(server_params[i]))
  end
  
  -- proxies
  if g_proxy then
    g_proxy.clear()
  end
  
  if modules.game_things.isLoaded() then
    g_logger.info("Connecting to: " .. server_ip .. ":" .. server_port)
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
    type = "login",
    account = G.account,
    accountname = G.account,
    email = G.account,
    password = G.password,
    accountpassword = G.password,
    token = G.authenticatorToken,
    version = APP_VERSION,
    uid = G.UUID,
    stayloggedin = true
  }
  
  local server = serverSelector:getText()
  if Servers and Servers[server] ~= nil then
    if type(Servers[server]) == "table" then
      local urls = Servers[server]      
      waitingForHttpResults = #urls
      for _, url in ipairs(urls) do
        HTTP.postJSON(url, data, onHTTPResult)
      end
    else
      waitingForHttpResults = 1
      HTTP.postJSON(G.host, data, onHTTPResult)    
    end
  end
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
  if err:lower():find("invalid") or err:lower():find("not correct") or err:lower():find("or password") then
    EnterGame.clearAccountFields()
  end
end
