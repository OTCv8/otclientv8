setDefaultTab("Tools")
local hotkey = "PageUp"

local candidates = {}

local m = macro(20, "Hold Mwall", function()
    if #candidates == 0 then return end

    for _, tile in pairs(candidates) do
        if tile:canShoot() then
            useWith(3180, tile:getTopUseThing())
        end
    end
end)

onRemoveThing(function(tile, thing)
    if m.isOff() then return end
    if thing:getId() ~= 2129 then return end
    if tile:getText():len() > 0 then
        table.insert(candidates, tile)
        useWith(3180, tile:getTopUseThing())
    end
end)

onAddThing(function(tile, thing)
    if m.isOff() then return end
    if thing:getId() ~= 2129 then return end
    if tile:getText():len() > 0 then
        table.remove(candidates, table.find(candidates,tile))
    end
end)

onKeyPress(function(keys)
    if m.isOff() then return end
    if keys ~= hotkey then return end

    local tile = getTileUnderCursor()
    if not tile then return end

    if tile:getText():len() > 0 then
        tile:setText("")
    else
        tile:setText("MARKED")
        table.insert(candidates, tile)
    end
end)


