CaveBot.Extensions.SupplyCheck = {}

storage.supplyRetries = 0
CaveBot.Extensions.SupplyCheck.setup = function()
 CaveBot.registerAction("supplyCheck", "#db5a5a", function(value)
  local softCount = itemAmount(6529) + itemAmount(3549)
  local totalItem1 = itemAmount(storage[suppliesPanelName].item1)
  local totalItem2 = itemAmount(storage[suppliesPanelName].item2)
  local totalItem3 = itemAmount(storage[suppliesPanelName].item3)
  local totalItem4 = itemAmount(storage[suppliesPanelName].item4)
  local totalItem5 = itemAmount(storage[suppliesPanelName].item5)
  local totalItem6 = itemAmount(storage[suppliesPanelName].item6)
 
  if storage.supplyRetries > 50 then
    print("CaveBot[SupplyCheck]: Round limit reached, going back on refill.")
    storage.supplyRetries = 0
    return false
  elseif (storage[suppliesPanelName].imbues and player:getSkillLevel(11) ~= 100) then 
    print("CaveBot[SupplyCheck]: Imbues ran out. Going on refill.")
    storage.supplyRetries = 0
    return false
  elseif (storage[suppliesPanelName].staminaSwitch and stamina() < tonumber(storage[suppliesPanelName].staminaValue)) then 
    print("CaveBot[SupplyCheck]: Stamina ran out. Going on refill.")
    storage.supplyRetries = 0
    return false
  elseif (softCount < 1 and storage[suppliesPanelName].SoftBoots) then 
    print("CaveBot[SupplyCheck]: No soft boots left. Going on refill.")
    storage.supplyRetries = 0
    return false
  elseif (totalItem1 < tonumber(storage[suppliesPanelName].item1Min) and storage[suppliesPanelName].item1 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. storage[suppliesPanelName].item1 .. "(only " .. totalItem1 .. " left). Going on refill.")
    storage.supplyRetries = 0
    return false
  elseif (totalItem2 < tonumber(storage[suppliesPanelName].item2Min) and storage[suppliesPanelName].item2 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. storage[suppliesPanelName].item2 .. "(only " .. totalItem2 .. " left). Going on refill.")
    storage.supplyRetries = 0
    return false
  elseif (totalItem3 < tonumber(storage[suppliesPanelName].item3Min) and storage[suppliesPanelName].item3 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. storage[suppliesPanelName].item3 .. "(only " .. totalItem3 .. " left). Going on refill.")
    storage.supplyRetries = 0
    return false
  elseif (totalItem4 < tonumber(storage[suppliesPanelName].item4Min) and storage[suppliesPanelName].item4 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. storage[suppliesPanelName].item4 .. "(only " .. totalItem4 .. " left). Going on refill.")
    storage.supplyRetries = 0
    return false
  elseif (totalItem5 < tonumber(storage[suppliesPanelName].item5Min) and storage[suppliesPanelName].item5 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. storage[suppliesPanelName].item5 .. "(only " .. totalItem5 .. " left). Going on refill.")
    storage.supplyRetries = 0
    return false
  elseif (totalItem6 < tonumber(storage[suppliesPanelName].item6Min) and storage[suppliesPanelName].item6 > 100) then 
    print("CaveBot[SupplyCheck]: Not enough item: " .. storage[suppliesPanelName].item6 .. "(only " .. totalItem6 .. " left). Going on refill.")
    storage.supplyRetries = 0
    return false
  elseif (freecap() < tonumber(storage[suppliesPanelName].capValue) and storage[suppliesPanelName].capSwitch) then
    print("CaveBot[SupplyCheck]: Not enough capacity. Going on refill.")
    storage.supplyRetries = 0
    return false
  else
    print("CaveBot[SupplyCheck]: Enough supplies. Hunting. Round (" .. storage.supplyRetries .. "/50)")
    storage.supplyRetries = storage.supplyRetries + 1
    return CaveBot.gotoLabel(value)
  end
 end)

 CaveBot.Editor.registerAction("supplycheck", "supply check", {
   value="startHunt",
   title="Supply check label",
   description="Insert here hunting start label",
 })  
end