-- auto recording for cavebot
-- smart mode only adds a waypoint where the path turns (a straight corridor
-- needs no waypoints in between), skips steps made while attacking, adds a
-- goto before every recorded use and turns used doors into "opendoors"
CaveBot.Recorder = {}

local isEnabled = nil
local anchor = nil -- position of the last recorded waypoint
local prevStep = nil -- position before the last step
local lastUse = 0 -- time of last recorded use/usewith, floor changes right after it come from that use

local function posStr(pos)
  return pos.x .. "," .. pos.y .. "," .. pos.z
end

local function samePos(a, b)
  return a and b and a.x == b.x and a.y == b.y and a.z == b.z
end

local function dist(a, b)
  return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

local function setting(id, default)
  local values = CaveBot.Config and CaveBot.Config.values
  if values and values[id] ~= nil then
    return values[id]
  end
  return default
end

local function lastAction()
  return CaveBot.actionList:getLastChild()
end

local function addGoto(pos, precision)
  local value = posStr(pos)
  if precision then
    value = value .. "," .. precision
  end
  local last = lastAction()
  if last and last.action == "goto" and last.value == value then
    anchor = pos
    return last -- don't record the same waypoint twice
  end
  anchor = pos
  return CaveBot.addAction("goto", value, true)
end

-- the bot can reach `to` from `from` without walking around anything
local function isStraight(from, to)
  if from.z ~= to.z then return false end
  local d = dist(from, to)
  if d <= 1 then return true end
  local path = findPath(from, to, d + 10, { ignoreNonPathable = true, ignoreCreatures = true, allowUnseen = true, allowOnlyVisibleTiles = false })
  return path and #path <= d + 1
end

local function setup()
  onPlayerPositionChange(function(newPos, oldPos)
    if CaveBot.isOn() or not isEnabled then return end
    if not anchor then
      -- first step
      addGoto(oldPos)
    elseif newPos.z ~= oldPos.z or dist(oldPos, newPos) > 1 then
      -- stairs, hole or teleport
      -- a floor change right after a recorded use (ladder, rope, shovel) is done by that use
      if now - lastUse > 1500 then
        if not isStraight(anchor, oldPos) and prevStep and prevStep.z == oldPos.z then
          addGoto(prevStep)
        end
        addGoto(oldPos, 0)
      end
      anchor = newPos
    elseif setting("recPauseAttack", true) and g_game.isAttacking() then
      -- chasing monsters, don't record those steps
    elseif dist(anchor, newPos) >= setting("recStep", 5) then
      addGoto(newPos)
    elseif setting("recSmart", true) and prevStep and not isStraight(anchor, newPos) then
      -- path turned, previous position was a corner
      addGoto(prevStep)
    end
    prevStep = newPos
  end)

  onUse(function(pos, itemId, stackPos, subType)
    if CaveBot.isOn() or not isEnabled then return end
    if pos.x == 0xFFFF then return end -- item in backpack
    if setting("recGotoBeforeUse", true) then
      addGoto(player:getPosition())
    end
    local tile = g_map.getTile(pos)
    local wasBlocked = tile and not tile:isWalkable()
    local widget = CaveBot.addAction("use", posStr(pos), true)
    lastUse = now
    if wasBlocked then
      -- if the tile became walkable it was a door
      schedule(600, function()
        local t = g_map.getTile(pos)
        if widget and not widget:isDestroyed() and widget.action == "use" and t and t:isWalkable() then
          CaveBot.editAction(widget, "opendoors", posStr(pos))
          CaveBot.save()
        end
      end)
    end
  end)

  onUseWith(function(pos, itemId, target, subType)
    if CaveBot.isOn() or not isEnabled then return end
    if not target:isItem() then return end
    local targetPos = target:getPosition()
    if targetPos.x == 0xFFFF then return end
    if setting("recGotoBeforeUse", true) then
      addGoto(player:getPosition())
    end
    CaveBot.addAction("usewith", itemId .. "," .. posStr(targetPos), true)
    lastUse = now
  end)
end

CaveBot.Recorder.isOn = function()
  return isEnabled
end

CaveBot.Recorder.enable = function()
  CaveBot.setOff()
  if isEnabled == nil then
    setup()
  end
  CaveBot.Editor.ui.autoRecording:setOn(true)
  isEnabled = true
  anchor = nil
  prevStep = nil
end

CaveBot.Recorder.disable = function()
  if isEnabled == true then
    isEnabled = false
    -- finish the route where the player stopped
    if anchor and not samePos(anchor, player:getPosition()) then
      addGoto(player:getPosition())
    end
  end
  CaveBot.Editor.ui.autoRecording:setOn(false)
  CaveBot.save()
end

-- adds a goto at the current position, used by the editor
CaveBot.Recorder.addHere = function()
  local widget = addGoto(player:getPosition())
  prevStep = player:getPosition()
  CaveBot.save()
  return widget
end
