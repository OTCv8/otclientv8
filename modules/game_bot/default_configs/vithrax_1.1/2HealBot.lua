setDefaultTab("HP")
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
      table.insert(storage[healPanelName].spellTable, {spell = spellFormula, sign = equasion, origin = source, cost = manaCost, value = spellTrigger})
      local label = g_ui.createWidget("SpellEntry", healWindow.spells.spellList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[healPanelName].spellTable, label:getText())
        label:destroy()
      end
      label:setText("(MP>" .. manaCost .. ") " .. source .. equasion .. spellTrigger .. ":" .. spellFormula)
      healWindow.spells.spellFormula:setText('')
      healWindow.spells.spellValue:setText('')
      healWindow.spells.manaCost:setText('')
    end
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
      healWindow.items.id:setItemId(0)
      healWindow.items.trigger:setText('')
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
      table.insert(storage[healPanelName].itemTable, {item = id, sign = equasion, origin = source, value = trigger})
      local label = g_ui.createWidget("SpellEntry", healWindow.items.itemList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[healPanelName].itemTable, label:getText())
        label:destroy()
      end
      label:setText(source .. equasion .. trigger .. ":" .. id)
      healWindow.items.id:setItemId(0)
      healWindow.items.trigger:setText('')
    end
  end

  if storage[healPanelName].itemTable and #storage[healPanelName].itemTable > 0 then
    for _, entry in pairs(storage[healPanelName].itemTable) do
      local label = g_ui.createWidget("SpellEntry", healWindow.items.itemList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[healPanelName].itemTable, entry)
        label:destroy()
      end
      label:setText(entry.origin .. entry.sign .. entry.value .. ":" .. entry.item)
    end
  end

  if storage[healPanelName].spellTable and #storage[healPanelName].spellTable > 0 then
    for _, entry in pairs(storage[healPanelName].spellTable) do
      local label = g_ui.createWidget("SpellEntry", healWindow.spells.spellList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[healPanelName].spellTable, entry)
        label:destroy()
      end
      label:setText("(MP>" .. entry.cost .. ") " .. entry.origin .. entry.sign .. entry.value .. ":" .. entry.spell)
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
    if mana() >= tonumber(entry.cost) and not getSpellCoolDown(entry.spell) then
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
  if not storage[healPanelName].enabled or storage.isUsing or #storage[healPanelName].itemTable == 0 then return end

  for _, entry in pairs(storage[healPanelName].itemTable) do
    local item = findItem(entry.item)
    if item then
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