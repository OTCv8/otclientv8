setDefaultTab("Cave")

macro(500, "TargetBot off if low supply", function()
    if TargetBot.isOff() then return end
    if CaveBot.isOff() then return end
    if not hasSupplies() then
        TargetBot.setOff()
    end
end)