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
    id: mode
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    text: Mode: PVP
    margin-right: 2
    margin-top: 4
    font: cipsoftFont
    height: 17

  Button
    id: safe
    anchors.top: settings.bottom
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    text: PVP Safe
    margin-left: 2
    margin-top: 4
    height: 17
    font:cipsoftFont
]])
ui:setId(attackPanelName)

local i = 1
local j = 1
local k = 1
local pvpDedicated = false
local item = false

if not storage[attackPanelName] or not storage[attackPanelName].attackTable then
  storage[attackPanelName] = {
    pvpMode = false,
    pvpSafe = true,
    enabled = false,
    attackTable = {},
    ignoreMana = true
  }
end

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

local updateModeText = function()
  local text
  if storage[attackPanelName].pvpMode then
    text = "PVP"
    ui.mode:setColor("yellow")
  else
    text = "HUNT"
    ui.mode:setColor("green")
  end
  ui.mode:setText("MODE: " .. text)
end
updateModeText()

local updatePvpColor = function()
  if storage[attackPanelName].pvpSafe then
    ui.safe:setColor("green")
  else
    ui.safe:setColor("white")
  end
end
updatePvpColor()

ui.title:setOn(storage[attackPanelName].enabled)
ui.title.onClick = function(widget)
storage[attackPanelName].enabled = not storage[attackPanelName].enabled
widget:setOn(storage[attackPanelName].enabled)
end

ui.mode.onClick = function(widget)
storage[attackPanelName].pvpMode = not storage[attackPanelName].pvpMode
updateModeText()
end

ui.safe.onClick = function(widget)
storage[attackPanelName].pvpSafe = not storage[attackPanelName].pvpSafe
updatePvpColor()
end

