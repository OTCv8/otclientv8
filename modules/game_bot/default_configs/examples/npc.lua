singlehotkey("f10", "npc buy and sell", function()
  NPC.say("hi")
  NPC.say("trade")
  NPC.buy(3074, 2) -- wand of vortex
  NPC.sell(3074, 1)
  NPC.closeTrade()
end)