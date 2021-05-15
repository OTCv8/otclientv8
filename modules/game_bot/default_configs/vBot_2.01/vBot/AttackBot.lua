-- author: Vithrax
-- version 2.0

-- if you want to change tab, in line below insert: setDefaultTab("tab name")



attackPanelName = "attackbot"
local ui = setupUI([[
Panel
  height: 38

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('AttackBot')

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

  Button
    id: 1
    anchors.top: prev.bottom
    anchors.left: parent.left
    text: 1
    margin-right: 2
    margin-top: 4
    size: 17 17

  Button
    id: 2
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 2
    margin-left: 4
    size: 17 17
    
  Button
    id: 3
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 3
    margin-left: 4
    size: 17 17

  Button
    id: 4
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 4
    margin-left: 4
    size: 17 17 
    
  Button
    id: 5
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 5
    margin-left: 4
    size: 17 17
    
  Label
    id: name
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    anchors.right: parent.right
    text-align: center
    margin-left: 4
    height: 17
    text: Profile #1
    background: #292A2A
]])

addSeparator()
ui:setId(attackPanelName)

local i = 1
local j = 1
local k = 1
local pvpDedicated = false
local item = false

-- create blank profiles 
if not AttackBotConfig[attackPanelName] or not AttackBotConfig[attackPanelName][1] or #AttackBotConfig[attackPanelName] ~= 5 then
  AttackBotConfig[attackPanelName] = {
    [1] = {
      enabled = false,
      attackTable = {},
      ignoreMana = true,
      Kills = false,
      Rotate = false,
      name = "Profile #1",
      Cooldown = true,
      Visible = true,
      pvpMode = false,
      KillsAmount = 1,
      PvpSafe = true,
      BlackListSafe = false,
      AntiRsRange = 5
    },
    [2] = {
      enabled = false,
      attackTable = {},
      ignoreMana = true,
      Kills = false,
      Rotate = false,
      name = "Profile #2",
      Cooldown = true,
      Visible = true,
      pvpMode = false,
      KillsAmount = 1,
      PvpSafe = true,
      BlackListSafe = false,
      AntiRsRange = 5
    },
    [3] = {
      enabled = false,
      attackTable = {},
      ignoreMana = true,
      Kills = false,
      Rotate = false,
      name = "Profile #3",
      Cooldown = true,
      Visible = true,
      pvpMode = false,
      KillsAmount = 1,
      PvpSafe = true,
      BlackListSafe = false,
      AntiRsRange = 5
    },
    [4] = {
      enabled = false,
      attackTable = {},
      ignoreMana = true,
      Kills = false,
      Rotate = false,
      name = "Profile #4",
      Cooldown = true,
      Visible = true,
      pvpMode = false,
      KillsAmount = 1,
      PvpSafe = true,
      BlackListSafe = false,
      AntiRsRange = 5
    },
    [5] = {
      enabled = false,
      attackTable = {},
      ignoreMana = true,
      Kills = false,
      Rotate = false,
      name = "Profile #5",
      Cooldown = true,
      Visible = true,
      pvpMode = false,
      KillsAmount = 1,
      PvpSafe = true,
      BlackListSafe = false,
      AntiRsRange = 5
    },
  }
end

if not AttackBotConfig.currentBotProfile or AttackBotConfig.currentBotProfile == 0 or AttackBotConfig.currentBotProfile > 5 then 
  AttackBotConfig.currentBotProfile = 1
end

-- finding correct table, manual unfortunately
local currentSettings
local setActiveProfile = function()
  local n = AttackBotConfig.currentBotProfile
  currentSettings = AttackBotConfig[attackPanelName][n]
end
setActiveProfile()

if not currentSettings.AntiRsRange then
  currentSettings.AntiRsRange = 5 
end

local activeProfileColor = function()
  for i=1,5 do
    if i == AttackBotConfig.currentBotProfile then
      ui[i]:setColor("green")
    else
      ui[i]:setColor("white")
    end
  end
end
activeProfileColor()

