--[[
  Bot-based Tibia 12 features v1.1
  made by Vithrax

  Credits also to:
  - Martín#2318
  - Lee#7725

  Thanks for ideas, graphics, functions, design tips!
  
  br, Vithrax
]]

-- here you can fix incorrect bosses names in cooldown messages
local BOSSES = {
  -- {in message, correct one}
  {"Scarlet Etzel", "Scarlett Etzel"},
  {"Leiden", "Ravenous Hunger"},
  {"Urmahlulu", "Urmahlullu"}
}

vBot.CaveBotData = vBot.CaveBotData or {
  refills = 0,
  rounds = 0,
  time = {},
  lastRefill = os.time(),
  refillTime = {}
}
local lootWorth = 0
local wasteWorth = 0
local balance = 0
local balanceDesc = ""
local hourDesc = ""
local desc = ""
local hour = ""
local launchTime = now
local startExp = exp()
local dmgTable = {}
local healTable = {}
local expTable = {}
local totalDmg = 0
local totalHeal = 0
local dmgDistribution = {}
local first = {l="-", r="0"}
local second = {l="-", r="0"}
local third = {l="-", r="0"}
local fourth = {l="-", r="0"}
local five = {l="-", r="0"}
storage.bestHit = storage.bestHit or 0
storage.bestHeal = storage.bestHeal or 0
local lootedItems = {}
local useData = {}
local usedItems ={}
local analyzerButton
local killList = {}
local membersData = {}
local bestDPS = 0
local bestHPS = 0
local lastCap = freecap()
HuntingSessionStart = os.date('%Y-%m-%d, %H:%M:%S')

if not storage.analyzers then
  storage.analyzers = {
    trackedLoot = {},
    trackedBoss = {},
    outfits = {},
    customPrices = {},
    lootChannel = true,
    rarityFrames = true,
  }
end

storage.analyzers = storage.analyzers or {}
storage.analyzers.trackedLoot = storage.analyzers.trackedLoot or {}
storage.analyzers.trackedBoss = storage.analyzers.trackedBoss or {}
storage.analyzers.outfits = storage.analyzers.outfits or {}
local trackedLoot = storage.analyzers.trackedLoot

--destroy old windows
local windowsTable = {"MainAnalyzerWindow", 
                      "HuntingAnalyzerWindow", 
                      "LootAnalyzerWindow", 
                      "SupplyAnalyzerWindow", 
                      "ImpactAnalyzerWindow", 
                      "XPAnalyzerWindow", 
                      "PartyAnalyzerWindow", 
                      "DropTracker", 
                      "CaveBotStats",
                      "BossTracker"
                     }

                      for i, window in ipairs(windowsTable) do
  local element = g_ui.getRootWidget():recursiveGetChildById(window)

  if element then
    element:destroy()
  end
end

local mainWindow = UI.createMiniWindow("MainAnalyzerWindow")
mainWindow:hide()
mainWindow:setContentMaximumHeight(267)
local huntingWindow = UI.createMiniWindow("HuntingAnalyzer")
huntingWindow:hide()
local lootWindow = UI.createMiniWindow("LootAnalyzer")
lootWindow:hide()
local supplyWindow = UI.createMiniWindow("SupplyAnalyzer")
supplyWindow:hide()
local impactWindow = UI.createMiniWindow("ImpactAnalyzer")
impactWindow:hide()
impactWindow:setContentMaximumHeight(615)
local xpWindow = UI.createMiniWindow("XPAnalyzer")
xpWindow:hide()
xpWindow:setContentMaximumHeight(230)
local settingsWindow = UI.createWindow("FeaturesWindow")
settingsWindow:hide()
local partyHuntWindow = UI.createMiniWindow("PartyAnalyzerWindow")
partyHuntWindow:hide()
local dropTrackerWindow = UI.createMiniWindow("DropTracker")
dropTrackerWindow:hide()
local statsWindow = UI.createMiniWindow("CaveBotStats")
statsWindow:hide()
local bossWindow = UI.createMiniWindow("BossTracker")
bossWindow:hide()

--f
local toggle = function()
    if mainWindow:isVisible() then
        analyzerButton:setOn(false)
        mainWindow:close()
    else
        analyzerButton:setOn(true)
        mainWindow:open()
    end
end

local drawGraph = function(graph, value)
    graph:addValue(value)
end

local toggleAnalyzer = function(window)
    if window:isVisible() then
        window:hide()
    else
        window:show()
    end
end

local function getSumStats()
  local totalWaste = 0
  local totalLoot = 0

  for k,v in pairs(membersData) do
    totalWaste = totalWaste + v.waste
    totalLoot = totalLoot + v.loot
  end

  local totalBalance = totalLoot - totalWaste

  return totalWaste, totalLoot, totalBalance
end

local function clipboardData()
  local totalWaste, totalLoot, totalBalance = getSumStats()
  local final = ""


  local first = "Session data: From " .. HuntingSessionStart .." to ".. os.date('%Y-%m-%d, %H:%M:%S')
  local second = "Session: " .. sessionTime()
  local third = "Loot Type: Market"
  local fourth = "Loot " .. format_thousand(totalLoot, true)
  local fifth = "Supplies " .. format_thousand(totalWaste, true)
  local six = "Balance " .. format_thousand(totalBalance, true)

  local t = {first, second, third, fourth, fifth, six}
  for i, string in ipairs(t) do
    final = final.. "\n"..string
  end

  --user data now
  for k,v in pairs(membersData) do
    final = final.. "\n".. k

    final = final.. "\n\tLoot "..v.loot
    final = final.. "\n\tSupplies "..v.waste
    final = final.. "\n\tBalance "..v.balance
    final = final.. "\n\tDamage "..v.damage
    final = final.. "\n\tHealing "..v.heal
  end

  g_window.setClipboardText(final)
end

-- create analyzers button
analyzerButton = modules.game_buttons.buttonsWindow.contentsPanel and modules.game_buttons.buttonsWindow.contentsPanel.buttons.botAnalyzersButton
analyzerButton = analyzerButton or modules.client_topmenu.getButton("botAnalyzersButton")
if analyzerButton then
    analyzerButton:destroy()
end

--button
analyzerButton = modules.client_topmenu.addRightGameToggleButton('botAnalyzersButton', 'vBot Analyzers', '/images/topbuttons/analyzers', toggle, false, 999999)
analyzerButton:setOn(false)

--toggles window
mainWindow.contentsPanel.HuntingAnalyzer.onClick = function()
    toggleAnalyzer(huntingWindow)
end
mainWindow.onClose = function()
  analyzerButton:setOn(false)
end
mainWindow.contentsPanel.LootAnalyzer.onClick = function()
    toggleAnalyzer(lootWindow)
end
mainWindow.contentsPanel.SupplyAnalyzer.onClick = function()
    toggleAnalyzer(supplyWindow)
end
mainWindow.contentsPanel.ImpactAnalyzer.onClick = function()
    toggleAnalyzer(impactWindow)
end
mainWindow.contentsPanel.XPAnalyzer.onClick = function()
    toggleAnalyzer(xpWindow)
end
mainWindow.contentsPanel.PartyHunt.onClick = function()
  toggleAnalyzer(partyHuntWindow)
end
mainWindow.contentsPanel.DropTracker.onClick = function()
  toggleAnalyzer(dropTrackerWindow)
end
mainWindow.contentsPanel.Stats.onClick = function()
  toggleAnalyzer(statsWindow)
end
mainWindow.contentsPanel.BossTracker.onClick = function()
  toggleAnalyzer(bossWindow)
end

-- boss tracker
bossWindow.contentsPanel.search.onTextChange = function(widget, newText)
  newText = newText:lower()
  for i, child in ipairs(bossWindow.contentsPanel:getChildren()) do
    local text = child:getId():lower()
    if child:getId() ~= "search" then
      child:setVisible(text:find(newText))
    end
  end
