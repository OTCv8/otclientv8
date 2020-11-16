local analyserPanelName = "AnalysersPanel"
local ui = setupUI([[
Panel
  height: 18

  Button
    id: analyzersMain
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 18
    text: Hunt Analysers
  ]], parent)
ui:setId(analyserPanelName)

if not storage[analyserPanelName] then
  storage[analyserPanelName] = {
    bestHit = 0,
    bestHeal = 0,
    lootItems = {}
  }
end

analyzersWindow = g_ui.createWidget('MainAnalyzer', modules.game_interface.getRightPanel())
huntWindow = g_ui.createWidget('HuntAnalyser', modules.game_interface.getRightPanel())
impactWindow = g_ui.createWidget('ImpactAnalyser', modules.game_interface.getRightPanel())
lootWindow = g_ui.createWidget('LootAnalyser', modules.game_interface.getRightPanel())
xpWindow = g_ui.createWidget('XpAnalyser', modules.game_interface.getRightPanel())
analyzersWindow:setup()
huntWindow:setup()
impactWindow:setup()
lootWindow:setup()
xpWindow:setup()

rootWidget = g_ui.getRootWidget()
lootListWindow = g_ui.createWidget('LootWindow', rootWidget)
lootListWindow:hide()

function refresh()
  analyzersWindow:setContentMinimumHeight(105)
  analyzersWindow:setContentMaximumHeight(105)
  huntWindow:setContentMinimumHeight(30)
  impactWindow:setContentMinimumHeight(30)
  impactWindow:setContentMaximumHeight(185)  
  lootWindow:setContentMinimumHeight(30)
  xpWindow:setContentMinimumHeight(30)
  xpWindow:setContentMaximumHeight(65)    
end
refresh()

function huntWindowToggle()
  if huntWindow:isVisible() then
    huntWindow:close()
  else
    huntWindow:open()
  end
end

function impactWindowToggle()
  if impactWindow:isVisible() then
    impactWindow:close()
  else
    impactWindow:open()
  end
end

function lootWindowToggle()
  if lootWindow:isVisible() then
    lootWindow:close()
  else
    lootWindow:open()
  end
end

function xpWindowToggle()
  if xpWindow:isVisible() then
    xpWindow:close()
  else
    xpWindow:open()
  end
end

ui.analyzersMain.onClick = function(widget)
  if analyzersWindow:isVisible() then
    analyzersWindow:close()
  else
    analyzersWindow:open()
  end
end
lootWindow.contentsPanel.LootEdit.onClick = function(widget)
  lootListWindow:show()
  lootListWindow:raise()
  lootListWindow:focus()
end

if storage[analyserPanelName].lootItems and #storage[analyserPanelName].lootItems > 0 then
  for _, name in ipairs(storage[analyserPanelName].lootItems) do
    local label = g_ui.createWidget("LootItemName", lootListWindow.LootList)
    label.remove.onClick = function(widget)
      table.removevalue(storage[analyserPanelName].lootItems, label:getText())
      label:destroy()
    end
    label:setText(name)
  end
end

lootListWindow.AddLoot.onClick = function(widget)
  local lootName = lootListWindow.LootName:getText()
  if lootName:len() > 0 and not table.contains(storage[analyserPanelName].lootItems, lootName, true) then
    table.insert(storage[analyserPanelName].lootItems, lootName)
    local label = g_ui.createWidget("LootItemName", lootListWindow.LootList)
    label.remove.onClick = function(widget)
      table.removevalue(storage[analyserPanelName].lootItems, label:getText())
      label:destroy()
    end
    label:setText(lootName)
    lootListWindow.LootName:setText('')
  end
end

lootListWindow.closeButton.onClick = function(widget)
  lootListWindow:hide()
end

analyzersWindow.contentsPanel.HuntButton.onClick = function(widget)
  huntWindowToggle()
end
analyzersWindow.contentsPanel.lootSupplyButton.onClick = function(widget)
  lootWindowToggle()
end
analyzersWindow.contentsPanel.impactButton.onClick = function(widget)
  impactWindowToggle()
end
analyzersWindow.contentsPanel.xpButton.onClick = function(widget)
  xpWindowToggle()
