local m = macro(1000, "Floor Change Delay", function() end)

onPlayerPositionChange(function(x,y)
  if m.isOff() then return end
  if CaveBot.isOff() then return end
  if x.z ~= y.z then 
    TargetBot.delay(500)
  end
end)