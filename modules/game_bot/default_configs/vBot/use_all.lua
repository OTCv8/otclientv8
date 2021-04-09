-- config 
storage.shovel = 9596
storage.rope = 9596
storage.machete = 9596
storage.scythe = 9596

local useId = {34847, 1764, 21051, 30823, 6264, 5282, 20453, 20454, 20474, 11708, 11705, 6257, 6256, 2772, 27260, 2773, 1632, 1633, 1948, 435, 6252, 6253, 5007, 4911, 1629, 1630, 5108, 5107, 5281, 1968, 435, 1948, 5542, 31116, 31120, 30742, 31115, 31118, 20474, 5737, 5736, 5734, 5733, 31202, 31228, 31199, 31200, 33262, 30824, 5125, 5126, 5116, 5117, 8257, 8258, 8255, 8256}
local shovelId = {606, 593, 867}
local ropeId = {17238, 12202, 12935, 386, 421, 21966, 14238}
local macheteId = {2130, 3696}
local scytheId = {3653}

setDefaultTab("Tools")
-- script
hotkey("space", "Use All", function()
    if not modules.game_walking.wsadWalking then return end
    for _, tile in pairs(g_map.getTiles(posz())) do
        if distanceFromPlayer(tile:getPosition()) < 2 then
            for _, item in pairs(tile:getItems()) do
                -- use
                if table.find(useId, item:getId()) then
                    use(item)
                    return
                elseif table.find(shovelId, item:getId()) then
                    useWith(storage.shovel, item)
                    return
                elseif table.find(ropeId, item:getId()) then
                    useWith(storage.rope, item) 
                    return
                elseif table.find(macheteId, item:getId()) then
                    useWith(storage.machete, item)
                    return
                elseif table.find(scytheId, item:getId()) then
                    useWith(storage.scythe, item)
                    return
                end
            end
        end
    end
end)