end

-- on login
newTimeFormat = function(v) -- v in seconds
  local hours = string.format("%02.f", math.floor(v/3600))
  local mins = string.format("%02.f", math.floor(v/60 - (hours*60)))

  local final = hours.. "h "..mins.."min"
  return final
end

function createBossPanel(bossName, dueTime)
  local widget = bossWindow.contentsPanel[bossName] or UI.createWidget("BossCreaturePanel", bossWindow.contentsPanel)
  local outfit = storage.analyzers.outfits[bossName]

  widget.time = dueTime
  widget:setId(bossName)
  if outfit then
    widget.creature:setOutfit(outfit)
  else
    widget.creature:setTooltip("Outfit preview not available.\nTo get one you need to 'attack' ".. bossName.."\nOr you need to correct the boss name inside analyzers.lua file, const BOSSES")
  end
  widget.name:setText(bossName)

  local timeLeft = os.difftime(dueTime, os.time())
  if timeLeft > 0 then
    widget.cooldown:setText(newTimeFormat(timeLeft))
    widget.cooldown:setColor('#f29257')
  else
    widget.cooldown:setText("No Cooldown")
    widget.cooldown:setColor('#b8b8b8')
  end
end

for bossName, dueTime in pairs(storage.analyzers.trackedBoss) do
  createBossPanel(bossName, dueTime)
end

local bossRegex = [[You (?:can|may) challenge ([\w\W]*) again in ([\d]+) ?([a-z]*)]]
onTalk(function(name, level, mode, text, channelId, pos)
  if mode == 34 then
    local re = regexMatch(text, bossRegex)
    local name = re and re[1] and re[1][2]
    local cd = re and re[1] and re[1][3]

    for i=1,#BOSSES do
      local bad = BOSSES[i][1]
      local good = BOSSES[i][2]

      if name == bad then
        name = good
      end
    end

    if not cd then return end

    -- cd in seconds, the message says hours unless it names another unit
    local unit = re[1][4] or ""
    local multiplier = 60 * 60
    if unit:find("^min") then
      multiplier = 60
    elseif unit:find("^day") then
      multiplier = 24 * 60 * 60
    elseif unit:find("^sec") then
      multiplier = 1
    end
    cd = tonumber(cd) * multiplier

    storage.analyzers.trackedBoss[name] = os.time() + cd
    createBossPanel(name, os.time() + cd)
  end
end)

-- save outfits
onAttackingCreatureChange(function(newCreature, oldCreature)
  local name = newCreature and newCreature:getName()
  local outfit = newCreature and newCreature:getOutfit()

  if name then
    storage.analyzers.outfits[name] = storage.analyzers.outfits[name] or outfit
  end
end)

--stats window
local totalRounds = UI.DualLabel("Total Rounds:", "0", {}, statsWindow.contentsPanel).right
local avRoundTime = UI.DualLabel("Time by Round:", "00:00h", {}, statsWindow.contentsPanel).right
UI.Separator(statsWindow.contentsPanel)
local totalRefills = UI.DualLabel("Total Refills:", "0", {}, statsWindow.contentsPanel).right
local avRefillTime = UI.DualLabel("Time by Refill:", "00:00h", {}, statsWindow.contentsPanel).right
local lastRefill = UI.DualLabel("Time since Refill:", "00:00h", {maxWidth = 200}, statsWindow.contentsPanel).right
UI.Separator(statsWindow.contentsPanel)
local label = UI.DualLabel("Supplies by Round:", "", {maxWidth = 200}, statsWindow.contentsPanel).left
label:setColor('#EC9706')
local suppliesByRound = UI.createWidget("AnalyzerItemsPanel", statsWindow.contentsPanel)
UI.Separator(statsWindow.contentsPanel)
label = UI.DualLabel("Supplies by Refill:", "", {maxWidth = 200}, statsWindow.contentsPanel).left
label:setColor('#ED7117')
local suppliesByRefill = UI.createWidget("AnalyzerItemsPanel", statsWindow.contentsPanel)
UI.Separator(statsWindow.contentsPanel)


--huntig
local sessionTimeLabel = UI.DualLabel("Session:", "00:00h", {}, huntingWindow.contentsPanel).right
local xpGainLabel = UI.DualLabel("XP Gain:", "0", {}, huntingWindow.contentsPanel).right
local xpHourLabel = UI.DualLabel("XP/h:", "0", {}, huntingWindow.contentsPanel).right
local lootLabel = UI.DualLabel("Loot:", "0", {}, huntingWindow.contentsPanel).right
local suppliesLabel = UI.DualLabel("Supplies:", "0", {}, huntingWindow.contentsPanel).right
local balanceLabel = UI.DualLabel("Balance:", "0", {}, huntingWindow.contentsPanel).right
local damageLabel = UI.DualLabel("Damage:", "0", {}, huntingWindow.contentsPanel).right
local damageHourLabel = UI.DualLabel("Damage/h:", "0", {}, huntingWindow.contentsPanel).right
local healingLabel = UI.DualLabel("Healing:", "0", {}, huntingWindow.contentsPanel).right
local healingHourLabel = UI.DualLabel("Healing/h:", "0", {}, huntingWindow.contentsPanel).right
UI.DualLabel("Killed Monsters:", "", {maxWidth = 200}, huntingWindow.contentsPanel)
local killedList = UI.createWidget("AnalyzerListPanel", huntingWindow.contentsPanel)
UI.DualLabel("Looted items:", "", {maxWidth = 200}, huntingWindow.contentsPanel)
local lootList = UI.createWidget("AnalyzerListPanel", huntingWindow.contentsPanel)


--party
UI.Button("Copy to Clipboard", function() clipboardData() end, partyHuntWindow.contentsPanel)
UI.Button("Reset Sessions", function()
  if BotServer._websocket then
    BotServer.send("partyHunt", false)
  end
end, partyHuntWindow.contentsPanel)

local switch = addSwitch("sendData", "Send Analyzer Data", function(widget)
  widget:setOn(not widget:isOn())
  storage.sendPartyAnalyzerData = widget:isOn()
end, partyHuntWindow.contentsPanel)
switch:setOn(storage.sendPartyAnalyzerData)
UI.Separator(partyHuntWindow.contentsPanel)
local partySessionTimeLabel = UI.DualLabel("Session:", "00:00h", {}, partyHuntWindow.contentsPanel).right
local partyLootLabel = UI.DualLabel("Loot:", "0", {}, partyHuntWindow.contentsPanel).right
local partySuppliesLabel = UI.DualLabel("Supplies:", "0", {}, partyHuntWindow.contentsPanel).right
local partyBalanceLabel = UI.DualLabel("Balance:", "0", {}, partyHuntWindow.contentsPanel).right
UI.Separator(partyHuntWindow.contentsPanel)

local function maintainDropTable()
  local panel = dropTrackerWindow.contentsPanel

  for k,v in pairs(trackedLoot) do
    local widget = panel[k]
    if not widget then
      trackedLoot[k] = nil
    end
  end
end

