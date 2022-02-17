function SuppliesPanel(parent)
  local panelName = "supplies"
  if not parent then
    parent = panel
  end

  local temp = nil
  if SuppliesConfig[panelName] and SuppliesConfig[panelName].item1 then
    temp = SuppliesConfig[panelName]
  end


if not SuppliesConfig[panelName] or SuppliesConfig[panelName].item1 then
  SuppliesConfig[panelName] = {
    currentProfile = "Default",
    ["Default"] = {}
  }
  if temp then
    SuppliesConfig[panelName].Default = temp
  end
end

local currentProfile = SuppliesConfig[panelName].currentProfile
local config = SuppliesConfig[panelName][currentProfile]

if not config then
  for k,v in pairs(SuppliesConfig[panelName]) do
    if type(v) == "table" then
      SuppliesConfig[panelName].currentProfile = k
      config = SuppliesConfig[panelName][k]
      break
    end
  end
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  SuppliesWindow = UI.createWindow('SuppliesWindow', rootWidget)
  SuppliesWindow:hide()

  SuppliesWindow.onVisibilityChange = function(widget, visible)
    if not visible then
      vBotConfigSave("supply")
    end
  end

  local function loadVariables()
    config.item1 = config.item1 or 0
    config.item2 = config.item2 or 0
    config.item3 = config.item3 or 0
    config.item4 = config.item4 or 0
    config.item5 = config.item5 or 0
    config.item6 = config.item6 or 0
    config.item1Min = config.item1Min or 0
    config.item1Max = config.item1Max or 0
    config.item2Min = config.item2Min or 0
    config.item2Max = config.item2Max or 0
    config.item3Min = config.item3Min or 0
    config.item3Max = config.item3Max or 0
    config.item4Min = config.item4Min or 0
    config.item4Max = config.item4Max or 0
    config.item5Min = config.item5Min or 0
    config.item5Max = config.item5Max or 0
    config.item6Min = config.item6Min or 0
    config.item6Max = config.item6Max or 0
    config.capValue = config.capValue or 0
    config.staminaValue = config.staminaValue or 0
  end
  loadVariables()
  
  local function setValues()
    SuppliesWindow.capSwitch:setOn(config.capSwitch)
    SuppliesWindow.SoftBoots:setOn(config.SoftBoots)
    SuppliesWindow.imbues:setOn(config.imbues)
    SuppliesWindow.staminaSwitch:setOn(config.staminaSwitch)
    SuppliesWindow.item1:setItemId(config.item1)
    SuppliesWindow.item2:setItemId(config.item2)
    SuppliesWindow.item3:setItemId(config.item3)
    SuppliesWindow.item4:setItemId(config.item4)
    SuppliesWindow.item5:setItemId(config.item5)
    SuppliesWindow.capValue:setText(config.capValue)
    SuppliesWindow.item1Min:setText(config.item1Min)
    SuppliesWindow.item1Max:setText(config.item1Max)
    SuppliesWindow.item2Min:setText(config.item2Min)
    SuppliesWindow.item2Max:setText(config.item2Max)
    SuppliesWindow.item3Min:setText(config.item3Min)
    SuppliesWindow.item3Max:setText(config.item3Max)
    SuppliesWindow.item4Min:setText(config.item4Min)
    SuppliesWindow.staminaValue:setText(config.staminaValue)
    SuppliesWindow.item4Max:setText(config.item4Max)
    SuppliesWindow.item5Min:setText(config.item5Min)
    SuppliesWindow.item5Max:setText(config.item5Max)
    SuppliesWindow.item6Min:setText(config.item6Min)
    SuppliesWindow.item6Max:setText(config.item6Max)
  end
  setValues()

  local function refreshProfileList()
    local profiles = SuppliesConfig[panelName]
  
    SuppliesWindow.profiles:destroyChildren()
    for k,v in pairs(profiles) do
      if type(v) == "table" then
        local label = UI.createWidget("ProfileLabel", SuppliesWindow.profiles)
        label:setText(k)
        label:setTooltip("Click to load this profile. \nDouble click to change the name.")
        label.remove.onClick = function()
          local childs = SuppliesWindow.profiles:getChildCount()
          if childs == 1 then
            return info("vBot[Supplies] You need at least one profile!")
          end
          profiles[k] = nil
          label:destroy()
          vBotConfigSave("supply")
        end
        label.onDoubleClick = function(widget)
          local window = modules.client_textedit.show(widget, {title = "Set Profile Name", description = "Enter a new name for selected profile"})
          schedule(50, function() 
            window:raise()
            window:focus() 
          end)
        end
        label.onClick = function()
          SuppliesConfig[panelName].currentProfile = label:getText()
          config = SuppliesConfig[panelName][label:getText()]
          loadVariables()
          setValues()
          vBotConfigSave("supply")
        end
        label.onTextChange = function(widget,text)
          profiles[text] = profiles[k]
          profiles[k] = nil
          vBotConfigSave("supply")
        end
      end
    end
  end
  refreshProfileList()

  local function setProfileFocus()
    for i,v in ipairs(SuppliesWindow.profiles:getChildren()) do
      local name = v:getText()
      if name == SuppliesConfig[panelName].currentProfile then
        return v:focus()
      end
    end
  end
  setProfileFocus()

  SuppliesWindow.newProfile.onClick = function()
    local n = SuppliesWindow.profiles:getChildCount()
    if n > 6 then
      return info("vBot[Supplies] - max profile count reached!")
    end
    local name = "Profile #"..n+1
    SuppliesConfig[panelName][name] = {}
    refreshProfileList()
    setProfileFocus()
    vBotConfigSave("supply")
  end

  SuppliesWindow.capSwitch.onClick = function(widget)
    config.capSwitch = not config.capSwitch
    widget:setOn(config.capSwitch)
  end

  SuppliesWindow.SoftBoots.onClick = function(widget)
    config.SoftBoots = not config.SoftBoots
    widget:setOn(config.SoftBoots)
  end

  SuppliesWindow.imbues.onClick = function(widget)
    config.imbues = not config.imbues
    widget:setOn(config.imbues)
  end

  SuppliesWindow.staminaSwitch.onClick = function(widget)
    config.staminaSwitch = not config.staminaSwitch
    widget:setOn(config.staminaSwitch)
  end

  -- bot items

  SuppliesWindow.item1.onItemChange = function(widget)
    config.item1 = widget:getItemId()
  end

  SuppliesWindow.item2.onItemChange = function(widget)
    config.item2 = widget:getItemId()
  end

  SuppliesWindow.item3.onItemChange = function(widget)
    config.item3 = widget:getItemId()
  end
  
  SuppliesWindow.item4.onItemChange = function(widget)
    config.item4 = widget:getItemId()
  end

  SuppliesWindow.item5.onItemChange = function(widget)
    config.item5 = widget:getItemId()
  end

  SuppliesWindow.item6:setItemId(config.item6)
  SuppliesWindow.item6.onItemChange = function(widget)
    config.item6 = widget:getItemId()
  end

  -- text windows
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

  SuppliesWindow.item3Max.onTextChange = function(widget, text)
    local value = tonumber(SuppliesWindow.item3Max:getText())
    if not value then
      SuppliesWindow.item3Max:setText(0)
      config.item3Max = 0
    else
      config.item3Max = text
    end
  end
   
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

  Supplies = {}
  Supplies.show = function()
    SuppliesWindow:show()
    SuppliesWindow:raise()
    SuppliesWindow:focus()
  end
end

UI.Button("Supplies", function()
  SuppliesWindow:show()
  SuppliesWindow:raise()
  SuppliesWindow:focus()
end)

SuppliesWindow.close.onClick = function(widget)
  SuppliesWindow:hide()
end
end

UI.Separator()
SuppliesPanel(setDefaultTab("Cave"))