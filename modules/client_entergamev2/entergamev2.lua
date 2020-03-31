local entergameWindow
local characterGroup
local outfitGroup
local protocol
local infoBox
local loadingBox

function init()
  if not USE_NEW_ENERGAME then return end
  entergameWindow = g_ui.displayUI('entergamev2')
  
  entergameWindow.news:hide()
  entergameWindow.quick:hide()
  entergameWindow.registration:hide()
  entergameWindow.characters:hide()
  entergameWindow.createcharacter:hide()
  entergameWindow.settings:hide()
  
  -- entergame
  entergameWindow.entergame.register.onClick = function()
    entergameWindow.registration:show()
    entergameWindow.entergame:hide()
  end
  entergameWindow.entergame.mainPanel.button.onClick = login
  
  -- registration
  entergameWindow.registration.back.onClick = function()
    entergameWindow.registration:hide()
    entergameWindow.entergame:show()
  end
  
  -- characters
  --- outfits
  entergameWindow.characters.mainPanel.showOutfits.onClick = function()
    local status = not (entergameWindow.characters.mainPanel.showOutfits:isOn())
    g_settings.set('showOutfits', status)
    entergameWindow.characters.mainPanel.showOutfits:setOn(status)
    if status then
      entergameWindow.characters.mainPanel.outfitsPanel:show()
      entergameWindow.characters.mainPanel.outfitsScroll:show()
      entergameWindow.characters.mainPanel.charactersPanel:hide()
      entergameWindow.characters.mainPanel.charactersScroll:hide()      
    else
      entergameWindow.characters.mainPanel.outfitsPanel:hide()
      entergameWindow.characters.mainPanel.outfitsScroll:hide()    
      entergameWindow.characters.mainPanel.charactersPanel:show()
      entergameWindow.characters.mainPanel.charactersScroll:show()      
    end
  end
  
  local showOutfits = g_settings.getBoolean("showOutfits", false)
  entergameWindow.characters.mainPanel.showOutfits:setOn(showOutfits)
  if showOutfits then
    entergameWindow.characters.mainPanel.charactersPanel:hide()
    entergameWindow.characters.mainPanel.charactersScroll:hide()        
  else
    entergameWindow.characters.mainPanel.outfitsPanel:hide()
    entergameWindow.characters.mainPanel.outfitsScroll:hide()    
  end
  
  --- auto reconnect
  entergameWindow.characters.mainPanel.autoReconnect.onClick = function()
    local status = (not entergameWindow.characters.mainPanel.autoReconnect:isOn())
    g_settings.set('autoReconnect', status)
    entergameWindow.characters.mainPanel.autoReconnect:setOn(status)
  end
  local autoReconnect = g_settings.getBoolean("autoReconnect", true)
  entergameWindow.characters.mainPanel.autoReconnect:setOn(autoReconnect)
  
  --- buttons
  entergameWindow.characters.logout.onClick = function()
    protocol:logout()
    entergameWindow.characters:hide()
    entergameWindow.entergame:show()  
    entergameWindow.entergame.mainPanel.account:setText("")
    entergameWindow.entergame.mainPanel.password:setText("")
  end
  entergameWindow.characters.createcharacter.onClick = function()
    entergameWindow.characters:hide()
    entergameWindow.createcharacter:show()
    entergameWindow.createcharacter.mainPanel.name:setText("")
  end
  entergameWindow.characters.settings.onClick = function()
    entergameWindow.characters:hide()
    entergameWindow.settings:show()
  end  
  
  -- create character
  entergameWindow.createcharacter.back.onClick = function()
    entergameWindow.createcharacter:hide()
    entergameWindow.characters:show()
  end
  entergameWindow.createcharacter.mainPanel.createButton.onClick = createcharacter

  entergameWindow.settings.back.onClick = function()
    entergameWindow.settings:hide()
    entergameWindow.characters:show()
  end
  entergameWindow.settings.mainPanel.updateButton.onClick = updateSettings
  
  -- pick server
  local server = nil
  if type(Servers) == "table" then
    for name, url in pairs(Servers) do
      server = url
    end
  elseif type(Servers) == "string" then
    server = Servers
  elseif type(Server) == "string" then
    server = Server
  end
  
  if not server then
    message("Configuration error", "You must set server url in init.lua!\nExample:\nServer = \"ws://otclient.ovh:8000\"")
    return
  end
    
  -- init protocol
  -- token is random string
  local session = g_crypt.sha1Encode("" .. math.random() .. g_clock.realMicros() .. tostring(G.UUID) .. g_platform.getCPUName() .. g_platform.getProcessId())
  protocol = EnterGameV2Protocol.new(session)
  if not protocol:setUrl(server) then
    return message("Configuration error", "Invalid url for entergamev2:\n" .. server)
  end
  
  protocol.onLogin = onLogin
  protocol.onLogout = logout
  protocol.onMessage = serverMessage
  protocol.onLoading = showLoading
  protocol.onQAuth = updateQAuth
  protocol.onCharacters = updateCharacters
  protocol.onNews = updateNews
  protocol.onMotd = updateMotd
  protocol.onCharacterCreate = onCharacterCreate
  
  -- game stuff
  connect(g_game, { onLoginError = onLoginError,
    onLoginToken = onLoginToken ,
    onUpdateNeeded = onUpdateNeeded,
    onConnectionError = onConnectionError,
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
    onLoginWait = onLoginWait,
    onLogout = onLogout
  })
  
  if g_game.isOnline() then
    onGameStart()
  end
