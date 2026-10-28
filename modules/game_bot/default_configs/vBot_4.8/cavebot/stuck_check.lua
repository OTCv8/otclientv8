CaveBot.Extensions.StuckCheck = {}

-- watchdog: if the character doesn't move for `stuckTimeout` seconds while
-- cavebot is on and targetbot has nothing to do, skip to the next reachable
-- waypoint (or the first previous one if nothing ahead is reachable)
local stuckTimeout = 0 -- seconds, 0 = disabled; set by the "stuckcheck" action
local lastPos = nil
local lastMove = 0

local function resetTimer()
  lastPos = player:getPosition()
  lastMove = now
end

CaveBot.Extensions.StuckCheck.setup = function()
  CaveBot.registerAction("stuckcheck", "#FF8C00", function(value)
    local seconds = tonumber(value)
    if not seconds then
      warn("CaveBot[StuckCheck]: wrong value, should be number of seconds (0 = off)")
      return false
    end
    stuckTimeout = seconds
    resetTimer()
    return true
  end)

  CaveBot.Editor.registerAction("stuckcheck", "stuck check", {
    value="20",
    title="Stuck check",
    description="Seconds without moving before skipping to next waypoint (0 = off)",
    validation="^[0-9]{1,4}$"
  })

  macro(1000, function()
    if stuckTimeout <= 0 or CaveBot.isOff() then
      return resetTimer()
    end
    -- standing still is expected while fighting, looting or in protection zone (depot, npc)
    if TargetBot.isActive() or isInPz() then
      return resetTimer()
    end

    local pos = player:getPosition()
    if not lastPos or pos.x ~= lastPos.x or pos.y ~= lastPos.y or pos.z ~= lastPos.z then
      return resetTimer()
    end

    if now - lastMove < stuckTimeout * 1000 then return end

    print("CaveBot[StuckCheck]: no movement for " .. stuckTimeout .. "s, skipping waypoint")
    if not CaveBot.gotoNextWaypointInRange() then
      CaveBot.gotoFirstPreviousReachableWaypoint()
    end
    resetTimer()
  end)
end
