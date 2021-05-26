setDefaultTab("HP")
healPanelName = "healbot"
local ui = setupUI([[
Panel
  height: 38

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('HealBot')

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

  Button
    id: 1
    anchors.top: prev.bottom
    anchors.left: parent.left
    text: 1
    margin-right: 2
    margin-top: 4
    size: 17 17

  Button
    id: 2
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 2
    margin-left: 4
    size: 17 17
    
  Button
    id: 3
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 3
    margin-left: 4
    size: 17 17

  Button
    id: 4
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 4
    margin-left: 4
    size: 17 17 
    
  Button
    id: 5
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 5
    margin-left: 4
    size: 17 17
    
  Label
    id: name
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    anchors.right: parent.right
    text-align: center
    margin-left: 4
    height: 17
    text: Profile #1
    background: #292A2A
]])
ui:setId(healPanelName)

if not HealBotConfig[healPanelName] or not HealBotConfig[healPanelName][1] or #HealBotConfig[healPanelName] ~= 5 then
  HealBotConfig[healPanelName] = {
    [1] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #1",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
    [2] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #2",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
    [3] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #3",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
    [4] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #4",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
    [5] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #5",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
  }
end

if not HealBotConfig.currentHealBotProfile or HealBotConfig.currentHealBotProfile == 0 or HealBotConfig.currentHealBotProfile > 5 then 
  HealBotConfig.currentHealBotProfile = 1
end

-- finding correct table, manual unfortunately
local currentSettings
local setActiveProfile = function()
  local n = HealBotConfig.currentHealBotProfile
  currentSettings = HealBotConfig[healPanelName][n]
end
setActiveProfile()

local activeProfileColor = function()
  for i=1,5 do
    if i == HealBotConfig.currentHealBotProfile then
      ui[i]:setColor("green")
    else
      ui[i]:setColor("white")
    end
  end
end
activeProfileColor()

ui.title:setOn(currentSettings.enabled)
ui.title.onClick = function(widget)
currentSettings.enabled = not currentSettings.enabled
widget:setOn(currentSettings.enabled)
vBotConfigSave("heal")
end

