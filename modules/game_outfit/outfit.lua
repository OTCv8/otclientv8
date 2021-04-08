ADDON_SETS = {
  [1] = {1},
  [2] = {2},
  [3] = {1, 2},
  [4] = {3},
  [5] = {1, 3},
  [6] = {2, 3},
  [7] = {1, 2, 3}
}

outfitWindow = nil
outfit = nil
outfits = nil
outfitCreatureBox = nil
currentOutfit = 1

addons = nil
currentColorBox = nil
currentClotheButtonBox = nil
colorBoxes = {}

mount = nil
mounts = nil
mountCreatureBox = nil
currentMount = 1
ignoreNextOutfitWindow = 0

function init()
  connect(
    g_game,
    {
      onOpenOutfitWindow = create,
      onGameEnd = destroy
    }
  )
end

function terminate()
  disconnect(
    g_game,
    {
      onOpenOutfitWindow = create,
      onGameEnd = destroy
    }
  )
  destroy()
end

function updateMount()
  if table.empty(mounts) or not mount then
    return
  end
  local nameMountWidget = outfitWindow:getChildById("mountName")
  nameMountWidget:setText(mounts[currentMount][2])

  mount.type = mounts[currentMount][1]
  mountCreature:setOutfit(mount)
end

function setupSelector(widget, id, outfit, list)
  widget:setId(id)
  if id == "healthBar" or id == "manaBar" then
    widget.title:setText(id == "healthBar" and "Health Bar" or "Mana Bar")
    table.insert(list, 1, {0, "-"})
  else
    widget.title:setText(id:gsub("^%l", string.upper))
    if id ~= "type" or #list == 0 then
      table.insert(list, 1, {0, "-"})
    end
  end

  local pos = 1
  for i, o in pairs(list) do
    if (id == "shader" and outfit[id] == o[2]) or outfit[id] == o[1] then
      pos = i
    end
  end
  if list[pos] then
    widget.outfit = list[pos]
    if id == "shader" then
      widget.creature:setOutfit(
        {
          shader = list[pos][2]
        }
      )
    elseif id == "healthBar" then
      if pos ~= 1 then
        widget.bar:setImageSource(g_healthBars.getHealthBarPath(pos - 1))
      else
        widget.bar:setImageSource("")
      end
      widget.bar.selected = pos - 1
    elseif id == "manaBar" then
      if pos ~= 1 then
        widget.bar:setImageSource(g_healthBars.getManaBarPath(pos - 1))
      else
        widget.bar:setImageSource("")
      end
      widget.bar.selected = pos - 1
    else
      widget.creature:setOutfit(
        {
          type = list[pos][1]
        }
      )
    end
    widget.label:setText(list[pos][2])
  end

  widget.prevButton.onClick = function()
    if pos == 1 then
      pos = #list
    else
      pos = pos - 1
    end
    if id == "healthBar" or id == "manaBar" then
      if id == "healthBar" then
        if pos ~= 1 then
          widget.bar:setImageSource(g_healthBars.getHealthBarPath(pos - 1))
        else
          widget.bar:setImageSource("")
        end
      elseif id == "manaBar" then
        if pos ~= 1 then
          widget.bar:setImageSource(g_healthBars.getManaBarPath(pos - 1))
        else
          widget.bar:setImageSource("")
        end
      end
      widget.bar.selected = pos - 1
      widget.label:setText(list[pos][2])
    else
      local outfit = widget.creature:getOutfit()
      if id == "shader" then
        outfit.shader = list[pos][2]
      else
        outfit.type = list[pos][1]
      end
      widget.outfit = list[pos]
      widget.creature:setOutfit(outfit)
      widget.label:setText(list[pos][2])
      updateOutfit()
    end
  end

  widget.nextButton.onClick = function()
    if pos == #list then
      pos = 1
    else
      pos = pos + 1
    end
    if id == "healthBar" or id == "manaBar" then
      if id == "healthBar" then
        if pos ~= 1 then
          widget.bar:setImageSource(g_healthBars.getHealthBarPath(pos - 1))
        else
          widget.bar:setImageSource("")
        end
      elseif id == "manaBar" then
        if pos ~= 1 then
          widget.bar:setImageSource(g_healthBars.getManaBarPath(pos - 1))
        else
          widget.bar:setImageSource("")
        end
      end
      widget.bar.selected = pos - 1
      widget.label:setText(list[pos][2])
    else
      local outfit = widget.creature:getOutfit()
      if id == "shader" then
        outfit.shader = list[pos][2]
      else
        outfit.type = list[pos][1]
      end
      widget.outfit = list[pos]
      widget.creature:setOutfit(outfit)
      widget.label:setText(list[pos][2])
      updateOutfit()
    end
  end
  return widget
