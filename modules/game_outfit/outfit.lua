local window = nil

local appearanceGroup = nil
local colorModeGroup = nil
local colorBoxGroup = nil

local floor = nil
local movementCheck = nil
local showFloorCheck = nil
local showOutfitCheck = nil
local showMountCheck = nil
local showWingsCheck = nil
local showAuraCheck = nil
local showShaderCheck = nil
local showBarsCheck = nil

local colorBoxes = {}
local currentColorBox = nil

ignoreNextOutfitWindow = 0
local floorTiles = 7
local settingsFile = "/settings/outfit.json"
local settings = {}

local tempOutfit = {}
local ServerData = {
  currentOutfit = {},
  outfits = {},
  mounts = {},
  wings = {},
  auras = {},
  shaders = {},
  healthBars = {},
  manaBars = {}
}

local AppearanceData = {
  "preset",
  "outfit",
  "mount",
  "wings",
  "aura",
  "shader",
  "healthBar",
  "manaBar"
}

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

function onMovementChange(checkBox, checked)
  previewCreature:setAnimate(checked)
  settings.movement = checked
end

function onShowFloorChange(checkBox, checked)
  if checked then
    floor:show()

    -- Magic!
    local delay = 50
    periodicalEvent(
      function()
        if movementCheck:isChecked() then
          local direction = previewCreature:getDirection()
          if direction == Directions.North then
            local newMargin = floor:getMarginTop() + 8
            floor:setMarginTop(newMargin)
            if newMargin >= 96 then
              for i = 1, floorTiles do
                floor:moveChildToIndex(floor:getChildByIndex(floorTiles * floorTiles), 1)
              end
              floor:setMarginTop(32)
            end
          elseif direction == Directions.South then
            local newMargin = floor:getMarginBottom() + 8
            floor:setMarginBottom(newMargin)
            if newMargin >= 64 then
              for i = 1, floorTiles do
                floor:moveChildToIndex(floor:getChildByIndex(1), floorTiles * floorTiles)
              end
              floor:setMarginBottom(0)
            end
          elseif direction == Directions.East then
            local newMargin = floor:getMarginRight() + 8
            floor:setMarginRight(newMargin)
            if newMargin >= 64 then
              floor:setMarginRight(0)
            end
          elseif direction == Directions.West then
            local newMargin = floor:getMarginLeft() + 8
            floor:setMarginLeft(newMargin)
            if newMargin >= 64 then
              floor:setMarginLeft(0)
            end
          end
        else
          floor:setMargin(0)
        end
      end,
      function()
        return window and floor and showFloorCheck:isChecked()
      end,
      delay,
      delay
    )
  else
    floor:hide()
  end

  settings.showFloor = checked
end

function onShowMountChange(checkBox, checked)
  settings.showMount = checked
  updatePreview()
end

function onShowOutfitChange(checkBox, checked)
  settings.showOutfit = checked
  showMountCheck:setEnabled(settings.showOutfit)
  showWingsCheck:setEnabled(settings.showOutfit)
  showAuraCheck:setEnabled(settings.showOutfit)
  showShaderCheck:setEnabled(settings.showOutfit)
  showBarsCheck:setEnabled(settings.showOutfit)
  updatePreview()
end

function onShowAuraChange(checkBox, checked)
  settings.showAura = checked
  updatePreview()
end

function onShowWingsChange(checkBox, checked)
  settings.showWings = checked
  updatePreview()
end

function onShowShaderChange(checkBox, checked)
  settings.showShader = checked
  updatePreview()
end

function onShowBarsChange(checkBox, checked)
  settings.showBars = checked
  updatePreview()
end

local PreviewOptions = {
  ["showFloor"] = onShowFloorChange,
  ["showOutfit"] = onShowOutfitChange,
  ["showMount"] = onShowMountChange,
  ["showWings"] = onShowWingsChange,
  ["showAura"] = onShowAuraChange,
  ["showShader"] = onShowShaderChange,
  ["showBars"] = onShowBarsChange
}

