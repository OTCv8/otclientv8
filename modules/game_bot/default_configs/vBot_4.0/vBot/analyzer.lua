--[[
  Bot-based Tibia 12 features v1.0 
  made by Vithrax

  Credits also to:
  - Martín#2318
  - Lee#7725

  Thanks for ideas, graphics, functions, design tips!
  
  br, Vithrax
]]

local analyzerButton

--destroy old windows
local windowsTable = {"MainAnalyzerWindow", "HuntingAnalyzerWindow", "LootAnalyzerWindow", "SupplyAnalyzerWindow", "ImpactAnalyzerWindow", "XPAnalyzerWindow"}
for i, window in ipairs(windowsTable) do
  local element = g_ui.getRootWidget():recursiveGetChildById(window)

  if element then
    element:destroy()
  end
end

local mainWindow = UI.createMiniWindow("MainAnalyzerWindow")
mainWindow:disableResize()
mainWindow:hide()

local huntingWindow = UI.createMiniWindow("HuntingAnalyzer")
huntingWindow:hide()

local lootWindow = UI.createMiniWindow("LootAnalyzer")
lootWindow:hide()
lootWindow:setContentMaximumHeight(215)

local supplyWindow = UI.createMiniWindow("SupplyAnalyzer")
supplyWindow:hide()
supplyWindow:setContentMaximumHeight(215)

local impactWindow = UI.createMiniWindow("ImpactAnalyzer")
impactWindow:hide()
impactWindow:setContentMaximumHeight(615)

local xpWindow = UI.createMiniWindow("XPAnalyzer")
xpWindow:hide()
xpWindow:setContentMaximumHeight(230)

local settingsWindow = UI.createWindow("FeaturesWindow")
settingsWindow:hide()


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

--hunting
huntingWindow:setContentMaximumHeight(204)
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
    else
        return "#FFFFFF" -- less than 1k, white
    end
end