ui.settings.onClick = function(widget)
  attackWindow:show()
  attackWindow:raise()
  attackWindow:focus()
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  attackWindow = g_ui.createWidget('AttackWindow', rootWidget)
  attackWindow:hide()

  -- functions
  local updateCategoryText = function()
    attackWindow.category:setText(categories[i])
  end
  updateCategoryText()
  local updateParameter1Text = function()
    attackWindow.parameter1:setText(pattern[k])
  end
  updateParameter1Text()
  local updateParameter2Text = function()
    attackWindow.parameter2:setText(range[j])
  end
  updateParameter2Text()

  -- checkbox
  attackWindow.pvpSpell.onClick = function(widget)
    pvpDedicated = not pvpDedicated
    attackWindow.pvpSpell:setChecked(pvpDedicated)
  end
  attackWindow.IgnoreMana:setChecked(storage[attackPanelName].ignoreMana)
  attackWindow.IgnoreMana.onClick = function(widget)
    storage[attackPanelName].ignoreMana = not storage[attackPanelName].ignoreMana
    attackWindow.IgnoreMana:setChecked(storage[attackPanelName].ignoreMana)
  end

  --buttons
  attackWindow.CloseButton.onClick = function(widget)
    attackWindow:hide()
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
  inputTypeToggle()

  attackWindow.categoryNext.onClick = function(widget)
    if i == #categories then
      i = 1
    else
      i = i + 1
    end
    updateCategoryText()
    inputTypeToggle()
  end

  attackWindow.categoryPrev.onClick = function(widget)
    if i == 1 then
      i = #categories
    else
      i = i - 1
    end
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
    attackWindow.minMana:setText("")
    attackWindow.minMonsters:setText("")
    attackWindow.itemId:setItemId(0)
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

  local refreshAttacks = function()
    if storage[attackPanelName].attackTable and #storage[attackPanelName].attackTable > 0 then
      for i, child in pairs(attackWindow.attackList:getChildren()) do
        child:destroy()
      end
      for _, entry in pairs(storage[attackPanelName].attackTable) do
        local label = g_ui.createWidget("AttackEntry", attackWindow.attackList)
        label.enabled:setChecked(entry.enabled)
        label.enabled.onClick = function(widget)
          entry.enabled = not entry.enabled
          label.enabled:setChecked(entry.enabled)
        end
        label.remove.onClick = function(widget)
          table.removevalue(storage[attackPanelName].attackTable, entry)
          reindexTable(storage[attackPanelName].attackTable)
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
  refreshAttacks()

  attackWindow.MoveUp.onClick = function(widget)
    local input = attackWindow.attackList:getFocusedChild()
    if not input then return end
    local index = attackWindow.attackList:getChildIndex(input)
    if index < 2 then return end

    local move
    if storage[attackPanelName].attackTable and #storage[attackPanelName].attackTable > 0 then
      for _, entry in pairs(storage[attackPanelName].attackTable) do
        if entry.index == index -1 then
          move = entry
        end
        if entry.index == index then
          move.index = index
          entry.index = index -1
        end
      end
    end
    table.sort(storage[attackPanelName].attackTable, function(a,b) return a.index < b.index end)

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
    if storage[attackPanelName].attackTable and #storage[attackPanelName].attackTable > 0 then
      for _, entry in pairs(storage[attackPanelName].attackTable) do
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
    table.sort(storage[attackPanelName].attackTable, function(a,b) return a.index < b.index end)

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
      table.insert(storage[attackPanelName].attackTable, {index = #storage[attackPanelName].attackTable+1, attack = val, manaCost = tonumber(attackWindow.minMana:getText()), minMonsters = tonumber(attackWindow.minMonsters:getText()), pvp = pvpDedicated, dist = j-1, model = k, category = i, enabled = true})
      refreshAttacks()
      clearValues()
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
  if not storage[attackPanelName].enabled then return end
  if #storage[attackPanelName].attackTable == 0 or isInPz() or not target() or modules.game_cooldown.isGroupCooldownIconActive(1) then return end

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

  if player:getDirection() ~= bestDir and bestSide > 0 then
    turn(bestDir)
  end

  for _, entry in pairs(storage[attackPanelName].attackTable) do
    if entry.enabled then
      if (type(entry.attack) == "string" and canCast(entry.attack, not storage[attackPanelName].ignoreMana)) or (type(entry.attack) == "number" and findItem(entry.attack)) then
        if manapercent() >= entry.manaCost and distanceFromPlayer(target():getPosition()) <= entry.dist then
          if storage[attackPanelName].pvpMode then
            if entry.pvp then
              if type(entry.attack) == "string" and target():canShoot() then
                say(entry.attack)
                return
              else
                if not storage.isUsing and target():canShoot() then
                  useWith(entry.attack, target())
                  return
                end
              end
            end
          else
            if entry.category == 6 or entry.category == 7 then
              if getMonsters(4) >= entry.minMonsters then
                if type(entry.attack) == "number" then
                  if not storage.isUsing then
                    useWith(entry.attack, target())
                    return
                  end
                else
                  say(entry.attack)
                  return
                end
              end
            else
              if killsToRs() > 2 then
                if entry.category == 8 then
                  bestTile = getBestTileByPatern(patterns[5], 2, entry.dist, storage[attackPanelName].pvpSafe)
                end
                if entry.category == 4 and (not storage[attackPanelName].pvpSafe or isSafe(2, false)) and bestSide >= entry.minMonsters then
                  say(entry.attack)
                  return
                elseif entry.category == 3 and (not storage[attackPanelName].pvpSafe or isSafe(2, false)) and getMonsters(1) >= entry.minMonsters then
                  say(entry.attack)
                  return
                elseif entry.category == 5 and getCreaturesInArea(player, patterns[entry.model], 2) >= entry.minMonsters and (not storage[attackPanelName].pvpSafe or getCreaturesInArea(player, safePatterns[entry.model], 3) == 0) then
                  say(entry.attack)
                  return
                elseif entry.category == 2 and getCreaturesInArea(pos(), patterns[entry.model], 2) >= entry.minMonsters and (not storage[attackPanelName].pvpSafe or getCreaturesInArea(pos(), safePatterns[entry.model], 3) == 0) then
                  say(entry.attack)
                  return
                elseif entry.category == 8 and bestTile and bestTile.count >= entry.minMonsters then
                  if not storage.isUsing then
                    useWith(entry.attack, bestTile.pos:getTopUseThing())
                  end
                  return
                elseif entry.category == 9 and not isBuffed() and getMonsters(entry.dist) >= entry.minMonsters then
                  say(entry.attack)
                  return
                else
                  if entry.category == 6 or entry.category == 7 then
                    if getMonsters(4) >= entry.minMonsters then
                      if type(entry.attack) == "number" then
                        if not storage.isUsing then
                          useWith(entry.attack, target())
                          return
                        end
                      else
                        say(entry.attack)
                        return
                      end
                    end
                  end
                end
              else
                if entry.category == 6 or entry.category == 7 then
                  if getMonsters(4) >= entry.minMonsters then
                    if type(entry.attack) == "number" then
                      if not storage.isUsing then
                        useWith(entry.attack, target())
                        return
                      end
                    else
                      say(entry.attack)
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