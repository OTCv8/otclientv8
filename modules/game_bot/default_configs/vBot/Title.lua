local vocation = player:getVocation()
local vocText = ""

if vocation == 1 or vocation == 11 then
    vocText = "- EK"
elseif vocation == 2 or vocation == 12 then
    vocText = "- RP"
elseif vocation == 3 or vocation == 13 then
    vocText = "- MS"
elseif vocation == 4 or vocation == 14 then
    vocText = "- ED"
end

macro(2000, function()
    if hppercent() > 0 then
        g_window.setTitle("Tibia - " .. player:getName() .. " - " .. lvl() .. "lvl " .. vocText)
    else
        g_window.setTitle("Tibia - " .. player:getName() .. " - DEAD")
    end
end)