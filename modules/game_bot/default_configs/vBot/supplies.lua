function SuppliesPanel(parent)
  suppliesPanelName = "supplies"
  if not parent then
    parent = panel
  end

local ui = setupUI([[
Panel
  height: 21

  Button
    id: supplies
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    !text: tr('Supplies')

]])
ui:setId(suppliesPanelName)

if not storage[suppliesPanelName] then
storage[suppliesPanelName] = {
  item1 = 0,
  item2 = 0,
  item3 = 0,
  item4 = 0,
  item5 = 0,
  item6 = 0,
  item7 = 0,
  capValue = 0,
  capSwitch = false,
  SoftBoots = false,
  staminaSwitch = false,
  staminaValue = 900,
  imbues = false,
  item1Min = 0,
  item1Max = 0,
  item2Min = 0,
  item2Max = 0,
  item3Min = 0,
  item3Max = 0,
  item4Min = 0,
  item4Max = 0,
  item5Min = 0,
  item5Max = 0,
  item6Min = 0,
  item6Max = 0,
  item7Max = 0,
  sortSupplies = false,
  potionBp = 0,
  runeBp = 0,
  ammoBp = 0
}
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  SuppliesWindow = g_ui.createWidget('SuppliesWindow', rootWidget)
  SuppliesWindow:hide()

  SuppliesWindow.capSwitch:setOn(storage[suppliesPanelName].capSwitch)
  SuppliesWindow.capSwitch.onClick = function(widget)
    storage[suppliesPanelName].capSwitch = not storage[suppliesPanelName].capSwitch
    widget:setOn(storage[suppliesPanelName].capSwitch)
  end

  SuppliesWindow.SoftBoots:setOn(storage[suppliesPanelName].SoftBoots)
  SuppliesWindow.SoftBoots.onClick = function(widget)
    storage[suppliesPanelName].SoftBoots = not storage[suppliesPanelName].SoftBoots
    widget:setOn(storage[suppliesPanelName].SoftBoots)
  end

  SuppliesWindow.imbues:setOn(storage[suppliesPanelName].imbues)
  SuppliesWindow.imbues.onClick = function(widget)
    storage[suppliesPanelName].imbues = not storage[suppliesPanelName].imbues
    widget:setOn(storage[suppliesPanelName].imbues)
  end

  SuppliesWindow.staminaSwitch:setOn(storage[suppliesPanelName].staminaSwitch)
  SuppliesWindow.staminaSwitch.onClick = function(widget)
    storage[suppliesPanelName].staminaSwitch = not storage[suppliesPanelName].staminaSwitch
    widget:setOn(storage[suppliesPanelName].staminaSwitch)
  end

  SuppliesWindow.SortSupplies:setOn(storage[suppliesPanelName].sortSupplies)
  SuppliesWindow.SortSupplies.onClick = function(widget)
    storage[suppliesPanelName].sortSupplies = not storage[suppliesPanelName].sortSupplies
    widget:setOn(storage[suppliesPanelName].sortSupplies)
  end

  -- bot items

  SuppliesWindow.item1:setItemId(storage[suppliesPanelName].item1)
  SuppliesWindow.item1.onItemChange = function(widget)
    storage[suppliesPanelName].item1 = widget:getItemId()
  end

  SuppliesWindow.item2:setItemId(storage[suppliesPanelName].item2)
  SuppliesWindow.item2.onItemChange = function(widget)
    storage[suppliesPanelName].item2 = widget:getItemId()
  end

  SuppliesWindow.item3:setItemId(storage[suppliesPanelName].item3)
  SuppliesWindow.item3.onItemChange = function(widget)
    storage[suppliesPanelName].item3 = widget:getItemId()
  end
  
  SuppliesWindow.item4:setItemId(storage[suppliesPanelName].item4)
  SuppliesWindow.item4.onItemChange = function(widget)
    storage[suppliesPanelName].item4 = widget:getItemId()
  end

  SuppliesWindow.item5:setItemId(storage[suppliesPanelName].item5)
  SuppliesWindow.item5.onItemChange = function(widget)
    storage[suppliesPanelName].item5 = widget:getItemId()
  end

  SuppliesWindow.item6:setItemId(storage[suppliesPanelName].item6)
  SuppliesWindow.item6.onItemChange = function(widget)
    storage[suppliesPanelName].item6 = widget:getItemId()
  end

  SuppliesWindow.PotionBp:setItemId(storage[suppliesPanelName].potionBp)
  SuppliesWindow.PotionBp.onItemChange = function(widget)
    storage[suppliesPanelName].potionBp = widget:getItemId()
  end
  
  SuppliesWindow.RuneBp:setItemId(storage[suppliesPanelName].runeBp)
  SuppliesWindow.RuneBp.onItemChange = function(widget)
    storage[suppliesPanelName].runeBp = widget:getItemId()
  end

  SuppliesWindow.AmmoBp:setItemId(storage[suppliesPanelName].ammoBp)
  SuppliesWindow.AmmoBp.onItemChange = function(widget)
    storage[suppliesPanelName].ammoBp = widget:getItemId()
  end

  -- text windows
  SuppliesWindow.capValue:setText(storage[suppliesPanelName].capValue)
  SuppliesWindow.capValue.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.capValue:getText())
    if not value then
      SuppliesWindow.capValue:setText(0)
    end
    storage[suppliesPanelName].capValue = text
