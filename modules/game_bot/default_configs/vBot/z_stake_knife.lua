setDefaultTab("Cave")

UI.Separator()
local knifeBodies = {4272, 4173, 4011, 4025, 4047, 4052, 4057, 4062, 4112, 4212, 4321, 4324, 4327, 10352, 10356, 10360, 10364} 
local stakeBodies = {4097, 4137, 8738, 18958}
local fishingBodies = {9582}


macro(500,"Stake Bodies", function()
    if not CaveBot.isOn() then return end
    for i, tile in ipairs(g_map.getTiles(posz())) do
        for u,item in ipairs(tile:getItems()) do
            if table.find(knifeBodies, item:getId()) and findItem(5908) then
                CaveBot.delay(550)
                useWith(5908, item)
                return
            end
            if table.find(stakeBodies, item:getId()) and findItem(5942) then
                CaveBot.delay(550)
                useWith(5942, item)
                return
            end
            if table.find(fishingBodies, item:getId()) and findItem(3483) then
                CaveBot.delay(550)
                useWith(3483, item)
                return
            end
        end
    end

end)