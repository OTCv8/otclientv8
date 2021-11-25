function SuppliesPanel(parent)
  local panelName = "supplies"
  if not parent then
    parent = panel
  end

if not SuppliesConfig[panelName] then
  SuppliesConfig[panelName] = {
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

local config = SuppliesConfig[panelName]

-- data validation
local setup = config
setup.item1 = setup.item1 or 0
setup.item2 = setup.item2 or 0
setup.item3 = setup.item3 or 0
setup.item4 = setup.item4 or 0
setup.item5 = setup.item5 or 0
setup.item6 = setup.item6 or 0
setup.item1Min = setup.item1Min or 0
setup.item1Max = setup.item1Max or 0
setup.item2Min = setup.item2Min or 0
setup.item2Max = setup.item2Max or 0
setup.item3Min = setup.item3Min or 0
setup.item3Max = setup.item3Max or 0
setup.item4Min = setup.item4Min or 0
setup.item4Max = setup.item4Max or 0
setup.item5Min = setup.item5Min or 0
setup.item5Max = setup.item5Max or 0
setup.item6Min = setup.item6Min or 0
setup.item6Max = setup.item6Max or 0
setup.capValue = setup.capValue or 0
setup.staminaValue = setup.staminaValue or 0

rootWidget = g_ui.getRootWidget()
if rootWidget then
  SuppliesWindow = g_ui.createWidget('SuppliesWindow', rootWidget)
  SuppliesWindow:hide()

  SuppliesWindow.capSwitch:setOn(config.capSwitch)
  SuppliesWindow.capSwitch.onClick = function(widget)
    config.capSwitch = not config.capSwitch
    widget:setOn(config.capSwitch)
  end

  SuppliesWindow.SoftBoots:setOn(config.SoftBoots)
  SuppliesWindow.SoftBoots.onClick = function(widget)
    config.SoftBoots = not config.SoftBoots
    widget:setOn(config.SoftBoots)
  end

  SuppliesWindow.imbues:setOn(config.imbues)
  SuppliesWindow.imbues.onClick = function(widget)
    config.imbues = not config.imbues
    widget:setOn(config.imbues)
  end

  SuppliesWindow.staminaSwitch:setOn(config.staminaSwitch)
  SuppliesWindow.staminaSwitch.onClick = function(widget)
    config.staminaSwitch = not config.staminaSwitch
    widget:setOn(config.staminaSwitch)
  end

  -- bot items

  SuppliesWindow.item1:setItemId(config.item1)
  SuppliesWindow.item1.onItemChange = function(widget)
    config.item1 = widget:getItemId()
  end

  SuppliesWindow.item2:setItemId(config.item2)
  SuppliesWindow.item2.onItemChange = function(widget)
    config.item2 = widget:getItemId()
  end

  SuppliesWindow.item3:setItemId(config.item3)
  SuppliesWindow.item3.onItemChange = function(widget)
    config.item3 = widget:getItemId()
  end
  
  SuppliesWindow.item4:setItemId(config.item4)
  SuppliesWindow.item4.onItemChange = function(widget)
    config.item4 = widget:getItemId()
  end

  SuppliesWindow.item5:setItemId(config.item5)
  SuppliesWindow.item5.onItemChange = function(widget)
    config.item5 = widget:getItemId()
  end

  SuppliesWindow.item6:setItemId(config.item6)
  SuppliesWindow.item6.onItemChange = function(widget)
    config.item6 = widget:getItemId()
  end

  -- text windows
  SuppliesWindow.capValue:setText(config.capValue)
  SuppliesWindow.capValue.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.capValue:getText())
    if not value then
      SuppliesWindow.capValue:setText(0)
      config.capValue = 0
    else
      text = text:match("0*(%d+)")
      config.capValue = text
    end
end
  
  SuppliesWindow.item1Min:setText(config.item1Min)
  SuppliesWindow.item1Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item1Min:getText())
    if not value then
      SuppliesWindow.item1Min:setText(0)
      config.item1Min = 0
    else
      text = text:match("0*(%d+)")
      config.item1Min = text
    end
