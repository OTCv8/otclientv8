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

  if not HealBotConfig[conditionPanelName] then
    HealBotConfig[conditionPanelName] = {
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

  ui.title:setOn(HealBotConfig[conditionPanelName].enabled)
  ui.title.onClick = function(widget)
    HealBotConfig[conditionPanelName].enabled = not HealBotConfig[conditionPanelName].enabled
    widget:setOn(HealBotConfig[conditionPanelName].enabled)
    vBotConfigSave("heal")
  end
  
  ui.conditionList.onClick = function(widget)
    conditionsWindow:show()
    conditionsWindow:raise()
    conditionsWindow:focus()
  end



  local rootWidget = g_ui.getRootWidget()
  if rootWidget then
    conditionsWindow = UI.createWindow('ConditionsWindow', rootWidget)
    conditionsWindow:hide()

    -- text edits
    conditionsWindow.Cure.PoisonCost:setText(HealBotConfig[conditionPanelName].poisonCost)
    conditionsWindow.Cure.PoisonCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].poisonCost = tonumber(text)
    end

    conditionsWindow.Cure.CurseCost:setText(HealBotConfig[conditionPanelName].curseCost)
    conditionsWindow.Cure.CurseCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].curseCost = tonumber(text)
    end

    conditionsWindow.Cure.BleedCost:setText(HealBotConfig[conditionPanelName].bleedCost)
    conditionsWindow.Cure.BleedCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].bleedCost = tonumber(text)
    end

    conditionsWindow.Cure.BurnCost:setText(HealBotConfig[conditionPanelName].burnCost)
    conditionsWindow.Cure.BurnCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].burnCost = tonumber(text)
    end

    conditionsWindow.Cure.ElectrifyCost:setText(HealBotConfig[conditionPanelName].electrifyCost)
    conditionsWindow.Cure.ElectrifyCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].electrifyCost = tonumber(text)
    end

    conditionsWindow.Cure.ParalyseCost:setText(HealBotConfig[conditionPanelName].paralyseCost)
    conditionsWindow.Cure.ParalyseCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].paralyseCost = tonumber(text)
    end

    conditionsWindow.Cure.ParalyseSpell:setText(HealBotConfig[conditionPanelName].paralyseSpell)
    conditionsWindow.Cure.ParalyseSpell.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].paralyseSpell = text
    end

    conditionsWindow.Hold.HasteSpell:setText(HealBotConfig[conditionPanelName].hasteSpell)
    conditionsWindow.Hold.HasteSpell.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].hasteSpell = text
    end 
    
    conditionsWindow.Hold.HasteCost:setText(HealBotConfig[conditionPanelName].hasteCost)
    conditionsWindow.Hold.HasteCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].hasteCost = tonumber(text)
    end
    
    conditionsWindow.Hold.UtamoCost:setText(HealBotConfig[conditionPanelName].utamoCost)
    conditionsWindow.Hold.UtamoCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].utamoCost = tonumber(text)
    end   
    
    conditionsWindow.Hold.UtanaCost:setText(HealBotConfig[conditionPanelName].utanaCost)
    conditionsWindow.Hold.UtanaCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].utanaCost = tonumber(text)
    end 

    conditionsWindow.Hold.UturaCost:setText(HealBotConfig[conditionPanelName].uturaCost)
    conditionsWindow.Hold.UturaCost.onTextChange = function(widget, text)
      HealBotConfig[conditionPanelName].uturaCost = tonumber(text)
    end

    -- combo box
    conditionsWindow.Hold.UturaType:setOption(HealBotConfig[conditionPanelName].uturaType)
    conditionsWindow.Hold.UturaType.onOptionChange = function(widget)
      HealBotConfig[conditionPanelName].uturaType = widget:getCurrentOption().text
    end

    -- checkboxes
    conditionsWindow.Cure.CurePoison:setChecked(HealBotConfig[conditionPanelName].curePoison)
    conditionsWindow.Cure.CurePoison.onClick = function(widget)
      HealBotConfig[conditionPanelName].curePoison = not HealBotConfig[conditionPanelName].curePoison
      widget:setChecked(HealBotConfig[conditionPanelName].curePoison)
    end
    
    conditionsWindow.Cure.CureCurse:setChecked(HealBotConfig[conditionPanelName].cureCurse)
    conditionsWindow.Cure.CureCurse.onClick = function(widget)
      HealBotConfig[conditionPanelName].cureCurse = not HealBotConfig[conditionPanelName].cureCurse
      widget:setChecked(HealBotConfig[conditionPanelName].cureCurse)
    end

    conditionsWindow.Cure.CureBleed:setChecked(HealBotConfig[conditionPanelName].cureBleed)
    conditionsWindow.Cure.CureBleed.onClick = function(widget)
      HealBotConfig[conditionPanelName].cureBleed = not HealBotConfig[conditionPanelName].cureBleed
      widget:setChecked(HealBotConfig[conditionPanelName].cureBleed)
    end

    conditionsWindow.Cure.CureBurn:setChecked(HealBotConfig[conditionPanelName].cureBurn)
    conditionsWindow.Cure.CureBurn.onClick = function(widget)
      HealBotConfig[conditionPanelName].cureBurn = not HealBotConfig[conditionPanelName].cureBurn
      widget:setChecked(HealBotConfig[conditionPanelName].cureBurn)
    end

    conditionsWindow.Cure.CureElectrify:setChecked(HealBotConfig[conditionPanelName].cureElectrify)
    conditionsWindow.Cure.CureElectrify.onClick = function(widget)
      HealBotConfig[conditionPanelName].cureElectrify = not HealBotConfig[conditionPanelName].cureElectrify
      widget:setChecked(HealBotConfig[conditionPanelName].cureElectrify)
    end

    conditionsWindow.Cure.CureParalyse:setChecked(HealBotConfig[conditionPanelName].cureParalyse)
    conditionsWindow.Cure.CureParalyse.onClick = function(widget)
      HealBotConfig[conditionPanelName].cureParalyse = not HealBotConfig[conditionPanelName].cureParalyse
      widget:setChecked(HealBotConfig[conditionPanelName].cureParalyse)
    end

    conditionsWindow.Hold.HoldHaste:setChecked(HealBotConfig[conditionPanelName].holdHaste)
    conditionsWindow.Hold.HoldHaste.onClick = function(widget)
      HealBotConfig[conditionPanelName].holdHaste = not HealBotConfig[conditionPanelName].holdHaste
      widget:setChecked(HealBotConfig[conditionPanelName].holdHaste)
    end

    conditionsWindow.Hold.HoldUtamo:setChecked(HealBotConfig[conditionPanelName].holdUtamo)
    conditionsWindow.Hold.HoldUtamo.onClick = function(widget)
      HealBotConfig[conditionPanelName].holdUtamo = not HealBotConfig[conditionPanelName].holdUtamo
      widget:setChecked(HealBotConfig[conditionPanelName].holdUtamo)
    end

    conditionsWindow.Hold.HoldUtana:setChecked(HealBotConfig[conditionPanelName].holdUtana)
    conditionsWindow.Hold.HoldUtana.onClick = function(widget)
      HealBotConfig[conditionPanelName].holdUtana = not HealBotConfig[conditionPanelName].holdUtana
      widget:setChecked(HealBotConfig[conditionPanelName].holdUtana)
    end

    conditionsWindow.Hold.HoldUtura:setChecked(HealBotConfig[conditionPanelName].holdUtura)
    conditionsWindow.Hold.HoldUtura.onClick = function(widget)
      HealBotConfig[conditionPanelName].holdUtura = not HealBotConfig[conditionPanelName].holdUtura
      widget:setChecked(HealBotConfig[conditionPanelName].holdUtura)
    end

    conditionsWindow.Hold.IgnoreInPz:setChecked(HealBotConfig[conditionPanelName].ignoreInPz)
    conditionsWindow.Hold.IgnoreInPz.onClick = function(widget)
      HealBotConfig[conditionPanelName].ignoreInPz = not HealBotConfig[conditionPanelName].ignoreInPz
      widget:setChecked(HealBotConfig[conditionPanelName].ignoreInPz)
    end

    conditionsWindow.Hold.StopHaste:setChecked(HealBotConfig[conditionPanelName].stopHaste)
    conditionsWindow.Hold.StopHaste.onClick = function(widget)
      HealBotConfig[conditionPanelName].stopHaste = not HealBotConfig[conditionPanelName].stopHaste
      widget:setChecked(HealBotConfig[conditionPanelName].stopHaste)
    end

    -- buttons
    conditionsWindow.closeButton.onClick = function(widget)
      conditionsWindow:hide()
      vBotConfigSave("heal")
    end
  end

  local utanaCast = nil
  macro(500, function()
    if not HealBotConfig[conditionPanelName].enabled or modules.game_cooldown.isGroupCooldownIconActive(2) then return end
    if hppercent() > 95 then
      if HealBotConfig[conditionPanelName].curePoison and mana() >= HealBotConfig[conditionPanelName].poisonCost and isPoisioned() then say("exana pox") 
      elseif HealBotConfig[conditionPanelName].cureCurse and mana() >= HealBotConfig[conditionPanelName].curseCost and isCursed() then say("exana mort") 
      elseif HealBotConfig[conditionPanelName].cureBleed and mana() >= HealBotConfig[conditionPanelName].bleedCost and isBleeding() then say("exana kor")
      elseif HealBotConfig[conditionPanelName].cureBurn and mana() >= HealBotConfig[conditionPanelName].burnCost and isBurning() then say("exana flam") 
      elseif HealBotConfig[conditionPanelName].cureElectrify and mana() >= HealBotConfig[conditionPanelName].electrifyCost and isEnergized() then say("exana vis") 
      end
    end
    if (not HealBotConfig[conditionPanelName].ignoreInPz or not isInPz()) and HealBotConfig[conditionPanelName].holdUtura and mana() >= HealBotConfig[conditionPanelName].uturaCost and not hasPartyBuff() then say(HealBotConfig[conditionPanelName].uturaType)
    elseif (not HealBotConfig[conditionPanelName].ignoreInPz or not isInPz()) and HealBotConfig[conditionPanelName].holdUtana and mana() >= HealBotConfig[conditionPanelName].utanaCost and (not utanaCast or (now - utanaCast > 120000)) then say("utana vid") utanaCast = now
    end
  end)

  macro(50, function()
    if not HealBotConfig[conditionPanelName].enabled then return end
    if (not HealBotConfig[conditionPanelName].ignoreInPz or not isInPz()) and HealBotConfig[conditionPanelName].holdUtamo and mana() >= HealBotConfig[conditionPanelName].utamoCost and not hasManaShield() then say("utamo vita")
    elseif (not HealBotConfig[conditionPanelName].ignoreInPz or not isInPz()) and HealBotConfig[conditionPanelName].holdHaste and mana() >= HealBotConfig[conditionPanelName].hasteCost and not hasHaste() and not getSpellCoolDown(HealBotConfig[conditionPanelName].hasteSpell) and (not target() or not HealBotConfig[conditionPanelName].stopHaste or TargetBot.isCaveBotActionAllowed()) then say(HealBotConfig[conditionPanelName].hasteSpell)
    elseif HealBotConfig[conditionPanelName].cureParalyse and mana() >= HealBotConfig[conditionPanelName].paralyseCost and isParalyzed() and not getSpellCoolDown(HealBotConfig[conditionPanelName].paralyseSpell) then say(HealBotConfig[conditionPanelName].paralyseSpell)
    end
  end)