function create(currentOutfit, outfitList, mountList, wingList, auraList, shaderList, healthBarList, manaBarList)
  if ignoreNextOutfitWindow and g_clock.millis() < ignoreNextOutfitWindow + 1000 then
    return
  end

  if window then
    destroy()
  end

  if currentOutfit.shader == "" then
    currentOutfit.shader = "outfit_default"
  end

  loadSettings()

  ServerData = {
    currentOutfit = currentOutfit,
    outfits = outfitList,
    mounts = mountList,
    wings = wingList,
    auras = auraList,
    shaders = shaderList,
    healthBars = healthBarList,
    manaBars = manaBarList
  }

  window = g_ui.displayUI("outfitwindow")

  floor = window.preview.panel.floor
  for i = 1, floorTiles * floorTiles do
    g_ui.createWidget("FloorTile", floor)
  end
  floor:hide()

  for _, appKey in ipairs(AppearanceData) do
    updateAppearanceText(appKey, "None")
  end

  previewCreature = window.preview.panel.creature

  if settings.currentPreset > 0 then
    local preset = settings.presets[settings.currentPreset]
    tempOutfit = table.copy(preset.outfit)

    updateAppearanceText("preset", preset.title)
  else
    tempOutfit = currentOutfit
  end

  updatePreview()

  updateAppearanceTexts(currentOutfit)

  if g_game.getFeature(GamePlayerMounts) then
    local isMount = g_game.getLocalPlayer():isMounted()
    if isMount then
      window.configure.mount.check:setEnabled(true)
      window.configure.mount.check:setChecked(true)
    else
      window.configure.mount.check:setEnabled(currentOutfit.mount > 0)
      window.configure.mount.check:setChecked(isMount and currentOutfit.mount > 0)
    end
  end

  if currentOutfit.addons == 3 then
    window.configure.addon1.check:setChecked(true)
    window.configure.addon2.check:setChecked(true)
  elseif currentOutfit.addons == 2 then
    window.configure.addon1.check:setChecked(false)
    window.configure.addon2.check:setChecked(true)
  elseif currentOutfit.addons == 1 then
    window.configure.addon1.check:setChecked(true)
    window.configure.addon2.check:setChecked(false)
  end
  window.configure.addon1.check.onCheckChange = onAddonChange
  window.configure.addon2.check.onCheckChange = onAddonChange

  configureAddons(currentOutfit.addons)

  movementCheck = window.preview.panel.movement
  showFloorCheck = window.preview.options.showFloor.check
  showOutfitCheck = window.preview.options.showOutfit.check
  showMountCheck = window.preview.options.showMount.check
  showWingsCheck = window.preview.options.showWings.check
  showAuraCheck = window.preview.options.showAura.check
  showShaderCheck = window.preview.options.showShader.check
  showBarsCheck = window.preview.options.showBars.check

  movementCheck.onCheckChange = onMovementChange
  for _, option in ipairs(window.preview.options:getChildren()) do
    option.check.onCheckChange = PreviewOptions[option:getId()]
  end

  movementCheck:setChecked(settings.movement)
  showFloorCheck:setChecked(settings.showFloor)

  if not settings.showOutfit then
    showMountCheck:setEnabled(false)
    showWingsCheck:setEnabled(false)
    showAuraCheck:setEnabled(false)
    showShaderCheck:setEnabled(false)
    showBarsCheck:setEnabled(false)
  end

  showOutfitCheck:setChecked(settings.showOutfit)
  showMountCheck:setChecked(settings.showMount)
  showWingsCheck:setChecked(settings.showWings)
  showAuraCheck:setChecked(settings.showAura)
  showShaderCheck:setChecked(settings.showShader)
  showBarsCheck:setChecked(settings.showBars)

  colorBoxGroup = UIRadioGroup.create()
  for j = 0, 6 do
    for i = 0, 18 do
      local colorBox = g_ui.createWidget("ColorBox", window.appearance.colorBoxPanel)
      local outfitColor = getOutfitColor(j * 19 + i)
      colorBox:setImageColor(outfitColor)
      colorBox:setId("colorBox" .. j * 19 + i)
      colorBox.colorId = j * 19 + i

      if colorBox.colorId == currentOutfit.head then
        currentColorBox = colorBox
        colorBox:setChecked(true)
      end
      colorBoxGroup:addWidget(colorBox)
    end
  end

  colorBoxGroup.onSelectionChange = onColorCheckChange

  appearanceGroup = UIRadioGroup.create()
  appearanceGroup:addWidget(window.appearance.settings.preset.check)
  appearanceGroup:addWidget(window.appearance.settings.outfit.check)
  appearanceGroup:addWidget(window.appearance.settings.mount.check)
  appearanceGroup:addWidget(window.appearance.settings.aura.check)
  appearanceGroup:addWidget(window.appearance.settings.wings.check)
  appearanceGroup:addWidget(window.appearance.settings.shader.check)
  appearanceGroup:addWidget(window.appearance.settings.healthBar.check)
  appearanceGroup:addWidget(window.appearance.settings.manaBar.check)

  appearanceGroup.onSelectionChange = onAppearanceChange
  appearanceGroup:selectWidget(window.appearance.settings.preset.check)

  colorModeGroup = UIRadioGroup.create()
  colorModeGroup:addWidget(window.appearance.colorMode.head)
  colorModeGroup:addWidget(window.appearance.colorMode.primary)
  colorModeGroup:addWidget(window.appearance.colorMode.secondary)
  colorModeGroup:addWidget(window.appearance.colorMode.detail)

  colorModeGroup.onSelectionChange = onColorModeChange
  colorModeGroup:selectWidget(window.appearance.colorMode.head)

  window.preview.options.showMount:setVisible(g_game.getFeature(GamePlayerMounts))
  window.preview.options.showWings:setVisible(g_game.getFeature(GameWingsAndAura))
  window.preview.options.showAura:setVisible(g_game.getFeature(GameWingsAndAura))
  window.preview.options.showShader:setVisible(g_game.getFeature(GameOutfitShaders))

  window.appearance.settings.mount:setVisible(g_game.getFeature(GamePlayerMounts))
  window.appearance.settings.wings:setVisible(g_game.getFeature(GameWingsAndAura))
  window.appearance.settings.aura:setVisible(g_game.getFeature(GameWingsAndAura))
  window.appearance.settings.shader:setVisible(g_game.getFeature(GameOutfitShaders))
  window.appearance.settings.healthBar:setVisible(g_game.getFeature(GameHealthInfoBackground))
  window.appearance.settings.manaBar:setVisible(g_game.getFeature(GameHealthInfoBackground))

  window.configure.mount:setVisible(g_game.getFeature(GamePlayerMounts))

  window.listSearch.search.onKeyPress = onFilterSearch