local categories = {
  "Select Category",
  "Area Spell (exevo mas san, exevo gran mas flam etc.)",
  "Adjacent (exori, exori gran)",
  "Front Sweep (exori min)",
  "Wave (exevo tera hur, exevo gran vis lux)",
  "Targeted Spell (exori ico, exori flam etc.)",
  "Targeted Rune (sudden death, heavy magic missle etc.)",
  "Area Rune (great fireball, avalanche etc.)",
  "Empowerment (utito tempo)"
}

local labels = {
  "",
  "Area Spell",
  "Adjacent",
  "Front Sweep",
  "Wave",
  "Targeted Spell",
  "Targeted Rune",
  "Area Rune",
  "Buff"
}

local range = {
  "Select Range",
  "Range: 1",
  "Range: 2",
  "Range: 3",
  "Range: 4",
  "Range: 5",
  "Range: 6",
  "Range: 7",
  "Range: 8",
  "Range: 9"
}

local pattern = {
  "Pattern",
  "Single (exori frigo, SD)",
  "Large AOE (mas tera)",
  "Medium AOE (mas frigo)",
  "Small AOE (mas san)",
  "Large Wave (tera hur)",
  "Medium Wave (frigo hur)",
  "Small Wave (gran frigo hur)",
  "Beam (exevo vis lux)",
  "Adjacent (exori)",
  "Area Rune (GFB, AVA)",
  "Empowerment"
}

ui.title.onClick = function(widget)
currentSettings.enabled = not currentSettings.enabled
widget:setOn(currentSettings.enabled)
vBotConfigSave("atk")
end

