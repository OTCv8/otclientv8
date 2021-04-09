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

if not storage.bestHit or type(storage.bestHit) ~= "number" then
    storage.bestHit = 0
end
if not storage.bestHeal or type(storage.bestHeal) ~= "number" then
    storage.bestHeal = 0
end

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
local sessionTime = function()
    uptime = math.floor((now - launchTime)/1000)
    return niceTimeFormat(uptime)
end

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

local regex = "You lose ([0-9]*) hitpoints due to an attack by ([a-z*]) ([a-z A-z-]*)" 
onTextMessage(function(mode, text)
    if mode == 21 then -- damage dealt
      totalDmg = totalDmg + getFirstNumberInText(text)
        table.insert(dmgTable, {d = getFirstNumberInText(text), t = now})
        if getFirstNumberInText(text) > storage.bestHit then
            storage.bestHit = getFirstNumberInText(text)
        end
    end
    if mode == 23 then -- healing
      totalHeal = totalHeal + getFirstNumberInText(text)
        table.insert(healTable, {d = getFirstNumberInText(text), t = now})
        if getFirstNumberInText(text) > storage.bestHeal then
            storage.bestHeal = getFirstNumberInText(text)
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

UI.Label("Session Analyzers")
UI.Separator()
UI.Button("Reset Session", function() resetSessionData() end)
UI.Separator()

-- visuals
local ui = setupUI([[
Panel
  height: 270
  padding: 5

  Label
    id: SessionLabel
    anchors.top: parent.top
    anchors.left: parent.left
    text: Session:

  Label
    id: XpGainLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: XP Gain:

  Label
    id: XpHourLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: XP/h:

  Label
    id: NextLevelLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: Next Level:

  Label
    id: BurstDamageLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: Burst Damage: 

  Label
    id: DamageDealtLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: Damage Dealt:

  Label
    id: DPSLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: DPS: 

  Label
    id: BestHitLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: Best Hit:     

  Label
    id: HealingDoneLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: Healing Done: 

  Label
    id: HPSLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: HPS: 

  Label
    id: BestHealLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text: Best Heal:
    
  Label
    id: one
    anchors.right: parent.right
    anchors.verticalCenter: SessionLabel.verticalCenter
    text-align: right
    text: 00:00h
    width: 150

  Label
    id: two
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: 0
    width: 150

  Label
    id: three
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: -
    width: 150

  Label
    id: four
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: -
    width: 150

  Label
    id: five
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: 0
    width: 150

  Label
    id: six
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: -
    width: 150

  Label
    id: seven
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: 0
    width: 150

  Label
    id: eight
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: 0
    width: 150
    
  Label
    id: nine
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: 0
    width: 150

  Label
    id: ten
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: 0
    width: 150

  Label
    id: eleven
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5
    text-align: right
    text: 0
    width: 150
  
  HorizontalSeparator
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 3

  Label
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 3
    text-align: center
    text: Damage Distribution

  Label
    id: dOne
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 5
    text-align: center
    text: -

  Label
    id: dTwo
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 5
    text-align: center
    text: -
    
  Label
    id: dThree
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 5
    text-align: center
    text: -
]])
ui:setId("analyzers")

macro(500, function()
    -- refresh part
    ui.one:setText(sessionTime())
    ui.two:setText(format_thousand(expGained()))
    ui.three:setText(expPerHour())
    ui.four:setText(timeToLevel())
    ui.five:setText(format_thousand(burstDamageValue()))
    ui.six:setText(format_thousand(totalDmg))
    ui.seven:setText(format_thousand(valueInSeconds(dmgTable)))
    ui.eight:setText(format_thousand(storage.bestHit))
    ui.nine:setText(format_thousand(totalHeal))
    ui.ten:setText(format_thousand(valueInSeconds(healTable)))
    ui.eleven:setText(format_thousand(storage.bestHeal))
    ui.dOne:setText(first)
    ui.dTwo:setText(second)
    ui.dThree:setText(third)
end)