end

function destroy()
  if window then
    window:destroy()
    window = nil

    floor = nil
    movementCheck = nil
    showFloorCheck = nil
    showOutfitCheck = nil
    showMountCheck = nil
    showWingsCheck = nil
    showAuraCheck = nil
    showShaderCheck = nil
    showBarsCheck = nil

    colorBoxes = {}
    currentColorBox = nil

    appearanceGroup:destroy()
    appearanceGroup = nil
    colorModeGroup:destroy()
    colorModeGroup = nil
    colorBoxGroup:destroy()
    colorBoxGroup = nil

    ServerData = {
      currentOutfit = {},
      outfits = {},
      mounts = {},
      wings = {},
      auras = {},
      shaders = {},
      healthBars = {},
      manaBars = {}
    }

    saveSettings()
    settings = {}
  end
end

function configureAddons(addons)
  local hasAddon1 = addons == 1 or addons == 3
  local hasAddon2 = addons == 2 or addons == 3
  window.configure.addon1.check:setEnabled(hasAddon1)
  window.configure.addon2.check:setEnabled(hasAddon2)

  window.configure.addon1.check.onCheckChange = nil
  window.configure.addon2.check.onCheckChange = nil
  window.configure.addon1.check:setChecked(false)
  window.configure.addon2.check:setChecked(false)
  if tempOutfit.addons == 3 then
    window.configure.addon1.check:setChecked(true)
    window.configure.addon2.check:setChecked(true)
  elseif tempOutfit.addons == 2 then
    window.configure.addon1.check:setChecked(false)
    window.configure.addon2.check:setChecked(true)
  elseif tempOutfit.addons == 1 then
    window.configure.addon1.check:setChecked(true)
    window.configure.addon2.check:setChecked(false)
  end
  window.configure.addon1.check.onCheckChange = onAddonChange
  window.configure.addon2.check.onCheckChange = onAddonChange
end

function newPreset()
  if not settings.presets then
    settings.presets = {}
  end

  local presetWidget = g_ui.createWidget("PresetButton", window.presetsList)
  local presetId = #settings.presets + 1
  presetWidget:setId(presetId)
  presetWidget.title:setText("New Preset")
  local outfitCopy = table.copy(tempOutfit)
  presetWidget.creature:setOutfit(outfitCopy)
  presetWidget.creature:setCenter(true)

  settings.presets[presetId] = {
    title = "New Preset",
    outfit = outfitCopy,
    mounted = window.configure.mount.check:isChecked()
  }

  presetWidget:focus()
  window.presetsList:ensureChildVisible(presetWidget, {x = 0, y = 196})
end

function deletePreset()
  local presetId = settings.currentPreset
  if presetId == 0 then
    local focused = window.presetsList:getFocusedChild()
    if focused then
      presetId = tonumber(focused:getId())
    end
  end

  if not presetId or presetId == 0 then
    return
  end

  table.remove(settings.presets, presetId)
  window.presetsList[presetId]:destroy()
  settings.currentPreset = 0
  local newId = 1
  for _, child in ipairs(window.presetsList:getChildren()) do
    child:setId(newId)
    newId = newId + 1
  end
  updateAppearanceText("preset", "None")
end

