setDefaultTab("Main")
  local panelName = "advancedFriendHealer"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Friend Healer')

  Button
    id: editList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
      
  ]], parent)
  ui:setId(panelName)

  if not storage[panelName] then
    storage[panelName] = {
      minMana = 60,
      minFriendHp = 40,
      spellName = "exura sio",
      spellHeal = true,
      distance = 8,
      itemHeal = true,
      id = 3160
    }
  end


  rootWidget = g_ui.getRootWidget()
  sioListWindow = g_ui.createWidget('SioListWindow', rootWidget)
  sioListWindow:hide()

  ui.title:setOn(storage[panelName].enabled)
  sioListWindow.spell:setOn(storage[panelName].spellHeal)
  sioListWindow.item:setOn(storage[panelName].itemHeal)  

  ui.title.onClick = function(widget)
    storage[panelName].enabled = not storage[panelName].enabled
    widget:setOn(storage[panelName].enabled)
  end

  ui.editList.onClick = function(widget)
    sioListWindow:show()
    sioListWindow:raise()
    sioListWindow:focus()
  end
  sioListWindow.spell.onClick = function(widget)
    storage[panelName].spellHeal = not storage[panelName].spellHeal
    widget:setOn(storage[panelName].spellHeal)
  end
  sioListWindow.item.onClick = function(widget)
    storage[panelName].itemHeal = not storage[panelName].itemHeal
    widget:setOn(storage[panelName].itemHeal)
  end
  sioListWindow.closeButton.onClick = function(widget)
    sioListWindow:hide()
  end
  sioListWindow.spellName.onTextChange = function(widget, text)
    storage[panelName].spellName = text
  end
  local updateMinManaText = function()
    sioListWindow.manaInfo:setText("Minimum Mana >= " .. storage[panelName].minMana .. "%")
  end
  local updateFriendHpText = function()
    sioListWindow.friendHp:setText("Heal Friend Below " .. storage[panelName].minFriendHp .. "% hp")  
  end
  local updateDistanceText = function()
    sioListWindow.distText:setText("Max Distance: " .. storage[panelName].distance)
  end
  sioListWindow.Distance.onValueChange = function(scroll, value)
    storage[panelName].distance = value
    updateDistanceText()
  end
  updateDistanceText()
  sioListWindow.minMana.onValueChange = function(scroll, value)
    storage[panelName].minMana = value
    updateMinManaText()
  end
  sioListWindow.minFriendHp.onValueChange = function(scroll, value)
    storage[panelName].minFriendHp = value

    updateFriendHpText()
  end
  sioListWindow.itemId:setItemId(storage[panelName].id)
  sioListWindow.itemId.onItemChange = function(widget)
    storage[panelName].id = widget:getItemId()
  end
  sioListWindow.spellName:setText(storage[panelName].spellName)
  sioListWindow.minMana:setValue(storage[panelName].minMana)
  sioListWindow.minFriendHp:setValue(storage[panelName].minFriendHp)
  sioListWindow.Distance:setValue(storage[panelName].distance)

  local healItem
  macro(200, function()
    if storage[panelName].enabled and storage[panelName].spellName:len() > 0 and manapercent() > storage[panelName].minMana then
      for _, spec in ipairs(getSpectators()) do
        if not spec:isLocalPlayer() then
          if spec:isPlayer() and storage[panelName].minFriendHp >= spec:getHealthPercent() and isFriend(spec:getName()) then
            if storage[panelName].spellHeal then
              saySpell(storage[panelName].spellName .. ' "' .. spec:getName(), 100)
              return
            end
            healItem = findItem(storage[panelName].id)
            if storage[panelName].itemHeal and distanceFromPlayer(spec:getPosition()) <= storage[panelName].distance and healItem then
              useWith(storage[panelName].id, spec)
              return
            end
          end
        end
      end
    end
  end)
addSeparator()