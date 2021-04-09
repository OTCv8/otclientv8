CaveBot.Extensions.Travel = {}

CaveBot.Extensions.Travel.setup = function()
  CaveBot.registerAction("Travel", "#db5a5a", function(value, retries)
   local data = string.split(value, ",")
   local waitVal = 0
    if #data < 2 or #data > 3 then
     warn("CaveBot[Travel]: incorrect travel value!")
     return false
    elseif #data == 3 then
      waitVal = tonumber(data[3]:trim())
    end

    if not waitVal then
      warn("CaveBot[Travel]: incorrect travel delay value!")
      return false
    end

    if retries > 5 then
      print("CaveBot[Travel]: too many tries, can't travel")
     return false
    end

    local npc = getCreatureByName(data[1]:trim())
    if not npc then 
      print("CaveBot[Travel]: NPC not found, can't travel")
     return false 
    end

    local pos = player:getPosition()
    local npcPos = npc:getPosition()
    if math.max(math.abs(pos.x - npcPos.x), math.abs(pos.y - npcPos.y)) > 3 then
      CaveBot.walkTo(npcPos, 20, {ignoreNonPathable = true, precision=3})
      delay(300)
      return "retry"
    end

    NPC.say("hi")
    schedule(waitVal, function() NPC.say(data[2]:trim()) end)
    schedule(2*waitVal, function() NPC.say("yes") end)
    delay(3*waitVal)
    print("CaveBot[Travel]: travel action finished")
    return true
    
  end)

 CaveBot.Editor.registerAction("travel", "travel", {
  value="NPC name, city",
  title="Travel",
  description="NPC name, City name, delay in ms(optional)",
 })
end