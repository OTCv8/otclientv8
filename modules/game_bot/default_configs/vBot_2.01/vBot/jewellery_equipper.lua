setDefaultTab("HP")
function jewelleryEquip()
  panelName = "jewelleryEquipper"
 
  local ui = setupUI([[
Panel
  height: 133
  margin-top: 2

  BotItem
    id: ringId
    anchors.left: parent.left
    anchors.top: parent.top

  SmallBotSwitch
    id: ringSwitch
    anchors.left: ringId.right
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    text: Equip Ring
    margin-left: 3
    margin-right: 45

  SmallBotSwitch
    id: valueRing
    anchors.left: ringSwitch.right
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    text: Mana
    margin-left: 3
    margin-right: 0  

  BotLabel
    id: ringTitle
    anchors.left: ringId.right
    anchors.right: parent.right
    anchors.top: ringId.verticalCenter
    text-align: center

  HorizontalScrollBar
    id: ringScroll1
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: ringId.bottom
    margin-right: 2
    margin-top: 2
    minimum: 0
    maximum: 100
    step: 1
    
  HorizontalScrollBar
    id: ringScroll2
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: prev.top
    margin-left: 2
    minimum: 0
    maximum: 100
    step: 1
    
  BotItem
    id: ammyId
    anchors.left: parent.left
    anchors.top: ringScroll1.bottom
    margin-top: 5

  SmallBotSwitch
    id: ammySwitch
    anchors.left: ammyId.right
    anchors.right: parent.right
    anchors.top: ringScroll2.bottom
    text-align: center
    text: Equip Amulet
    margin-top: 5
    margin-left: 3
    margin-right: 45

  SmallBotSwitch
    id: valueAmmy
    anchors.left: ammySwitch.right
    anchors.right: parent.right
    anchors.top: ringScroll2.bottom
    text-align: center
    text: Mana
    margin-top: 5
    margin-left: 3

  BotLabel
    id: ammyTitle
    anchors.left: ammyId.right
    anchors.right: parent.right
    anchors.top: ammyId.verticalCenter
    text-align: center

  HorizontalScrollBar
    id: ammyScroll1
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: ammyId.bottom
    margin-right: 2
    margin-top: 2
    minimum: 0
    maximum: 100
    step: 1
    
  HorizontalScrollBar
    id: ammyScroll2
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: prev.top
    margin-left: 2
    minimum: 0
    maximum: 100
    step: 1
    
  SmallBotSwitch
    id: safe
    anchors.top: ammyScroll2.bottom
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    text: Safe min
    margin-top: 5
    width: 60

  BotLabel
    id: safeText
    anchors.top: ammyScroll2.bottom
    anchors.left: parent.left
    anchors.right: prev.left
    anchors.bottom: prev.verticalCenter
    text-align: center
    text: Stop if below 99%

  HorizontalScrollBar
    id: safeMin
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: safe.left
    anchors.bottom: safe.bottom
    margin-left: 2
    margin-top: 2
    margin-right: 5
    minimum: 0
    maximum: 99
    step: 1

  ]], parent)
  ui:setId(panelName)
  if not storage[panelName] or not storage[panelName].ringId or not storage[panelName].ammyId then
    storage[panelName] = {
      ringSwitch = true,
      ammySwitch = true,
      ringId = 3048,
      ammyId = 3081,
      ringMin = 30,
      ringMax = 80,
      ammyMin = 30,
      ammyMax = 80,
      valueAmmy = false,
      valueRing = false,
      ringValue = "HP",
      ammyValue = "HP",
      safe = true,
      safeMin = 30
    }
  end
  if not storage[panelName].safeMin then
    storage[panelName].safeMin = 30
  end


  ui.ringSwitch:setOn(storage[panelName].ringEnabled)
  ui.ringSwitch.onClick = function(widget)
    storage[panelName].ringEnabled = not storage[panelName].ringEnabled
    widget:setOn(storage[panelName].ringEnabled)
  end
  ui.safe:setOn(storage[panelName].safe)
  ui.safe.onClick = function(widget)
    storage[panelName].safe = not storage[panelName].safe
    widget:setOn(storage[panelName].safe)
  end
  ui.ammySwitch:setOn(storage[panelName].ammyEnabled)
  ui.ammySwitch.onClick = function(widget)
    storage[panelName].ammyEnabled = not storage[panelName].ammyEnabled
    widget:setOn(storage[panelName].ammyEnabled)
  end

  local updateRingText = function()
    ui.ringTitle:setText("" .. storage[panelName].ringMin .. "% <= " .. storage[panelName].ringValue .. " >= " .. storage[panelName].ringMax .. "%")  
  end
  local updateAmmyText = function()
    ui.ammyTitle:setText("" .. storage[panelName].ammyMin .. "% <= " .. storage[panelName].ammyValue .. " >= " .. storage[panelName].ammyMax .. "%")  
  end
  local updateSafeText = function()
    ui.safeText:setText("Stop if below " .. storage[panelName].safeMin .. "%")  
  end
  updateSafeText()

  ui.valueRing:setOn(storage[panelName].valueRing)
  ui.valueRing.onClick = function(widget)
    storage[panelName].valueRing = not storage[panelName].valueRing
    widget:setOn(storage[panelName].valueRing)
    if storage[panelName].valueRing then
      storage[panelName].ringValue = "MP"
    else
      storage[panelName].ringValue = "HP"
    end
    updateRingText()
  end
  ui.valueAmmy:setOn(storage[panelName].valueAmmy)
  ui.valueAmmy.onClick = function(widget)
    storage[panelName].valueAmmy = not storage[panelName].valueAmmy
    widget:setOn(storage[panelName].valueAmmy)
    if storage[panelName].valueAmmy then
      storage[panelName].ammyValue = "MP"
    else
      storage[panelName].ammyValue = "HP"
    end
    updateAmmyText()
  end
 
  ui.ringScroll1.onValueChange = function(scroll, value)
    storage[panelName].ringMin = value
    updateRingText()
  end
  ui.ringScroll2.onValueChange = function(scroll, value)
    storage[panelName].ringMax = value
    updateRingText()
  end
  ui.ammyScroll1.onValueChange = function(scroll, value)
    storage[panelName].ammyMin = value
    updateAmmyText()
  end
  ui.ammyScroll2.onValueChange = function(scroll, value)
    storage[panelName].ammyMax = value
    updateAmmyText()
  end  
  ui.ringId.onItemChange = function(widget)
    storage[panelName].ringId = widget:getItemId()
  end
  ui.ammyId.onItemChange = function(widget)
    storage[panelName].ammyId = widget:getItemId()
  end
  ui.safeMin.onValueChange = function(scroll, value)
    storage[panelName].safeMin = value
    updateSafeText()
  end

  ui.ringScroll1:setValue(storage[panelName].ringMin)
  ui.ringScroll2:setValue(storage[panelName].ringMax)
  ui.ammyScroll1:setValue(storage[panelName].ammyMin)
  ui.ammyScroll2:setValue(storage[panelName].ammyMax)  
  ui.ringId:setItemId(storage[panelName].ringId)
  ui.ammyId:setItemId(storage[panelName].ammyId)
  ui.safeMin:setValue(storage[panelName].safeMin)

  local defaultRing
  local defaultAmmy

  -- basic ring check
  function defaultRingFind()
    if storage[panelName].ringEnabled then
      if getFinger() and (getFinger():getId() ~= storage[panelName].ringId and getFinger():getId() ~= getActiveItemId(storage[panelName].ringId)) then
        defaultRing = getInactiveItemId(getFinger():getId())
      else
        defaultRing = false
      end
    end
  end

  -- basic amulet check
  function defaultAmmyFind()
    if storage[panelName].ammyEnabled then
      if getNeck() and (getNeck():getId() ~= storage[panelName].ammyId and getNeck():getId() ~= getActiveItemId(storage[panelName].ammyId)) then
        defaultAmmy = getInactiveItemId(getNeck():getId())
      else
        defaultAmmy = false
      end
    end
  end

  local lastAction = now
  macro(20, function()
    if now - lastAction < math.max(math.max(g_game.getPing()*2,150),300) then return end
    if not storage[panelName].ringEnabled and not storage[panelName].ammyEnabled then return end

    -- [[ safe findout ]] --
    local safeAmmyVal
    local safeRingVal
    if not storage[panelName].valueAmmy then
      safeAmmyVal = hppercent()
    else
      safeAmmyVal = manapercent()
    end
    if not storage[panelName].valueRing then
      safeRingVal = hppercent()
    else
      safeRingVal = manapercent()
    end

    

    -- [[ condition list ]] --
    local ringEnabled = storage[panelName].ringEnabled
    local ringEquipped = getFinger() and (getFinger():getId() == storage[panelName].ringId or getFinger():getId() == getActiveItemId(storage[panelName].ringId))
    local shouldEquipRing = not storage[panelName].valueRing and hppercent() <= storage[panelName].ringMin or storage[panelName].valueRing and manapercent() <= storage[panelName].ringMin
    local shouldUnequipRing = not storage[panelName].valueRing and hppercent() >= storage[panelName].ringMax or storage[panelName].valueRing and manapercent() >= storage[panelName].ringMax
    local hasDefaultRing = defaultRing and findItem(defaultRing)
    local ammyEnabled = storage[panelName].ammyEnabled
    local ammyEquipped = getNeck() and (getNeck():getId() == storage[panelName].ammyId or getNeck():getId() == getActiveItemId(storage[panelName].ammyId))
    local shouldEquipAmmy = not storage[panelName].valueAmmy and hppercent() <= storage[panelName].ammyMin or storage[panelName].valueAmmy and manapercent() <= storage[panelName].ammyMin
    local shouldUnequipAmmy = not storage[panelName].valueAmmy and hppercent() >= storage[panelName].ammyMax or storage[panelName].valueAmmy and manapercent() >= storage[panelName].ammyMax
    local hasDefaultAmmy = defaultAmmy and findItem(defaultAmmy)
    local ringIsSafe = not storage[panelName].safe or safeRingVal >= storage[panelName].safeMin
    local ammyIsSafe = not storage[panelName].safe or safeAmmyVal >= storage[panelName].safeMin

    -- [[ ring ]] --
      if ringEnabled then
        if not ringEquipped and shouldEquipRing and ringIsSafe then
          defaultRingFind()
          g_game.equipItemId(storage[panelName].ringId)
          lastAction = now
          return
        elseif ringEquipped and (shouldUnequipRing or not ringIsSafe) then
          if hasDefaultRing then
            g_game.equipItemId(defaultRing)
            lastAction = now
            return
          else
            g_game.equipItemId(storage[panelName].ringId)
            lastAction = now
            return
          end
        end
      end          
      -- [[ amulet ]] --
      if ammyEnabled then
        if not ammyEquipped and shouldEquipAmmy and ammyIsSafe then
          defaultAmmyFind()
          g_game.equipItemId(storage[panelName].ammyId)
          lastAction = now
          return
        elseif ammyEquipped and (shouldUnequipAmmy or not ammyIsSafe) then
          if hasDefaultAmmy then
            g_game.equipItemId(defaultAmmy)
            lastAction = now
            return
          else
            g_game.equipItemId(storage[panelName].ammyId)
            lastAction = now
            return
          end
        end
      end 
  end)
  -- end of function
end

if g_game.getClientVersion() >= 1000 then
  addSeparator()
  UI.Label("-- [[ Equipper ]] --")
  addSeparator()
  jewelleryEquip()
  addSeparator()
end