local function createTrackedItems()
  local panel = dropTrackerWindow.contentsPanel

  for i, child in ipairs(panel:getChildren()) do
    if i > 2 then
      child:destroy()
    end
  end

  for k,v in pairs(trackedLoot) do
    local dropLoot = UI.createWidget("TrackerItem", dropTrackerWindow.contentsPanel)
    local item = dropLoot.item
    local name = dropLoot.name
    local drops = dropLoot.drops
    local id = tonumber(k)
    local itemName = id == 3031 and "gold coin" or id == 3035 and "platinum coin" or id == 3043 and "crystal coin" or Item.create(id):getMarketData().name

    dropLoot:setId(id)
    item:setItemId(id)
    if item:getItemCount() > 1 then
      item:setItemCount(1)
    end
    name:setText(itemName)
    drops:setText("Loot Drops: "..v)

    dropLoot.onDoubleClick = function()
      local id = dropLoot.item:getItemId()
      trackedLoot[tostring(id)] = 0
      drops:setText("Loot Drops: 0")
    end
  
    for i, child in pairs(dropLoot:getChildren()) do
      child:setTooltip("Double click to reset or clear item to remove.")
    end

    item.onItemChange = function(widget)
      local id = widget:getItemId()
      if id == 0 then 
        trackedLoot[widget:getParent():getId()] = nil
        if tonumber(widget:getParent():getId()) then
          widget:getParent():destroy()
          return
        end
        widget:setImageSource('/images/ui/item')
        widget:getParent():setId("blank")
        name:setText("Set Item to start track.")
        drops:setText("Loot Drops: 0")
        return 
      end

    -- only amount have changed, ignore
      if tonumber(widget:getParent():getId()) == id then return end
      local itemName = id == 3031 and "gold coin" or id == 3035 and "platinum coin" or id == 3043 and "crystal coin" or Item.create(id):getMarketData().name

      if trackedLoot[tostring(id)] then
        warn("vBot[Drop Tracker]: Item already added!")
        name:setText("Set Item to start track.")
        widget:setItemId(0)
        return 
      end
  
      widget:setImageSource('')
      drops:setText("Loot Drops: 0")
      name:setText(itemName)
      trackedLoot[tostring(id)] = trackedLoot[tostring(id)] or 0
      widget:getParent():setId(id)
      maintainDropTable()
    end
  end
end

--drop tracker
UI.Button("Add item to track drops", function()
  local dropLoot = UI.createWidget("TrackerItem", dropTrackerWindow.contentsPanel)
  local item = dropLoot.item
  local name = dropLoot.name
  local drops = dropLoot.drops

  item:setImageSource('/images/ui/item')

  dropLoot.onDoubleClick = function()
    local id = dropLoot.item:getItemId()
    trackedLoot[tostring(id)] = 0
    drops:setText("Loot Drops: 0")
  end

  for i, child in pairs(dropLoot:getChildren()) do
    child:setTooltip("Double click to reset or clear item to remove.")
  end

  item.onItemChange = function(widget)
    local id = widget:getItemId()

    if id == 0 then 
      trackedLoot[widget:getParent():getId()] = nil
      if tonumber(widget:getParent():getId()) then
        widget:getParent():destroy()
        return
      end
      widget:setImageSource('/images/ui/item')
      widget:getParent():setId("blank")
      name:setText("Set Item to start track.")
      drops:setText("Loot Drops: 0")
      return 
    end

    -- only amount have changed, ignore
    if tonumber(widget:getParent():getId()) == id then return end
    local itemName = id == 3031 and "gold coin" or id == 3035 and "platinum coin" or id == 3043 and "crystal coin" or Item.create(id):getMarketData().name

    if trackedLoot[tostring(id)] then
      warn("vBot[Drop Tracker]: Item already added!")
      name:setText("Set Item to start track.")
      widget:setItemId(0)
      return 
    end

    widget:setImageSource('')
    drops:setText("Loot Drops: 0")
    name:setText(itemName)
    trackedLoot[tostring(id)] = trackedLoot[tostring(id)] or 0
    widget:getParent():setId(id)
    maintainDropTable()
  end
end, dropTrackerWindow.contentsPanel)

UI.Separator(dropTrackerWindow.contentsPanel)
createTrackedItems()


--loot
local lootInLootAnalyzerLabel = UI.DualLabel("Gold Value:", "0", {}, lootWindow.contentsPanel).right
local lootHourInLootAnalyzerLabel = UI.DualLabel("Per Hour:", "0", {}, lootWindow.contentsPanel).right
UI.Separator(lootWindow.contentsPanel)
--//items panel
local lootItems = UI.createWidget("AnalyzerItemsPanel", lootWindow.contentsPanel)
UI.Separator(lootWindow.contentsPanel)
--//graph
local lootGraph = UI.createWidget("AnalyzerGraph", lootWindow.contentsPanel)
      lootGraph:setTitle("Loot/h")
      drawGraph(lootGraph, 0)




--supplies
local suppliesInSuppliesAnalyzerLabel = UI.DualLabel("Gold Value:", "0", {}, supplyWindow.contentsPanel).right
local suppliesHourInSuppliesAnalyzerLabel = UI.DualLabel("Per Hour:", "0", {}, supplyWindow.contentsPanel).right
UI.Separator(supplyWindow.contentsPanel)
--//items panel
local supplyItems = UI.createWidget("AnalyzerItemsPanel", supplyWindow.contentsPanel)
UI.Separator(supplyWindow.contentsPanel)
--//graph
local supplyGraph = UI.createWidget("AnalyzerGraph", supplyWindow.contentsPanel)
      supplyGraph:setTitle("Waste/h")
      drawGraph(supplyGraph, 0)      




-- impact

--- damage
local title = UI.DualLabel("Damage", "", {}, impactWindow.contentsPanel).left
title:setColor('#E3242B')
local totalDamageLabel = UI.DualLabel("Total:", "0", {}, impactWindow.contentsPanel).right
local maxDpsLabel = UI.DualLabel("Max-DPS:", "0", {}, impactWindow.contentsPanel).right
local bestHitLabel = UI.DualLabel("All-Time High:", "0", {}, impactWindow.contentsPanel).right
UI.Separator(impactWindow.contentsPanel)
local dmgGraph = UI.createWidget("AnalyzerGraph", impactWindow.contentsPanel)
      dmgGraph:setTitle("DPS")
      drawGraph(dmgGraph, 0)
      
      
--- distribution 
UI.Separator(impactWindow.contentsPanel)
local title2 = UI.DualLabel("Damage Distribution", "", {maxWidth = 150}, impactWindow.contentsPanel).left
title2:setColor('#FABD02')
local top1 = UI.DualLabel("-", "0", {maxWidth = 200}, impactWindow.contentsPanel)
local top2 = UI.DualLabel("-", "0", {maxWidth = 200}, impactWindow.contentsPanel)
local top3 = UI.DualLabel("-", "0", {maxWidth = 200}, impactWindow.contentsPanel)
local top4 = UI.DualLabel("-", "0", {maxWidth = 200}, impactWindow.contentsPanel)
local top5 = UI.DualLabel("-", "0", {maxWidth = 200}, impactWindow.contentsPanel)

top1.left:setWidth(135)
top2.left:setWidth(135)
top3.left:setWidth(135)
top4.left:setWidth(135)
top5.left:setWidth(135)


--- healing
UI.Separator(impactWindow.contentsPanel)
local title3 = UI.DualLabel("Healing", "", {}, impactWindow.contentsPanel).left
title3:setColor('#03C04A')
local totalHealingLabel = UI.DualLabel("Total:", "0", {}, impactWindow.contentsPanel).right
local maxHpsLabel = UI.DualLabel("Max-HPS:", "0", {}, impactWindow.contentsPanel).right
local bestHealLabel = UI.DualLabel("All-Time High:", "0", {}, impactWindow.contentsPanel).right
UI.Separator(impactWindow.contentsPanel)
--//graph
local healGraph = UI.createWidget("AnalyzerGraph", impactWindow.contentsPanel)
      healGraph:setTitle("HPS")
      drawGraph(healGraph, 0)  