ui.settings.onClick = function(widget)
  healWindow:show()
  healWindow:raise()
  healWindow:focus()
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  healWindow = UI.createWindow('HealWindow', rootWidget)
  healWindow:hide()

  local setProfileName = function()
    ui.name:setText(currentSettings.name)
  end
  healWindow.Name.onTextChange = function(widget, text)
    currentSettings.name = text
    setProfileName()
  end
  healWindow.Visible.onClick = function(widget)
    currentSettings.Visible = not currentSettings.Visible
    healWindow.Visible:setChecked(currentSettings.Visible)
  end
  healWindow.Cooldown.onClick = function(widget)
    currentSettings.Cooldown = not currentSettings.Cooldown
    healWindow.Cooldown:setChecked(currentSettings.Cooldown)
  end
  healWindow.Interval.onClick = function(widget)
    currentSettings.Interval = not currentSettings.Interval
    healWindow.Interval:setChecked(currentSettings.Interval)
  end
  healWindow.Conditions.onClick = function(widget)
    currentSettings.Conditions = not currentSettings.Conditions
    healWindow.Conditions:setChecked(currentSettings.Conditions)
  end
  healWindow.Delay.onClick = function(widget)
    currentSettings.Delay = not currentSettings.Delay
    healWindow.Delay:setChecked(currentSettings.Delay)
  end
  healWindow.MessageDelay.onClick = function(widget)
    currentSettings.MessageDelay = not currentSettings.MessageDelay
    healWindow.MessageDelay:setChecked(currentSettings.MessageDelay)
  end

  local refreshSpells = function()
    if currentSettings.spellTable then
      for i, child in pairs(healWindow.spells.spellList:getChildren()) do
        child:destroy()
      end
      for _, entry in pairs(currentSettings.spellTable) do
        local label = UI.createWidget("SpellEntry", healWindow.spells.spellList)
        label.enabled:setChecked(entry.enabled)
        label.enabled.onClick = function(widget)
          entry.enabled = not entry.enabled
          label.enabled:setChecked(entry.enabled)
        end
        label.remove.onClick = function(widget)
          table.removevalue(currentSettings.spellTable, entry)
          reindexTable(currentSettings.spellTable)
          label:destroy()
        end
        label:setText("(MP>" .. entry.cost .. ") " .. entry.origin .. entry.sign .. entry.value .. ":" .. entry.spell)
      end
    end
  end
  refreshSpells()

  local refreshItems = function()
    if currentSettings.itemTable then
      for i, child in pairs(healWindow.items.itemList:getChildren()) do
        child:destroy()
      end
      for _, entry in pairs(currentSettings.itemTable) do
        local label = UI.createWidget("SpellEntry", healWindow.items.itemList)
        label.enabled:setChecked(entry.enabled)
        label.enabled.onClick = function(widget)
          entry.enabled = not entry.enabled
          label.enabled:setChecked(entry.enabled)
        end
        label.remove.onClick = function(widget)
          table.removevalue(currentSettings.itemTable, entry)
          reindexTable(currentSettings.itemTable)
          label:destroy()
        end
        label:setText(entry.origin .. entry.sign .. entry.value .. ":" .. entry.item)
      end
    end
  end
  refreshItems()

  healWindow.spells.MoveUp.onClick = function(widget)
    local input = healWindow.spells.spellList:getFocusedChild()
    if not input then return end
    local index = healWindow.spells.spellList:getChildIndex(input)
    if index < 2 then return end

    local move
    if currentSettings.spellTable and #currentSettings.spellTable > 0 then
      for _, entry in pairs(currentSettings.spellTable) do
        if entry.index == index -1 then
          move = entry
        end
        if entry.index == index then
          move.index = index
          entry.index = index -1
        end
      end
    end
    table.sort(currentSettings.spellTable, function(a,b) return a.index < b.index end)

    healWindow.spells.spellList:moveChildToIndex(input, index - 1)
    healWindow.spells.spellList:ensureChildVisible(input)
  end

  healWindow.spells.MoveDown.onClick = function(widget)
    local input = healWindow.spells.spellList:getFocusedChild()
    if not input then return end
    local index = healWindow.spells.spellList:getChildIndex(input)
    if index >= healWindow.spells.spellList:getChildCount() then return end

    local move
    local move2
    if currentSettings.spellTable and #currentSettings.spellTable > 0 then
      for _, entry in pairs(currentSettings.spellTable) do
        if entry.index == index +1 then
          move = entry
        end
        if entry.index == index then
          move2 = entry
        end
      end
      if move and move2 then
        move.index = index
        move2.index = index + 1
      end
    end
    table.sort(currentSettings.spellTable, function(a,b) return a.index < b.index end)

    healWindow.spells.spellList:moveChildToIndex(input, index + 1)
    healWindow.spells.spellList:ensureChildVisible(input)
  end

  healWindow.items.MoveUp.onClick = function(widget)
    local input = healWindow.items.itemList:getFocusedChild()
    if not input then return end
    local index = healWindow.items.itemList:getChildIndex(input)
    if index < 2 then return end

    local move
    if currentSettings.itemTable and #currentSettings.itemTable > 0 then
      for _, entry in pairs(currentSettings.itemTable) do
        if entry.index == index -1 then
          move = entry
        end
        if entry.index == index then
          move.index = index
          entry.index = index - 1
        end
      end
    end
    table.sort(currentSettings.itemTable, function(a,b) return a.index < b.index end)

    healWindow.items.itemList:moveChildToIndex(input, index - 1)
    healWindow.items.itemList:ensureChildVisible(input)
  end

  healWindow.items.MoveDown.onClick = function(widget)
    local input = healWindow.items.itemList:getFocusedChild()
    if not input then return end
    local index = healWindow.items.itemList:getChildIndex(input)
    if index >= healWindow.items.itemList:getChildCount() then return end

    local move
    local move2
    if currentSettings.itemTable and #currentSettings.itemTable > 0 then
      for _, entry in pairs(currentSettings.itemTable) do
        if entry.index == index +1 then
          move = entry
        end
        if entry.index == index then
          move2 = entry
        end
      end
      if move and move2 then
        move.index = index
        move2.index = index + 1
      end
    end
    table.sort(currentSettings.itemTable, function(a,b) return a.index < b.index end)

    healWindow.items.itemList:moveChildToIndex(input, index + 1)
    healWindow.items.itemList:ensureChildVisible(input)
  end

  healWindow.spells.addSpell.onClick = function(widget)
 
    local spellFormula = healWindow.spells.spellFormula:getText():trim()
    local manaCost = tonumber(healWindow.spells.manaCost:getText())
    local spellTrigger = tonumber(healWindow.spells.spellValue:getText())
    local spellSource = healWindow.spells.spellSource:getCurrentOption().text
    local spellEquasion = healWindow.spells.spellCondition:getCurrentOption().text
    local source
    local equasion

    if not manaCost then  
      warn("HealBot: incorrect mana cost value!")       
      healWindow.spells.spellFormula:setText('')
      healWindow.spells.spellValue:setText('')
      healWindow.spells.manaCost:setText('') 
      return 
    end
    if not spellTrigger then  
      warn("HealBot: incorrect condition value!") 
      healWindow.spells.spellFormula:setText('')
      healWindow.spells.spellValue:setText('')
      healWindow.spells.manaCost:setText('')
      return 
    end

    if spellSource == "Current Mana" then
      source = "MP"
    elseif spellSource == "Current Health" then
      source = "HP"
    elseif spellSource == "Mana Percent" then
      source = "MP%"
    elseif spellSource == "Health Percent" then
      source = "HP%"
    else
      source = "burst"
    end
    
    if spellEquasion == "Above" then
      equasion = ">"
    elseif spellEquasion == "Below" then
      equasion = "<"
    else
      equasion = "="
    end

    if spellFormula:len() > 0 then
      table.insert(currentSettings.spellTable,  {index = #currentSettings.spellTable+1, spell = spellFormula, sign = equasion, origin = source, cost = manaCost, value = spellTrigger, enabled = true})
      healWindow.spells.spellFormula:setText('')
      healWindow.spells.spellValue:setText('')
      healWindow.spells.manaCost:setText('')
    end
    refreshSpells()
  end

  healWindow.items.addItem.onClick = function(widget)
 
    local id = healWindow.items.itemId:getItemId()
    local trigger = tonumber(healWindow.items.itemValue:getText())
    local src = healWindow.items.itemSource:getCurrentOption().text
    local eq = healWindow.items.itemCondition:getCurrentOption().text
    local source
    local equasion

    if not trigger then
      warn("HealBot: incorrect trigger value!")
      healWindow.items.itemId:setItemId(0)
      healWindow.items.itemValue:setText('')
      return
    end

    if src == "Current Mana" then
      source = "MP"
    elseif src == "Current Health" then
      source = "HP"
    elseif src == "Mana Percent" then
      source = "MP%"
    elseif src == "Health Percent" then
      source = "HP%"
    else
      source = "burst"
    end
    
    if eq == "Above" then
      equasion = ">"
    elseif eq == "Below" then
      equasion = "<"
    else
      equasion = "="
    end

    if id > 100 then
      table.insert(currentSettings.itemTable, {index = #currentSettings.itemTable+1,item = id, sign = equasion, origin = source, value = trigger, enabled = true})
      refreshItems()
      healWindow.items.itemId:setItemId(0)
      healWindow.items.itemValue:setText('')
    end
  end

  healWindow.closeButton.onClick = function(widget)
    healWindow:hide()
    vBotConfigSave("heal")
  end

  local loadSettings = function()
    ui.title:setOn(currentSettings.enabled)
    setProfileName()
    healWindow.Name:setText(currentSettings.name)
    refreshSpells()
    refreshItems()
    healWindow.Visible:setChecked(currentSettings.Visible)
    healWindow.Cooldown:setChecked(currentSettings.Cooldown)
    healWindow.Delay:setChecked(currentSettings.Delay)
    healWindow.MessageDelay:setChecked(currentSettings.MessageDelay)
    healWindow.Interval:setChecked(currentSettings.Interval)
    healWindow.Conditions:setChecked(currentSettings.Conditions)
  end
  loadSettings()

  local profileChange = function()
    setActiveProfile()
    activeProfileColor()
    loadSettings()
    vBotConfigSave("heal")
  end

  local resetSettings = function()
    currentSettings.enabled = false
    currentSettings.spellTable = {}
    currentSettings.itemTable = {}
    currentSettings.Visible = true
    currentSettings.Cooldown = true
    currentSettings.Delay = true
    currentSettings.MessageDelay = false
    currentSettings.Interval = true
    currentSettings.Conditions = true
    currentSettings.name = "Profile #" .. HealBotConfig.currentBotProfile
  end

  -- profile buttons
  for i=1,5 do
    local button = ui[i]
      button.onClick = function()
      HealBotConfig.currentHealBotProfile = i
      profileChange()
    end
  end

  healWindow.ResetSettings.onClick = function()
    resetSettings()
    loadSettings()
  end


  -- public functions
  HealBot = {} -- global table

  HealBot.isOn = function()
    return currentSettings.enabled
  end

  HealBot.isOff = function()
    return not currentSettings.enabled
  end

  HealBot.setOff = function()
    currentSettings.enabled = false
    ui.title:setOn(currentSettings.enabled)
    vBotConfigSave("atk")
  end

  HealBot.setOn = function()
    currentSettings.enabled = true
    ui.title:setOn(currentSettings.enabled)
    vBotConfigSave("atk")
  end

  HealBot.getActiveProfile = function()
    return HealBotConfig.currentHealBotProfile -- returns number 1-5
  end

  HealBot.setActiveProfile = function(n)
    if not n or not tonumber(n) or n < 1 or n > 5 then
      return error("[HealBot] wrong profile parameter! should be 1 to 5 is " .. n)
    else
      HealBotConfig.currentHealBotProfile = n
      profileChange()
    end
  end
end

-- spells
macro(100, function()
  if not currentSettings.enabled or modules.game_cooldown.isGroupCooldownIconActive(2) or #currentSettings.spellTable == 0 then return end

  for _, entry in pairs(currentSettings.spellTable) do
    if canCast(entry.spell, not currentSettings.Conditions, not currentSettings.Cooldown) and entry.enabled and entry.cost < mana() then
      if entry.origin == "HP%" then
        if entry.sign == "=" and hppercent() == entry.value then
          say(entry.spell)
          return
        elseif entry.sign == ">" and hppercent() >= entry.value then
          say(entry.spell)
          return
        elseif entry.sign == "<" and hppercent() <= entry.value then
          say(entry.spell)
          return
        end
      elseif entry.origin == "HP" then
        if entry.sign == "=" and hp() == entry.value then
          say(entry.spell)
          return
        elseif entry.sign == ">" and hp() >= entry.value then
          say(entry.spell)
          return
        elseif entry.sign == "<" and hp() <= entry.value then
          say(entry.spell)
          return
        end
      elseif entry.origin == "MP%" then
        if entry.sign == "=" and manapercent() == entry.value then
          say(entry.spell)
          return
        elseif entry.sign == ">" and manapercent() >= entry.value then
          say(entry.spell)
          return
        elseif entry.sign == "<" and manapercent() <= entry.value then
          say(entry.spell)
          return
        end
      elseif entry.origin == "MP" then
        if entry.sign == "=" and mana() == entry.value then
          say(entry.spell)
          return
        elseif entry.sign == ">" and mana() >= entry.value then
          say(entry.spell)
          return
        elseif entry.sign == "<" and mana() <= entry.value then
          say(entry.spell)
          return
        end    
      elseif entry.origin == "burst" then
        if entry.sign == "=" and burstDamageValue() == entry.value then
          say(entry.spell)
          return
        elseif entry.sign == ">" and burstDamageValue() >= entry.value then
          say(entry.spell)
          return
        elseif entry.sign == "<" and burstDamageValue() <= entry.value then
          say(entry.spell)
          return
        end    
      end
    end
  end  
end)

-- items
macro(100, function()
  if not currentSettings.enabled or #currentSettings.itemTable == 0 then return end
  if currentSettings.Delay and storage.isUsing then return end
  if currentSettings.MessageDelay and storage.isUsingPotion then return end

  if not currentSettings.MessageDelay then
    delay(400)
  end

  if TargetBot.isOn() and TargetBot.Looting.getStatus():len() > 0 and currentSettings.Interval then
    if not currentSettings.MessageDelay then
      delay(700)
    else
      delay(200)
    end
  end

  for _, entry in pairs(currentSettings.itemTable) do
    local item = findItem(entry.item)
    if (not currentSettings.Visible or item) and entry.enabled then
      if entry.origin == "HP%" then
        if entry.sign == "=" and hppercent() == entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == ">" and hppercent() >= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == "<" and hppercent() <= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        end
      elseif entry.origin == "HP" then
        if entry.sign == "=" and hp() == tonumberentry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == ">" and hp() >= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == "<" and hp() <= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        end
      elseif entry.origin == "MP%" then
        if entry.sign == "=" and manapercent() == entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == ">" and manapercent() >= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == "<" and manapercent() <= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        end
      elseif entry.origin == "MP" then
        if entry.sign == "=" and mana() == entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == ">" and mana() >= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == "<" and mana() <= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        end   
      elseif entry.origin == "burst" then
        if entry.sign == "=" and burstDamageValue() == entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == ">" and burstDamageValue() >= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        elseif entry.sign == "<" and burstDamageValue() <= entry.value then
          g_game.useInventoryItemWith(entry.item, player)
          return
        end   
      end
    end
  end
end)
UI.Separator()