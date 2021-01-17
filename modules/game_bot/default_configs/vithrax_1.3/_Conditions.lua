setDefaultTab("HP")
  local conditionPanelName = "ConditionPanel"
  local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Conditions')

  Button
    id: conditionList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
      
  ]])
  ui:setId(conditionPanelName)

  if not storage[conditionPanelName] then
    storage[conditionPanelName] = {
      enabled = false,
      curePosion = false,
      poisonCost = 20,
      cureCurse = false,
      curseCost = 80,
      cureBleed = false,
      bleedCost = 45,
      cureBurn = false,
      burnCost = 30,
      cureElectrify = false,
      electrifyCost = 22,
      cureParalyse = false,
      paralyseCost = 40,
      paralyseSpell = "utani hur",
      holdHaste = false,
      hasteCost = 40,
      hasteSpell = "utani hur",
      holdUtamo = false,
      utamoCost = 40,
      holdUtana = false,
      utanaCost = 440,
      holdUtura = false,
      uturaType = "",
      uturaCost = 100,
      ignoreInPz = true,
      stopHaste = false
    }
  end

  ui.title:setOn(storage[conditionPanelName].enabled)
  ui.title.onClick = function(widget)
    storage[conditionPanelName].enabled = not storage[conditionPanelName].enabled
    widget:setOn(storage[conditionPanelName].enabled)
  end
  
  ui.conditionList.onClick = function(widget)
    conditionsWindow:show()
    conditionsWindow:raise()
    conditionsWindow:focus()
  end



  local rootWidget = g_ui.getRootWidget()
  if rootWidget then
    conditionsWindow = g_ui.createWidget('ConditionsWindow', rootWidget)
    conditionsWindow:hide()

    -- text edits
    conditionsWindow.Cure.PoisonCost:setText(storage[conditionPanelName].poisonCost)
    conditionsWindow.Cure.PoisonCost.onTextChange = function(widget, text)
      storage[conditionPanelName].poisonCost = tonumber(text)
    end

    conditionsWindow.Cure.CurseCost:setText(storage[conditionPanelName].curseCost)
    conditionsWindow.Cure.CurseCost.onTextChange = function(widget, text)
      storage[conditionPanelName].curseCost = tonumber(text)
    end

    conditionsWindow.Cure.BleedCost:setText(storage[conditionPanelName].bleedCost)
    conditionsWindow.Cure.BleedCost.onTextChange = function(widget, text)
      storage[conditionPanelName].bleedCost = tonumber(text)
    end

    conditionsWindow.Cure.BurnCost:setText(storage[conditionPanelName].burnCost)
    conditionsWindow.Cure.BurnCost.onTextChange = function(widget, text)
      storage[conditionPanelName].burnCost = tonumber(text)
    end

    conditionsWindow.Cure.ElectrifyCost:setText(storage[conditionPanelName].electrifyCost)
    conditionsWindow.Cure.ElectrifyCost.onTextChange = function(widget, text)
      storage[conditionPanelName].electrifyCost = tonumber(text)
    end

    conditionsWindow.Cure.ParalyseCost:setText(storage[conditionPanelName].paralyseCost)
    conditionsWindow.Cure.ParalyseCost.onTextChange = function(widget, text)
      storage[conditionPanelName].paralyseCost = tonumber(text)
    end

    conditionsWindow.Cure.ParalyseSpell:setText(storage[conditionPanelName].paralyseSpell)
    conditionsWindow.Cure.ParalyseSpell.onTextChange = function(widget, text)
      storage[conditionPanelName].paralyseSpell = text
    end

    conditionsWindow.Hold.HasteSpell:setText(storage[conditionPanelName].hasteSpell)
    conditionsWindow.Hold.HasteSpell.onTextChange = function(widget, text)
      storage[conditionPanelName].hasteSpell = text
    end 
    
    conditionsWindow.Hold.HasteCost:setText(storage[conditionPanelName].hasteCost)
    conditionsWindow.Hold.HasteCost.onTextChange = function(widget, text)
      storage[conditionPanelName].hasteCost = tonumber(text)
    end
    
    conditionsWindow.Hold.UtamoCost:setText(storage[conditionPanelName].utamoCost)
    conditionsWindow.Hold.UtamoCost.onTextChange = function(widget, text)
      storage[conditionPanelName].utamoCost = tonumber(text)
    end   
    
    conditionsWindow.Hold.UtanaCost:setText(storage[conditionPanelName].utanaCost)
    conditionsWindow.Hold.UtanaCost.onTextChange = function(widget, text)
      storage[conditionPanelName].utanaCost = tonumber(text)
    end 

    conditionsWindow.Hold.UturaCost:setText(storage[conditionPanelName].uturaCost)
    conditionsWindow.Hold.UturaCost.onTextChange = function(widget, text)
      storage[conditionPanelName].uturaCost = tonumber(text)
    end

    -- combo box
    conditionsWindow.Hold.UturaType:setOption(storage[conditionPanelName].uturaType)
    conditionsWindow.Hold.UturaType.onOptionChange = function(widget)
      storage[conditionPanelName].uturaType = widget:getCurrentOption().text
    end

    -- checkboxes
    conditionsWindow.Cure.CurePoison:setChecked(storage[conditionPanelName].curePoison)
    conditionsWindow.Cure.CurePoison.onClick = function(widget)
      storage[conditionPanelName].curePoison = not storage[conditionPanelName].curePoison
      widget:setChecked(storage[conditionPanelName].curePoison)
    end
    
    conditionsWindow.Cure.CureCurse:setChecked(storage[conditionPanelName].cureCurse)
    conditionsWindow.Cure.CureCurse.onClick = function(widget)
      storage[conditionPanelName].cureCurse = not storage[conditionPanelName].cureCurse
      widget:setChecked(storage[conditionPanelName].cureCurse)
    end

    conditionsWindow.Cure.CureBleed:setChecked(storage[conditionPanelName].cureBleed)
    conditionsWindow.Cure.CureBleed.onClick = function(widget)
      storage[conditionPanelName].cureBleed = not storage[conditionPanelName].cureBleed
      widget:setChecked(storage[conditionPanelName].cureBleed)
    end

    conditionsWindow.Cure.CureBurn:setChecked(storage[conditionPanelName].cureBurn)
    conditionsWindow.Cure.CureBurn.onClick = function(widget)
      storage[conditionPanelName].cureBurn = not storage[conditionPanelName].cureBurn
      widget:setChecked(storage[conditionPanelName].cureBurn)
    end

    conditionsWindow.Cure.CureElectrify:setChecked(storage[conditionPanelName].cureElectrify)
    conditionsWindow.Cure.CureElectrify.onClick = function(widget)
      storage[conditionPanelName].cureElectrify = not storage[conditionPanelName].cureElectrify
      widget:setChecked(storage[conditionPanelName].cureElectrify)
    end

    conditionsWindow.Cure.CureParalyse:setChecked(storage[conditionPanelName].cureParalyse)
    conditionsWindow.Cure.CureParalyse.onClick = function(widget)
      storage[conditionPanelName].cureParalyse = not storage[conditionPanelName].cureParalyse
      widget:setChecked(storage[conditionPanelName].cureParalyse)
    end

    conditionsWindow.Hold.HoldHaste:setChecked(storage[conditionPanelName].holdHaste)
    conditionsWindow.Hold.HoldHaste.onClick = function(widget)
      storage[conditionPanelName].holdHaste = not storage[conditionPanelName].holdHaste
      widget:setChecked(storage[conditionPanelName].holdHaste)
    end

    conditionsWindow.Hold.HoldUtamo:setChecked(storage[conditionPanelName].holdUtamo)
    conditionsWindow.Hold.HoldUtamo.onClick = function(widget)
      storage[conditionPanelName].holdUtamo = not storage[conditionPanelName].holdUtamo
      widget:setChecked(storage[conditionPanelName].holdUtamo)
    end

    conditionsWindow.Hold.HoldUtana:setChecked(storage[conditionPanelName].holdUtana)
    conditionsWindow.Hold.HoldUtana.onClick = function(widget)
      storage[conditionPanelName].holdUtana = not storage[conditionPanelName].holdUtana
      widget:setChecked(storage[conditionPanelName].holdUtana)
    end

    conditionsWindow.Hold.HoldUtura:setChecked(storage[conditionPanelName].holdUtura)
    conditionsWindow.Hold.HoldUtura.onClick = function(widget)
      storage[conditionPanelName].holdUtura = not storage[conditionPanelName].holdUtura
      widget:setChecked(storage[conditionPanelName].holdUtura)
    end

    conditionsWindow.Hold.IgnoreInPz:setChecked(storage[conditionPanelName].ignoreInPz)
    conditionsWindow.Hold.IgnoreInPz.onClick = function(widget)
      storage[conditionPanelName].ignoreInPz = not storage[conditionPanelName].ignoreInPz
      widget:setChecked(storage[conditionPanelName].ignoreInPz)
    end

    conditionsWindow.Hold.StopHaste:setChecked(storage[conditionPanelName].stopHaste)
    conditionsWindow.Hold.StopHaste.onClick = function(widget)
      storage[conditionPanelName].stopHaste = not storage[conditionPanelName].stopHaste
      widget:setChecked(storage[conditionPanelName].stopHaste)
    end

    -- buttons
    conditionsWindow.closeButton.onClick = function(widget)
      conditionsWindow:hide()
    end
  end

  local utanaCast = nil
  macro(500, function()
    if not storage[conditionPanelName].enabled or modules.game_cooldown.isGroupCooldownIconActive(2) then return end
    if storage[conditionPanelName].curePoison and mana() >= storage[conditionPanelName].poisonCost and isPoisioned() then say("exana pox") 
    elseif storage[conditionPanelName].cureCurse and mana() >= storage[conditionPanelName].curseCost and isCursed() then say("exana mort") 
    elseif storage[conditionPanelName].cureBleed and mana() >= storage[conditionPanelName].bleedCost and isBleeding() then say("exana kor")
    elseif storage[conditionPanelName].cureBurn and mana() >= storage[conditionPanelName].burnCost and isBurning() then say("exana flam") 
    elseif storage[conditionPanelName].cureElectrify and mana() >= storage[conditionPanelName].electrifyCost and isEnergized() then say("exana vis")
    elseif (not storage[conditionPanelName].ignoreInPz or not isInPz()) and storage[conditionPanelName].holdUtura and mana() >= storage[conditionPanelName].uturaCost and not hasPartyBuff() then say(storage[conditionPanelName].uturaType)
    elseif (not storage[conditionPanelName].ignoreInPz or not isInPz()) and storage[conditionPanelName].holdUtana and mana() >= storage[conditionPanelName].utanaCost and (not utanaCast or (now - utanaCast > 120000)) then say("utana vid") utanaCast = now
    end
  end)

  macro(50, function()
    if not storage[conditionPanelName].enabled then return end
    if (not storage[conditionPanelName].ignoreInPz or not isInPz()) and storage[conditionPanelName].holdUtamo and mana() >= storage[conditionPanelName].utamoCost and not hasManaShield() then say("utamo vita")
    elseif (not storage[conditionPanelName].ignoreInPz or not isInPz()) and storage[conditionPanelName].holdHaste and mana() >= storage[conditionPanelName].hasteCost and not hasHaste() and not getSpellCoolDown(storage[conditionPanelName].hasteSpell) and (not target() or not storage[conditionPanelName].stopHaste or TargetBot.isCaveBotActionAllowed()) then say(storage[conditionPanelName].hasteSpell)
    elseif storage[conditionPanelName].cureParalyse and mana() >= storage[conditionPanelName].paralyseCost and isParalyzed() and not getSpellCoolDown(storage[conditionPanelName].paralyseSpell) then say(storage[conditionPanelName].paralyseSpell)
    end
  end)