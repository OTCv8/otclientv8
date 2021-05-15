CaveBot.Extensions.BuySupplies = {}

CaveBot.Extensions.BuySupplies.setup = function()
  CaveBot.registerAction("BuySupplies", "#C300FF", function(value, retries)
    local supplies = SuppliesConfig[suppliesPanelName]
    local item1Count = itemAmount(supplies.item1)
    local item2Count = itemAmount(supplies.item2)
    local item3Count = itemAmount(supplies.item3)
    local item4Count = itemAmount(supplies.item4)
    local item5Count = itemAmount(supplies.item5)
    local item6Count = itemAmount(supplies.item6)
    local item7Count = itemAmount(supplies.item7)
    local possibleItems = {}

    local val = string.split(value, ",")
    local waitVal
    if #val == 0 or #val > 2 then 
      warn("CaveBot[BuySupplies]: incorrect BuySupplies value")
      return false 
    elseif #val == 2 then
      waitVal = tonumber(val[2]:trim())
    end

    local npcName = val[1]:trim()
    local npc = getCreatureByName(npcName)
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

    if not CaveBot.ReachNPC(npcName) then
      return "retry"
    end

    local itemList = {
        item1 = {ID = supplies.item1, maxAmount = supplies.item1Max, currentAmount = item1Count},
        item2 = {ID = supplies.item2, maxAmount = supplies.item2Max, currentAmount = item2Count}, 
        item3 = {ID = supplies.item3, maxAmount = supplies.item3Max, currentAmount = item3Count},
        item4 = {ID = supplies.item4, maxAmount = supplies.item4Max, currentAmount = item4Count},
        item5 = {ID = supplies.item5, maxAmount = supplies.item5Max, currentAmount = item5Count},
        item6 = {ID = supplies.item6, maxAmount = supplies.item6Max, currentAmount = item6Count},
        item7 = {ID = supplies.item7, maxAmount = supplies.item7Max, currentAmount = item7Count}
    }

    if not NPC.isTrading() then
      CaveBot.OpenNpcTrade()
      CaveBot.delay(storage.extras.talkDelay*2)
      return "retry"
    end

    -- get items from npc
    local npcItems = NPC.getBuyItems()
    for i,v in pairs(npcItems) do
      table.insert(possibleItems, v.id)
    end

    for i, item in pairs(itemList) do
     if item["ID"] and item["ID"] > 100 and table.find(possibleItems, item["ID"]) then
      local amountToBuy = item["maxAmount"] - item["currentAmount"]
      if amountToBuy > 0 then  
        NPC.buy(item["ID"], math.min(100, amountToBuy))
        print("CaveBot[BuySupplies]: bought " .. math.min(100, amountToBuy) .. "x " .. item["ID"])
        return "retry"
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