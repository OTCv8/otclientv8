CaveBot.Extensions.BuySupplies = {}

storage.buySuppliesCap = 0
CaveBot.Extensions.BuySupplies.setup = function()
  CaveBot.registerAction("BuySupplies", "#00FFFF", function(value, retries)
    local item1Count = 0
    local item2Count = 0
    local item3Count = 0
    local item4Count = 0
    local item5Count = 0

    local val = string.split(value, ",")
    local waitVal
    if #val == 0 or #val > 2 then 
      warn("CaveBot[BuySupplies]: incorrect BuySupplies value")
      return false 
    elseif #val == 2 then
      waitVal = tonumber(val[2]:trim())
    end

    local npc = getCreatureByName(val[1]:trim())
    if not npc then 
      print("CaveBot[BuySupplies]: NPC not found")
      return false 
    end
    
    if not waitVal and #val == 2 then 
      warn("CaveBot[BuySupplies]: incorrect delay values!")
    elseif waitVal and #val == 2 then
      delay(waitVal)
    end

    if retries > 40 then
      print("CaveBot[BuySupplies]: Too many tries, can't buy")
      return false
    end

    if freecap() == storage.buySuppliesCap then
      storage.buySuppliesCap = 0 
      print("CaveBot[BuySupplies]: Bought Everything, proceeding")
      return true
    end

    delay(800)

    local pos = player:getPosition()
    local npcPos = npc:getPosition()
    if math.max(math.abs(pos.x - npcPos.x), math.abs(pos.y - npcPos.y)) > 3 then
      CaveBot.walkTo(npcPos, 20, {ignoreNonPathable = true, precision=3})
      delay(300)
      return "retry"
    end

    for _, container in pairs(getContainers()) do
     for _, item in ipairs(container:getItems()) do
       if (storage[suppliesPanelName].item1 > 100) and (item:getId() == storage[suppliesPanelName].item1) then
           item1Count = item1Count + item:getCount()   
       end
       if (storage[suppliesPanelName].item2 > 100) and (item:getId() == storage[suppliesPanelName].item2) then
           item2Count = item2Count + item:getCount()   
       end
       if (storage[suppliesPanelName].item3 > 100) and (item:getId() == storage[suppliesPanelName].item3) then
           item3Count = item3Count + item:getCount()   
       end
       if (storage[suppliesPanelName].item4 > 100) and (item:getId() == storage[suppliesPanelName].item4) then
           item4Count = item4Count + item:getCount()   
       end
       if (storage[suppliesPanelName].item5 > 100) and (item:getId() == storage[suppliesPanelName].item5) then
           item5Count = item5Count + item:getCount()   
       end
     end
    end

    local itemList = {
        item1 = {ID = storage[suppliesPanelName].item1, maxAmount = storage[suppliesPanelName].item1Max, currentAmount = item1Count},
        item2 = {ID = storage[suppliesPanelName].item2, maxAmount = storage[suppliesPanelName].item2Max, currentAmount = item2Count}, 
        item3 = {ID = storage[suppliesPanelName].item3, maxAmount = storage[suppliesPanelName].item3Max, currentAmount = item3Count},
        item4 = {ID = storage[suppliesPanelName].item4, maxAmount = storage[suppliesPanelName].item4Max, currentAmount = item4Count},
        item5 = {ID = storage[suppliesPanelName].item5, maxAmount = storage[suppliesPanelName].item5Max, currentAmount = item5Count}
    }

    if not NPC.isTrading() then
      NPC.say("hi")
      schedule(500, function() NPC.say("trade") end)
    else
      storage.buySuppliesCap = freecap()
    end

    for i, item in pairs(itemList) do
     if item["ID"] > 100 then
      local amountToBuy = item["maxAmount"] - item["currentAmount"]
       if amountToBuy > 100 then
        for i=1, math.ceil(amountToBuy/100), 1 do
         NPC.buy(item["ID"], math.min(100, amountToBuy))
         amountToBuy = amountToBuy - math.min(100, amountToBuy)
         print("CaveBot[BuySupplies]: bought " .. amountToBuy .. "x " .. item["ID"])
         return "retry"
        end
        else
         if amountToBuy > 0 then
          NPC.buy(item["ID"], amountToBuy)
          print("CaveBot[BuySupplies]: bought " .. amountToBuy .. "x " .. item["ID"])
          return "retry"
         end
       end
      end
     end
    return "retry"
 end)

 CaveBot.Editor.registerAction("buysupplies", "buy supplies", {
  value="NPC name",
  title="Buy Supplies",
  description="NPC Name, delay(in ms, optional)",
 })
end