end

local uptime
local launchTime = now
local startTime = now
function sessionTime()
 uptime = math.floor((now - launchTime)/1000)
 local hours = string.format("%02.f", math.floor(uptime/3600))
 local mins = string.format("%02.f", math.floor(uptime/60 - (hours*60)))

return hours .. ":" .. mins .. "h"
end

local startExp = exp()
function expGained()
  return exp() - startExp
end

function expForLevel(level)
  return math.floor((50*level*level*level)/3 - 100*level*level + (850*level)/3 - 200)
end

function expH()
  return (expGained() / (now - startTime))
end

function format_thousand(v)
  if not v then return 0 end
  local s = string.format("%d", math.floor(v))
  local pos = string.len(s) % 3
  if pos == 0 then pos = 3 end
  return string.sub(s, 1, pos)
  .. string.gsub(string.sub(s, pos+1), "(...)", ".%1")
end

function checkExpSpeed()
  local player = g_game.getLocalPlayer()
  if not player then return end

  local currentExp = player:getExperience()
  local currentTime = now/1000
  if player.lastExps ~= nil then
    player.expSpeed = (currentExp - player.lastExps[1][1])/(currentTime - player.lastExps[1][2])
  else
    player.lastExps = {}
  end
  table.insert(player.lastExps, {currentExp, currentTime})
  if #player.lastExps > 30 then
    table.remove(player.lastExps, 1)
  end

  return player.expSpeed
end

function nextLevelData(time)

  if checkExpSpeed() ~= nil then
     expPerHour = math.floor(checkExpSpeed() * 3600)
     if expPerHour > 0 then
        nextLevelExp = expForLevel(player:getLevel()+1)
        hoursLeft = (nextLevelExp - player:getExperience()) / expPerHour
        minutesLeft = math.floor((hoursLeft - math.floor(hoursLeft))*60)
        hoursLeft = math.floor(hoursLeft)
        timeLeft = tostring(hoursLeft .. ":" .. minutesLeft .. "h")
     end
  end

    if time then
      return expPerHour
    else
      return timeLeft
    end
end

function sum(t)
  local sum = 0
  for k,v in pairs(t) do
      sum = sum + v
  end

  return sum
end

local cumulatedDamage = 0
local cumulatedHealing = 0
local allHits = {}
local allHeals = {}
local dps
local hps
local kills = {}
local droppedItems = {}
onTextMessage(function(mode, text)
  -- [[ kill counter ]] --
  if string.find(text, "Loot of") then
    local split = string.split(text, ":")
    local mobName = string.split(split[1], "of ")[2]:trim()
    table.insert(kills, mobName)

    local killCount = {}
    for i, entry in pairs(kills) do
      if killCount[entry] then
        killCount[entry] = killCount[entry] + 1
      else
        killCount[entry] = 1
      end
    end

    for i, child in pairs(huntWindow.contentsPanel.MessagePanel:getChildren()) do
      child:destroy()
    end

    for k,v in pairs(killCount) do
      local label = g_ui.createWidget("MonsterLabel", huntWindow.contentsPanel.MessagePanel)
      label:setText(v .. "x " .. k)
    end

    -- [[ loot counter ]] --
    local monsterDrop = string.split(split[2], ",")

    if #monsterDrop > 0 then
      for i=1,#monsterDrop do
        local drop = monsterDrop[i]:trim()
          for i, entry in pairs(storage[analyserPanelName].lootItems) do
            if string.match(drop, entry) then
              local entryCount 
              if tonumber(string.match(drop, "%d+")) then
                entryCount = tonumber(string.match(drop, "%d+"))
              else
                entryCount = 1
              end
              if droppedItems[entry] then
                droppedItems[entry] = droppedItems[entry] + entryCount
              else
                droppedItems[entry] = entryCount
              end
            end
          end
      end
    end
    for i, child in pairs(lootWindow.contentsPanel.MessagePanel:getChildren()) do
      child:destroy()
    end
    for k,v in pairs(droppedItems) do
      local label = g_ui.createWidget("MonsterLabel", lootWindow.contentsPanel.MessagePanel)
      label:setText(v .. "x " .. k)
    end
  end

  -- damage
  if string.find(text, "hitpoints due to your attack") then
    table.insert(allHits, tonumber(string.match(text, "%d+")))
    if dps then
      if now - startTime > 1000 then
        local dmgSum = sum(allHits)
        dps = dmgSum
        allHits = {}
        startTime = now
      end
    else
      dps = 0
    end

    local dmgValue = tonumber(string.match(text, "%d+"))
      cumulatedDamage = cumulatedDamage + dmgValue
    if storage[analyserPanelName].bestHit < dmgValue then
      storage[analyserPanelName].bestHit = dmgValue
    end
  end
  -- healing
  if string.find(text, "You heal") then
    table.insert(allHeals, tonumber(string.match(text, "%d+")))
    if hps then
      if now - startTime > 1000 then
        local healSum = sum(allHeals)
        hps = healSum
        allHeals = {}
        startTime = now
      end
    else
      hps = 0
    end
    local healValue = tonumber(string.match(text, "%d+"))
    cumulatedHealing = cumulatedHealing + healValue
    if storage[analyserPanelName].bestHeal < healValue then
      storage[analyserPanelName].bestHeal = healValue
    end
  end

  -- [[ waste]] --
  if string.find(text, "Using one of") then
    local splitTwo = string.split(text, "Using one of")
    if #splitTwo == 1 then
      local itemAmount = string.match(splitTwo[1], "%d+")
    end

  end
end)

