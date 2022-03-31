local loadLocalShaders = false

appearanceOptions = {}
configOptions = {}
previewOptions = {}
previewDir = 2
filterText = ""
currentCategory = "outfit"
outfitWindow = nil
outfitCreatureBox = nil
currentColorBox = nil
currentClotheButtonBox = nil
colorBoxes = {}
dataTables = {
  outfits = {},
  mounts = {},
  auras = {},
  wings = {},
  shaders = {},
  manaBar = {},
  healthBar = {}
}

math.randomseed(os.time())

-- take local shaders, won't work if server does not support it
localShaders = {}
local shaderFiles = g_resources.listDirectoryFiles("/data/shaders/", true, false)
for i, file in ipairs(shaderFiles) do
  local name = file:split(".")[1]:trim():lower()
  name = name:gsub("/data/shaders//", "")
  name = name:gsub("_fragment", "")
  name = name:gsub("_vertex", "")
  if name:find("outfit") and not table.find(localShaders, name) then
    table.insert(localShaders, name)
  end
end

function setupTables()
  configOptions = {
    {id = "addon1", text = "Addon 1", checked = false, enabled = g_game.getClientVersion() >= 780},
    {id = "addon2", text = "Addon 2", checked = false, enabled = g_game.getClientVersion() >= 780},
    {id = "mount", text = "Mount", checked = false, enabled = g_game.getFeature(GamePlayerMounts)},
    {id = "wings", text = "Wings", checked = false, enabled = g_game.getFeature(GameWingsAndAura)},
    {id = "aura", text = "Aura", checked = false, enabled = g_game.getFeature(GameWingsAndAura)},
    {id = "shader", text = "Shaders", checked = false, enabled = g_game.getFeature(GameOutfitShaders) or loadLocalShaders and #localShaders > 0},
    {id = "healtbar", text = "Health Bars", checked = false, enabled = g_game.getFeature(GameHealthInfoBackground)},
    {id = "manabar", text = "Mana Bars", checked = false, enabled = g_game.getFeature(GameHealthInfoBackground)}
  }
  appearanceOptions = {
    {id = "presetCat", text = "Preset", enabled = true},
    {id = "outfitCat", text = "Outfit", enabled = true},
    {id = "mountCat", text = "Mount", enabled = g_game.getFeature(GamePlayerMounts)},
    {id = "wingsCat", text = "Wings", enabled = g_game.getFeature(GameWingsAndAura)},
    {id = "auraCat", text = "Aura", enabled = g_game.getFeature(GameWingsAndAura)},
    {id = "shaderCat", text = "Shader", enabled = g_game.getFeature(GameOutfitShaders) or loadLocalShaders and #localShaders > 0},
    {id = "healtbarCat", text = "Health Bars", enabled = g_game.getFeature(GameHealthInfoBackground)},
    {id = "manabarCat", text = "Mana Bars", enabled = g_game.getFeature(GameHealthInfoBackground)}
  }
  previewOptions = {
    {id = "move", text = "Movement", checked = false, enabled = true},
    {id = "showOutfit", text = "Outfit", checked = true, enabled = true},
    {id = "showMount", text = "Mount", checked = false, enabled = g_game.getFeature(GamePlayerMounts)},
    {id = "showWings", text = "Wings", checked = false, enabled = g_game.getFeature(GameWingsAndAura)},
    {id = "showAura", text = "Aura", checked = false, enabled = g_game.getFeature(GameWingsAndAura)},
    {id = "showShader", text = "Shader", checked = false, enabled = g_game.getFeature(GameOutfitShaders) or loadLocalShaders and #localShaders > 0}
  }
end

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

function onFilterList(text)
  if not outfitWindow then
    return
  end
  filterText = text:lower()

  refreshVisiblePreviews()
end

function clearFilterText()
  if not outfitWindow then
    return
  end

  outfitWindow.search.filterWindow:setText("")
end

function onPresetButtonPress(key)
  local widget

  for i, child in ipairs(outfitWindow.list:getChildren()) do
    if child.catalog == "preset" then
      if child:isChecked() then
        widget = child
        break
      end
    end
  end

  if key == "delete" then
    if widget then
      widget:destroy()
    end
  elseif key == "new" then
    local outfit = getOutfitFromCurrentChecks(1)
    outfit.mount = 0
    local mount = getOutfitFromCurrentChecks().mount
    local name = "new preset"

    local widget = g_ui.createWidget("LargePreviewTile", outfitWindow.list)
    widget.catalog = "preset"
    widget:setId("preset." .. outfit.type .. name)
    widget.outfit:setOutfit(outfit)
    if mount then
      widget.mount:setOutfit(
        {
          type = mount
        }
      )
    end
    widget.title:setText(name)
  elseif key == "rename" then
    if widget then
      modules.client_textedit.show(widget.title, {title = "Rename Preset", placeholder = widget.title:getText()})
    end
  elseif key == "save" then
    if widget then
      local data = getOutfitFromCurrentChecks()
      local outfit = data.outfit
      local mount = data.mount

      widget.outfit:setOutfit(outfit)
      if mount then
        widget.mount:setOutfit(mount)
      end
      save()
    end
  end
end

function onOptionChange(key, checked, widget)
  if not outfitWindow then
    return
  end
  local creature = outfitWindow.preview.creaturePanel.creature

  if key:find("show") or key:find("addon") then
    refreshPreview()
  end

  if key:find("Cat") then
    currentCategory = string.sub(key, 1, key:len() - 3)

    -- set filter window title
    outfitWindow.search.title:setText("Filter " .. currentCategory .. "s")

    if key == "presetCat" then
      outfitWindow.list:getLayout():setNumColumns(1)
      outfitWindow.list:getLayout():setCellSize({height = 100, width = 217})
      outfitWindow.search:setVisible(false)
      outfitWindow.preset:setVisible(true)
    else
      outfitWindow.list:getLayout():setNumColumns(2)
      outfitWindow.list:getLayout():setCellSize({height = 100, width = 106})
      outfitWindow.search:setVisible(true)
      outfitWindow.preset:setVisible(false)
    end

    -- set correct checks
    for i, child in ipairs(widget:getParent():getParent():getChildren()) do
      child.checkBox:setChecked(widget == child.checkBox)
    end

    refreshVisiblePreviews()
  elseif key == "move" then
    creature:setAnimate(checked)
  elseif key == "showOutfit" or key == "showMount" then
    local options = outfitWindow.preview.options
    local showOutfit = options.showOutfit
    local showMount = options.showMount
    showOutfit = showOutfit and showOutfit.check:isChecked()
    showMount = showMount and showMount.check:isChecked()

    if not showMount and not showOutfit then
      options.move.check:setChecked(false)
      creature:setAnimate(false)
      options.move:disable()
    else
      options.move:enable()
    end
  end
end

function refreshVisiblePreviews()
  if not outfitWindow then
    return
  end

  for i, child in ipairs(outfitWindow.list:getChildren()) do
    local id = child:getId()
    local catalog = string.split(id, ".")[1]
    local name = string.split(id, ".")[2]
    local show = catalog == currentCategory and name:find(filterText)
    child:setVisible(show)
  end
end

function getOutfitFromCurrentChecks(returnVal)
  returnVal = returnVal or 0

  -- 0 - return raw table
  -- 1 - return combined outfit according to configure checks
  -- 2 - return combined outfit according to preview checks
  if not outfitWindow then
    return
  end

  local data = {
    cleanOutfit = {}, -- outfit.type & colors
    mount = 0, -- outfit.mount
    addons = 0, -- outfit.addons
    shader = "", -- outfit.shader
    wings = 0, -- outfit.wings
    aura = 0, -- outfit.aura
    healthbar = "", -- outfit.healthbar
    manabar = "" -- outfit.manabar
  }

  local combinedOutfit
  local previewOutfit
  local options = outfitWindow.config.options
  local addon1 = options.addon1
  local addon2 = options.addon2
  addon1 = addon1 and addon1.check:isChecked()
  addon2 = addon2 and addon2.check:isChecked()
  local showAddons = addon1 and addon2 and 3 or addon2 and 2 or addon1 and 1 or 0
  local showMount = g_game.getFeature(GamePlayerMounts) and options.mount and options.mount.check:isChecked()
  local showShader = (g_game.getFeature(GameOutfitShaders) or #localShaders > 0) and options.shader and options.shader.check:isChecked()
  local showHealthBar = g_game.getFeature(GameHealthInfoBackground) and options.healthbar and options.healthbar:isChecked()
  local showManaBar = g_game.getFeature(GameHealthInfoBackground) and options.manabar and options.manabar:isChecked()
  local showAura = g_game.getFeature(GameWingsAndAura) and options.aura and options.aura:isChecked()
  local showWings = g_game.getFeature(GameWingsAndAura) and options.wings and options.wings:isChecked()

  for i, child in ipairs(outfitWindow.list:getChildren()) do
    if child:isChecked() and child.catalog ~= "preset" then
      local catalog = child.catalog
      local outfit = child.creature:getOutfit()
      if catalog == "outfit" then -- get type and colors
        data.cleanOutfit = outfit
      elseif catalog == "mount" then
        data[catalog] = outfit.type
      elseif catalog == "shader" then
        data[catalog] = child.shader
      elseif catalog == "wings" then
        data[catalog] = outfit.type
      elseif catalog == "aura" then
        data[catalog] = outfit.aura
      elseif catalog == "healthbar" then
        local id = string.split(child:getId(), " ")[2]
        data[catalog] = id
      elseif catalog == "manabar" then
        local id = string.split(child:getId(), " ")[2]
        data[catalog] = id
      end
    end
  end
  data.addons = showAddons

  if returnVal == 1 then
    combinedOutfit = data.cleanOutfit
    combinedOutfit.addons = showAddons
    combinedOutfit.mount = showMount and data.mount > 0 and data.mount or nil
    combinedOutfit.shader = showShader and data.shader:len() > 0 and data.shader or nil
    combinedOutfit.wings = showWings and data.wings > 0 and data.wings or nil
    combinedOutfit.aura = showAura and data.aura > 0 and data.aura or nil
    combinedOutfit.healthbar = showHealthBar and data.healthbar:len() > 0 and data.healthbar or nil
    combinedOutfit.manabar = showManaBar and data.manabar:len() > 0 and data.manabar or nil
  elseif returnVal == 2 then
    previewOutfit = data.cleanOutfit
    previewOutfit.addons = showAddons
    previewOutfit.mount = data.mount > 0 and data.mount or nil
    previewOutfit.shader = data.shader:len() > 0 and data.shader or nil
    previewOutfit.wings = data.wings > 0 and data.wings or nil
    previewOutfit.aura = data.aura > 0 and data.aura or nil
    previewOutfit.healthbar = data.healthbar:len() > 0 and data.healthbar or nil
    previewOutfit.manabar = data.manabar:len() > 0 and data.manabar or nil
  end

  -- TODO: test & most likely fix all custom features (wings, auras, shaders, bars)
  if returnVal == 0 then
    return data -- raw
  elseif returnVal == 1 then
    return combinedOutfit -- combined @ configure
  else
    return previewOutfit -- combined @ preview
  end
end

function randomize()
  local outfitTemplate = {
    outfitWindow.appearance.parts.head,
    outfitWindow.appearance.parts.primary,
    outfitWindow.appearance.parts.secondary,
    outfitWindow.appearance.parts.detail
  }

  for i = 1, #outfitTemplate do
    local n = math.random(#colorBoxes)

    outfitTemplate[i]:setChecked(true)
    colorBoxes[n]:setChecked(true)
    outfitTemplate[i]:setChecked(false)
  end
  outfitTemplate[1]:setChecked(true)
end

function onElementSelect(widget)
  if not outfitWindow then
    return
  end
  local catalog = string.split(widget:getId(), ".")[1]

  -- apply correct check
  for i, child in ipairs(widget:getParent():getChildren()) do
    -- there can be few items checked, but only one per catalog
    if child.catalog == widget.catalog then
      child:setChecked(widget == child)
    end
  end

  if catalog == "outfit" then
    local outfit = widget.creature:getOutfit()
    local addons = outfit.addons

    local addon1 = outfitWindow.config.options.addon1.check
    local addon2 = outfitWindow.config.options.addon2.check

    addon1:setChecked(addons == 1 or addons == 3)
    addon2:setChecked(addons > 1)

    addon1:setEnabled(addons == 1 or addons == 3)
    addon2:setEnabled(addons > 1)

    refreshPreview()
    setCategoryDescription(catalog, outfit.type)
  elseif catalog == "mount" then
    local outfit = widget.creature:getOutfit()

    refreshPreview()
    setCategoryDescription(catalog, outfit.type)
  elseif catalog == "preset" then
    local outfit = widget.outfit:getOutfit().type
    local mount = widget.mount:getOutfit().type

    for i, child in ipairs(outfitWindow.list:getChildren()) do
      if child.catalog == "outfit" then
        if child.creature:getOutfit().type == outfit then
          onElementSelect(child)
        end
      end
      if child.catalog == "mount" then
        if child.creature:getOutfit().type == mount then
          onElementSelect(child)
        end
      end
    end

    setCategoryDescription(catalog, widget.title:getText())
    refreshPreview()
  elseif catalog == "shader" then
    local shader = widget.creature:getOutfit().shader

    setCategoryDescription(catalog, widget.title:getText())
    refreshPreview()
  elseif catalog == "healthbar" then
  elseif catalog == "manabar" then
  elseif catalog == "wings" then
  end
end

function refreshPreview()
  if not outfitWindow then
    return
  end
  local creature = outfitWindow.preview.creaturePanel.creature
  local options = outfitWindow.preview.options

  local outfit = getOutfitFromCurrentChecks(2)

  local showOutfit = options.showOutfit and options.showOutfit.check:isChecked()
  local showMount = g_game.getFeature(GamePlayerMounts) and options.showMount and options.showMount.check:isChecked()
  local showShader = (g_game.getFeature(GameOutfitShaders) or #localShaders > 0) and options.showShader and options.showShader.check:isChecked()
  local showWings = g_game.getFeature(GameWingsAndAura) and options.showWings and options.showWings.check:isChecked()
  local showAura = g_game.getFeature(GameWingsAndAura) and options.showAura and options.showAura.check:isChecked()

  if showOutfit then
    outfit.mount = not showMount and 0 or outfit.mount
    -- those things can only be displaed when showOutfit
    outfit.shader = not showShader and "" or outfit.shader
    outfit.wings = not showWings and 0 or outfit.wings
    outfit.aura = not showAura and 0 or outfit.aura
  elseif showMount then
    outfit = {type = outfit.mount}
  else
    return creature:setOutfit({})
  end

  creature:setOutfit(outfit)
end

function rotatePreview(side)
  if not outfitWindow then
    return
  end
  local creature = outfitWindow.preview.creaturePanel.creature
  previewDir = side == "rotateLeft" and (previewDir + 1) or (previewDir - 1)
  previewDir = previewDir % 4

  creature:setDirection(previewDir)
end

function setCategoryDescription(id, key)
  if not outfitWindow then
    return
  end

  -- id can be widgetId so extract id
  local type = string.split(id, ".")[1] -- ie. outfit
  local tableKey = type .. "s" -- ie. outfits
  local newId = type .. "Cat" -- ie. outfitCat
  local table = dataTables[tableKey]
  local widget = outfitWindow.appearance.categories[newId]

  widget = widget and widget.description

  if id == "preset" or id == "shader" then
    return widget:setText(key)
  end

  -- something went wrong
  if not table or not widget then
    return
  end

  for i, data in ipairs(table) do
    if data[1] == key then
      return widget:setText(data[2])
    end
  end

  widget:setText("-")
end

function onClotheCheckChange(clotheButtonBox)
  if not outfitWindow then
    return
  end
  local outfit = outfitWindow.preview.creaturePanel.creature:getOutfit()
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
    outfitWindow.appearance.colorBoxPanel["colorBox" .. colorId]:setChecked(true)
  end
end

function onColorCheckChange(colorBox)
  if not outfitWindow then
    return
  end
  local outfit = outfitWindow.preview.creaturePanel.creature:getOutfit()
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
    outfitWindow.preview.creaturePanel.creature:setOutfit(outfit)
    updateOutfits()
    refreshPreview()
  end
end

function updateOutfits()
  if not outfitWindow then
    return
  end
  local outfit = outfitWindow.preview.creaturePanel.creature:getOutfit()

  for i, child in ipairs(outfitWindow.list:getChildren()) do
    if child.catalog == "outfit" then
      local previewOutfit = child.creature:getOutfit()
      previewOutfit.head = outfit.head
      previewOutfit.body = outfit.body
      previewOutfit.legs = outfit.legs
      previewOutfit.feet = outfit.feet

      child.creature:setOutfit(previewOutfit)
    end
  end
end

function create(currentOutfit, outfitList, mountList, wingList, auraList, shaderList, hpBarList, manaBarList)
  if outfitWindow and not outfitWindow:isHidden() then
    return
  end

  load()
  destroy()
  setupTables()

  -- use local shaders if server doesnt send any
  shaderList = #shaderList > 0 and shaderList or loadLocalShaders and localShaders or {}

  outfitWindow = g_ui.displayUI("outfitwindow")
  dataTables = {
    outfits = outfitList,
    mounts = mountList,
    wings = wingList,
    auras = auraList,
    shaders = shaderList,
    hpBars = hpBarList,
    manaBars = manaBarList
  }

  outfitWindow.appearance.onGeometryChange = function(widget, old, new)
    local filterHeight = outfitWindow.search:getHeight() -- to detect layout used, 56 for default 47 for retro
    local diff = 239 + filterHeight
    local height = new.height
    outfitWindow:setHeight(height + diff)
  end

  local creature = outfitWindow.preview.creaturePanel.creature
  local outfitType = currentOutfit.type
  local mountType = currentOutfit.mount
  local clearOutfit = currentOutfit
  local currentAddons = currentOutfit.addons

  local availableAddons
  for i, outfit in ipairs(outfitList) do
    if outfit[1] == outfitType then
      availableAddons = outfit[3]
    end
  end

  clearOutfit.mount = 0
  creature:setOutfit(clearOutfit)

  previewDir = 2

  -- outfits
  for i, outfit in ipairs(outfitList) do
    local id = outfit[1]
    local name = outfit[2]
    local addons = outfit[3]
    local outfit = currentOutfit
    outfit.type = id
    outfit.addons = addons

    local widget = g_ui.createWidget("SmallPreviewTile", outfitWindow.list)
    widget:setId("outfit." .. name:lower() .. " " .. id)
    widget.title:setText(name)
    outfit.mount = 0
    widget.creature:setOutfit(outfit)
    widget.catalog = "outfit"
  end

  -- mounts
  for i, mount in ipairs(mountList) do
    local id = mount[1]
    local name = mount[2]
    local mountOufit = {
      type = id
    }

    local widget = g_ui.createWidget("SmallPreviewTile", outfitWindow.list)
    widget:setId("mount." .. name:lower() .. " " .. id)
    widget.title:setText(name)
    widget.creature:setOutfit(mountOufit)
    widget.catalog = "mount"
  end

  -- wings
  for i, wings in ipairs(wingList) do
    local id = wings[1]
    local name = wings[2]
    local wingsOufit = {
      type = id
    }

    local widget = g_ui.createWidget("SmallPreviewTile", outfitWindow.list)
    widget:setId("wings." .. name:lower() .. " " .. id)
    widget.title:setText(name)
    widget.creature:setOutfit(wingsOufit)
    widget.catalog = "wings"
  end

  -- auras
  for i, aura in ipairs(auraList) do
    local id = aura[1]
    local name = aura[2]
    local auraOufit = {
      type = id
    }

    local widget = g_ui.createWidget("SmallPreviewTile", outfitWindow.list)
    widget:setId("aura." .. name:lower() .. " " .. id)
    widget.title:setText(name)
    widget.creature:setOutfit(auraOufit)
    widget.catalog = "aura"
  end

  -- shaders
  for i, shader in ipairs(shaderList) do
    if type(shader) ~= "table" then
      shader = {i, shader}
    end
    local id = shader[1]
    local name = shader[2]
    local shaderOutfit = currentOutfit
    shaderOutfit.shader = name
    shaderOutfit.type = outfitType

    local widget = g_ui.createWidget("SmallPreviewTile", outfitWindow.list)
    widget:setId("shader." .. name:lower() .. " " .. id)
    widget.title:setText(name)
    widget.creature:setOutfit(shaderOutfit)
    widget.catalog = "shader"
    widget.shader = shaderOutfit.shader
  end

  if g_game.getFeature(GameHealthInfoBackground) then
    table.insert(hpBarList, 1, {0, "-"})
    table.insert(manaBarList, 1, {0, "-"})
  end

  -- hpbar
  for i, bar in ipairs(hpBarList) do
    local id = bar[1]
    local name = bar[2]
    local path = g_healthBars.getHealthBarPath(id)

    local widget = g_ui.createWidget("SmallPreviewTile", outfitWindow.list)
    widget:setId("healthbar." .. name:lower() .. " " .. id)
    widget.item:setImageSource(i > 1 and path or "")
    widget.title:setText(i > i and name or "Standard")
    widget.catalog = "healthbar"
  end

  -- hpbar
  for i, bar in ipairs(manaBarList) do
    local id = bar[1]
    local name = bar[2]
    local path = g_healthBars.getHealthBarPath(id)

    local widget = g_ui.createWidget("SmallPreviewTile", outfitWindow.list)
    widget:setId("manabar." .. name:lower() .. " " .. id)
    widget.item:setImageSource(i > 1 and path or "")
    widget.title:setText(i > i and name or "Standard")
    widget.catalog = "manabar"
  end

  -- check current outfit
  for i, child in ipairs(outfitWindow.list:getChildren()) do
    local catalog = child.catalog
    local outfit = child.creature:getOutfit()

    if catalog == "outfit" then
      if outfit.type == outfitType then
        child:setChecked(true)
        outfitWindow.list:moveChildToIndex(child, 1)
      end
    elseif catalog == "mount" then
      if outfit.type == mountType then
        child:setChecked(true)
        outfitWindow.list:moveChildToIndex(child, 1)
        child:setVisible(false)
      end
    elseif catalog == "shader" then
      if outfit.shader == currentOutfit.shader then
        child:setChecked(true)
        outfitWindow.list:moveChildToIndex(child, 1)
        child:setVisible(false)
      end
    elseif catalog == "wings" then
      if outfit.wings == currentOutfit.wings then
        child:setChecked(true)
        outfitWindow.list:moveChildToIndex(child, 1)
        child:setVisible(false)
      end
    elseif catalog == "aura" then
      if outfit.aura == currentOutfit.aura then
        child:setChecked(true)
        outfitWindow.list:moveChildToIndex(child, 1)
        child:setVisible(false)
      end
    elseif catalog == "manabar" then
      if child:getId():find(outfit.manabar) then
        child:setChecked(true)
        outfitWindow.list:moveChildToIndex(child, 1)
        child:setVisible(false)
      end
    elseif catalog == "healthbar" then
      if child:getId():find(outfit.healthbar) then
        child:setChecked(true)
        outfitWindow.list:moveChildToIndex(child, 1)
        child:setVisible(false)
      end
    end
  end

  -- color box
  for j = 0, 6 do
    for i = 0, 18 do
      local colorBox = g_ui.createWidget("ColorBox", outfitWindow.appearance.colorBoxPanel)
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

  -- hook outfit sections
  currentClotheButtonBox = outfitWindow.appearance.parts.head
  outfitWindow.appearance.parts.head.onCheckChange = onClotheCheckChange
  outfitWindow.appearance.parts.primary.onCheckChange = onClotheCheckChange
  outfitWindow.appearance.parts.secondary.onCheckChange = onClotheCheckChange
  outfitWindow.appearance.parts.detail.onCheckChange = onClotheCheckChange

  -- previewOptions
  for i, settings in ipairs(previewOptions) do
    if settings.enabled then
      local widget = g_ui.createWidget("OptionsCheckBox", outfitWindow.preview.options)
      widget:setId(settings.id)
      widget:setText(settings.text)
      widget.check:setChecked(settings.checked)

      if i > 1 then
        local catalog = string.sub(settings.id, 5):lower()
        local data = dataTables[catalog .. "s"]

        -- if there's no options for certain category disable widget
        if not data or #data == 0 then
          widget.check:setChecked(false)
          widget.check:setEnabled(false)
          widget:setEnabled(false)
          widget.check:setColor("#808080")
        end
      end
    end
  end

  -- config options
  for i, settings in ipairs(configOptions) do
    if settings.enabled then
      local widget = g_ui.createWidget("OptionsCheckBox", outfitWindow.config.options)
      widget:setId(settings.id)
      widget:setText(settings.text)
      widget:setChecked(settings.checked)
    end
  end

  -- appearance options
  for i, settings in ipairs(appearanceOptions) do
    if settings.enabled then
      local widget = g_ui.createWidget("AppearanceCategory", outfitWindow.appearance.categories)
      widget:setId(settings.id)
      widget.checkBox:setText(settings.text)
      widget.checkBox:setChecked(i == 2)
    end
  end

  setCategoryDescription("outfit", outfitType)
  setCategoryDescription("mount", mountType)

  local addon1 = outfitWindow.config.options.addon1.check
  local addon2 = outfitWindow.config.options.addon2.check
  local mount = g_game.getFeature(GamePlayerMounts) and outfitWindow.config.options.mount.check

  if #mountList == 0 and g_game.getFeature(GamePlayerMounts) then
    mount:disable()
  end

  addon1:setChecked(currentAddons == 1 or currentAddons == 3)
  addon2:setChecked(currentAddons > 1)

  addon1:setEnabled(availableAddons > 0)
  addon2:setEnabled(availableAddons > 1)

  for i, setting in ipairs(settings) do
    local outfit = setting.outfit
    local mount = setting.mount
    local name = setting.name

    local widget = g_ui.createWidget("LargePreviewTile", outfitWindow.list)
    widget.catalog = "preset"
    widget:setId("preset." .. outfit.type .. name)
    widget.outfit:setOutfit(outfit)
    if mount then
      widget.mount:setOutfit(mount)
    end
    widget.title:setText(name)
  end

  refreshVisiblePreviews()
  refreshPreview()
end

function destroy()
  if outfitWindow then
    filterText = ""
    currentCategory = "outfit"

    outfitWindow:destroy()
    outfitWindow = nil
  end
end

function accept()
  local player = g_game.getLocalPlayer()
  if outfitWindow then
    save()
    filterText = ""
    currentCategory = "outfit"

    if g_game.getFeature(GamePlayerMounts) then
      local mount = outfitWindow.config.options.mount.check:isChecked()

      if not player:isMounted() and mount then
        player:mount()
      end
    end

    g_game.changeOutfit(getOutfitFromCurrentChecks(1))
    outfitWindow:destroy()
    outfitWindow = nil
  end
end

-- json
function save()
  local settings = {}

  for i, child in ipairs(outfitWindow.list:getChildren()) do
    if child.catalog == "preset" then
      local data = {
        outfit = child.outfit:getOutfit(),
        mount = child.mount:getOutfit(),
        name = child.title:getText()
      }

      table.insert(settings, data)
    end
  end

  local file = "/settings/outfits.json"

  if not g_resources.fileExists(file) then
    g_resources.makeDir("/settings")
  end

  local status, result =
    pcall(
    function()
      return json.encode(settings, 2)
    end
  )
  if not status then
    return onError("Error while saving top bar settings. Data won't be saved. Details: " .. result)
  end

  if result:len() > 100 * 1024 * 1024 then
    return onError("Something went wrong, file is above 100MB, won't be saved")
  end

  g_resources.writeFileContents(file, result)
end

function load()
  local file = "/settings/outfits.json"

  if not g_resources.fileExists(file) then
    g_resources.makeDir("/settings")
  end

  if g_resources.fileExists(file) then
    local status, result =
      pcall(
      function()
        return json.decode(g_resources.readFileContents(file))
      end
    )
    if not status then
      return onError("Error while reading top bar settings file. To fix this problem you can delete storage.json. Details: " .. result)
    end
    settings = result
  else
    settings = {}
  end
end
