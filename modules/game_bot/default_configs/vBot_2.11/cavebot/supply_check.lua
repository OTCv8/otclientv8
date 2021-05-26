CaveBot.Extensions.SupplyCheck = {}

SuppliesConfig.supplyRetries = 0
CaveBot.Extensions.SupplyCheck.setup = function()
 CaveBot.registerAction("supplyCheck", "#db5a5a", function(value)
  local supplies = SuppliesConfig[suppliesPanelName]
  local softCount = itemAmount(6529) + itemAmount(3549)
  local totalItem1 = itemAmount(supplies.item1)
  local totalItem2 = itemAmount(supplies.item2)
  local totalItem3 = itemAmount(supplies.item3)
  local totalItem4 = itemAmount(supplies.item4)
  local totalItem5 = itemAmount(supplies.item5)
  local totalItem6 = itemAmount(supplies.item6)
 
  if SuppliesConfig.supplyRetries > 50 then
    print("CaveBot[SupplyCheck]: Round limit reached, going back on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (supplies.imbues and player:getSkillLevel(11) == 0) then 
    print("CaveBot[SupplyCheck]: Imbues ran out. Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (supplies.staminaSwitch and stamina() < tonumber(supplies.staminaValue)) then 
    print("CaveBot[SupplyCheck]: Stamina ran out. Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (softCount < 1 and supplies.SoftBoots) then 
    print("CaveBot[SupplyCheck]: No soft boots left. Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (totalItem1 < tonumber(supplies.item1Min) and supplies.item1 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item1 .. "(only " .. totalItem1 .. " left). Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (totalItem2 < tonumber(supplies.item2Min) and supplies.item2 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item2 .. "(only " .. totalItem2 .. " left). Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (totalItem3 < tonumber(supplies.item3Min) and supplies.item3 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item3 .. "(only " .. totalItem3 .. " left). Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (totalItem4 < tonumber(supplies.item4Min) and supplies.item4 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item4 .. "(only " .. totalItem4 .. " left). Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (totalItem5 < tonumber(supplies.item5Min) and supplies.item5 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item5 .. "(only " .. totalItem5 .. " left). Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (totalItem6 < tonumber(supplies.item6Min) and supplies.item6 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. supplies.item6 .. "(only " .. totalItem6 .. " left). Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  elseif (freecap() < tonumber(supplies.capValue) and supplies.capSwitch) then
    print("CaveBot[SupplyCheck]: Not enough capacity. Going on refill.")
    SuppliesConfig.supplyRetries = 0
    return false
  else
    print("CaveBot[SupplyCheck]: Enough supplies. Hunting. Round (" .. SuppliesConfig.supplyRetries .. "/50)")
    SuppliesConfig.supplyRetries = SuppliesConfig.supplyRetries + 1
    return CaveBot.gotoLabel(value)
  end
 end)

 CaveBot.Editor.registerAction("supplycheck", "supply check", {
   value="startHunt",
   title="Supply check label",
   description="Insert here hunting start label",
 })  
end