CaveBot.Extensions.Bank = {}

CaveBot.Extensions.Bank.setup = function()
  CaveBot.registerAction("bank", "#db5a5a", function(value, retries)
   local data = string.split(value, ",")
   local waitVal = 300
   local amount = 0
   local actionType
   local npcName
    if #data ~= 3 and #data ~= 2 then
     warn("CaveBot[Bank]: incorrect value!")
     return false
    else
      actionType = data[1]:trim():lower()
      npcName = data[2]:trim()
      if #data == 3 then
        amount = tonumber(data[3]:trim())
      end
    end

    if actionType ~= "withdraw" and actionType ~= "deposit" then
      warn("CaveBot[Bank]: incorrect action type! should be withdraw/deposit, is: " .. actionType)
      return false
    elseif actionType == "withdraw" then
      local value = tonumber(amount)
      if not value then
        warn("CaveBot[Bank]: incorrect amount value! should be number, is: " .. amount)
        return false
      end
    end

    if retries > 5 then
      print("CaveBot[Bank]: too many tries, skipping")
     return false
    end

    local npc = getCreatureByName(npcName)
    if not npc then 
      print("CaveBot[Bank]: NPC not found, skipping")
     return false 
    end

    if not CaveBot.ReachNPC(npcName) then
      return "retry"
    end

    if actionType == "deposit" then
      CaveBot.Conversation("hi", "deposit all", "yes")
      CaveBot.delay(storage.extras.talkDelay*3)
      return true
    else
      CaveBot.Conversation("hi", "withdraw", value, "yes")
      CaveBot.delay(storage.extras.talkDelay*4)
      return true
    end
  end)

 CaveBot.Editor.registerAction("bank", "bank", {
  value="action, NPC name",
  title="Banker",
  description="action type(withdraw/deposit), NPC name, if withdraw: amount",
 })
end