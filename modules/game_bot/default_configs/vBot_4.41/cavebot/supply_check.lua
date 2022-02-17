CaveBot.Extensions.SupplyCheck = {}

local supplyRetries = 0
local missedChecks = 0
local time = nil
CaveBot.Extensions.SupplyCheck.setup = function()
 CaveBot.registerAction("supplyCheck", "#db5a5a", function(value)
  local data = string.split(value, ",")
  local round = 0
  local label = data[1]:trim()
  local pos = nil
    if #data == 4 then
      pos = {x=tonumber(data[2]),y=tonumber(data[3]),z=tonumber(data[4])}
    end

  if pos then
    if missedChecks >= 4 then
      missedChecks = 0
      supplyRetries = 0
      print("CaveBot[SupplyCheck]: Missed 5 supply checks, proceeding with waypoints")
      return true
    end
    if getDistanceBetween(player:getPosition(), pos) > 10 then
      missedChecks = missedChecks + 1
      print("CaveBot[SupplyCheck]: Missed supply check! ".. 5-missedChecks .. " tries left before skipping.")
      return CaveBot.gotoLabel(label)
    end
  end

  if time then
    round = math.ceil((now - time)/1000) .. "s"
  else
    round = ""
  end
  time = now

  local supplies = SuppliesConfig.supplies
  supplies = supplies[supplies.currentProfile]
  local softCount = itemAmount(6529) + itemAmount(3549)
  local totalItem1 = itemAmount(supplies.item1)
  local totalItem2 = itemAmount(supplies.item2)
  local totalItem3 = itemAmount(supplies.item3)
  local totalItem4 = itemAmount(supplies.item4)
  local totalItem5 = itemAmount(supplies.item5)
  local totalItem6 = itemAmount(supplies.item6)

  if storage.caveBot.forceRefill then
    print("CaveBot[SupplyCheck]: User forced, going back on refill. Last round took: " .. round)
    storage.caveBot.forceRefill = false
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif storage.caveBot.backStop then
    print("CaveBot[SupplyCheck]: User forced, going back to city and turning off CaveBot. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false   
  elseif storage.caveBot.backTrainers then
    print("CaveBot[SupplyCheck]: User forced, going back to city, then on trainers. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false     
  elseif storage.caveBot.backOffline then
    print("CaveBot[SupplyCheck]: User forced, going back to city, then on offline training. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false    
  elseif supplyRetries > (storage.extras.huntRoutes or 50) then
    print("CaveBot[SupplyCheck]: Round limit reached, going back on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (supplies.imbues and player:getSkillLevel(11) == 0) then 
    print("CaveBot[SupplyCheck]: Imbues ran out. Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (supplies.staminaSwitch and stamina() < tonumber(supplies.staminaValue)) then 
    print("CaveBot[SupplyCheck]: Stamina ran out. Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (softCount < 1 and supplies.SoftBoots) then 
    print("CaveBot[SupplyCheck]: No soft boots left. Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (totalItem1 < tonumber(supplies.item1Min) and supplies.item1 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item1 .. "(only " .. totalItem1 .. " left). Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (totalItem2 < tonumber(supplies.item2Min) and supplies.item2 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item2 .. "(only " .. totalItem2 .. " left). Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (totalItem3 < tonumber(supplies.item3Min) and supplies.item3 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item3 .. "(only " .. totalItem3 .. " left). Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (totalItem4 < tonumber(supplies.item4Min) and supplies.item4 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item4 .. "(only " .. totalItem4 .. " left). Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (totalItem5 < tonumber(supplies.item5Min) and supplies.item5 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item5 .. "(only " .. totalItem5 .. " left). Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (totalItem6 < tonumber(supplies.item6Min) and supplies.item6 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item6 .. "(only " .. totalItem6 .. " left). Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif (freecap() < tonumber(supplies.capValue) and supplies.capSwitch) then
    print("CaveBot[SupplyCheck]: Not enough capacity. Going on refill. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false
  elseif ForcedRefill then
    print("CaveBot[SupplyCheck]: Forced refill, going back to city. Last round took: " .. round)
    supplyRetries = 0
    missedChecks = 0
    return false    
  else
    print("CaveBot[SupplyCheck]: Enough supplies. Hunting. Round (" .. supplyRetries .. "/" .. (storage.extras.huntRoutes or 50) .."). Last round took: " .. round)
    supplyRetries = supplyRetries + 1
    missedChecks = 0
    return CaveBot.gotoLabel(label)
  end
 end)

 CaveBot.Editor.registerAction("supplycheck", "supply check", {
   value=function() return "startHunt," .. posx() .. "," .. posy() .. "," .. posz() end,
   title="Supply check label",
   description="Insert here hunting start label",
   validation=[[[^,]+,\d{1,5},\d{1,5},\d{1,2}$]]
 })  
end