function savePreset()
  local presetId = settings.currentPreset
  if presetId == 0 then
    local focused = window.presetsList:getFocusedChild()
    if focused then
      presetId = tonumber(focused:getId())
    end
  end

  if not presetId or presetId == 0 then
    return
  end

  local outfitCopy = table.copy(tempOutfit)
  window.presetsList[presetId].creature:setOutfit(outfitCopy)
  window.presetsList[presetId].creature:setCenter(true)
  settings.presets[presetId].outfit = outfitCopy
  settings.presets[presetId].mounted = window.configure.mount.check:isChecked()
  settings.currentPreset = presetId
end

function renamePreset()
  local presetId = settings.currentPreset
  if presetId == 0 then
    local focused = window.presetsList:getFocusedChild()
    if focused then
      presetId = tonumber(focused:getId())
    end
  end

  if not presetId or presetId == 0 then
    return
  end

  local presetWidget = window.presetsList[presetId]
  presetWidget.title:hide()
  presetWidget.rename.input:setText("")
  presetWidget.rename.save.onClick = function()
    saveRename(presetId)
  end
  presetWidget.rename:show()
end

function saveRename(presetId)
  local presetWidget = window.presetsList[presetId]
  if not presetWidget then
    return
  end

  local newTitle = presetWidget.rename.input:getText():trim()
  presetWidget.rename.input:setText("")
  presetWidget.rename:hide()
  presetWidget.title:setText(newTitle)
  presetWidget.title:show()
  settings.presets[presetId].title = newTitle

  if presetId == settings.currentPreset then
    updateAppearanceText("preset", newTitle)
  end
end

function onAppearanceChange(widget, selectedWidget)
  local id = selectedWidget:getParent():getId()
  if id == "preset" then
    showPresets()
  elseif id == "outfit" then
    showOutfits()
  elseif id == "mount" then
    showMounts()
  elseif id == "aura" then
    showAuras()
  elseif id == "wings" then
    showWings()
  elseif id == "shader" then
    showShaders()
  elseif id == "healthBar" then
    showHealthBars()
  elseif id == "manaBar" then
    showManaBars()
  end
end

function showPresets()
  window.listSearch:hide()
  window.selectionList:hide()
  window.selectionScroll:hide()

  local focused = nil
  if window.presetsList:getChildCount() == 0 and settings.presets then
    for presetId, preset in ipairs(settings.presets) do
      local presetWidget = g_ui.createWidget("PresetButton", window.presetsList)
      presetWidget:setId(presetId)
      presetWidget.title:setText(preset.title)
      presetWidget.creature:setOutfit(preset.outfit)
      presetWidget.creature:setCenter(true)
      if presetId == settings.currentPreset then
        focused = presetId
      end
    end
  end

  if focused then
    local w = window.presetsList[focused]
    w:focus()
    window.presetsList:ensureChildVisible(w, {x = 0, y = 196})
  end

  window.presetsList.onChildFocusChange = onPresetSelect
  window.presetsList:show()
  window.presetsScroll:show()
  window.presetButtons:show()
end

function showOutfits()
  window.presetsList:hide()
  window.presetsScroll:hide()
  window.presetButtons:hide()

  window.selectionList.onChildFocusChange = nil
  window.selectionList:destroyChildren()

  local focused = nil
  for _, outfitData in ipairs(ServerData.outfits) do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId(outfitData[1])

    local outfit = table.copy(previewCreature:getOutfit())
    outfit.type = outfitData[1]
    outfit.addons = outfitData[3]
    outfit.mount = 0
    outfit.aura = 0
    outfit.wings = 0
    outfit.shader = "outfit_default"
    outfit.healthBar = 0
    outfit.manaBar = 0
    button.outfit:setOutfit(outfit)
    button.outfit:setCenter(true)
    button.name:setText(outfitData[2])
    if tempOutfit.type == outfitData[1] then
      focused = outfitData[1]
      configureAddons(outfitData[3])
    end
  end

  if focused then
    local w = window.selectionList[focused]
    w:focus()
    window.selectionList:ensureChildVisible(w, {x = 0, y = 196})
  end

  window.selectionList.onChildFocusChange = onOutfitSelect
  window.selectionList:show()
  window.selectionScroll:show()
  window.listSearch:show()
end

