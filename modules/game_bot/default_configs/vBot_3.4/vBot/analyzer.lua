setDefaultTab("Main")
-- first, the variables
local launchTime = now
local startExp = exp()
local dmgTable = {}
local healTable = {}
local expTable = {}
local totalDmg = 0
local totalHeal = 0
local dmgDistribution = {}
local first = "-"
local second = "-"
local third = "-"
local bestHit = 0
local bestHeal = 0
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
    first = "-"
    second = "-"
    third = "-"
    bestHit = 0
    bestHeal = 0
    lootedItems = {}
    useData = {}
    usedItems ={}
    refreshLoot()
    refreshWaste()
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
    if mode == 21 then -- damage dealt
      totalDmg = totalDmg + getFirstNumberInText(text)
        table.insert(dmgTable, {d = getFirstNumberInText(text), t = now})
        if getFirstNumberInText(text) > bestHit then
            bestHit = getFirstNumberInText(text)
        end
    end
    if mode == 23 then -- healing
      totalHeal = totalHeal + getFirstNumberInText(text)
        table.insert(healTable, {d = getFirstNumberInText(text), t = now})
        if getFirstNumberInText(text) > bestHeal then
            bestHeal = getFirstNumberInText(text)
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

    if not dmgFinal[1] then
      first = "-"
    end
    if not dmgFinal[2] then
      second = "-"
    end
    if not dmgFinal[3] then
      third = "-"
    end

    local iter = 0
    for k,v in pairs(dmgFinal) do
      table.insert(labelTable, {m=k, d=tonumber(v)})
    end

    table.sort(labelTable, function(a,b) return a.d > b.d end)

    for i,v in pairs(labelTable) do
      local label = v.m .. ": " .. math.floor((v.d/dmgSum)*100) .. "%"
      if i == 1 then
        first = label
      elseif i == 2 then
        second = label
      elseif i == 3 then
        third = label
      end
    end
end)

-- visuals
UI.Separator()
local main = UI.createWidget("MainAnalyzer")
local ui = UI.createWidget("HuntingAnalyzer")
local ui2 = UI.createWidget("LootAnalyzer")
ui:hide()
ui2:hide()

function refreshLoot()
  for i, child in pairs(ui2.List:getChildren()) do
    child:destroy()
  end

  for k,v in pairs(lootedItems) do
    local label = g_ui.createWidget("LootItemLabel", ui2.List)
    label:setText(v .. "x " .. k)
  end
end

function refreshWaste()
  for i, child in pairs(ui2.supplyList:getChildren()) do
    child:destroy()
  end

  for k,v in pairs(usedItems) do
    local label = g_ui.createWidget("LootItemLabel", ui2.supplyList)
    label:setText(v .. "x " .. k)
  end

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
  local name = item:getId() == 3031 and "gold coin" or item:getId() == 3035 and "platinum coin" or item:getId() == 3043 and "crystal coin" or item:getMarketData().name

  if not lootedItems[name] then
    lootedItems[name] = item:getCount()
  else
    lootedItems[name] = lootedItems[name] + item:getCount()
  end
  refreshLoot()
end)

onContainerUpdateItem(function(container, slot, item, oldItem)
  if not table.find(containers, container:getContainerItem():getId()) then return end
  if not oldItem then return end
  if isInPz() then return end 
  if freecap() == lastCap then return end
  
  local name = item:getId() == 3031 and "gold coin" or item:getId() == 3035 and "platinum coin" or item:getId() == 3043 and "crystal coin" or item:getMarketData().name
  local amount = item:getCount() - oldItem:getCount()

  if not lootedItems[name] then
    lootedItems[name] = amount
  else
    lootedItems[name] = lootedItems[name] + amount
  end
  refreshLoot()
end)

-- waste
local regex3 = [[\d ([a-z A-Z]*)s...]]
useData = {}
usedItems = {}
onTextMessage(function(mode, text)
  text = text:lower()
  if not text:find("using one of") then return end

  local amount = getFirstNumberInText(text)
  local re = regexMatch(text, regex3)
  local name = re[1][2]

  if not useData[name] then
    useData[name] = amount
  else
    if math.abs(useData[name]-amount) == 1 then
      useData[name] = amount
      if not usedItems[name] then
        usedItems[name] = 1
      else
        usedItems[name] = usedItems[name] + 1
      end
    end
  end
  refreshWaste()
end)

function toggleBetween()
  if ui:isVisible() then
    ui:hide()
    ui2:show()
    main.change:setText("Hunt")
  else
    ui:show()
    ui2:hide()
    main.change:setText("Loot")
  end
end

function hideAll()
  if not ui:isVisible() and not ui2:isVisible() then
    ui:show()
    ui2:hide()
  else
    ui:hide()
    ui2:hide()
  end
end

main.reset.onClick = function(widget)
  resetSessionData()
end
main.toggle.onClick = function(widget)
  hideAll()
end
main.change.onClick = function(widget)
  toggleBetween()
end

function hourVal(v)
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
    if LootItems[k] then
      lootWorth = lootWorth + (LootItems[k]*v)
    end
  end
  for k, v in pairs(usedItems) do
    if LootItems[k] then
      wasteWorth = wasteWorth + (LootItems[k]*v)
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

macro(500, function()
    local lootWorth, wasteWorth, balance = bottingStats()
    local balanceDesc, hourDesc = bottingLabels(lootWorth, wasteWorth, balance)
    -- hunting
    ui.one:setText(sessionTime())
    ui.two:setText(format_thousand(expGained()))
    ui.three:setText(expPerHour())
    ui.four:setText(timeToLevel())
    ui.five:setText(format_thousand(burstDamageValue()))
    ui.six:setText(format_thousand(totalDmg))
    ui.seven:setText(format_thousand(valueInSeconds(dmgTable)))
    ui.eight:setText(format_thousand(bestHit))
    ui.nine:setText(format_thousand(totalHeal))
    ui.ten:setText(format_thousand(valueInSeconds(healTable)))
    ui.eleven:setText(format_thousand(bestHeal))
    ui.dOne:setText(first)
    ui.dTwo:setText(second)
    ui.dThree:setText(third)

    -- loot
    ui2.loot:setText(format_thousand(lootWorth))
    ui2.lootHour:setText(format_thousand(hourVal(lootWorth)))
    ui2.supplies:setText(format_thousand(wasteWorth))
    ui2.suppliesHour:setText(format_thousand(hourVal(wasteWorth)))
    ui.balance:setColor(balance >= 0 and "green" or "red")
    ui.balance:setText(balanceDesc .. " (" .. hourDesc .. ")")
end)

