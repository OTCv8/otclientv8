CaveBot.Extensions.BuySupplies = {}

CaveBot.Extensions.BuySupplies.setup = function()
  CaveBot.registerAction("BuySupplies", "#C300FF", function(value, retries)
    local item1Count = itemAmount(storage[suppliesPanelName].item1)
    local item2Count = itemAmount(storage[suppliesPanelName].item2)
    local item3Count = itemAmount(storage[suppliesPanelName].item3)
    local item4Count = itemAmount(storage[suppliesPanelName].item4)
    local item5Count = itemAmount(storage[suppliesPanelName].item5)
    local item6Count = itemAmount(storage[suppliesPanelName].item6)
    local item7Count = itemAmount(storage[suppliesPanelName].item7)
    local possibleItems = {}

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

    if retries > 50 then
      print("CaveBot[BuySupplies]: Too many tries, can't buy")
      return false
    end

    delay(200)

    local pos = player:getPosition()
    local npcPos = npc:getPosition()
    if math.max(math.abs(pos.x - npcPos.x), math.abs(pos.y - npcPos.y)) > 3 then
      CaveBot.walkTo(npcPos, 20, {ignoreNonPathable = true, precision=3})
      delay(300)
      return "retry"
    end

    local itemList = {
        item1 = {ID = storage[suppliesPanelName].item1, maxAmount = storage[suppliesPanelName].item1Max, currentAmount = item1Count},
        item2 = {ID = storage[suppliesPanelName].item2, maxAmount = storage[suppliesPanelName].item2Max, currentAmount = item2Count}, 
        item3 = {ID = storage[suppliesPanelName].item3, maxAmount = storage[suppliesPanelName].item3Max, currentAmount = item3Count},
        item4 = {ID = storage[suppliesPanelName].item4, maxAmount = storage[suppliesPanelName].item4Max, currentAmount = item4Count},
        item5 = {ID = storage[suppliesPanelName].item5, maxAmount = storage[suppliesPanelName].item5Max, currentAmount = item5Count},
        item6 = {ID = storage[suppliesPanelName].item6, maxAmount = storage[suppliesPanelName].item6Max, currentAmount = item6Count},
        item7 = {ID = storage[suppliesPanelName].item7, maxAmount = storage[suppliesPanelName].item7Max, currentAmount = item7Count}
    }

    if not NPC.isTrading() then
      NPC.say("hi")
      schedule(500, function() NPC.say("trade") end)
      return "retry"
    end

    -- get items from npc
    local npcItems = NPC.getBuyItems()
    for i,v in pairs(npcItems) do
      table.insert(possibleItems, v.id)
    end

    for i, item in pairs(itemList) do
   --   info(table.find(possibleItems, item["ID"]))
     if item["ID"] and item["ID"] > 100 and table.find(possibleItems, item["ID"]) then
      local amountToBuy = item["maxAmount"] - item["currentAmount"]
       if amountToBuy > 100 then
        for i=1, math.ceil(amountToBuy/100), 1 do
         NPC.buy(item["ID"], math.min(100, amountToBuy))
         print("CaveBot[BuySupplies]: bought " .. amountToBuy .. "x " .. item["ID"])
         return "retry"
        end
        else
         if amountToBuy > 0 then
          NPC.buy(item["ID"], math.min(100, amountToBuy))
          print("CaveBot[BuySupplies]: bought " .. amountToBuy .. "x " .. item["ID"])
          return "retry"
         end
       end
      end
     end
    print("CaveBot[BuySupplies]: bought everything, proceeding")
    return true
 end)

 CaveBot.Editor.registerAction("buysupplies", "buy supplies", {
  value="NPC name",
  title="Buy Supplies",
  description="NPC Name, delay(in ms, optional)",
 })
end