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
    SuppliesWindow.staminaValue:setText("")
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

UI.Separator()
SuppliesPanel(setDefaultTab("Cave"))