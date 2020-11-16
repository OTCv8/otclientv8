setDefaultTab("HP")
function jewelleryEquip()
  panelName = "jewelleryEquipper"
 
  local ui = setupUI([[
Panel
  height: 130
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

  Button
    id: resetDefault
    anchors.top: ammyScroll2.bottom
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    margin-top: 8
    margin-left: 2
    text: Reset Default
    
  SmallBotSwitch
    id: pzCheck
    anchors.top: ammyScroll2.bottom
    anchors.left: resetDefault.right
    anchors.bottom: resetDefault.bottom
    anchors.right: parent.right
    margin-top: 8
    margin-right: 2
    margin-left: 1
    text: Ignore in PZ

  ]], parent)
  ui:setId(panelName)
  if not storage[panelName] or not storage[panelName].ringId or not storage[panelName].ammyId then
    storage[panelName] = {
      pzCheck = true,
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
      ammyValue = "HP"
    }
  end


  ui.ringSwitch:setOn(storage[panelName].ringEnabled)
  ui.ringSwitch.onClick = function(widget)
    storage[panelName].ringEnabled = not storage[panelName].ringEnabled
    widget:setOn(storage[panelName].ringEnabled)
  end
  ui.ammySwitch:setOn(storage[panelName].ammyEnabled)
  ui.ammySwitch.onClick = function(widget)
    storage[panelName].ammyEnabled = not storage[panelName].ammyEnabled
    widget:setOn(storage[panelName].ammyEnabled)
  end
  ui.pzCheck:setOn(storage[panelName].pzCheck)
  ui.pzCheck.onClick = function(widget)
    storage[panelName].pzCheck = not storage[panelName].pzCheck
    widget:setOn(storage[panelName].pzCheck)
  end

  local updateRingText = function()
    ui.ringTitle:setText("" .. storage[panelName].ringMin .. "% <= " .. storage[panelName].ringValue .. " >= " .. storage[panelName].ringMax .. "%")  
  end
  local updateAmmyText = function()
    ui.ammyTitle:setText("" .. storage[panelName].ammyMin .. "% <= " .. storage[panelName].ammyValue .. " >= " .. storage[panelName].ammyMax .. "%")  
  end

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


  ui.ringScroll1:setValue(storage[panelName].ringMin)
  ui.ringScroll2:setValue(storage[panelName].ringMax)
  ui.ammyScroll1:setValue(storage[panelName].ammyMin)
  ui.ammyScroll2:setValue(storage[panelName].ammyMax)  
  ui.ringId:setItemId(storage[panelName].ringId)
  ui.ammyId:setItemId(storage[panelName].ammyId)

  local defaultRing
  local defaultAmmy
  local ringToEquip
  local ammyToEquip


  -- basic ring check
  function defaultRingFind()
    if storage[panelName].ringEnabled then
      if getFinger() and (getFinger():getId() ~= storage[panelName].ringId and getFinger():getId() ~= getActiveItemId(storage[panelName].ringId)) then
        defaultRing = getFinger():getId()
      else
        defaultRing = false
      end
    end
  end
  defaultRingFind()

  -- basic amulet check
  function defaultAmmyFind()
    if storage[panelName].ammyEnabled then
      if getNeck() and (getNeck():getId() ~= storage[panelName].ammyId and getNeck():getId() ~= getActiveItemId(storage[panelName].ammyId)) then
        defaultAmmy = getNeck():getId()
      else
        defaultAmmy = false
      end
    end
  end
  defaultAmmyFind()
  
  ui.resetDefault.onClick = function(widget)
    defaultRingFind()
    defaultAmmyFind()
  end

  macro(20, function()
    ammyToEquip = findItem(storage[panelName].ammyId)
    ringToEquip = findItem(storage[panelName].ringId)

    -- basic conditions to met 
    if not storage[panelName].ringEnabled and not storage[panelName].ammyEnabled then return end
    if not storage[panelName].ringEnabled and storage[panelName].ammyEnabled and not ammyToEquip and (not getNeck() or (getNeck():getId() ~= storage[panelName].ammyId and getNeck():getId() ~= getActiveItemId(storage[panelName].ammyId))) then return end
    if storage[panelName].ringEnabled and not storage[panelName].ammyEnabled and not ringToEquip and (not getFinger() or (getFinger():getId() ~= storage[panelName].ringId and getFinger():getId() ~= getActiveItemId(storage[panelName].ringId))) then return end

    -- ring unequip conditions
    if storage[panelName].ringEnabled and getFinger() and getFinger():getId() == getActiveItemId(storage[panelName].ringId) and ((storage[panelName].pzCheck and isInPz()) or (not storage[panelName].valueRing and hppercent() >= storage[panelName].ringMax) or (storage[panelName].valueRing and manapercent() >= storage[panelName].ringMax)) then
      if defaultRing then
        moveToSlot(findItem(defaultRing), SlotFinger, 1)
      else
        for _,container in pairs(getContainers()) do
          g_game.move(getFinger(), container:getSlotPosition(container:getItemsCount()))
          return
        end
      end
    end

    -- amulet unequip conditions
    if storage[panelName].ammyEnabled and getNeck() and getNeck():getId() == getActiveItemId(storage[panelName].ammyId) and ((storage[panelName].pzCheck and isInPz()) or (not storage[panelName].valueAmmy and hppercent() >= storage[panelName].ammyMax) or (not storage[panelName].valueAmmy and manapercent() >= storage[panelName].ammyMax)) then
      if defaultAmmy then
        moveToSlot(findItem(defaultAmmy), SlotNeck, 1)
      else
        for _,container in pairs(getContainers()) do
          g_game.move(getNeck(), container:getSlotPosition(container:getItemsCount()))
          return
        end
      end
    end

    -- ring equip conditions
    if storage[panelName].ringEnabled and (not getFinger() or getFinger():getId() ~= getActiveItemId(storage[panelName].ringId)) and (not storage[panelName].pzCheck or not isInPz()) and ((not storage[panelName].valueRing and hppercent() <= storage[panelName].ringMin) or (storage[panelName].valueRing and manapercent() <= storage[panelName].ringMin)) then
      moveToSlot(ringToEquip, SlotFinger, 1)
    end
    -- amulet equip conditions
    if storage[panelName].ammyEnabled and (not getNeck() or getNeck():getId() ~= getActiveItemId(storage[panelName].ammyId)) and (not storage[panelName].pzCheck or not isInPz()) and ((not storage[panelName].valueAmmy and hppercent() <= storage[panelName].ammyMin) or (storage[panelName].valueAmmy and manapercent() <= storage[panelName].ammyMin)) then
      moveToSlot(ammyToEquip, SlotNeck, 1)
    end
  end)
  -- end of function
end
addSeparator()
UI.Label("-- [[ Equipper ]] --")
addSeparator()
jewelleryEquip()
addSeparator()