--xp
local xpGrainInXpLabel = UI.DualLabel("XP Gain:", "0", {}, xpWindow.contentsPanel).right
local xpHourInXpLabel = UI.DualLabel("XP/h:", "0", {}, xpWindow.contentsPanel).right
local nextLevelLabel = UI.DualLabel("Next Level:", "-", {}, xpWindow.contentsPanel).right
local progressBar = UI.createWidget("AnalyzerProgressBar", xpWindow.contentsPanel)
progressBar:setPercent(modules.game_skills.skillsWindow.contentsPanel.level.percent:getPercent())
UI.Separator(xpWindow.contentsPanel)
--//graph
local xpGraph = UI.createWidget("AnalyzerGraph", xpWindow.contentsPanel)
      xpGraph:setTitle("XP/h")
      drawGraph(xpGraph, 0)
      




--#############################################
--#############################################   UI DONE
--#############################################
--#############################################
--#############################################
--#############################################

setDefaultTab("Main")
-- first, the variables

local console = modules.game_console
local regex = [[ ([^,|^.]+)]]
local noData = {}
local data = {}

local function getColor(v)
    if v >= 10000000 then -- 10kk, red
        return "#FF0000" 
    elseif v >= 5000000 then -- 5kk, orange
        return "#FFA500"
    elseif v >= 1000000 then -- 1kk, yellow
        return "#FFFF00"
    elseif v >= 100000 then -- 100k, purple
        return "#F25AED"
    elseif v >= 10000 then -- 10k, blue
        return "#5F8DF7"
    elseif v >= 1000 then -- 1k, green
        return "#00FF00"
    elseif v >= 50 then
        return "#FFFFFF" -- 50gp, white
    else
      return "#aaaaaa" -- less than 100gp, grey
    end
end