end

function create(currentOutfit, outfitList, mountList, wingList, auraList, shaderList, hpBarList, manaBarList)
  if ignoreNextOutfitWindow and g_clock.millis() < ignoreNextOutfitWindow + 1000 then
    return
  end
  if outfitWindow and not outfitWindow:isHidden() then
    return
  end

  destroy()

  outfitWindow = g_ui.displayUI("outfitwindow")

  setupSelector(outfitWindow.type, "type", currentOutfit, outfitList)

  local outfit = outfitWindow.type.creature:getOutfit()
  outfit.head = currentOutfit.head
  outfit.body = currentOutfit.body
  outfit.legs = currentOutfit.legs
  outfit.feet = currentOutfit.feet
  outfitWindow.type.creature:setOutfit(outfit)

  if g_game.getFeature(GamePlayerMounts) then
    setupSelector(g_ui.createWidget("OutfitSelectorPanel", outfitWindow.extensions), "mount", currentOutfit, mountList)
  end
  if g_game.getFeature(GameWingsAndAura) then
    setupSelector(g_ui.createWidget("OutfitSelectorPanel", outfitWindow.extensions), "wings", currentOutfit, wingList)
    setupSelector(g_ui.createWidget("OutfitSelectorPanel", outfitWindow.extensions), "aura", currentOutfit, auraList)
  end
  if g_game.getFeature(GameOutfitShaders) then
    setupSelector(g_ui.createWidget("OutfitSelectorPanel", outfitWindow.extensions), "shader", currentOutfit, shaderList)
  end

  if g_game.getFeature(GameHealthInfoBackground) then
    setupSelector(g_ui.createWidget("BarSelectorPanel", outfitWindow.extensions), "healthBar", currentOutfit, hpBarList)
    setupSelector(g_ui.createWidget("BarSelectorPanel", outfitWindow.extensions), "manaBar", currentOutfit, manaBarList)
  end

  if not outfitWindow.extensions:getFirstChild() then
    outfitWindow:setHeight(outfitWindow:getHeight() - 128)
  end

  for j = 0, 6 do
    for i = 0, 18 do
      local colorBox = g_ui.createWidget("ColorBox", outfitWindow.colorBoxPanel)
      local outfitColor = getOutfitColor(j * 19 + i)
      colorBox:setImageColor(outfitColor)
      colorBox:setId("colorBox" .. j * 19 + i)
      colorBox.colorId = j * 19 + i

      if j * 19 + i == currentOutfit.head then
        currentColorBox = colorBox
        colorBox:setChecked(true)
      end
      colorBox.onCheckChange = onColorCheckChange
      colorBoxes[#colorBoxes + 1] = colorBox
    end
  end

  -- set addons
  addons = {
    [1] = {widget = outfitWindow:getChildById("addon1"), value = 1},
    [2] = {widget = outfitWindow:getChildById("addon2"), value = 2},
    [3] = {widget = outfitWindow:getChildById("addon3"), value = 4}
  }

  for _, addon in pairs(addons) do
    addon.widget.onCheckChange = function(self)
      onAddonCheckChange(self, addon.value)
    end
  end

  if currentOutfit.addons and currentOutfit.addons > 0 then
    for _, i in pairs(ADDON_SETS[currentOutfit.addons]) do
      addons[i].widget:setChecked(true)
    end
  end

  -- hook outfit sections
  currentClotheButtonBox = outfitWindow.head
  outfitWindow.head.onCheckChange = onClotheCheckChange
  outfitWindow.primary.onCheckChange = onClotheCheckChange
  outfitWindow.secondary.onCheckChange = onClotheCheckChange
  outfitWindow.detail.onCheckChange = onClotheCheckChange

  updateOutfit()
end

function destroy()
  if outfitWindow then
    outfitWindow:destroy()
    outfitWindow = nil
    currentColorBox = nil
    currentClotheButtonBox = nil
    colorBoxes = {}
    addons = {}
  end
end

function randomize()
  local outfitTemplate = {
    outfitWindow.head,
    outfitWindow.primary,
    outfitWindow.secondary,
    outfitWindow.detail
  }

  for i = 1, #outfitTemplate do
    outfitTemplate[i]:setChecked(true)
    colorBoxes[math.random(1, #colorBoxes)]:setChecked(true)
    outfitTemplate[i]:setChecked(false)
  end
  outfitTemplate[1]:setChecked(true)
end

function accept()
  local outfit = outfitWindow.type.creature:getOutfit()
  for i, child in pairs(outfitWindow.extensions:getChildren()) do
    if child:getId() == "healthBar" or child:getId() == "manaBar" then
      outfit[child:getId()] = child.bar.selected
    else
      if child.creature:getCreature() then
        if child:getId() == "shader" then
          outfit[child:getId()] = child.creature:getOutfit().shader
        else
          outfit[child:getId()] = child.creature:getOutfit().type
        end
      end
    end
  end

  g_game.changeOutfit(outfit)
  destroy()
end

function onAddonCheckChange(addon, value)
  local outfit = outfitWindow.type.creature:getOutfit()
  if addon:isChecked() then
    outfit.addons = outfit.addons + value
  else
    outfit.addons = outfit.addons - value
  end
  outfitWindow.type.creature:setOutfit(outfit)
end

function onColorCheckChange(colorBox)
  local outfit = outfitWindow.type.creature:getOutfit()
  if colorBox == currentColorBox then
    colorBox.onCheckChange = nil
    colorBox:setChecked(true)
    colorBox.onCheckChange = onColorCheckChange
  else
    if currentColorBox then
      currentColorBox.onCheckChange = nil
      currentColorBox:setChecked(false)
      currentColorBox.onCheckChange = onColorCheckChange
    end

    currentColorBox = colorBox

    if currentClotheButtonBox:getId() == "head" then
      outfit.head = currentColorBox.colorId
    elseif currentClotheButtonBox:getId() == "primary" then
      outfit.body = currentColorBox.colorId
    elseif currentClotheButtonBox:getId() == "secondary" then
      outfit.legs = currentColorBox.colorId
    elseif currentClotheButtonBox:getId() == "detail" then
      outfit.feet = currentColorBox.colorId
    end
    outfitWindow.type.creature:setOutfit(outfit)
  end
end

function onClotheCheckChange(clotheButtonBox)
  local outfit = outfitWindow.type.creature:getOutfit()
  if clotheButtonBox == currentClotheButtonBox then
    clotheButtonBox.onCheckChange = nil
    clotheButtonBox:setChecked(true)
    clotheButtonBox.onCheckChange = onClotheCheckChange
  else
    currentClotheButtonBox.onCheckChange = nil
    currentClotheButtonBox:setChecked(false)
    currentClotheButtonBox.onCheckChange = onClotheCheckChange

    currentClotheButtonBox = clotheButtonBox

    local colorId = 0
    if currentClotheButtonBox:getId() == "head" then
      colorId = outfit.head
    elseif currentClotheButtonBox:getId() == "primary" then
      colorId = outfit.body
    elseif currentClotheButtonBox:getId() == "secondary" then
      colorId = outfit.legs
    elseif currentClotheButtonBox:getId() == "detail" then
      colorId = outfit.feet
    end
    outfitWindow:recursiveGetChildById("colorBox" .. colorId):setChecked(true)
  end
end

function updateOutfit()
  local currentSelection = outfitWindow.type.outfit
  if not currentSelection then
    return
  end
  local outfit = outfitWindow.type.creature:getOutfit()

  local availableAddons = currentSelection[3]
  local prevAddons = {}
  for k, addon in pairs(addons) do
    prevAddons[k] = addon.widget:isChecked()
    addon.widget:setChecked(false)
    addon.widget:setEnabled(false)
  end
  outfit.addons = 0
  outfitWindow.type.creature:setOutfit(outfit)

  local shader = outfitWindow.extensions:getChildById("shader")
  if shader then
    outfit.shader = shader.creature:getOutfit().shader
    if outfit.shader == "-" then
      outfit.shader = ""
    end
    shader.creature:setOutfit(outfit)
  end

  if availableAddons > 0 then
    for _, i in pairs(ADDON_SETS[availableAddons]) do
      addons[i].widget:setEnabled(true)
      addons[i].widget:setChecked(true)
    end
  end
end