function showMounts()
  window.presetsList:hide()
  window.presetsScroll:hide()
  window.presetButtons:hide()

  window.selectionList.onChildFocusChange = nil
  window.selectionList:destroyChildren()

  local focused = nil
  for _, mountData in ipairs(ServerData.mounts) do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId(mountData[1])

    button.outfit:setOutfit({type = mountData[1]})
    button.outfit:setCenter(true)
    button.name:setText(mountData[2])
    if tempOutfit.mount == mountData[1] then
      focused = mountData[1]
    end
  end

  if #ServerData.mounts == 1 then
    window.selectionList:focusChild(nil)
  end

  window.configure.mount.check:setEnabled(focused)
  window.configure.mount.check:setChecked(g_game.getLocalPlayer():isMounted() and focused)

  if focused ~= nil then
    local w = window.selectionList[focused]
    w:focus()
    window.selectionList:ensureChildVisible(w, {x = 0, y = 196})
  end

  window.selectionList.onChildFocusChange = onMountSelect
  window.selectionList:show()
  window.selectionScroll:show()
  window.listSearch:show()
end

function showAuras()
  window.presetsList:hide()
  window.presetsScroll:hide()
  window.presetButtons:hide()

  window.selectionList.onChildFocusChange = nil
  window.selectionList:destroyChildren()

  local focused = nil
  do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId("0")

    button.outfit:setOutfit({type = 0})
    button.name:setText("None")
    if tempOutfit.aura == 0 then
      focused = 0
    end
  end

  for _, auraData in ipairs(ServerData.auras) do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId(auraData[1])

    button.outfit:setOutfit({type = auraData[1]})
    button.outfit:setAnimate(true)
    button.name:setText(auraData[2])
    if tempOutfit.aura == auraData[1] then
      focused = auraData[1]
    end
  end

  if focused ~= nil then
    local w = window.selectionList[focused]
    w:focus()
    window.selectionList:ensureChildVisible(w, {x = 0, y = 196})
  end

  window.selectionList.onChildFocusChange = onAuraSelect
  window.selectionList:show()
  window.selectionScroll:show()
  window.listSearch:show()
end

function showWings()
  window.presetsList:hide()
  window.presetsScroll:hide()
  window.presetButtons:hide()

  window.selectionList.onChildFocusChange = nil
  window.selectionList:destroyChildren()

  local focused = nil
  do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId("0")

    button.outfit:setOutfit({type = 0})
    button.name:setText("None")
    if tempOutfit.wings == 0 then
      focused = 0
    end
  end

  for _, wingsData in ipairs(ServerData.wings) do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId(wingsData[1])

    button.outfit:setOutfit({type = wingsData[1]})
    button.outfit:setAnimate(true)
    button.name:setText(wingsData[2])
    if tempOutfit.wings == wingsData[1] then
      focused = wingsData[1]
    end
  end

  if focused ~= nil then
    local w = window.selectionList[focused]
    w:focus()
    window.selectionList:ensureChildVisible(w, {x = 0, y = 196})
  end

  window.selectionList.onChildFocusChange = onWingsSelect
  window.selectionList:show()
  window.selectionScroll:show()
  window.listSearch:show()
end

function showShaders()
  window.presetsList:hide()
  window.presetsScroll:hide()
  window.presetButtons:hide()

  window.selectionList.onChildFocusChange = nil
  window.selectionList:destroyChildren()

  local focused = nil
  do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId("outfit_default")

    button.outfit:setOutfit({type = tempOutfit.type, addons = tempOutfit.addons, shader = "outfit_default"})
    button.name:setText("None")
    if tempOutfit.shader == "outfit_default" then
      focused = "outfit_default"
    end
  end

  for _, shaderData in ipairs(ServerData.shaders) do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId(shaderData[2])

    button.outfit:setOutfit({type = tempOutfit.type, addons = tempOutfit.addons, shader = shaderData[2]})
    button.outfit:setCenter(true)
    button.name:setText(shaderData[2])
    if tempOutfit.shader == shaderData[2] then
      focused = shaderData[2]
    end
  end

  if focused ~= nil then
    local w = window.selectionList[focused]
    w:focus()
    window.selectionList:ensureChildVisible(w, {x = 0, y = 196})
  end

  window.selectionList.onChildFocusChange = onShaderSelect
  window.selectionList:show()
  window.selectionScroll:show()
  window.listSearch:show()
end

function showHealthBars()
  window.presetsList:hide()
  window.presetsScroll:hide()
  window.presetButtons:hide()

  window.selectionList.onChildFocusChange = nil
  window.selectionList:destroyChildren()

  local focused = nil
  do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId("0")

    button.outfit:hide()
    button.name:setText("None")
    if tempOutfit.healthBar == 0 then
      focused = 0
    end
  end

  for _, barData in ipairs(ServerData.healthBars) do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId(barData[1])

    button.outfit:hide()

    button.bar:setImageSource(g_healthBars.getHealthBarPath(barData[1]))
    button.bar:show()

    button.name:setText(barData[2])
    if tempOutfit.healthBar == barData[1] then
      focused = barData[1]
    end
  end

  if focused ~= nil then
    local w = window.selectionList[focused]
    w:focus()
    window.selectionList:ensureChildVisible(w, {x = 0, y = 196})
  end

  window.selectionList.onChildFocusChange = onHealthBarSelect
  window.selectionList:show()
  window.selectionScroll:show()
  window.listSearch:show()
