setDefaultTab("HP")
storage.lootStatus = ""
healPanelName = "healbot"
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('HealBot')

  Button
    id: combos
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

]])
ui:setId(healPanelName)

if not storage[healPanelName] or not storage[healPanelName].spellTable or not storage[healPanelName].itemTable then
  storage[healPanelName] = {
    enabled = false,
    spellTable = {},
    itemTable = {}
  }
end

ui.title:setOn(storage[healPanelName].enabled)
ui.title.onClick = function(widget)
storage[healPanelName].enabled = not storage[healPanelName].enabled
widget:setOn(storage[healPanelName].enabled)
end

ui.combos.onClick = function(widget)
  healWindow:show()
  healWindow:raise()
  healWindow:focus()
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  healWindow = g_ui.createWidget('HealWindow', rootWidget)
  healWindow:hide()

  local refreshSpells = function()
    if storage[healPanelName].spellTable and #storage[healPanelName].spellTable > 0 then
      for i, child in pairs(healWindow.spells.spellList:getChildren()) do
        child:destroy()
      end
      for _, entry in pairs(storage[healPanelName].spellTable) do
        local label = g_ui.createWidget("SpellEntry", healWindow.spells.spellList)
        label.enabled:setChecked(entry.enabled)
        label.enabled.onClick = function(widget)
          entry.enabled = not entry.enabled
          label.enabled:setChecked(entry.enabled)
        end
        label.remove.onClick = function(widget)
          table.removevalue(storage[healPanelName].spellTable, entry)
          reindexTable(storage[healPanelName].spellTable)
          label:destroy()
        end
        label:setText("(MP>" .. entry.cost .. ") " .. entry.origin .. entry.sign .. entry.value .. ":" .. entry.spell)
      end
    end
  end
  refreshSpells()

  local refreshItems = function()
    if storage[healPanelName].itemTable and #storage[healPanelName].itemTable > 0 then
      for i, child in pairs(healWindow.items.itemList:getChildren()) do
        child:destroy()
      end
      for _, entry in pairs(storage[healPanelName].itemTable) do
        local label = g_ui.createWidget("SpellEntry", healWindow.items.itemList)
        label.enabled:setChecked(entry.enabled)
        label.enabled.onClick = function(widget)
          entry.enabled = not entry.enabled
          label.enabled:setChecked(entry.enabled)
        end
        label.remove.onClick = function(widget)
          table.removevalue(storage[healPanelName].itemTable, entry)
          reindexTable(storage[healPanelName].itemTable)
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
    if storage[healPanelName].spellTable and #storage[healPanelName].spellTable > 0 then
      for _, entry in pairs(storage[healPanelName].spellTable) do
        if entry.index == index -1 then
          move = entry
        end
        if entry.index == index then
          move.index = index
          entry.index = index -1
        end
      end
    end
    table.sort(storage[healPanelName].spellTable, function(a,b) return a.index < b.index end)

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
    if storage[healPanelName].spellTable and #storage[healPanelName].spellTable > 0 then
      for _, entry in pairs(storage[healPanelName].spellTable) do
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
    table.sort(storage[healPanelName].spellTable, function(a,b) return a.index < b.index end)

    healWindow.spells.spellList:moveChildToIndex(input, index + 1)
    healWindow.spells.spellList:ensureChildVisible(input)
  end

  healWindow.items.MoveUp.onClick = function(widget)
    local input = healWindow.items.itemList:getFocusedChild()
    if not input then return end
    local index = healWindow.items.itemList:getChildIndex(input)
    if index < 2 then return end

    local move
    if storage[healPanelName].itemTable and #storage[healPanelName].itemTable > 0 then
      for _, entry in pairs(storage[healPanelName].itemTable) do
        if entry.index == index -1 then
          move = entry
        end
        if entry.index == index then
          move.index = index
          entry.index = index - 1
        end
      end
    end
    table.sort(storage[healPanelName].itemTable, function(a,b) return a.index < b.index end)

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
    if storage[healPanelName].itemTable and #storage[healPanelName].itemTable > 0 then
      for _, entry in pairs(storage[healPanelName].itemTable) do
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
    table.sort(storage[healPanelName].itemTable, function(a,b) return a.index < b.index end)

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
    else
      source = "HP%"
    end
    
    if spellEquasion == "Above" then
      equasion = ">"
    elseif spellEquasion == "Below" then
      equasion = "<"
    else
      equasion = "="
    end

    if spellFormula:len() > 0 then
      table.insert(storage[healPanelName].spellTable,  {index = #storage[healPanelName].spellTable+1, spell = spellFormula, sign = equasion, origin = source, cost = manaCost, value = spellTrigger, enabled = true})
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
    else
      source = "HP%"
    end
    
    if eq == "Above" then
      equasion = ">"
    elseif eq == "Below" then
      equasion = "<"
    else
      equasion = "="
    end

    if id > 100 then
      table.insert(storage[healPanelName].itemTable, {index = #storage[healPanelName].itemTable+1,item = id, sign = equasion, origin = source, value = trigger, enabled = true})
      refreshItems()
      healWindow.items.itemId:setItemId(0)
      healWindow.items.itemValue:setText('')
    end
  end

  healWindow.closeButton.onClick = function(widget)
    healWindow:hide()
  end
end

-- spells
macro(100, function()
  if not storage[healPanelName].enabled or modules.game_cooldown.isGroupCooldownIconActive(2) or #storage[healPanelName].spellTable == 0 then return end

  for _, entry in pairs(storage[healPanelName].spellTable) do
    if canCast(entry.spell) and entry.enabled then
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
      end
    end
  end  
end)

-- items
macro(500, function()
  if TargetBot.isOff() then storage.lootStatus = "" end
  if not storage[healPanelName].enabled or storage.isUsing or #storage[healPanelName].itemTable == 0 then return end

  if storage.lootStatus:len() > 0 then
    delay(500)
  end
  for _, entry in pairs(storage[healPanelName].itemTable) do
    local item = findItem(entry.item)
    if item and entry.enabled then
      if entry.origin == "HP%" then
        if entry.sign == "=" and hppercent() == entry.value then
          useWith(entry.item, player)
          return
        elseif entry.sign == ">" and hppercent() >= entry.value then
          useWith(entry.item, player)
          return
        elseif entry.sign == "<" and hppercent() <= entry.value then
          useWith(entry.item, player)
          return
        end
      elseif entry.origin == "HP" then
        if entry.sign == "=" and hp() == tonumberentry.value then
          useWith(entry.item, player)
          return
        elseif entry.sign == ">" and hp() >= entry.value then
          useWith(entry.item, player)
          return
        elseif entry.sign == "<" and hp() <= entry.value then
          useWith(entry.item, player)
          return
        end
      elseif entry.origin == "MP%" then
        if entry.sign == "=" and manapercent() == entry.value then
          useWith(entry.item, player)
          return
        elseif entry.sign == ">" and manapercent() >= entry.value then
          useWith(entry.item, player)
          return
        elseif entry.sign == "<" and manapercent() <= entry.value then
          useWith(entry.item, player)
          return
        end
      elseif entry.origin == "MP" then
        if entry.sign == "=" and mana() == entry.value then
          useWith(entry.item, player)
          return
        elseif entry.sign == ">" and mana() >= entry.value then
          useWith(entry.item, player)
          return
        elseif entry.sign == "<" and mana() <= entry.value then
          useWith(entry.item, player)
          return
        end   
      end
    end
  end
end)