end
  
  SuppliesWindow.item1Min:setText(storage[suppliesPanelName].item1Min)
  SuppliesWindow.item1Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item1Min:getText())
    if not value then
      SuppliesWindow.item1Min:setText(0)
    end
    storage[suppliesPanelName].item1Min = text
end

  SuppliesWindow.item1Max:setText(storage[suppliesPanelName].item1Max)
  SuppliesWindow.item1Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item1Max:getText())
    if not value then
      SuppliesWindow.item1Max:setText(0)
    end
    storage[suppliesPanelName].item1Max = text
end

  SuppliesWindow.item2Min:setText(storage[suppliesPanelName].item2Min)
  SuppliesWindow.item2Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item2Min:getText())
    if not value then
      SuppliesWindow.item2Min:setText(0)
    end
    storage[suppliesPanelName].item2Min = text
end

  SuppliesWindow.item2Max:setText(storage[suppliesPanelName].item2Max)
  SuppliesWindow.item2Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item2Max:getText())
    if not value then
      SuppliesWindow.item2Max:setText(0)
    end
    storage[suppliesPanelName].item2Max = text
end 

  SuppliesWindow.item3Min:setText(storage[suppliesPanelName].item3Min)
  SuppliesWindow.item3Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item3Min:getText())
    if not value then
      SuppliesWindow.item3Min:setText(0)
    end
    storage[suppliesPanelName].item3Min = text
end   

  SuppliesWindow.item3Max:setText(storage[suppliesPanelName].item3Max)
  SuppliesWindow.item3Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item3Max:getText())
    if not value then
      SuppliesWindow.item3Max:setText(0)
    end
    storage[suppliesPanelName].item3Max = text
end
   
  SuppliesWindow.item4Min:setText(storage[suppliesPanelName].item4Min)
  SuppliesWindow.item4Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item4Min:getText())
    if not value then
      SuppliesWindow.item4Min:setText(0)
    end
    storage[suppliesPanelName].item4Min = text
end

SuppliesWindow.staminaValue:setText(storage[suppliesPanelName].staminaValue)
SuppliesWindow.staminaValue.onTextChange = function(widget, text)
  local value = tonumber(SuppliesWindow.staminaValue:getText())
  if not value then
    SuppliesWindow.staminaValue:setText(0)
  end
  storage[suppliesPanelName].staminaValue = text
end

  SuppliesWindow.item4Max:setText(storage[suppliesPanelName].item4Max)
  SuppliesWindow.item4Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item4Max:getText())
    if not value then
      SuppliesWindow.item4Max:setText(0)
    end
    storage[suppliesPanelName].item4Max = text
end

  SuppliesWindow.item5Min:setText(storage[suppliesPanelName].item5Min)
  SuppliesWindow.item5Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item5Min:getText())
    if not value then
      SuppliesWindow.item5Min:setText(0)
    end
    storage[suppliesPanelName].item5Min = text
end

  SuppliesWindow.item5Max:setText(storage[suppliesPanelName].item5Max)
  SuppliesWindow.item5Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item5Max:getText())
    if not value then
      SuppliesWindow.item5Max:setText(0)
    end
    storage[suppliesPanelName].item5Max = text
end