end

function showManaBars()
  window.presetsList:hide()
  window.presetsScroll:hide()
  window.presetButtons:hide()

  window.selectionList.onChildFocusChange = nil
  window.selectionList:destroyChildren()

  local focused = nil
  do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId("0")

    button.outfit:hide()
    button.name:setText("None")
    if tempOutfit.manaBar == 0 then
      focused = 0
    end
  end

  for _, barData in ipairs(ServerData.manaBars) do
    local button = g_ui.createWidget("SelectionButton", window.selectionList)
    button:setId(barData[1])

    button.outfit:hide()

    button.bar:setImageSource(g_healthBars.getManaBarPath(barData[1]))
    button.bar:show()

    button.name:setText(barData[2])
    if tempOutfit.manaBar == barData[1] then
      focused = barData[1]
    end
  end

  if focused ~= nil then
    local w = window.selectionList[focused]
    w:focus()
    window.selectionList:ensureChildVisible(w, {x = 0, y = 196})
  end

  window.selectionList.onChildFocusChange = onManaBarSelect
  window.selectionList:show()
  window.selectionScroll:show()
  window.listSearch:show()
end

function onPresetSelect(list, focusedChild, unfocusedChild, reason)
  if focusedChild then
    local presetId = tonumber(focusedChild:getId())
    local preset = settings.presets[presetId]
    tempOutfit = table.copy(preset.outfit)

    for _, outfitData in ipairs(ServerData.outfits) do
      if tempOutfit.type == outfitData[1] then
        configureAddons(outfitData[3])
        break
      end
    end

    if g_game.getFeature(GamePlayerMounts) then
      window.configure.mount.check:setChecked(preset.mounted and tempOutfit.mount > 0)
    end

    settings.currentPreset = presetId

    updatePreview()

    updateAppearanceTexts(tempOutfit)
    updateAppearanceText("preset", preset.title)
  end
end

function onOutfitSelect(list, focusedChild, unfocusedChild, reason)
  if focusedChild then
    local outfitType = tonumber(focusedChild:getId())
    local outfit = focusedChild.outfit:getOutfit()
    tempOutfit.type = outfit.type
    tempOutfit.addons = outfit.addons

    deselectPreset()

    configureAddons(outfit.addons)

    if showOutfitCheck:isChecked() then
      updatePreview()
    end
    updateAppearanceText("outfit", focusedChild.name:getText())
  end
end

function onMountSelect(list, focusedChild, unfocusedChild, reason)
  if focusedChild then
    local mountType = tonumber(focusedChild:getId())
    tempOutfit.mount = mountType

    deselectPreset()

    if showMountCheck:isChecked() then
      updatePreview()
    end

    window.configure.mount.check:setEnabled(tempOutfit.mount > 0)
    window.configure.mount.check:setChecked(g_game.getLocalPlayer():isMounted() and tempOutfit.mount > 0)

    updateAppearanceText("mount", focusedChild.name:getText())
  end
end

function onAuraSelect(list, focusedChild, unfocusedChild, reason)
  if focusedChild then
    local auraType = tonumber(focusedChild:getId())
    tempOutfit.aura = auraType
    updatePreview()

    deselectPreset()

    updateAppearanceText("aura", focusedChild.name:getText())
  end
end

function onWingsSelect(list, focusedChild, unfocusedChild, reason)
  if focusedChild then
    local wingsType = tonumber(focusedChild:getId())
    tempOutfit.wings = wingsType
    updatePreview()

    deselectPreset()

    updateAppearanceText("wings", focusedChild.name:getText())
  end
end

function onShaderSelect(list, focusedChild, unfocusedChild, reason)
  if focusedChild then
    local shaderType = focusedChild:getId()
    tempOutfit.shader = shaderType
    updatePreview()

    deselectPreset()

    updateAppearanceText("shader", focusedChild.name:getText())
  end
end

function onHealthBarSelect(list, focusedChild, unfocusedChild, reason)
  if focusedChild then
    local barType = tonumber(focusedChild:getId())
    tempOutfit.healthBar = barType
    updatePreview()

    deselectPreset()

    updateAppearanceText("healthBar", focusedChild.name:getText())
  end
end

function onManaBarSelect(list, focusedChild, unfocusedChild, reason)
  if focusedChild then
    local barType = tonumber(focusedChild:getId())
    tempOutfit.manaBar = barType
    updatePreview()

    deselectPreset()

    updateAppearanceText("manaBar", focusedChild.name:getText())
  end