end

function terminate()
  if not USE_NEW_ENERGAME then return end
  if protocol then
    protocol:destroy()
    protocol = nil
  end
  if infoBox then
    infoBox:destroy()
    infoBox = nil
  end
  if loadingBox then
    loadingBox:destroy()
    loadingBox = nil
  end
  if characterGroup then
    characterGroup:destroy()
    characterGroup = nil
  end
  if outfitGroup then
    outfitGroup:destroy()
    outfitGroup = nil
  end
  entergameWindow:destroy()
  entergameWindow = nil
  
  disconnect(g_game, { onLoginError = onLoginError,
    onLoginToken = onLoginToken ,
    onUpdateNeeded = onUpdateNeeded,
    onConnectionError = onConnectionError,
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
    onLoginWait = onLoginWait,
    onLogout = onLogout
  })  
end

function show()

end

function hide()

end

function message(title, text)
  if infoBox then
    infoBox:destroy()
  end
  
  infoBox = displayInfoBox(title, text)
  infoBox.onDestroy = function(widget)
    if widget == infoBox then
      infoBox = nil
    end
  end
  infoBox:show()
  infoBox:raise()
  infoBox:focus()
end

function showLoading(titie, text)
  if loadingBox then
    loadingBox:destroy()
  end
  
  local callback = function() end -- do nothing
  loadingBox = displayGeneralBox(titie, text, {}, callback, callback)
  loadingBox.onDestroy = function(widget)
    if widget == loadingBox then
      loadingBox = nil
    end
  end
  loadingBox:show()
  loadingBox:raise()
  loadingBox:focus()  
end

function serverMessage(title, text)
  return message(title, text)
end

function updateCharacters(characters)
  if outfitGroup then
    outfitGroup:destroy()
  end
  if characterGroup then
    characterGroup:destroy()
  end
  entergameWindow.characters.mainPanel.charactersPanel:destroyChildren()
  entergameWindow.characters.mainPanel.outfitsPanel:destroyChildren()
  
  outfitGroup = UIRadioGroup.create()
  characterGroup = UIRadioGroup.create()
  for i, character in ipairs(characters) do
    local characterWidget = g_ui.createWidget('EntergameCharacter', entergameWindow.characters.mainPanel.charactersPanel)
    characterGroup:addWidget(characterWidget)
    local outfitWidget = g_ui.createWidget('EntergameBigCharacter', entergameWindow.characters.mainPanel.outfitsPanel)
    outfitGroup:addWidget(outfitWidget)
    for i, widget in ipairs({characterWidget, outfitWidget}) do
      widget.character = character
      widget.outfit:setOutfit(character["outfit"])    
      widget.line1:setText(character["line1"])
      widget.line2:setText(character["line2"])
      widget.line3:setText(character["line3"])
    end
  end
  if #characters > 1 then
    characterGroup:selectWidget(entergameWindow.characters.mainPanel.charactersPanel:getFirstChild())
    outfitGroup:selectWidget(entergameWindow.characters.mainPanel.outfitsPanel:getFirstChild())
  end
end

function updateQAuth(token)
  if not token or token:len() == 0 then
    return entergameWindow.quick:hide()
  end
  entergameWindow.quick:show()
  entergameWindow.quick.qrcode:setQRCode(token, 1)
  entergameWindow.quick.qrcode.onClick = function()
    g_platform.openUrl(token)
  end
  entergameWindow.quick.quathlogo.onClick = entergameWindow.quick.qrcode.onClick
end

function updateNews(news)
  if not news or #news == 0 then
    return entergameWindow.news:hide()
  end
  entergameWindow.news:show()
  entergameWindow.news.content:destroyChildren()
  for i, entry in ipairs(news) do
    local title = entry["title"]
    local text = entry["text"]
    local image = entry["image"]
    if title then
      local newsLabel = g_ui.createWidget('NewsLabel', entergameWindow.news.content)
      newsLabel:setText(title)
    end
    if text ~= nil then
      local newsText = g_ui.createWidget('NewsText', entergameWindow.news.content)  
      newsText:setText(text)
    end    
  end