SuppliesWindow.item6Min:setText(storage[suppliesPanelName].item6Min)
SuppliesWindow.item6Min.onTextChange = function(widget, text)
  local value = tonumber(SuppliesWindow.item6Min:getText())
  if not value then
    SuppliesWindow.item6Min:setText(0)
  end
  storage[suppliesPanelName].item6Min = text
end

SuppliesWindow.item6Max:setText(storage[suppliesPanelName].item6Max)
SuppliesWindow.item6Max.onTextChange = function(widget, text)
  local value = tonumber(SuppliesWindow.item6Max:getText())
  if not value then
    SuppliesWindow.item6Max:setText(0)
  end
  storage[suppliesPanelName].item6Max = text
end

end

ui.supplies.onClick = function(widget)
  SuppliesWindow:show()
  SuppliesWindow:raise()
  SuppliesWindow:focus()
end

SuppliesWindow.close.onClick = function(widget)
  SuppliesWindow:hide()
end
end

local potions = {268, 237, 238, 23373, 266, 236, 239, 7643, 7642, 23374} 
local runes = {3725, 3203, 3161, 3147, 3178, 3177, 3153, 3148, 3197, 3149, 3164, 3166, 3200, 3192, 3188, 3190, 3189, 3191, 3198, 3182, 3158, 3152, 3174, 3180, 3165, 3173, 3172, 3176, 3195, 3179, 3175, 3155, 3202, 3160, 3156}
local ammo = {23375, 3446, 16142, 6528, 7363, 3450, 16141, 25785, 14252, 3447, 3449, 15793, 25757, 774, 16143, 763, 761, 7365, 3448, 762, 21470, 7364, 14251, 7368, 25759, 3287, 7366, 3298, 25758}

macro(250, function()
  if not storage[suppliesPanelName].sortSupplies then return end
  local sortPotions = storage[suppliesPanelName].potionBp > 100
  local sortRunes = storage[suppliesPanelName].runeBp > 100
  local sortAmmo = storage[suppliesPanelName].ammoBp > 100
  local potionsContainer = nil
  local runesContainer = nil
  local ammoContainer = nil

  -- set the containers
  if not potionsContainer or not runesContainer or not ammoContainer then
    for i, container in pairs(getContainers()) do
      if not containerIsFull(container) then
        if sortPotions and container:getContainerItem():getId() == storage[suppliesPanelName].potionBp then
          potionsContainer = container
        elseif sortRunes and container:getContainerItem():getId() == storage[suppliesPanelName].runeBp then
          runesContainer = container
        elseif sortAmmo and container:getContainerItem():getId() == storage[suppliesPanelName].ammoBp then
          ammoContainer = container
        end 
      end
    end
  end


   -- potions
   if potionsContainer then 
    for i, container in pairs(getContainers()) do
      if (container:getContainerItem():getId() ~= storage[suppliesPanelName].potionBp and (string.find(container:getName(), "backpack") or string.find(container:getName(), "bag") or string.find(container:getName(), "chess"))) then
        for j, item in pairs(container:getItems()) do
          if table.find(potions, item:getId()) then
            return g_game.move(item, potionsContainer:getSlotPosition(potionsContainer:getItemsCount()), item:getCount())
          end
        end
      end
    end
  end

   -- runes
   if runesContainer then 
    for i, container in pairs(getContainers()) do
      if (container:getContainerItem():getId() ~= storage[suppliesPanelName].runeBp and (string.find(container:getName(), "backpack") or string.find(container:getName(), "bag") or string.find(container:getName(), "chess"))) then
        for j, item in pairs(container:getItems()) do
          if table.find(runes, item:getId()) then
            return g_game.move(item, runesContainer:getSlotPosition(runesContainer:getItemsCount()), item:getCount())
          end
        end
      end
    end
  end 

  -- ammo
  if ammoContainer then 
    for i, container in pairs(getContainers()) do
      if (container:getContainerItem():getId() ~= storage[suppliesPanelName].ammoBp and (string.find(container:getName(), "backpack") or string.find(container:getName(), "bag") or string.find(container:getName(), "chess"))) and not string.find(container:getName():lower(), "loot") then
        for j, item in pairs(container:getItems()) do
          if table.find(ammo, item:getId()) then
            return g_game.move(item, ammoContainer:getSlotPosition(ammoContainer:getItemsCount()), item:getCount())
          end
        end
      end
    end
  end
end)

UI.Separator()
SuppliesPanel(setDefaultTab("Cave"))