function hourVal(v)
  if not v then return end
  return (v/uptime)*3600
end

function expH()
  return (expGained()/uptime)*3600
end

local lootWorth
macro(1000, function()
  -- [[ profit ]] --
  lootWorth = 0
  for k, v in pairs(droppedItems) do
    if lootitems[k] then
      lootWorth = lootWorth + (lootitems[k]*v)
    end
  end
  -- [[ Hunt Window ]] --
    huntWindow.contentsPanel.sessionValue:setText(sessionTime())
    huntWindow.contentsPanel.xpGainValue:setText(format_thousand(expGained()))
    huntWindow.contentsPanel.xpHourValue:setText(format_thousand(expH()))
    if cumulatedDamage then huntWindow.contentsPanel.damageValue:setText(format_thousand(cumulatedDamage)) end
    if cumulatedHealing then huntWindow.contentsPanel.healingValue:setText(format_thousand(cumulatedHealing)) end
    huntWindow.contentsPanel.damageHourValue:setText(format_thousand(hourVal(cumulatedDamage)))
    huntWindow.contentsPanel.healingHourValue:setText(format_thousand(hourVal(cumulatedHealing)))
    huntWindow.contentsPanel.lootValue:setText(format_thousand(lootWorth))
  -- [[ XP Window ]] --
    xpWindow.contentsPanel.xpValue:setText(format_thousand(expGained()))
    xpWindow.contentsPanel.hourValue:setText(format_thousand(expH()))
    if not nextLevelData() then xpWindow.contentsPanel.ttnlValue:setText("-") else xpWindow.contentsPanel.ttnlValue:setText(nextLevelData()) end
  -- [[ Impact Window ]] -- 
    if cumulatedDamage then impactWindow.contentsPanel.damageValue:setText(format_thousand(cumulatedDamage)) end
    if dps then impactWindow.contentsPanel.maxDpsValue:setText(format_thousand(dps)) end
    impactWindow.contentsPanel.allTimeHighValue:setText(format_thousand(storage[analyserPanelName].bestHit))
    if cumulatedHealing then impactWindow.contentsPanel.healingValue:setText(format_thousand(cumulatedHealing)) end
    if hps then impactWindow.contentsPanel.maxHpsValue:setText(format_thousand(hps)) end
    impactWindow.contentsPanel.allTimeHighHealValue:setText(format_thousand(storage[analyserPanelName].bestHeal))
  -- [[ Loot Window ]] --
  lootWindow.contentsPanel.lootValue:setText(format_thousand(lootWorth))
  lootWindow.contentsPanel.lootHourValue:setText(format_thousand(hourVal(lootWorth)))
end)