local function formatStr(str)
    if string.starts(str, "a ") then
        str = str:sub(2, #str)
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

local function add(t, text, color, last)
    table.insert(t, text)
    table.insert(t, color)
    if not last then
        table.insert(t, ", ")
        table.insert(t, "#FFFFFF")
    end
end

onTextMessage(function(mode, text)
    if not storage.analyzers.lootChannel then return end
    if not text:find("Loot of") and not text:find("The following items are available in your reward chest") then return end
    -- variables
    local split = string.split(text, ":")
    local re = regexMatch(split[2], regex)
    local combinedWorth = 0
    local formatted
    local div
    local t = {}

    -- add timestamp, creature part and color it as white
    add(t, os.date('%H:%M') .. ' ' .. split[1]..": ", "#FFFFFF", true)

    -- main part
    if re ~= 0 then
        for i=1,#re do
            local data = re[i][2] -- each looted item
            local amount = getFirstNumberInText(data) -- amount found in data
            local price = amount and getPrice(data) * amount or getPrice(data) -- if amount then multity price, else just take price
            local color = getColor(price) -- generate hex string based off price

            combinedWorth = combinedWorth + price -- add all prices to calculate total worth

            add(t, data, color, i==#re)
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

local resetSessionData = function()
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
end

mainWindow.contentsPanel.ResetSession.onClick = function()
  resetSessionData()
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

if not storage.analyzers then
  storage.analyzers = {
    customPrices = {},
    lootChannel = true,
    rarityFrames = true
  }
end

local function getFrame(v)
  if v > 1000000 then
      return '/images/ui/rarity_gold'
  elseif v > 100000 then
      return '/images/ui/rarity_purple'
  elseif v > 10000 then
      return '/images/ui/rarity_blue'
  elseif v > 1000 then
      return '/images/ui/rarity_green'
  else
      return '/images/ui/item'
  end
end

local function setFrames()
  if not storage.analyzers.rarityFrames then return end
  for _, container in pairs(getContainers()) do
      local window = container.itemsPanel
      for i, child in pairs(window:getChildren()) do
          local id = child:getItemId()

          if id ~= 0 then -- there's item
              local item = Item.create(id)
              local name = item:getMarketData().name:lower()

              local price = getPrice(name)
              -- set rarity frame
              child:setImageSource(getFrame(price))
          else -- empty widget
              -- revert any possible changes
              child:setImageSource("/images/ui/item")
          end
      end
  end 
end 
setFrames()

onContainerOpen(function(container, previousContainer)
  setFrames()
end)

onAddItem(function(container, slot, item, oldItem)
  setFrames()
end)

onRemoveItem(function(container, slot, item)
  setFrames()
end)

onContainerUpdateItem(function(container, slot, item, oldItem)
  setFrames()
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

  local name = Item.create(id):getMarketData().name

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
  setFrames()
end









function format_thousand(v)
    if not v then return 0 end
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos)
    .. string.gsub(string.sub(s, pos+1), "(...)", ".%1")
  end

local expGained = function()
    return exp() - startExp
end
local expLeft = function()
    local level = lvl()+1
    return math.floor((50*level*level*level)/3 - 100*level*level + (850*level)/3 - 200) - exp()
end

local niceTimeFormat = function(v) -- v in seconds
    local hours = string.format("%02.f", math.floor(v/3600))
    local mins = string.format("%02.f", math.floor(v/60 - (hours*60)))
   return hours .. ":" .. mins .. "h"
end
local uptime
local sessionTime = function()
    uptime = math.floor((now - launchTime)/1000)
    return niceTimeFormat(uptime)
end
sessionTime()

local expPerHour = function(calculation)
    local r = 0
    if #expTable > 0 then
        r = exp() - expTable[1]
    else
        return "-"
    end

    if uptime < 15*60 then
        r = math.ceil((r/uptime)*60*60)
    else
        r = math.ceil(r*8)
    end
    if calculation then
        return r
    else
        return format_thousand(r)
    end
end

local timeToLevel = function()
    local t = 0
    if expPerHour(true) == 0 or expPerHour() == "-" then
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

local regex = "You lose ([0-9]*) hitpoints due to an attack by ([a-z]*) ([a-z A-z-]*)" 
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
        local monster = data[4]
        local val = data[2]
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
    table.insert(expTable, exp())
    if #expTable > 15*60 then
        for i,v in pairs(expTable) do
            if i == 1 then
              table.remove(expTable, i)
            end
        end
    end

    for i,v in pairs(dmgDistribution) do
      if now - v.t > 60*1000*10 then
        table.remove(dmgDistribution, i)
      else
        dmgSum = dmgSum + v.v
        if not dmgFinal[v.m] then
          dmgFinal[v.m] = v.v
        else
          dmgFinal[v.m] = dmgFinal[v.m] + v.v
        end
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

    lootItems.List:destroyChildren()
    for k,v in pairs(lootedItems) do
        local label1 = UI.createWidget("AnalyzerLootItem", lootItems.List)
        local price = v.count and getPrice(v.name) * v.count or getPrice(v.name)

        label1:setItemId(k)
        label1:setItemCount(50)
        label1:setShowCount(false)
        label1.count:setText(niceFormat(v.count))
        label1.count:setColor(getColor(price))
        local tooltipName = v.count > 1 and v.name.."s" or v.name
        label1:setTooltip(v.count .. "x " .. tooltipName .. " (Value: "..format_thousand(getPrice(v.name)).."gp, Sum: "..format_thousand(price).."gp)")
    end
    local height = getPanelHeight(lootItems)
    lootItems:setHeight(height)
    lootWindow:setContentMaximumHeight(height+220)
end

function refreshWaste()

    supplyItems.List:destroyChildren()
    for k,v in pairs(usedItems) do
      local label1 = UI.createWidget("AnalyzerLootItem", supplyItems.List)
      local price = v.count and getPrice(v.name) * v.count or getPrice(v.name)

      label1:setItemId(k)
      label1:setItemCount(10023)
      label1:setShowCount(false)
      label1.count:setText(niceFormat(v.count))
      label1.count:setColor(getColor(price))
      local tooltipName = v.count > 1 and v.name.."s" or v.name
      label1:setTooltip(v.count .. "x " .. tooltipName .. " (Value: "..format_thousand(getPrice(v.name)).."gp, Sum: "..format_thousand(price).."gp)")
    end
    local height = getPanelHeight(supplyItems)
    supplyItems:setHeight(height)    
    supplyWindow:setContentMaximumHeight(height+215)
end



-- loot analyzer
-- adding
local containers = CaveBot.GetLootContainers()
local lastCap = freecap()
onAddItem(function(container, slot, item, oldItem)
  if not table.find(containers, container:getContainerItem():getId()) then return end
  if isInPz() then return end
  if slot > 0 then return end 
  if freecap() >= lastCap then return end
  --local name = item:getId() == 3031 and "gold coin" or item:getId() == 3035 and "platinum coin" or item:getId() == 3043 and "crystal coin" or item:getMarketData().name
  local name = item:getId()
  local tmpname = item:getId() == 3031 and "gold coin" or item:getId() == 3035 and "platinum coin" or item:getId() == 3043 and "crystal coin" or item:getMarketData().name
  if not lootedItems[name] then
    lootedItems[name] = { count = item:getCount(), name = tmpname }
  else
    lootedItems[name].count =  lootedItems[name].count + item:getCount()
  end
  lastCap = freecap()
  refreshLoot()
end)

onContainerUpdateItem(function(container, slot, item, oldItem)
  if not table.find(containers, container:getContainerItem():getId()) then return end
  if not oldItem then return end
  if isInPz() then return end 
  if freecap() == lastCap then return end
  
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
onContainerUpdateItem(function(container, slot, item, oldItem)
  local id = item:getId()
  if not table.find(ammo, id) then return end
  local newCount = item:getCount()
  local oldCount = oldItem:getCount()
  local name = item:getMarketData().name

  if oldCount - newCount == 1 then
    if not usedItems[id] then
      usedItems[id] = { count = 1, name = name}
    else
      usedItems[id].count = usedItems[id].count + 1
    end
    refreshWaste()
  end
end)

-- waste
local regex3 = [[\d ([a-z A-Z]*)s...]]
onTextMessage(function(mode, text)
  text = text:lower()
  if not text:find("using one of") then return end

  local amount = getFirstNumberInText(text)
  local re = regexMatch(text, regex3)
  local name = re[1][2]
  local id = WasteItems[name]

  if not useData[name] then
    useData[name] = amount
  else
    if math.abs(useData[name]-amount) == 1 then
      useData[name] = amount
      if not usedItems[id] then
        usedItems[id] = { count = 1, name = name}
      else
        usedItems[id].count = usedItems[id].count + 1
      end
    end
    refreshWaste()
  end
end)

function hourVal(v)
  v = v or 0
  return (v/uptime)*3600
end

local lootWorth 
local wasteWorth
local balance
local balanceDesc
local hourDesc
local desc
local hour


function bottingStats()
  lootWorth = 0
  wasteWorth = 0
  for k, v in pairs(lootedItems) do
    if LootItems[v.name] then
      lootWorth = lootWorth + (LootItems[v.name]*v.count)
    end
  end
  for k, v in pairs(usedItems) do
    if LootItems[v.name] then
      wasteWorth = wasteWorth + (LootItems[v.name]*v.count)
    end
  end
  balance = lootWorth - wasteWorth

  return lootWorth, wasteWorth, balance
end

function bottingLabels(lootWorth, wasteWorth, balance)
  balanceDesc = nil
  hourDesc = nil
  desc = nil

  if balance >= 1000000 or balance <= -1000000 then
    desc = balance / 1000000
    balanceDesc = math.floor(desc) .. "." .. math.floor(desc * 10) % 10 .. "kk"
  elseif balance >= 1000 or balance <= -1000 then
    desc = balance / 1000
    balanceDesc = math.floor(desc) .. "." .. math.floor(desc * 10) % 10 .."k"
  else
    balanceDesc = balance .. "gp"
  end

  hour = hourVal(balance)
  if hour >= 1000000 or hour <= -1000000 then
    desc = balance / 1000000
    hourDesc = math.floor(hourVal(desc)) .. "." .. math.floor(hourVal(desc) * 10) % 10 .. "kk/h"
  elseif hour >= 1000 or hour <= -1000 then
    desc = balance / 1000
    hourDesc = math.floor(hourVal(desc)) .. "." .. math.floor(hourVal(desc) * 10) % 10 .. "k/h"
  else
    hourDesc = math.floor(hourVal(balance)) .. "gp/h"
  end

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

--bestdps/hps
local bestDPS = 0
local bestHPS = 0
--main loop
macro(500, function()
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
    balanceLabel:setColor(balance >= 0 and "green" or "red")
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
end)

--graphs, draw each minute
macro(60*1000, function()

  drawGraph(xpGraph, expPerHour(true) or 0)
  drawGraph(lootGraph, lootHour() or 0)
  drawGraph(supplyGraph, wasteHour() or 0)
  drawGraph(dmgGraph, valueInSeconds(dmgTable) or 0)
  drawGraph(healGraph, valueInSeconds(healTable) or 0)
end)