local function formatStr(str)
    if string.starts(str, "a ") then
        str = str:sub(2, #str)
    elseif string.starts(str, "an ") then
      str = str:sub(3, #str)
    end

    local n = getFirstNumberInText(str)
    if n then
        str = string.split(str, tostring(n))[1]
        str = str:sub(1,#str-1)
    end

    return str:trim()
end

local function getPrice(name)
    name = formatStr(name)
    name = name:lower()
    -- first check custom prices
    if storage.analyzers.customPrices[name] then
      return storage.analyzers.customPrices[name]
    end

    -- if already checked and no data skip looping items.lua
    if noData[name] then
        return 0
    end

    -- maybe was already checked, if so, skip looping items.lua
    if data[name] then
        return data[name]
    end

    -- searching in items.lua - big table, if possible skip
    for k,v in pairs(LootItems) do
        if name == k then
            data[name] = v
            return v
        end
    end

    -- if no data, save it and return 0
    noData[name] = true
    return 0
end

local expGained = function()
  return exp() - startExp
end

function format_thousand(v, comma)
  comma = comma and "," or "."
  if not v then return 0 end
  local s = string.format("%d", math.floor(v))
  local pos = string.len(s) % 3
  if pos == 0 then pos = 3 end
  return string.sub(s, 1, pos)
  .. string.gsub(string.sub(s, pos+1), "(...)", comma.."%1")
end

local expLeft = function()
  local level = lvl()+1
  return math.floor((50*level*level*level)/3 - 100*level*level + (850*level)/3 - 200) - exp()
end

niceTimeFormat = function(v, seconds) -- v in seconds
  local hours = string.format("%02.f", math.floor(v/3600))
  local mins = string.format("%02.f", math.floor(v/60 - (hours*60)))
  local secs = string.format("%02.f", math.floor(math.fmod(v, 60)))

  local final = string.format('%s:%s%s',hours,mins,seconds and ":"..secs or "")
 return final
end
local uptime
sessionTime = function()
  uptime = math.floor((now - launchTime)/1000)
  return niceTimeFormat(uptime)
end
sessionTime()

local expPerHour = function(calculation)
  if #expTable == 0 then
      return calculation and 0 or "-"
  end

  -- expTable holds samples from the last 15 minutes
  local r = exp() - expTable[1].e
  local seconds = (now - expTable[1].t) / 1000
  if seconds <= 0 then
      r = 0
  else
      r = math.ceil((r/seconds)*60*60)
  end
  if calculation then
      return r
  else
      return format_thousand(r)
  end
end

local function add(t, text, color, last)
    table.insert(t, text)
    table.insert(t, color)
    if not last then
        table.insert(t, ", ")
        table.insert(t, "#FFFFFF")
    end
end

-- Bot Server
local function sendData()
  if BotServer._websocket then
    local totalDmg, totalHeal, lootWorth, wasteWorth, balance = getHuntingData()
    local outfit = player:getOutfit()
    outfit.mount = 0
    local t = {
      totalDmg, 
      totalHeal, 
      balance, 
      hppercent(), 
      manapercent(), 
      outfit, 
      player:isPartyLeader(), 
      lootWorth, 
      wasteWorth,
      modules.game_skills.skillsWindow.contentsPanel.stamina.value:getText(),
      format_thousand(expGained()),
      expPerHour(),
      balanceDesc .. " (" .. hourDesc .. ")",
      sessionTime()
    }

    -- always send, members without data for 10s are shown as inactive
    BotServer.send("partyHunt", t)
  end
end

-- process data
if BotServer._websocket then
  BotServer.listen("partyHunt", function(name, message)
    if message == true then
      sendData()
    elseif message == false then
      resetAnalyzerSessionData()
    else
      membersData[name] = {
        damage = message[1], 
        heal = message[2], 
        balance = message[3], 
        hp = message[4], 
        mana = message[5], 
        outfit = message[6], 
        leader = message[7], 
        loot = message[8], 
        waste = message[9],
        stamina = message[10],
        expGained = message[11],
        expH = message[12],
        balanceH = message[13],
        session = message[14]
      }

      local widgetName = "Widget"..name
      local widget = partyHuntWindow.contentsPanel[widgetName] or UI.createWidget("MemberWidget", partyHuntWindow.contentsPanel)
      widget:setId(widgetName)
      widget.lastUpdate = now


      local t = membersData[name]
      widget.name:setText(name)
      widget.name:setColor("white")
      if t.leader then
        widget.name:setColor('#f8db38')
      end
      schedule(10*1000, function()
        if widget and widget.lastUpdate and now - widget.lastUpdate > 10000 then
          widget.name:setText(widget.name:getText().. " [inactive]")
          widget.name:setColor("#aeaeae")
          widget.health:setBackgroundColor("#aeaeae")
          widget.mana:setBackgroundColor("#aeaeae")
          widget.balance.value:setText("-")
          widget.damage.value:setText("-")
          widget.healing.value:setText("-")
          widget.creature:disable()
        end
      end)
      widget.creature:setOutfit(t.outfit)
      widget.health:setPercent(t.hp)
      widget.health:setBackgroundColor("#00c000")
      widget.mana:setPercent(t.mana)
      widget.mana:setBackgroundColor("#0000FF")
      widget.balance.value:setText(format_thousand(t.balance))
      if t.balance < 0 then
        widget.balance.value:setColor('#ff9854')
      elseif t.balance > 0 then
        widget.balance.value:setColor('#45ad25')
      else
        widget.balance.value:setColor('white')
      end
      widget.damage.value:setText(format_thousand(t.damage))
      widget.healing.value:setText(format_thousand(t.heal))

      widget.onDoubleClick = function()
        membersData[name] = nil
        widget:destroy()
      end

      --tooltip
      local tooltip = "Session: "..t.session.."\n"..
                      "Stamina: "..t.stamina.."\n"..
                      "Exp Gained: "..t.expGained.."\n"..
                      "Exp per Hour: "..t.expH.."\n"..
                      "Balance: "..t.balanceH

      widget.creature:setTooltip(tooltip)
    end
  end)
end


function hightlightText(widget, color, duration)
  for i=0,duration do
    schedule(i * 250, function()
      if i == duration or (i > 0 and i % 2 == 0) then
        widget:setColor("#FFFFFF")
      else
        widget:setColor(color)
      end
    end)
  end
end

local nameRegex = [[Loot of (?:an |a |the |)([^:]+)]]
onTextMessage(function(mode, text)
    if not text:find("Loot of") and not text:find("The following items are available in your reward chest") then return end
    local rawText = text
    -- 12.x servers send items as {id|name}, keep only the name
    text = text:gsub("{%d+|([^}]*)}", "%1")
    local name = "reward chest"

    -- adding monster to killed list
    if text:find("Loot of") then
      local re = regexMatch(text, nameRegex)
      name = re[1] and re[1][2] or "unknown creature"
      if not killList[name] then
        killList[name] = 1
      else
        killList[name] = killList[name] + 1
      end
      refreshKills()
    end
    -- variables
    local split = string.split(text, ":")
    if not split[2] then return end
    local re = regexMatch(split[2], regex)
    local combinedWorth = 0
    local formatted
    local div
    local t = {}
    local messageT = {}

    -- add timestamp, creature part and color it as white
    add(t, os.date('%H:%M') .. ' ' .. split[1]..": ", "#FFFFFF", true)
    add(messageT, split[1]..": ", "#FFFFFF", true)    

    -- main part
    if re ~= 0 then
        for i=1,#re do
            local data = re[i][2] -- each looted item
            local formattedLoot = regexMatch(data, [[(^[^(]+)]])[1][1]
            formattedLoot = formattedLoot:trim()
            local amount = getFirstNumberInText(formattedLoot) -- amount found in data
            local price = amount and getPrice(formattedLoot) * amount or getPrice(formattedLoot) -- if amount then multity price, else just take price
            local color = getColor(price) -- generate hex string based off price
            local messageColor = getColor(getPrice(formattedLoot))

            combinedWorth = combinedWorth + price -- add all prices to calculate total worth

            add(t, data, color, i==#re)
            add(messageT, data, color, i==#re)

            --drop tracker
            for i, child in ipairs(dropTrackerWindow.contentsPanel:getChildren()) do
              local childName = child.name
              childName = childName and childName:getText()
              local trackedId = child.item and tostring(child.item:getItemId())
              local lootName = formatStr(formattedLoot):lower()

              -- prefix match keeps plurals ("gold coins") but not "giant sword" for "sword"
              if childName and trackedLoot[trackedId] and lootName:sub(1, #childName) == childName:lower() then
                trackedLoot[tostring(child.item:getItemId())] = trackedLoot[tostring(child.item:getItemId())] + (amount or 1)
                child.drops:setText("Loot Drops: "..trackedLoot[tostring(child.item:getItemId())])

                hightlightText(child.name,"#f0b400", 8)
                modules.game_textmessage.messagesPanel.statusLabel:setVisible(true)
                modules.game_textmessage.messagesPanel.statusLabel:setColoredText({
                  "Valuable loot: ", "#f0b400",
                  childName.."", messageColor,
                  " dropped by "..name.."!", "#f0b400"
                })
                schedule(3000, function()
                  modules.game_textmessage.messagesPanel.statusLabel:setVisible(false)
                end)
              end
            end
        end
    end

    -- format total worth so it wont look obnoxious
    if combinedWorth >= 1000000 then
        div = combinedWorth/1000000
        formatted = math.floor(div) .. "." .. math.floor(div * 10) % 10 .. "kk"
    elseif combinedWorth >= 1000 then
        div = combinedWorth/1000
        formatted = math.floor(div) .. "." .. math.floor(div * 10) % 10 .. "k"
    else
        formatted = combinedWorth .. "gp"
    end

    if modules.game_textmessage.messagesPanel.centerTextMessagePanel.highCenterLabel:getText() == rawText then
      modules.game_textmessage.messagesPanel.centerTextMessagePanel.highCenterLabel:setColoredText(messageT)
      schedule(math.max(#text * 50, 2000), function() 
        modules.game_textmessage.messagesPanel.centerTextMessagePanel.highCenterLabel:setVisible(false)
      end)
    end

    -- the rest only writes to the loot channel
    if not storage.analyzers.lootChannel then return end

    -- add total worth to string
    add(t, " - (", "#FFFFFF", true)
    add(t, formatted, getColor(combinedWorth), true)
    add(t, ")", "#FFFFFF", true)

    -- get/create tab and write raw message
    local tabName = "vBot Loot"
    local tab = console.getTab(tabName) or console.addTab(tabName, true)
    console.addText(text, console.SpeakTypesSettings, tabName, "")

    -- find last message in given tab and rewrite it with formatted string
    local panel = console.consoleTabBar:getTabPanel(tab)
    local consoleBuffer = panel:getChildById('consoleBuffer')
    local message = consoleBuffer:getLastChild()
    message:setColoredText(t)
end)

local function niceFormat(v)
  local div
  local formatted
    if v >= 10000000 then
      div = v/10000000
      formatted = math.ceil(div) .. "M"
    elseif v >= 1000000 then
      div = v/1000000
      formatted = math.floor(div) .. "." .. math.floor(div * 10) % 10 .. "M"
    elseif v >= 10000 then
      div = v/1000
      formatted = math.floor(div) .. "k"
    elseif v >= 1000 then
        div = v/1000
        formatted = math.floor(div) .. "." .. math.floor(div * 10) % 10 .. "k"
    else
        formatted = v
    end
    return formatted
end

resetAnalyzerSessionData = function()
    vBot.CaveBotData = {
      refills = 0,
      rounds = 0,
      time = {},
      lastRefill = os.time(),
      refillTime = {}
    }
    launchTime = now
    startExp = exp()
    dmgTable = {}
    healTable = {}
    expTable = {}
    totalDmg = 0
    totalHeal = 0
    dmgDistribution = {}
    first = {l="-", r="0"}
    second = {l="-", r="0"}
    third = {l="-", r="0"}
    fourth = {l="-", r="0"}
    five = {l="-", r="0"}
    lootedItems = {}
    useData = {}
    usedItems ={}
    bestDPS = 0
    bestHPS = 0
    lastCap = freecap()
    refreshLoot()
    refreshWaste()
    xpGraph:clear()
    drawGraph(xpGraph, 0)
    lootGraph:clear()
    drawGraph(lootGraph, 0)
    supplyGraph:clear()
    drawGraph(supplyGraph, 0)
    dmgGraph:clear()
    drawGraph(dmgGraph, 0)
    healGraph:clear()
    drawGraph(healGraph, 0)
    killList = {}
    refreshKills()
    HuntingSessionStart = os.date('%Y-%m-%d, %H:%M:%S')
end

mainWindow.contentsPanel.ResetSession.onClick = function()
  resetAnalyzerSessionData()
end

mainWindow.contentsPanel.Settings.onClick = function()
  settingsWindow:show()
  settingsWindow:raise()
  settingsWindow:focus()
end
  

-- extras window
settingsWindow.closeButton.onClick = function()
  settingsWindow:hide()
end

local function getFrame(v)
  if v >= 1000000 then
      return '/images/ui/rarity_gold'
  elseif v >= 100000 then
      return '/images/ui/rarity_purple'
  elseif v >= 10000 then
      return '/images/ui/rarity_blue'
  elseif v >= 1000 then
      return '/images/ui/rarity_green'
  else
      return '/images/ui/item'
  end
end


displayCondition = function(menuPosition, lookThing, useThing, creatureThing)
  if lookThing and not lookThing:isCreature() and not lookThing:isNotMoveable() and lookThing:isPickupable() then
    return true
  end
end
local interface = modules.game_interface

local function clearFrames()
  for _, container in pairs(getContainers()) do
    for i, child in pairs(container.itemsPanel:getChildren()) do
      child:setImageSource("/images/ui/item")
    end
  end
end

local function setFrames()
  if not storage.analyzers.rarityFrames then return end
  for _, container in pairs(getContainers()) do
      local window = container.itemsPanel
      for i, child in pairs(window:getChildren()) do
          local id = child:getItemId()
          local price = 0

          if id ~= 0 then -- there's item
              local item = Item.create(id)
              local name = item:getMarketData().name:lower()
              price = getPrice(name)

              -- set rarity frame
              child:setImageSource(getFrame(price))
          else -- empty widget
              -- revert any possible changes
              child:setImageSource("/images/ui/item")
          end
          child.onHoverChange = function(widget, hovered)
            if id == 0 or not hovered then
              return interface.removeMenuHook('analyzer')
            end
            interface.addMenuHook('analyzer', 'Price:', function() end, displayCondition, price)          
        end
      end
  end 
end 
setFrames()

-- looting fires many events at once, redraw the frames once per batch
local framesScheduled = false
local function requestFrames()
  if framesScheduled or not storage.analyzers.rarityFrames then return end
  framesScheduled = true
  schedule(100, function()
    framesScheduled = false
    setFrames()
  end)
end

onContainerOpen(function(container, previousContainer)
  requestFrames()
end)

onAddItem(function(container, slot, item, oldItem)
  requestFrames()
end)

onRemoveItem(function(container, slot, item)
  requestFrames()
end)

onContainerUpdateItem(function(container, slot, item, oldItem)
  requestFrames()
end)

function smallNumbers(n)
  if n >= 10 ^ 6 then
      return string.format("%.1fkk", n / 10 ^ 6)
  elseif n >= 10 ^ 3 then
      return string.format("%.1fk", n / 10 ^ 3)
  else
      return tostring(n)
  end
end

function refreshList()
  local list = settingsWindow.CustomPrices
  list:destroyChildren()

  for name, price in pairs(storage.analyzers.customPrices) do
    local label = UI.createWidget("AnalyzerPriceLabel", list)
    label.remove.onClick = function()
      storage.analyzers.customPrices[name] = nil
      label:destroy()
      schedule(5, function()
        setFrames()
      end)
    end
    label:setText("["..name.."] = "..smallNumbers(price).." gp")
  end
end
refreshList()

settingsWindow.addItem.onClick = function()
  local newPrices = storage.analyzers.customPrices
  local id = settingsWindow.ID:getItemId()
  local newPrice = tonumber(settingsWindow.NewPrice:getText())

  if id < 100 then
    return warn("No item added!")
  end

  if not newPrice then
    return warn("Enter a price first!")
  end

  -- getPrice() looks names up in lower case
  local name = Item.create(id):getMarketData().name:lower()

  if newPrices[name] then
    return warn("Item already added! Remove it from the list to set a new price!")
  end

  newPrices[name] = newPrice
  settingsWindow.ID:setItemId(0)
  settingsWindow.NewPrice:setText(0)
  schedule(5, function()
    setFrames()
  end)
  refreshList()
end

settingsWindow.LootChannel:setOn(storage.analyzers.lootChannel)
settingsWindow.LootChannel.onClick = function(widget)
  storage.analyzers.lootChannel = not storage.analyzers.lootChannel
  widget:setOn(storage.analyzers.lootChannel)
end

settingsWindow.RarityFrames:setOn(storage.analyzers.rarityFrames)
settingsWindow.RarityFrames.onClick = function(widget)
  storage.analyzers.rarityFrames = not storage.analyzers.rarityFrames
  widget:setOn(storage.analyzers.rarityFrames)
  if storage.analyzers.rarityFrames then
    setFrames()
  else
    clearFrames()
  end
end

local timeToLevel = function()
    local t = 0
    if expPerHour(true) <= 0 then
        return "-"
    else
        t = expLeft()/expPerHour(true)
        return niceTimeFormat(math.ceil(t*60*60))
    end
end

local sumT = function(t)
    local s = 0
    for i,v in pairs(t) do
        s = s + v.d
    end
    return s
end

local valueInSeconds = function(t)
    local d = 0
    local time = 0
    if #t > 0 then
        for i, v in ipairs(t) do
            if now - v.t <= 3000 then
                if time == 0 then
                    time = v.t
                end
                d = d + v.d
            else
              table.remove(t, 1)
            end
        end
    end
    return math.ceil(d/((now-time)/1000))
end

local regex = [[You lose ([0-9]+) hitpoints? due to an attack by (?:an |a |the )?([^.]+)]]
onTextMessage(function(mode, text)
  local value = getFirstNumberInText(text)
    if mode == 21 then -- damage dealt
      totalDmg = totalDmg + value
        table.insert(dmgTable, {d = value, t = now})
        if value > storage.bestHit then
            storage.bestHit = value
        end
    end
    if mode == 23 then -- healing
      totalHeal = totalHeal + value
        table.insert(healTable, {d = value, t = now})
        if value > storage.bestHeal then
            storage.bestHeal = value
        end
    end

    -- damage distribution part
    if text:find("You lose") then
      local data = regexMatch(text, regex)[1]
      if data then
        local monster = data[3]:lower()
        local val = tonumber(data[2]) or 0
        table.insert(dmgDistribution, {v=val,m=monster,t=now})
      end
    end
end)

function capitalFistLetter(str)
  return (string.gsub(str, "^%l", string.upper))
end

-- tables maintance
macro(500, function()
  local dmgFinal = {}
  local labelTable = {}
  local dmgSum = 0
    table.insert(expTable, {e = exp(), t = now})
    while #expTable > 1 and now - expTable[1].t > 15*60*1000 do
        table.remove(expTable, 1)
    end

    while #dmgDistribution > 0 and now - dmgDistribution[1].t > 60*1000*10 do
      table.remove(dmgDistribution, 1)
    end

    for i,v in ipairs(dmgDistribution) do
      dmgSum = dmgSum + v.v
      if not dmgFinal[v.m] then
        dmgFinal[v.m] = v.v
      else
        dmgFinal[v.m] = dmgFinal[v.m] + v.v
      end
    end

    first = dmgFinal[1] or {l="-", r="0"}
    second = dmgFinal[2] or {l="-", r="0"}
    third = dmgFinal[3] or {l="-", r="0"}
    fourth = dmgFinal[4] or {l="-", r="0"}
    five = dmgFinal[5] or {l="-", r="0"}

    for k,v in pairs(dmgFinal) do
      table.insert(labelTable, {m=k, d=tonumber(v)})
    end

    table.sort(labelTable, function(a,b) return a.d > b.d end)

    for i,v in pairs(labelTable) do
      local val = math.floor((v.d/dmgSum)*100) .. "%"
      local words = string.split(v.m, " ")
      local name = ""
      for i, word in ipairs(words) do
        name = name .. " " .. capitalFistLetter(word)
      end
      name = name:len() < 20 and name or name:sub(1,17).."..."
      name = name:trim()..": "
      if i == 1 then
        first = {l=name, r=val}
      elseif i == 2 then
        second = {l=name, r=val}
      elseif i == 3 then
        third = {l=name, r=val}
      elseif i == 4 then
        fourth = {l=name, r=val}
      elseif i == 5 then
        five = {l=name, r=val}
      else
        break
      end
    end
end)

function getPanelHeight(panel)

  local elements = panel.List:getChildCount()
  if elements == 0 then
    return 0
  else
    local rows = math.ceil(elements/5)
    local height = rows * 35
    return height
  end
end

function refreshLoot()

    lootItems:destroyChildren()
    lootList:destroyChildren()

    for k,v in pairs(lootedItems) do
      local label1 = UI.createWidget("AnalyzerLootItem", lootItems)
      local price = v.count and getPrice(v.name) * v.count or getPrice(v.name)

      label1:setItemId(k)
      label1:setItemCount(50)
      label1:setShowCount(false)
      label1.count:setText(niceFormat(v.count))
      label1.count:setColor(getColor(price))
      local tooltipName = v.count > 1 and v.name.."s" or v.name
      label1:setTooltip(v.count .. "x " .. tooltipName .. " (Value: "..format_thousand(getPrice(v.name)).."gp, Sum: "..format_thousand(price).."gp)")
      --hunting window loot list
      local label2 = UI.createWidget("ListLabel", lootList)
      label2:setText(v.count .. "x " .. v.name)
    end

    if lootItems:getChildCount() == 0 then
      local label = UI.createWidget("ListLabel", lootList)
      label:setText("None")
    end
end
refreshLoot()

function refreshKills()
    killedList:destroyChildren()
    local kills = 0
    for k,v in pairs(killList) do
      kills = kills + 1
      local label = UI.createWidget("ListLabel", killedList)
      label:setText(v .. "x " .. k)
    end

    if kills == 0 then
      local label = UI.createWidget("ListLabel", killedList)
      label:setText("None")
    end
end
refreshKills()

function refreshWaste()

    supplyItems:destroyChildren()
    suppliesByRefill:destroyChildren()
    suppliesByRound:destroyChildren()

    local parents = {supplyItems, suppliesByRound, suppliesByRefill}    

    for k,v in pairs(usedItems) do
      for i=1,#parents do
        local amount = i == 1 and v.count or 
                       i == 2 and v.count/(vBot.CaveBotData.rounds + 1) or 
                       i == 3 and v.count/(vBot.CaveBotData.refills + 1)
        amount = math.floor(amount)
        local label1 = UI.createWidget("AnalyzerLootItem", parents[i])
        local price = amount and getPrice(v.name) * amount or getPrice(v.name)
        label1.amount = amount

        label1:setItemId(k)
        label1:setItemCount(50)
        label1:setShowCount(false)
        label1.count:setText(niceFormat(amount))
        label1.count:setColor(getColor(price))
        local tooltipName = amount > 1 and v.name.."s" or v.name
        label1:setTooltip(amount .. "x " .. tooltipName .. " (Value: "..format_thousand(getPrice(v.name)).."gp, Sum: "..format_thousand(price).."gp)")
      end
    end
end

-- loot analyzer
-- adding
local containers = CaveBot.GetLootContainers()
macro(5000, function()
  containers = CaveBot.GetLootContainers()
end)

-- without CaveBot loot containers every container counts, the cap check filters out non-loot
local function isLootContainer(container)
  if #containers == 0 then return true end
  local containerItem = container:getContainerItem()
  return containerItem and table.find(containers, containerItem:getId())
end

-- Canary quick loot can put loot in the Loot pouch in the Store Inbox, which weighs nothing,
-- so loot there is counted without the cap check (only while the pouch is open)
local function isLootPouch(container)
  local containerItem = container:getContainerItem()
  if containerItem and containerItem:getId() == 23721 then return true end
  local cName = container:getName():lower()
  return cName == "loot pouch" or cName == "loot bag"
end

onAddItem(function(container, slot, item, oldItem)
  local pouch = isLootPouch(container)
  if not pouch and not isLootContainer(container) then return end
  if isInPz() then return end
  if slot > 0 then return end 
  if not pouch and freecap() >= lastCap then return end
  local name = item:getId()
  local tmpname = item:getId() == 3031 and "gold coin" or item:getId() == 3035 and "platinum coin" or item:getId() == 3043 and "crystal coin" or item:getMarketData().name
  if not lootedItems[name] then
    lootedItems[name] = { count = item:getCount(), name = tmpname }
  else
    lootedItems[name].count =  lootedItems[name].count + item:getCount()
  end
  lastCap = freecap()
  refreshLoot()

  -- drop tracker
end)

onContainerUpdateItem(function(container, slot, item, oldItem)
  local pouch = isLootPouch(container)
  if not pouch and not isLootContainer(container) then return end
  if not oldItem then return end
  if isInPz() then return end 
  if not pouch and freecap() == lastCap then return end
  
  local tmpname = item:getId() == 3031 and "gold coin" or item:getId() == 3035 and "platinum coin" or item:getId() == 3043 and "crystal coin" or item:getMarketData().name
  local amount = item:getCount() - oldItem:getCount()
  if amount < 0 then
    return
  end
  local name = item:getId()
  if not lootedItems[name] then
      lootedItems[name] = { count = amount, name = tmpname }
  else
      lootedItems[name].count = lootedItems[name].count + amount
  end
  lastCap = freecap()
  refreshLoot()
end)

-- ammo
local ammo = {16143, 763, 761, 7365, 3448, 762, 21470, 7364, 14251, 3447, 3449, 15793, 25757, 774, 35901, 6528, 7363, 3450, 16141, 25758, 14252, 3446, 16142, 35902}
local function countAmmo(item, oldItem)
  if not item or not oldItem then return end
  local id = item:getId()
  if id ~= oldItem:getId() or not table.find(ammo, id) then return end

  if oldItem:getCount() - item:getCount() == 1 then
    if not usedItems[id] then
      usedItems[id] = { count = 1, name = oldItem:getMarketData().name }
    else
      usedItems[id].count = usedItems[id].count + 1
    end
    refreshWaste()
  end
end

onContainerUpdateItem(function(container, slot, item, oldItem)
  countAmmo(item, oldItem)
end)

-- arrows/bolts in the ammo slot (no quiver)
onInventoryChange(function(player, slot, item, oldItem)
  if slot ~= InventorySlotAmmo then return end
  countAmmo(item, oldItem)
end)

-- waste
local regex3 = [[\d ([a-z A-Z]*)s...]]
local regexLast = [[using the last ([a-z A-Z]*)\.]]
local lackOfData = {}
onTextMessage(function(mode, text)
  text = text:lower()
  local last = text:find("using the last")
  if not text:find("using one of") and not last then return end

  local amount = last and 0 or getFirstNumberInText(text)
  local re = regexMatch(text, last and regexLast or regex3)
  local name = re and re[1] and re[1][2]
  if not name then return end
  local id = WasteItems[name]

  if not id then

    if not lackOfData[name] then
      lackOfData[name] = true
      print("[Analyzer] no data for item: "..name.. "inside items.lua -> WasteItems")
    end

    return
  end

  -- every message is one item used, the same amount twice in a row is a repeated message
  if useData[name] == amount then return end
  useData[name] = amount
  if not usedItems[id] then
    usedItems[id] = { count = 1, name = name}
  else
    usedItems[id].count = usedItems[id].count + 1
  end
  refreshWaste()
end)

function hourVal(v)
  v = v or 0
  if not uptime or uptime <= 0 then return 0 end
  return (v/uptime)*3600
end

function bottingStats()
  lootWorth = 0
  wasteWorth = 0
  for k, v in pairs(lootedItems) do
    lootWorth = lootWorth + (getPrice(v.name)*v.count)
  end
  for k, v in pairs(usedItems) do
    wasteWorth = wasteWorth + (getPrice(v.name)*v.count)
  end
  balance = lootWorth - wasteWorth

  return lootWorth, wasteWorth, balance
end

-- 1234567 -> "1.2kk", -1500 -> "-1.5k", sign is kept apart so floor doesn't round negatives down
local function shortValue(v, unit)
  local sign = v < 0 and "-" or ""
  local a = math.abs(v)
  local div, suffix
  if a >= 1000000 then
    div, suffix = a / 1000000, "kk"
  elseif a >= 1000 then
    div, suffix = a / 1000, "k"
  else
    return sign .. math.floor(a) .. "gp" .. unit
  end
  return sign .. math.floor(div) .. "." .. math.floor(div * 10) % 10 .. suffix .. unit
end

function bottingLabels(lootWorth, wasteWorth, balance)
  hour = hourVal(balance)
  balanceDesc = shortValue(balance, "")
  hourDesc = shortValue(hour, "/h")

  return balanceDesc, hourDesc
end

function reportStats()
  local lootWorth, wasteWorth, balance = bottingStats()
  local balanceDesc, hourDesc = bottingLabels(lootWorth, wasteWorth, balance)

  local a, b, c

  a = "Session Time: " .. sessionTime() .. ", Exp Gained: " .. format_thousand(expGained()) .. ", Exp/h: " .. expPerHour()
  b = " | Balance: " .. balanceDesc .. " (" .. hourDesc .. ")"
  c = a..b

  return c
end

function damageHour()
  if uptime < 5*60 then
    return totalDmg
  else
    return hourVal(totalDmg)
  end
end

function healHour()
  if uptime < 5*60 then
    return totalHeal
  else
    return hourVal(totalHeal)
  end
end

function wasteHour()
  local lootWorth, wasteWorth, balance = bottingStats()
  if uptime < 5*60 then
    return wasteWorth
  else
    return hourVal(wasteWorth)
  end
end


function lootHour()
  local lootWorth, wasteWorth, balance = bottingStats()
  if uptime < 5*60 then
    return lootWorth
  else
    return hourVal(lootWorth)
  end
end

function getHuntingData()
  local lootWorth, wasteWorth, balance = bottingStats()
  return totalDmg, totalHeal, lootWorth, wasteWorth, balance
end

function avgTable(t)
  if type(t) ~= 'table' then return 0 end
  local val = 0

  for i,v in pairs(t) do
    val = val + v
  end

  if #t == 0 then
    return 0
  else
    return val/#t
  end
end

--main loop
macro(500, function()
    -- cap can go up (potions used, items dropped) without loot, keep the reference fresh
    lastCap = math.max(lastCap, freecap())

    local lootWorth, wasteWorth, balance = bottingStats()
    local balanceDesc, hourDesc = bottingLabels(lootWorth, wasteWorth, balance)

    -- hps and dps
    local curHPS = valueInSeconds(healTable)
    local curDPS = valueInSeconds(dmgTable)

    bestHPS = bestHPS > curHPS and bestHPS or curHPS
    bestDPS = bestDPS > curDPS and bestDPS or curDPS

    --hunt window
    sessionTimeLabel:setText(sessionTime())
    xpGainLabel:setText(format_thousand(expGained()))
    xpHourLabel:setText(expPerHour())
    lootLabel:setText(format_thousand(lootWorth))
    suppliesLabel:setText(format_thousand(wasteWorth))
    balanceLabel:setColor(balance >= 0 and "#45ad25" or "#ff9854")
    balanceLabel:setText(balanceDesc .. " (" .. hourDesc .. ")")
    damageLabel:setText(format_thousand(totalDmg))
    damageHourLabel:setText(format_thousand(damageHour()))
    healingLabel:setText(format_thousand(totalHeal))
    healingHourLabel:setText(format_thousand(healHour()))

    --loot window
    lootInLootAnalyzerLabel:setText(format_thousand(lootWorth))
    lootHourInLootAnalyzerLabel:setText(format_thousand(lootHour()))


    --supply window
    suppliesInSuppliesAnalyzerLabel:setText(format_thousand(wasteWorth))
    suppliesHourInSuppliesAnalyzerLabel:setText(format_thousand(wasteHour()))

    --impact window
    totalDamageLabel:setText(format_thousand(totalDmg))
    maxDpsLabel:setText(format_thousand(bestDPS))
    bestHitLabel:setText(storage.bestHit)

    top1.left:setText(first.l)
    top1.right:setText(first.r)
    top2.left:setText(second.l)
    top2.right:setText(second.r)
    top3.left:setText(third.l)
    top3.right:setText(third.r)
    top4.left:setText(fourth.l)
    top4.right:setText(fourth.r)
    top5.left:setText(five.l)
    top5.right:setText(five.r)

    totalHealingLabel:setText(format_thousand(totalHeal))
    maxHpsLabel:setText(format_thousand(bestHPS))
    bestHealLabel:setText(storage.bestHeal)

    --xp window
    xpGrainInXpLabel:setText(format_thousand(expGained()))
    xpHourInXpLabel:setText(expPerHour())
    nextLevelLabel:setText(timeToLevel())
    progressBar:setPercent(modules.game_skills.skillsWindow.contentsPanel.level.percent:getPercent())


    --stats
    totalRounds:setText(vBot.CaveBotData.rounds)
    avRoundTime:setText(niceTimeFormat(avgTable(vBot.CaveBotData.time),true))
    totalRefills:setText(vBot.CaveBotData.refills)
    avRefillTime:setText(niceTimeFormat(avgTable(vBot.CaveBotData.refillTime),true))
    lastRefill:setText(niceTimeFormat(os.difftime(os.time()-vBot.CaveBotData.lastRefill),true))

end)

--graphs, draw each minute
macro(60*1000, function()

  drawGraph(xpGraph, expPerHour(true) or 0)
  drawGraph(lootGraph, lootHour() or 0)
  drawGraph(supplyGraph, wasteHour() or 0)
  drawGraph(dmgGraph, valueInSeconds(dmgTable) or 0)
  drawGraph(healGraph, valueInSeconds(healTable) or 0)
end)

--party hunt analyzer
macro(2000, function()
  if not BotServer._websocket then return end

  -- send data
  if storage.sendPartyAnalyzerData then
    sendData()
  end

  local totalWaste, totalLoot, totalBalance = getSumStats()

  partySessionTimeLabel:setText(sessionTime())
  partyLootLabel:setText(format_thousand(totalLoot))
  partySuppliesLabel:setText(format_thousand(totalWaste))
  partyBalanceLabel:setText(format_thousand(totalBalance))

  if totalBalance < 0 then
    partyBalanceLabel:setColor('#ff9854')
  elseif totalBalance > 0 then
    partyBalanceLabel:setColor('#45ad25')
  else
    partyBalanceLabel:setColor('white')
  end

  for bossName, dueTime in pairs(storage.analyzers.trackedBoss) do
    createBossPanel(bossName, dueTime)
  end
end)

-- public functions
-- global namespace
Analyzer = {}

Analyzer.getKillsAmount = function(name)
  return killList[name] or 0
end

Analyzer.getLootedAmount = function(nameOrId)
  if type(nameOrId) == "number" then
    return lootedItems[nameOrId] and lootedItems[nameOrId].count or 0
  else
    local nameOrId = nameOrId:lower()
    for k,v in pairs(lootedItems) do
      if v.name == nameOrId then
        return v.count
      end
    end
  end
  return 0
end

Analyzer.getTotalProfit = function()
  local lootWorth, wasteWorth, balance = bottingStats()

  return lootWorth
end

Analyzer.getTotalWaste = function()
  local lootWorth, wasteWorth, balance = bottingStats()

  return wasteWorth
end

Analyzer.getBalance = function()
  local lootWorth, wasteWorth, balance = bottingStats()

  return balance
end

Analyzer.getXpGained = function()
  return expGained()
end

Analyzer.getXpHour = function()
  return expPerHour()
end

Analyzer.getTimeToNextLevel = function()
  return timeToLevel()
end

Analyzer.getCaveBotStats = function()
  local parents = {suppliesByRound, suppliesByRefill}
  local round = {}
  local refill = {}
  for i=1,2 do
    local data = parents[i]
    for j, child in ipairs(data:getChildren()) do
      local id = child:getItemId()
      local count = child.amount or 0

      if i == 1 then
        round[id] = count
      else
        refill[id] = count
      end
    end
  end

  return {
    totalRounds = totalRounds:getText(),
    avRoundTime = avRoundTime:getText(),
    totalRefills = totalRefills:getText(),
    avRefillTime = avRefillTime:getText(),
    lastRefill = lastRefill:getText(),
    roundSupplies = round, -- { [id] = amount, [id2] = amount ...}
    refillSupplies = refill -- { [id] = amount, [id2] = amount ...}
  }
end