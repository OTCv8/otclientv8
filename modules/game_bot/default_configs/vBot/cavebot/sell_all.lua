CaveBot.Extensions.SellAll = {}

storage.sellAllCap = 0
CaveBot.Extensions.SellAll.setup = function()
  CaveBot.registerAction("SellAll", "#C300FF", function(value, retries)
    local val = string.split(value, ",")
    local wait
    if #val > 2 then 
      warn("CaveBot[SellAll]: incorrect sell all value!")
      return false
    end

    if #val == 2 then
      wait = true
    else
      wait = false
    end

    local npc = getCreatureByName(val[1])
    if not npc then 
      print("CaveBot[SellAll]: NPC not found! skipping")
      return false 
    end

    if retries > 10 then
      print("CaveBot[SellAll]: can't sell, skipping")
      return false
    end

    if freecap() == storage.sellAllCap then
      storage.sellAllCap = 0 
      print("CaveBot[SellAll]: Sold everything, proceeding")
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

    if not NPC.isTrading() then
      NPC.say("hi")
      schedule(500, function() NPC.say("trade") end)
    else
      storage.sellAllCap = freecap()
    end
    
    NPC.sellAll(wait)
    if #val == 2 then
      print("CaveBot[SellAll]: Sold All with delay")
    else
      print("CaveBot[SellAll]: Sold All without delay")
    end

    return "retry"
  end)

 CaveBot.Editor.registerAction("sellall", "sell all", {
  value="NPC",
  title="Sell All",
  description="Insert NPC name, and 'yes' if sell with delay  ",
 })
end