end

function updateAppearanceText(widget, text)
  window.appearance.settings[widget].name:setText(text)
end

function updateAppearanceTexts(outfit)
  for _, appKey in ipairs(AppearanceData) do
    updateAppearanceText(appKey, "None")
  end

  for key, value in pairs(outfit) do
    local newKey = key
    local appKey = key
    if key == "type" then
      newKey = "outfits"
      appKey = "outfit"
    elseif key == "wings" then
      newKey = "wings"
      appKey = "wings"
    else
      newKey = key .. "s"
      appKey = key
    end
    local dataTable = ServerData[newKey]
    if dataTable then
      for _, data in ipairs(dataTable) do
        if outfit[key] == data[1] or outfit[key] == data[2] then
          updateAppearanceText(appKey, data[2])
        end
      end
    end
  end
end

function deselectPreset()
  settings.currentPreset = 0
end

function onAddonChange(widget, checked)
  local addonId = widget:getParent():getId()

  local addons = tempOutfit.addons
  if addonId == "addon1" then
    addons = checked and addons + 1 or addons - 1
  elseif addonId == "addon2" then
    addons = checked and addons + 2 or addons - 2
  end

  settings.currentPreset = 0

  tempOutfit.addons = addons
  updatePreview()
  if appearanceGroup:getSelectedWidget() == window.appearance.settings.outfit.check then
    showOutfits()
  end
end

function onColorModeChange(widget, selectedWidget)
  local colorMode = selectedWidget:getId()
  if colorMode == "head" then
    colorBoxGroup:selectWidget(window.appearance.colorBoxPanel["colorBox" .. tempOutfit.head])
  elseif colorMode == "primary" then
    colorBoxGroup:selectWidget(window.appearance.colorBoxPanel["colorBox" .. tempOutfit.body])
  elseif colorMode == "secondary" then
    colorBoxGroup:selectWidget(window.appearance.colorBoxPanel["colorBox" .. tempOutfit.legs])
  elseif colorMode == "detail" then
    colorBoxGroup:selectWidget(window.appearance.colorBoxPanel["colorBox" .. tempOutfit.feet])
  end
end

function onColorCheckChange(widget, selectedWidget)
  local colorId = selectedWidget.colorId
  local colorMode = colorModeGroup:getSelectedWidget():getId()
  if colorMode == "head" then
    tempOutfit.head = colorId
  elseif colorMode == "primary" then
    tempOutfit.body = colorId
  elseif colorMode == "secondary" then
    tempOutfit.legs = colorId
  elseif colorMode == "detail" then
    tempOutfit.feet = colorId
  end

  updatePreview()

  if appearanceGroup:getSelectedWidget() == window.appearance.settings.outfit.check then
    showOutfits()
  end
end

function updatePreview()
  local direction = previewCreature:getDirection()
  local previewOutfit = table.copy(tempOutfit)

  if not settings.showOutfit then
    previewCreature:hide()
  else
    previewCreature:show()
  end

  if not settings.showMount then
    previewOutfit.mount = 0
  end

  if not settings.showAura then
    previewOutfit.aura = 0
  end

  if not settings.showWings then
    previewOutfit.wings = 0
  end

  if not settings.showShader then
    previewOutfit.shader = "outfit_default"
  end

  if not settings.showBars then
    previewOutfit.healthBar = 0
    previewOutfit.manaBar = 0
    window.preview.panel.bars:hide()
  else
    if g_game.getFeature(GamePlayerMounts) and settings.showMount and previewOutfit.mount > 0 then
      window.preview.panel.bars:setMarginTop(45)
      window.preview.panel.bars:setMarginLeft(25)
    else
      window.preview.panel.bars:setMarginTop(30)
      window.preview.panel.bars:setMarginLeft(15)
    end
    local name = g_game.getCharacterName()
    window.preview.panel.bars.name:setText(name)
    if name:find("g") or name:find("j") or name:find("p") or name:find("q") or name:find("y") then
      window.preview.panel.bars.name:setHeight(14)
    else
      window.preview.panel.bars.name:setHeight(11)
    end

    local healthBar = window.preview.panel.bars.healthBar
    local manaBar = window.preview.panel.bars.manaBar
    if not g_game.getFeature(GameHealthInfoBackground) then
      manaBar:setMarginTop(0)
      healthBar:setMarginTop(1)
      healthBar.image:setMargin(0)
      healthBar.image:hide()
      manaBar.image:setMargin(0)
      manaBar.image:hide(0)
    else
      local healthOffset = g_healthBars.getHealthBarOffset(previewOutfit.healthBar)
      local healthBarOffset = g_healthBars.getHealthBarOffsetBar(previewOutfit.healthBar)
      local manaOffset = g_healthBars.getHealthBarOffset(previewOutfit.manaBar)

      if previewOutfit.healthBar > 0 then
        healthBar.image:setImageSource(g_healthBars.getHealthBarPath(previewOutfit.healthBar))

        healthBar:setMarginTop(-healthOffset.y + 1)
        healthBar.image:setMarginTop(-healthOffset.y)
        healthBar.image:setMarginBottom(-healthOffset.y)
        healthBar.image:setMarginLeft(-healthOffset.x)
        healthBar.image:setMarginRight(-healthOffset.x)
        healthBar.image:show()
        manaBar:setMarginTop(healthBarOffset.y + 1 - manaOffset.y)
      else
        manaBar:setMarginTop(0)
        healthBar:setMarginTop(1)
        healthBar.image:setMargin(0)
        healthBar.image:hide()
      end

      if previewOutfit.manaBar > 0 then
        manaBar.image:setImageSource(g_healthBars.getManaBarPath(previewOutfit.manaBar))

        manaBar:setMarginTop(healthBarOffset.y + 1 - manaOffset.y)

        manaBar.image:setMarginTop(-manaOffset.y)
        manaBar.image:setMarginBottom(-manaOffset.y)
        manaBar.image:setMarginLeft(-manaOffset.x)
        manaBar.image:setMarginRight(-manaOffset.x)
        manaBar.image:show()
      else
        manaBar.image:setMargin(0)
        manaBar.image:hide(0)
      end
    end
    window.preview.panel.bars:show()
  end

  previewCreature:setOutfit(previewOutfit)
  previewCreature:setDirection(direction)
