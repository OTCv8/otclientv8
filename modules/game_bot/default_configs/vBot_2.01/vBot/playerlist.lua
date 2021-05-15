setDefaultTab("Main")
  local listPanelName = "playerList"
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
  ui:setId(listPanelName)

  if not storage[listPanelName] then
    storage[listPanelName] = {
      enemyList = {},
      friendList = {},
      blackList = {},
      groupMembers = true,
      outfits = false,
      marks = false
    }
  end
  -- for backward compability
  if not storage[listPanelName].blackList then
    storage[listPanelName].blackList = {}
  end

  rootWidget = g_ui.getRootWidget()
  playerListWindow = g_ui.createWidget('PlayerListsWindow', rootWidget)
  playerListWindow:hide()

  playerListWindow.Members:setOn(storage[listPanelName].groupMembers)
  playerListWindow.Members.onClick = function(widget)
    storage[listPanelName].groupMembers = not storage[listPanelName].groupMembers
    widget:setOn(storage[listPanelName].groupMembers)
  end
  playerListWindow.Outfit:setOn(storage[listPanelName].outfits)
  playerListWindow.Outfit.onClick = function(widget)
    storage[listPanelName].outfits = not storage[listPanelName].outfits
    widget:setOn(storage[listPanelName].outfits)
  end
  playerListWindow.Marks:setOn(storage[listPanelName].marks)
  playerListWindow.Marks.onClick = function(widget)
    storage[listPanelName].marks = not storage[listPanelName].marks
    widget:setOn(storage[listPanelName].marks)
  end

  if storage[listPanelName].enemyList and #storage[listPanelName].enemyList > 0 then
    for _, name in ipairs(storage[listPanelName].enemyList) do
      local label = g_ui.createWidget("PlayerName", playerListWindow.EnemyList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[listPanelName].enemyList, label:getText())
        label:destroy()
      end
      label:setText(name)
    end
  end

  if storage[listPanelName].blackList and #storage[listPanelName].blackList > 0 then
    for _, name in ipairs(storage[listPanelName].blackList) do
      local label = g_ui.createWidget("PlayerName", playerListWindow.BlackList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[listPanelName].blackList, label:getText())
        label:destroy()
      end
      label:setText(name)
    end
  end

  playerListWindow.AddEnemy.onClick = function(widget)
    local friendName = playerListWindow.FriendName:getText()
    if friendName:len() > 0 and not table.contains(storage[listPanelName].enemyList, friendName, true) then
      table.insert(storage[listPanelName].enemyList, friendName)
      local label = g_ui.createWidget("PlayerName", playerListWindow.EnemyList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[listPanelName].enemyList, label:getText())
        label:destroy()
      end
      label:setText(friendName)
      playerListWindow.FriendName:setText('')
    end
  end

  if storage[listPanelName].friendList and #storage[listPanelName].friendList > 0 then
    for _, name in ipairs(storage[listPanelName].friendList) do
      local label = g_ui.createWidget("PlayerName", playerListWindow.FriendList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[listPanelName].friendList, label:getText())
        label:destroy()
      end
      label:setText(name)
    end
  end

  playerListWindow.AddFriend.onClick = function(widget)
    local friendName = playerListWindow.FriendName:getText()
    if friendName:len() > 0 and not table.contains(storage[listPanelName].friendList, friendName, true) then
      table.insert(storage[listPanelName].friendList, friendName)
      local label = g_ui.createWidget("PlayerName", playerListWindow.FriendList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[listPanelName].friendList, label:getText())
        label:destroy()
      end
      label:setText(friendName)
      playerListWindow.FriendName:setText('')
    end
  end
  
  playerListWindow.AddEnemy.onClick = function(widget)
    local enemyName = playerListWindow.EnemyName:getText()
    if enemyName:len() > 0 and not table.contains(storage[listPanelName].enemyList, enemyName, true) then
      table.insert(storage[listPanelName].enemyList, enemyName)
      local label = g_ui.createWidget("PlayerName", playerListWindow.EnemyList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[listPanelName].enemyList, label:getText())
        label:destroy()
      end
      label:setText(enemyName)
      playerListWindow.EnemyName:setText('')
    end
  end 

  playerListWindow.AddBlack.onClick = function(widget)
    local blackName = playerListWindow.BlackName:getText()
    if blackName:len() > 0 and not table.contains(storage[listPanelName].blackList, blackName, true) then
      table.insert(storage[listPanelName].blackList, blackName)
      local label = g_ui.createWidget("PlayerName", playerListWindow.BlackList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[listPanelName].blackList, label:getText())
        label:destroy()
      end
      label:setText(blackName)
      playerListWindow.BlackName:setText('')
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

local refreshStatus = function()
  for _, spec in ipairs(getSpectators()) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      if storage[listPanelName].outfits then
        local specOutfit = spec:getOutfit()
        if isFriend(spec:getName()) then
          spec:setMarked('#0000FF')
          specOutfit.head = 88
          specOutfit.body = 88
          specOutfit.legs = 88
          specOutfit.feet = 88
          spec:setOutfit(specOutfit)
        elseif isEnemy(spec:getName()) then
          spec:setMarked('#FF0000')
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
    creature:setMarked('#0000FF')
    specOutfit.head = 88
    specOutfit.body = 88
    specOutfit.legs = 88
    specOutfit.feet = 88
    creature:setOutfit(specOutfit)
  elseif isEnemy(specName) then
    creature:setMarked('#FF0000')
    specOutfit.head = 94
    specOutfit.body = 94
    specOutfit.legs = 94
    specOutfit.feet = 94
    creature:setOutfit(specOutfit)
  end
end

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