ui.settings.onClick = function(widget)
  attackWindow:show()
  attackWindow:raise()
  attackWindow:focus()
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  attackWindow = UI.createWindow('AttackWindow', rootWidget)
  attackWindow:hide()

  -- functions
  local updateCategoryText = function()
    attackWindow.category:setText(categories[i])
  end
  local updateParameter1Text = function()
    attackWindow.parameter1:setText(pattern[k])
  end
  local updateParameter2Text = function()
    attackWindow.parameter2:setText(range[j])
  end

  -- spin box
  attackWindow.KillsAmount.onValueChange = function(widget, value)
    currentSettings.KillsAmount = value
  end
  attackWindow.AntiRsRange.onValueChange = function(widget, value)
    currentSettings.AntiRsRange = value
  end

  -- checkbox
  attackWindow.pvpSpell.onClick = function(widget)
    pvpDedicated = not pvpDedicated
    attackWindow.pvpSpell:setChecked(pvpDedicated)
  end
  attackWindow.IgnoreMana.onClick = function(widget)
    currentSettings.ignoreMana = not currentSettings.ignoreMana
    attackWindow.IgnoreMana:setChecked(currentSettings.ignoreMana)
  end
  attackWindow.Rotate.onClick = function(widget)
    currentSettings.Rotate = not currentSettings.Rotate
    attackWindow.Rotate:setChecked(currentSettings.Rotate)
  end
  attackWindow.Kills.onClick = function(widget)
    currentSettings.Kills = not currentSettings.Kills
    attackWindow.Kills:setChecked(currentSettings.Kills)
  end
  attackWindow.Cooldown.onClick = function(widget)
    currentSettings.Cooldown = not currentSettings.Cooldown
    attackWindow.Cooldown:setChecked(currentSettings.Cooldown)
  end
  attackWindow.Visible.onClick = function(widget)
    currentSettings.Visible = not currentSettings.Visible
    attackWindow.Visible:setChecked(currentSettings.Visible)
  end
  attackWindow.PvpMode.onClick = function(widget)
    currentSettings.pvpMode = not currentSettings.pvpMode
    attackWindow.PvpMode:setChecked(currentSettings.pvpMode)
  end
  attackWindow.PvpSafe.onClick = function(widget)
    currentSettings.PvpSafe = not currentSettings.PvpSafe
    attackWindow.PvpSafe:setChecked(currentSettings.PvpSafe)
  end
  attackWindow.BlackListSafe.onClick = function(widget)
    currentSettings.BlackListSafe = not currentSettings.BlackListSafe
    attackWindow.BlackListSafe:setChecked(currentSettings.BlackListSafe)
  end

  --buttons
  attackWindow.CloseButton.onClick = function(widget)
    attackWindow:hide()
    vBotConfigSave("atk")
  end

  local inputTypeToggle = function()
    if attackWindow.category:getText():lower():find("rune") then
      item = true
      attackWindow.spellFormula:setText("")
      attackWindow.spellFormula:hide()
      attackWindow.spellDescription:hide()
      attackWindow.itemId:show()
      attackWindow.itemDescription:show()
    else
      item = false
      attackWindow.itemId:setItemId(0)
      attackWindow.itemId:hide()
      attackWindow.itemDescription:hide()
      attackWindow.spellFormula:show()
      attackWindow.spellDescription:show()
    end
  end

  local setSimilarPattern = function()
    if i == 2 then
      k = 3
    elseif i == 3 then
      k = 10
    elseif i == 4 then
      k = 10
    elseif i == 5 then
      k = 6
    elseif i == 6 or i == 7 then
      k = 2
    elseif i == 8 then
      k = 11
    elseif i == 9 then
      k = 12
    end
  end

  attackWindow.categoryNext.onClick = function(widget)
    if i == #categories then
      i = 1
    else
      i = i + 1
    end
    setSimilarPattern()
    updateParameter1Text()
    updateCategoryText()
    inputTypeToggle()
  end

  attackWindow.categoryPrev.onClick = function(widget)
    if i == 1 then
      i = #categories
    else
      i = i - 1
    end
    setSimilarPattern()
    updateParameter1Text()
    updateCategoryText()
    inputTypeToggle()
  end

  attackWindow.parameter1Next.onClick = function(widget)
    if k == #pattern then
      k = 1
    else
      k = k + 1
    end
    updateParameter1Text()
  end

  attackWindow.parameter1Prev.onClick = function(widget)
    if k == 1 then
      k = #pattern
    else
      k = k - 1
    end
    updateParameter1Text()
  end

  attackWindow.parameter2Next.onClick = function(widget)
    if j == #range then
      j = 1
    else
      j = j + 1
    end
    updateParameter2Text()
  end

  attackWindow.parameter2Prev.onClick = function(widget)
    if j == 1 then
      j = #range
    else
      j = j - 1
    end
    updateParameter2Text()
  end

  local validVal = function(v)
    if type(v) ~= "number" then
      local val = tonumber(v)
      if not val then return false end
    end
    if v >= 0 and v < 101 then
      return true
    else
      return false
    end
  end

  local clearValues = function()
    attackWindow.spellFormula:setText("")
    attackWindow.minMana:setText(1)
    attackWindow.minMonsters:setText(1)
    attackWindow.itemId:setItemId(0)
    attackWindow.newCooldown:setText(1)
    pvpDedicated = false
    item = false
    attackWindow.pvpSpell:setChecked(false)
    i = 1
    j = 1
    k = 1
    updateParameter1Text()
    updateParameter2Text()
    updateCategoryText()
    inputTypeToggle()
  end

  local setProfileName = function()
    ui.name:setText(currentSettings.name)
  end
  attackWindow.Name.onTextChange = function(widget, text)
    currentSettings.name = text
    setProfileName()
  end

  local refreshAttacks = function()
    if currentSettings.attackTable then
      for i, child in pairs(attackWindow.attackList:getChildren()) do
        child:destroy()
      end
      for _, entry in pairs(currentSettings.attackTable) do
        local label = UI.createWidget("AttackEntry", attackWindow.attackList)
        label.enabled:setChecked(entry.enabled)
        label.enabled.onClick = function(widget)
          entry.enabled = not entry.enabled
          label.enabled:setChecked(entry.enabled)
        end
        label.remove.onClick = function(widget)
          table.removevalue(currentSettings.attackTable, entry)
          reindexTable(currentSettings.attackTable)
          label:destroy()
        end
        if entry.pvp then
          label:setText("(" .. entry.manaCost .. "% MP) " .. labels[entry.category] .. ": " .. entry.attack ..  " (Range: ".. entry.dist .. ")")
          label:setColor("yellow")
        else
          label:setText("(" .. entry.manaCost .. "% MP & mob >= " .. entry.minMonsters .. ") " .. labels[entry.category] .. ": " .. entry.attack ..  " (Range: ".. entry.dist .. ")")
          label:setColor("green")
        end
      end
    end
  end


  attackWindow.MoveUp.onClick = function(widget)
    local input = attackWindow.attackList:getFocusedChild()
    if not input then return end
    local index = attackWindow.attackList:getChildIndex(input)
    if index < 2 then return end

    local move
    if currentSettings.attackTable and #currentSettings.attackTable > 0 then
      for _, entry in pairs(currentSettings.attackTable) do
        if entry.index == index -1 then
          move = entry
        end
        if entry.index == index then
          move.index = index
          entry.index = index -1
        end
      end
    end
    table.sort(currentSettings.attackTable, function(a,b) return a.index < b.index end)

    attackWindow.attackList:moveChildToIndex(input, index - 1)
    attackWindow.attackList:ensureChildVisible(input)
  end

  attackWindow.MoveDown.onClick = function(widget)
    local input = attackWindow.attackList:getFocusedChild()
    if not input then return end
    local index = attackWindow.attackList:getChildIndex(input)
    if index >= attackWindow.attackList:getChildCount() then return end

    local move
    local move2
    if currentSettings.attackTable and #currentSettings.attackTable > 0 then
      for _, entry in pairs(currentSettings.attackTable) do
        if entry.index == index +1 then
          move = entry
        end
        if entry.index == index then
          move2 = entry
        end
      end
      if move and move2 then
        move.index = index
        move2.index = index + 1
      end
    end
    table.sort(currentSettings.attackTable, function(a,b) return a.index < b.index end)

    attackWindow.attackList:moveChildToIndex(input, index + 1)
    attackWindow.attackList:ensureChildVisible(input)
  end

  attackWindow.addButton.onClick = function(widget)
    local val
    if (item and attackWindow.itemId:getItemId() <= 100) or (not item and attackWindow.spellFormula:getText():len() == 0) then
      warn("AttackBot: missing spell or item id!")
    elseif not tonumber(attackWindow.minMana:getText()) or not validVal(tonumber(attackWindow.minMana:getText())) then
      warn("AttackBot: Mana Values incorrect! it has to be number from between 1 and 100")
    elseif not tonumber(attackWindow.minMonsters:getText()) or not validVal(tonumber(attackWindow.minMonsters:getText())) then
      warn("AttackBot: Monsters Count incorrect! it has to be number higher than 0")
    elseif i == 1 or j == 1 or k == 1 then
      warn("AttackBot: Categories not changed! You need to be more precise")
    else
      if item then 
        val = attackWindow.itemId:getItemId()
      else
        val = attackWindow.spellFormula:getText()
      end
      table.insert(currentSettings.attackTable, {index = #currentSettings.attackTable+1, cd = tonumber(attackWindow.newCooldown:getText()) ,attack = val, manaCost = tonumber(attackWindow.minMana:getText()), minMonsters = tonumber(attackWindow.minMonsters:getText()), pvp = pvpDedicated, dist = j-1, model = k, category = i, enabled = true})
      refreshAttacks()
      clearValues()
    end
  end

  -- [[ if added new options, include them below]]



  
  local loadSettings = function()
    ui.title:setOn(currentSettings.enabled)
    attackWindow.KillsAmount:setValue(currentSettings.KillsAmount)
    updateCategoryText()
    updateParameter1Text()
    updateParameter2Text()
    attackWindow.IgnoreMana:setChecked(currentSettings.ignoreMana)
    attackWindow.Rotate:setChecked(currentSettings.Rotate)
    attackWindow.Kills:setChecked(currentSettings.Kills)
    setProfileName()
    inputTypeToggle()
    attackWindow.Name:setText(currentSettings.name)
    refreshAttacks()
    attackWindow.Visible:setChecked(currentSettings.Visible)
    attackWindow.Cooldown:setChecked(currentSettings.Cooldown)
    attackWindow.PvpMode:setChecked(currentSettings.pvpMode)
    attackWindow.PvpSafe:setChecked(currentSettings.PvpSafe)
    attackWindow.BlackListSafe:setChecked(currentSettings.BlackListSafe)
    attackWindow.AntiRsRange:setValue(currentSettings.AntiRsRange)
  end
  loadSettings()

  local profileChange = function()
    setActiveProfile()
    activeProfileColor()
    loadSettings()
    vBotConfigSave("atk")
  end

    -- profile buttons
  for i=1,5 do
    local button = ui[i]
      button.onClick = function()
      AttackBotConfig.currentBotProfile = i
      profileChange()
    end
  end

  local resetSettings = function()
    currentSettings.enabled = false
    currentSettings.attackTable = {}
    currentSettings.ignoreMana = true
    currentSettings.Kills = false
    currentSettings.Rotate = false
    currentSettings.name = "Profile #" .. AttackBotConfig.currentBotProfile
    currentSettings.Cooldown = true
    currentSettings.Visible = true
    currentSettings.pvpMode = false
    currentSettings.pvpSafe = true
    currentSettings.BlackListSafe = false
    currentSettings.AntiRsRange = 5
  end





  -- [[ end ]] --

  attackWindow.ResetSettings.onClick = function()
    resetSettings()
    loadSettings()
  end


  -- public functions
  AttackBot = {} -- global table
  
  AttackBot.isOn = function()
    return currentSettings.enabled
  end
  
  AttackBot.isOff = function()
    return not currentSettings.enabled
  end
  
  AttackBot.setOff = function()
    currentSettings.enabled = false
    ui.title:setOn(currentSettings.enabled)
    vBotConfigSave("atk")
  end
  
  AttackBot.setOn = function()
    currentSettings.enabled = true
    ui.title:setOn(currentSettings.enabled)
    vBotConfigSave("atk")
  end
  
  AttackBot.getActiveProfile = function()
    return AttackBotConfig.currentBotProfile -- returns number 1-5
  end

  AttackBot.setActiveProfile = function(n)
    if not n or not tonumber(n) or n < 1 or n > 5 then
      return error("[AttackBot] wrong profile parameter! should be 1 to 5 is " .. n)
    else
      AttackBotConfig.currentBotProfile = n
      profileChange()
    end
  end
end

-- executor
-- table example (attack = 3155, manaCost = 50(%), minMonsters = 5, pvp = true, dist = 3, model = 6, category = 3)
-- i = category 
-- j = range
-- k = pattern - covered

local patterns = {
  "",
  "",
  [[
    0000001000000
    0000011100000
    0000111110000
    0001111111000
    0011111111100
    0111111111110
    1111111111111
    0111111111110
    0011111111100
    0001111111000
    0000111110000
    0000011100000
    0000001000000
  ]],
  [[
    00000100000
    00011111000
    00111111100
    01111111110
    01111111110
    11111111111
    01111111110
    01111111110
    00111111100
    00001110000
    00000100000
  ]],
  [[
    0011100
    0111110
    1111111
    1111111
    1111111
    0111110
    0011100
  ]],
  [[
    0000NNN0000
    0000NNN0000
    0000NNN0000
    00000N00000
    WWW00N00EEE
    WWWWW0EEEEE
    WWW00S00EEE
    00000S00000
    0000SSS0000
    0000SSS0000
    0000SSS0000
  ]],
  [[
    000NNNNN000
    000NNNNN000
    0000NNN0000
    WW00NNN00EE
    WWWW0N0EEEE
    WWWWW0EEEEE
    WWWW0S0EEEE
    WW00SSS00EE
    0000SSS0000
    000SSSSS000
    000SSSSS000
  ]],
  [[
    00NNN00
    00NNN00
    WW0N0EE
    WWW0EEE
    WW0S0EE
    00SSS00
    00SSS00
  ]],
  [[
    0000000N0000000
    0000000N0000000
    0000000N0000000
    0000000N0000000
    0000000N0000000
    0000000N0000000
    0000000N0000000
    WWWWWWW0EEEEEEE
    0000000S0000000
    0000000S0000000
    0000000S0000000
    0000000S0000000
    0000000S0000000
    0000000S0000000
    0000000S0000000
  ]],
  "",
  ""
}

local safePatterns = {
  "",
  "",
  [[
    000000010000000
    000000111000000
    000001111100000
    000011111110000
    000111111111000
    001111111111100
    011111111111110
    111111111111111
    011111111111110
    001111111111100
    000111111111000
    000011111110000
    000001111100000
    000000111000000
    000000010000000
  ]],
  [[
    0000011100000
    0000111110000
    0001111111000
    0011111111100
    0111111111110
    0111111111110
    1111111111111
    0111111111110
    0111111111110
    0011111111100
    0001111111000
    0000111110000
    0000011100000
  ]],
  [[
    000111000
    001111100
    011111110
    111111111
    111111111
    111111111
    011111110
    001111100
    000111000
  ]],
  [[
    0000NNNNN0000
    0000NNNNN0000
    0000NNNNN0000
    0000NNNNN0000
    WWWW0NNN0EEEE
    WWWWWNNNEEEEE
    WWWWWW0EEEEEE
    WWWWWSSSEEEEE
    WWWW0SSS0EEEE
    0000SSSSS0000
    0000SSSSS0000
    0000SSSSS0000
    0000SSSSS0000
  ]],
  [[
    000NNNNNNN000
    000NNNNNNN000
    000NNNNNNN000
    WWWWNNNNNEEEE
    WWWWNNNNNEEEE
    WWWWWNNNEEEEE
    WWWWWW0EEEEEE
    WWWWWSSSEEEEE
    WWWWSSSSSEEEE
    WWWWSSSSSEEEE
    000SSSSSSS000
    000SSSSSSS000
    000SSSSSSS000
  ]],
  [[
    00NNNNN00
    00NNNNN00
    WWNNNNNEE
    WWWWNEEEE
    WWWW0EEEE
    WWWWSEEEE
    WWSSSSSEE
    00SSSSS00
    00SSSSS00
  ]],
  [[
    0000000NNN0000000
    0000000NNN0000000
    0000000NNN0000000
    0000000NNN0000000
    0000000NNN0000000
    0000000NNN0000000
    0000000NNN0000000
    WWWWWWWNNNEEEEEEE
    WWWWWWWW0EEEEEEEE
    WWWWWWWSSSEEEEEEE
    0000000SSS0000000
    0000000SSS0000000
    0000000SSS0000000
    0000000SSS0000000
    0000000SSS0000000
    0000000SSS0000000
    0000000SSS0000000
  ]],
  "",
  ""
}

local posN = [[
  111
  000
  000
]]
local posE = [[
  001
  001
  001
]]
local posS = [[
  000
  000
  111
]]
local posW = [[
  100
  100
  100
]]

local bestTile
macro(100, function()
  if not currentSettings.enabled then return end
  if #currentSettings.attackTable == 0 or isInPz() or not target() or modules.game_cooldown.isGroupCooldownIconActive(1) then return end

  if g_game.getClientVersion() < 960 or not currentSettings.Cooldown then
    delay(400)
  end

  local monstersN = 0
  local monstersE = 0
  local monstersS = 0
  local monstersW = 0
  monstersN = getCreaturesInArea(pos(), posN, 2)
  monstersE = getCreaturesInArea(pos(), posE, 2)
  monstersS = getCreaturesInArea(pos(), posS, 2)
  monstersW = getCreaturesInArea(pos(), posW, 2)
  local posTable = {monstersE, monstersN, monstersS, monstersW}
  local bestSide = 0
  local bestDir
  -- pulling out the biggest number
  for i, v in pairs(posTable) do
    if v > bestSide then
        bestSide = v
    end
  end
  -- associate biggest number with turn direction
  if monstersN == bestSide then bestDir = 0
    elseif monstersE == bestSide then bestDir = 1
    elseif monstersS == bestSide then bestDir = 2
    elseif monstersW == bestSide then bestDir = 3
  end

  if currentSettings.Rotate then
    if player:getDirection() ~= bestDir and bestSide > 0 then
      turn(bestDir)
    end
  end

  for _, entry in pairs(currentSettings.attackTable) do
    if entry.enabled then
      if (type(entry.attack) == "string" and canCast(entry.attack, not currentSettings.ignoreMana, not currentSettings.Cooldown)) or (type(entry.attack) == "number" and (not currentSettings.Visible or findItem(entry.attack))) then
        if manapercent() >= entry.manaCost and distanceFromPlayer(target():getPosition()) <= entry.dist then
          if currentSettings.pvpMode then
            if entry.pvp then
              if type(entry.attack) == "string" and target():canShoot() then
                cast(entry.attack, entry.cd)
                return
              else
                if not AttackBotConfig.isUsing and target():canShoot() then
                  g_game.useInventoryItemWith(entry.attack, target())
                  return
                end
              end
            end
          else
            if entry.category == 6 or entry.category == 7 then
              if getMonsters(4) >= entry.minMonsters then
                if type(entry.attack) == "number" then
                  if not AttackBotConfig.isUsing then
                    g_game.useInventoryItemWith(entry.attack, target())
                    return
                  end
                else
                  cast(entry.attack, entry.cd)
                  return
                end
              end
            else
              if (g_game.getClientVersion() < 960 or not currentSettings.Kills or killsToRs() > currentSettings.KillsAmount) and (not currentSettings.BlackListSafe or not isBlackListedPlayerInRange(currentSettings.AntiRsRange)) then
                if entry.category == 8 then
                  bestTile = getBestTileByPatern(patterns[5], 2, entry.dist, currentSettings.PvpSafe)
                end
                if entry.category == 4 and (not currentSettings.PvpSafe or isSafe(2, false)) and bestSide >= entry.minMonsters then
                  cast(entry.attack, entry.cd)
                  return
                elseif entry.category == 3 and (not currentSettings.PvpSafe or isSafe(2, false)) and getMonsters(1) >= entry.minMonsters then
                  cast(entry.attack, entry.cd)
                  return
                elseif entry.category == 5 and getCreaturesInArea(player, patterns[entry.model], 2) >= entry.minMonsters and (not currentSettings.PvpSafe or getCreaturesInArea(player, safePatterns[entry.model], 3) == 0) then
                  cast(entry.attack, entry.cd)
                  return
                elseif entry.category == 2 and getCreaturesInArea(pos(), patterns[entry.model], 2) >= entry.minMonsters and (not currentSettings.PvpSafe or getCreaturesInArea(pos(), safePatterns[entry.model], 3) == 0) then
                  cast(entry.attack, entry.cd)
                  return
                elseif entry.category == 8 and bestTile and bestTile.count >= entry.minMonsters then
                  if not AttackBotConfig.isUsing then
                    g_game.useInventoryItemWith(entry.attack, bestTile.pos:getTopUseThing())
                  end
                  return
                elseif entry.category == 9 and not isBuffed() and getMonsters(entry.dist) >= entry.minMonsters then
                  cast(entry.attack, entry.cd)
                  return
                else
                  if entry.category == 6 or entry.category == 7 then
                    if getMonsters(4) >= entry.minMonsters then
                      if type(entry.attack) == "number" then
                        if not AttackBotConfig.isUsing then
                          g_game.useInventoryItemWith(entry.attack, target())
                          return
                        end
                      else
                        cast(entry.attack, entry.cd)
                        return
                      end
                    end
                  end
                end
              else
                if entry.category == 6 or entry.category == 7 then
                  if getMonsters(4) >= entry.minMonsters then
                    if type(entry.attack) == "number" then
                      if not AttackBotConfig.isUsing then
                        g_game.useInventoryItemWith(entry.attack, target())
                        return
                      end
                    else
                      cast(entry.attack, entry.cd)
                      return
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end)