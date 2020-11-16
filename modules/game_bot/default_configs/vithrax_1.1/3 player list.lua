  local listPanelName = "playerList"
  local ui = setupUI([[
Panel
  height: 18

  Button
    id: editList
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 18
    text: Player Lists
  ]], parent)
  ui:setId(listPanelName)

  if not storage[listPanelName] then
    storage[listPanelName] = {
      enemyList = {},
      friendList = {},
      groupMembers = true,
      outfits = false,
      marks = false
    }
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

  playerListWindow.AddFriend.onClick = function(widget)
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

  ui.editList.onClick = function(widget)
    playerListWindow:show()
    playerListWindow:raise()
    playerListWindow:focus()
  end
  playerListWindow.closeButton.onClick = function(widget)
    playerListWindow:hide()
  end

function refreshStatus()
  for _, spec in ipairs(getSpectators()) do
    if spec:isPlayer() and not spec:isLocalPlayer() then
      if storage[listPanelName].outfits then
        specOutfit = spec:getOutfit()
        if isEnemy(spec:getName()) then
          specOutfit.head = 112
          specOutfit.body = 112
          specOutfit.legs = 112
          specOutfit.feet = 112
          spec:setOutfit(specOutfit)
        elseif isFriend(spec:getName()) then
          specOutfit.head = 88
          specOutfit.body = 88
          specOutfit.legs = 88
          specOutfit.feet = 88
          spec:setOutfit(specOutfit)
        end
      end
    end
  end
end
refreshStatus()

onCreatureAppear(function(creature)
  if creature:isPlayer() then
   refreshStatus()
  end
end)

addSeparator()