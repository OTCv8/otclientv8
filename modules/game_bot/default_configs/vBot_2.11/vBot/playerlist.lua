setDefaultTab("Main")
  local panelName = "playerList"
  local ui = setupUI([[
Panel
  height: 18

  Button
    id: editList
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    background: #292A2A
    height: 18
    text: Player Lists
  ]], parent)
  ui:setId(panelName)

  if not storage[panelName] then
    storage[panelName] = {
      enemyList = {},
      friendList = {},
      blackList = {},
      groupMembers = true,
      outfits = false,
      marks = false,
      highlight = false
    }
  end

  local config = storage[panelName]
  -- for backward compability
  if not config.blackList then
    config.blackList = {}
  end


  -- functions
  local function clearCachedPlayers()
    CachedFriends = {}
    CachedEnemies = {}
  end

  local refreshStatus = function()
    for _, spec in ipairs(getSpectators()) do
      if spec:isPlayer() and not spec:isLocalPlayer() then
        if config.outfits then
          local specOutfit = spec:getOutfit()
          if isFriend(spec:getName()) then
            if config.highlight then
              spec:setMarked('#0000FF')
            end
            specOutfit.head = 88
            specOutfit.body = 88
            specOutfit.legs = 88
            specOutfit.feet = 88
            if storage.BOTserver.outfit then
              local voc = BotServerMembers[spec:getName()]
              specOutfit.addons = 3 
              if voc == 1 then
                specOutfit.type = 131
              elseif voc == 2 then
                specOutfit.type = 129
              elseif voc == 3 then
                specOutfit.type = 130
              elseif voc == 4 then
                specOutfit.type = 144
              end
            end
            spec:setOutfit(specOutfit)
          elseif isEnemy(spec:getName()) then
            if config.highlight then
              spec:setMarked('#FF0000')
            end
            specOutfit.head = 94
            specOutfit.body = 94
            specOutfit.legs = 94
            specOutfit.feet = 94
            spec:setOutfit(specOutfit)
          end
        end
      end
    end
  end
  refreshStatus()

  local checkStatus = function(creature)
    if not creature:isPlayer() or creature:isLocalPlayer() then return end
  
    local specName = creature:getName()
    local specOutfit = creature:getOutfit()
  
    if isFriend(specName) then
      if config.highlight then
        creature:setMarked('#0000FF')
      end
      specOutfit.head = 88
      specOutfit.body = 88
      specOutfit.legs = 88
      specOutfit.feet = 88
      if storage.BOTserver.outfit then
        local voc = BotServerMembers[creature:getName()]
        specOutfit.addons = 3 
        if voc == 1 then
          specOutfit.type = 131
        elseif voc == 2 then
          specOutfit.type = 129
        elseif voc == 3 then
          specOutfit.type = 130
        elseif voc == 4 then
          specOutfit.type = 144
        end
      end
      creature:setOutfit(specOutfit)
    elseif isEnemy(specName) then
      if config.highlight then
        creature:setMarked('#FF0000')
      end
      specOutfit.head = 94
      specOutfit.body = 94
      specOutfit.legs = 94
      specOutfit.feet = 94
      creature:setOutfit(specOutfit)
    end
  end

  -- eof

  -- UI
  rootWidget = g_ui.getRootWidget()
  playerListWindow = UI.createWindow('PlayerListsWindow', rootWidget)
  playerListWindow:hide()

  playerListWindow.Members:setOn(config.groupMembers)
  playerListWindow.Members.onClick = function(widget)
    config.groupMembers = not config.groupMembers
    if not config then
      clearCachedPlayers()
    end
    refreshStatus()
    widget:setOn(config.groupMembers)
  end
  playerListWindow.Outfit:setOn(config.outfits)
  playerListWindow.Outfit.onClick = function(widget)
    config.outfits = not config.outfits
    widget:setOn(config.outfits)
  end
  playerListWindow.Marks:setOn(config.marks)
  playerListWindow.Marks.onClick = function(widget)
    config.marks = not config.marks
    widget:setOn(config.marks)
  end
  playerListWindow.Highlight:setOn(config.highlight)
  playerListWindow.Highlight.onClick = function(widget)
    config.highlight = not config.highlight
    widget:setOn(config.highlight)
  end

  if config.enemyList and #config.enemyList > 0 then
    for _, name in ipairs(config.enemyList) do
      local label = g_ui.createWidget("PlayerName", playerListWindow.EnemyList)
      label.remove.onClick = function(widget)
        table.removevalue(config.enemyList, label:getText())
        label:destroy()
      end
      label:setText(name)
    end
  end

  if config.blackList and #config.blackList > 0 then
    for _, name in ipairs(config.blackList) do
      local label = g_ui.createWidget("PlayerName", playerListWindow.BlackList)
      label.remove.onClick = function(widget)
        table.removevalue(config.blackList, label:getText())
        label:destroy()
      end
      label:setText(name)
    end
  end

  if config.friendList and #config.friendList > 0 then
    for _, name in ipairs(config.friendList) do
      local label = g_ui.createWidget("PlayerName", playerListWindow.FriendList)
      label.remove.onClick = function(widget)
        table.removevalue(config.friendList, label:getText())
        label:destroy()
      end
      label:setText(name)
    end
  end

  playerListWindow.AddFriend.onClick = function(widget)
    local friendName = playerListWindow.FriendName:getText()
    if friendName:len() > 0 and not table.contains(config.friendList, friendName, true) then
      table.insert(config.friendList, friendName)
      local label = g_ui.createWidget("PlayerName", playerListWindow.FriendList)
      label.remove.onClick = function(widget)
        table.removevalue(config.friendList, label:getText())
        label:destroy()
      end
      label:setText(friendName)
      playerListWindow.FriendName:setText('')
      clearCachedPlayers()
      refreshStatus()
    end
  end
  
  playerListWindow.AddEnemy.onClick = function(widget)
    local enemyName = playerListWindow.EnemyName:getText()
    if enemyName:len() > 0 and not table.contains(config.enemyList, enemyName, true) then
      table.insert(config.enemyList, enemyName)
      local label = g_ui.createWidget("PlayerName", playerListWindow.EnemyList)
      label.remove.onClick = function(widget)
        table.removevalue(config.enemyList, label:getText())
        label:destroy()
      end
      label:setText(enemyName)
      playerListWindow.EnemyName:setText('')
      clearCachedPlayers()
      refreshStatus()
    end
  end 

  playerListWindow.AddBlack.onClick = function(widget)
    local blackName = playerListWindow.BlackName:getText()
    if blackName:len() > 0 and not table.contains(config.blackList, blackName, true) then
      table.insert(config.blackList, blackName)
      local label = g_ui.createWidget("PlayerName", playerListWindow.BlackList)
      label.remove.onClick = function(widget)
        table.removevalue(config.blackList, label:getText())
        label:destroy()
      end
      label:setText(blackName)
      playerListWindow.BlackName:setText('')
      clearCachedPlayers()
      refreshStatus()
    end
  end 

  ui.editList.onClick = function(widget)
    playerListWindow:show()
    playerListWindow:raise()
    playerListWindow:focus()
  end
  playerListWindow.closeButton.onClick = function(widget)
    playerListWindow:hide()
  end


-- execution

onCreatureAppear(function(creature)
  checkStatus(creature)
end)

onPlayerPositionChange(function(x,y)
  if x.z ~= y.z then
    schedule(20, function()
      refreshStatus()
    end)
  end
end)