end

function rotate(value)
  local direction = previewCreature:getDirection()
  direction = direction + value
  if direction < Directions.North then
    direction = Directions.West
  elseif direction > Directions.West then
    direction = Directions.North
  end
  previewCreature:setDirection(direction)
  floor:setMargin(0)
end

function onFilterSearch()
  addEvent(
    function()
      local searchText = window.listSearch.search:getText():lower():trim()
      local children = window.selectionList:getChildren()
      if searchText:len() >= 1 then
        for _, child in ipairs(children) do
          local text = child.name:getText():lower()
          if text:find(searchText) then
            child:show()
          else
            child:hide()
          end
        end
      else
        for _, child in ipairs(children) do
          child:show()
        end
      end
    end
  )
end

function saveSettings()
  if not g_resources.fileExists(settingsFile) then
    g_resources.makeDir("/settings")
    g_resources.writeFileContents(settingsFile, "[]")
  end

  local fullSettings = {}
  do
    local json_status, json_data =
      pcall(
      function()
        return json.decode(g_resources.readFileContents(settingsFile))
      end
    )

    if not json_status then
      g_logger.error("[saveSettings] Couldn't load JSON: " .. json_data)
      return
    end
    fullSettings = json_data
  end

  fullSettings[g_game.getCharacterName()] = settings

  local json_status, json_data =
    pcall(
    function()
      return json.encode(fullSettings)
    end
  )

  if not json_status then
    g_logger.error("[saveSettings] Couldn't save JSON: " .. json_data)
    return
  end

  g_resources.writeFileContents(settingsFile, json.encode(fullSettings))
end

function loadSettings()
  if not g_resources.fileExists(settingsFile) then
    g_resources.makeDir("/settings")
  end

  if g_resources.fileExists(settingsFile) then
    local json_status, json_data =
      pcall(
      function()
        return json.decode(g_resources.readFileContents(settingsFile))
      end
    )

    if not json_status then
      g_logger.error("[loadSettings] Couldn't load JSON: " .. json_data)
      return
    end

    settings = json_data[g_game.getCharacterName()]
    if not settings then
      loadDefaultSettings()
    end
  else
    loadDefaultSettings()
  end
end

function loadDefaultSettings()
  settings = {
    movement = false,
    showFloor = false,
    showOutfit = true,
    showMount = false,
    showWings = false,
    showAura = false,
    showShader = false,
    showBars = false,
    presets = {},
    currentPreset = 0
  }
  settings.currentPreset = 0
end

function accept()
  if g_game.getFeature(GamePlayerMounts) then
    local player = g_game.getLocalPlayer()
    local isMountedChecked = window.configure.mount.check:isChecked()
    if not player:isMounted() and isMountedChecked then
      player:mount()
    elseif player:isMounted() and not isMountedChecked then
      player:dismount()
    end
    if settings.currentPreset > 0 then
      settings.presets[settings.currentPreset].mounted = isMountedChecked
    end
  end

  g_game.changeOutfit(tempOutfit)
  destroy()
end