end

  SuppliesWindow.item1Max:setText(config.item1Max)
  SuppliesWindow.item1Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item1Max:getText())
    if not value then
      SuppliesWindow.item1Max:setText(0)
      config.item1Max = 0
    else
      text = text:match("0*(%d+)")
      config.item1Max = text
    end
end

  SuppliesWindow.item2Min:setText(config.item2Min)
  SuppliesWindow.item2Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item2Min:getText())
    if not value then
      SuppliesWindow.item2Min:setText(0)
      config.item2Min = 0
    else
      text = text:match("0*(%d+)")
      config.item2Min = text
    end
end

  SuppliesWindow.item2Max:setText(config.item2Max)
  SuppliesWindow.item2Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item2Max:getText())
    if not value then
      SuppliesWindow.item2Max:setText(0)
      config.item2Max = 0
    else
      text = text:match("0*(%d+)")
      config.item2Max = text
    end
end 

  SuppliesWindow.item3Min:setText(config.item3Min)
  SuppliesWindow.item3Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item3Min:getText())
    if not value then
      SuppliesWindow.item3Min:setText(0)
      config.item3Min = 0
    else
      text = text:match("0*(%d+)")
      config.item3Min = text
    end
end   

  SuppliesWindow.item3Max:setText(config.item3Max)
  SuppliesWindow.item3Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item3Max:getText())
    if not value then
      SuppliesWindow.item3Max:setText(0)
      config.item3Max = 0
    else
      config.item3Max = text
    end
end
   
  SuppliesWindow.item4Min:setText(config.item4Min)
  SuppliesWindow.item4Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item4Min:getText())
    if not value then
      SuppliesWindow.item4Min:setText(0)
      config.item4Min = 0
    else
      text = text:match("0*(%d+)")
      config.item4Min = text
    end
end

SuppliesWindow.staminaValue:setText(config.staminaValue)
SuppliesWindow.staminaValue.onTextChange = function(widget, text)
  local value = tonumber(SuppliesWindow.staminaValue:getText())
  if not value then
    SuppliesWindow.staminaValue:setText(0)
    config.staminaValue = 0
  else
    text = text:match("0*(%d+)")
    config.staminaValue = text
  end
end

  SuppliesWindow.item4Max:setText(config.item4Max)
  SuppliesWindow.item4Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item4Max:getText())
    if not value then
      SuppliesWindow.item4Max:setText(0)
      config.item4Max = 0
    else
      text = text:match("0*(%d+)")
      config.item4Max = text
    end
  end

  SuppliesWindow.item5Min:setText(config.item5Min)
  SuppliesWindow.item5Min.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item5Min:getText())
    if not value then
      SuppliesWindow.item5Min:setText(0)
      config.item5Min = 0
    else
      text = text:match("0*(%d+)")
      config.item5Min = text
    end
  end

  SuppliesWindow.item5Max:setText(config.item5Max)
  SuppliesWindow.item5Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item5Max:getText())
    if not value then
      SuppliesWindow.item5Max:setText(0)
      config.item5Max = 0
    else
      text = text:match("0*(%d+)")
      config.item5Max = text
    end
  end

SuppliesWindow.item6Min:setText(config.item6Min)
SuppliesWindow.item6Min.onTextChange = function(widget, text)
  local value = tonumber(SuppliesWindow.item6Min:getText())
  if not value then
    SuppliesWindow.item6Min:setText(0)
    config.item6Min = 0
  else
    text = text:match("0*(%d+)")
    config.item6Min = text
  end
end

SuppliesWindow.item6Max:setText(config.item6Max)
SuppliesWindow.item6Max.onTextChange = function(widget, text)
  local value = tonumber(SuppliesWindow.item6Max:getText())
  if not value then
    SuppliesWindow.item6Max:setText(0)
    config.item6Max = 0
  else
    text = text:match("0*(%d+)")
    config.item6Max = text
  end
end

end

UI.Button("Supplies", function()
  SuppliesWindow:show()
  SuppliesWindow:raise()
  SuppliesWindow:focus()
end)

SuppliesWindow.close.onClick = function(widget)
  SuppliesWindow:hide()
  vBotConfigSave("supply")
end
end

UI.Separator()
SuppliesPanel(setDefaultTab("Cave"))