end

function updateMotd(text)
  if not text or text:len() == 0 then
    return entergameWindow.characters.mainPanel.motd:hide()
  end
  entergameWindow.characters.mainPanel.motd:show()
  entergameWindow.characters.mainPanel.motd:setText(text)
end

function login()
  local account = entergameWindow.entergame.mainPanel.account:getText()
  local password = entergameWindow.entergame.mainPanel.password:getText()
  entergameWindow.entergame:hide()
  showLoading("Login", "Connecting to server...")
  protocol:login(account, password, "")
end

function onLogin(data)
  if loadingBox then
    loadingBox:destroy()
    loadingBox = nil
  end

  if data["error"] and data["error"]:len() > 0 then
    entergameWindow.entergame:show()
    return message("Login error", data["error"])
  end

  local incorrectThings = validateThings(data["things"])
  if incorrectThings:len() > 0 then
    entergameWindow.entergame:show()
    return message("Login error - missing things", incorrectThings)
  end
  
  if infoBox then
    infoBox:destroy()
  end
  
  local version = data["version"]  
  G.clientVersion = version
  g_game.setClientVersion(version)
  g_game.setProtocolVersion(g_game.getClientProtocolVersion(version))  
  g_game.setCustomOs(-1) -- disable custom os
  
  local customProtocol = data["customProtocol"]
  g_game.setCustomProtocolVersion(0)
  if type(customProtocol) == 'number' then
    g_game.setCustomProtocolVersion(customProtocol)    
  end
  
  local email = data["email"]
  local security = data["security"]
  entergameWindow.settings.mainPanel.email:setText(email)
  entergameWindow.settings.mainPanel.security:setCurrentIndex(math.max(1, security))  
  
  entergameWindow.characters:show()
  entergameWindow.entergame:hide()
end

function logout()
  if not entergameWindow.characters:isVisible() and not entergameWindow.createcharacter:isVisible() then
    return
  end
  entergameWindow.characters:hide()
  entergameWindow.createcharacter:hide()
  entergameWindow.entergame:show()  
  message("Information", "Session expired, you has been logged out.")
end

function validateThings(things)
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
    ".\nIn this directory (data/things/" .. versionForMissingFiles .. ") you should put missing\nfiles (Tibia.dat and Tibia.spr) " ..
    "from correct Tibia version."
  end
  return incorrectThings
end

function doGameLogin()
  local selected = nil
  if entergameWindow.characters.mainPanel.charactersPanel:isVisible() then
    selected = characterGroup:getSelectedWidget()
  else
    selected = outfitGroup:getSelectedWidget()
  end
  if not selected then 
    return message("Entergame error", "Please select character")
  end
  local character = selected.character
  if not g_game.getFeature(GameSessionKey) then
    g_game.enableFeature(GameSessionKey)
  end
  g_game.loginWorld("", "", character.worldName, character.worldHost, character.worldPort, character.name, "", protocol.session)
end

function onLoginError(err)
  message("Login error", err)
end

function onLoginToken()

end

function onUpdateNeeded(signature)

end

function onConnectionError(message, code)

end

function onGameStart()
  entergameWindow:hide()
end

function onGameEnd()
  entergameWindow:show()
end

function onLoginWait(message, time)

end

function onLogout()

end

function createcharacter()
  local name = entergameWindow.createcharacter.mainPanel.name:getText()
  local gender = entergameWindow.createcharacter.mainPanel.gender:getCurrentOption().text
  local vocation = entergameWindow.createcharacter.mainPanel.vocation:getCurrentOption().text
  local town = entergameWindow.createcharacter.mainPanel.town:getCurrentOption().text
  if name:len() < 3 or name:len() > 20 then
    return message("Error", "Invalid character name")
  end
  protocol:createCharacter(name, gender, vocation, town)
  showLoading("Creating character", "Creating new character...")
end

function onCharacterCreate(err, msg)
  if loadingBox then
    loadingBox:destroy()
    loadingBox = nil
  end

  if err then
    return message("Error", err)
  end
  message("Success", msg)
  entergameWindow.createcharacter:hide()
  entergameWindow.characters:show()
end

function updateSettings()
  local email = entergameWindow.settings.mainPanel.email:getText()
  local security = entergameWindow.settings.mainPanel.security.currentIndex  
  
  protocol:updateSettings({
    email=email,
    security=security
  })
  
  entergameWindow.settings:hide()
  entergameWindow.characters:show()
end