if type(storage.killedCreatures) ~= "table" then
    storage.killedCreatures = {}
end
local regex = "Loot of ([a-z])* ([a-z A-Z]*):"
local regex2 = "Loot of ([a-z A-Z]*):"

onTextMessage(function(mode, text)
    if not text:lower():find("loot of") then return end
    local monster
    
    if #regexMatch(text, regex) == 1 and #regexMatch(text, regex)[1] == 3 then
        monster = regexMatch(text, regex)[1][3]
    else
        monster = regexMatch(text, regex2)[1][2]
    end 
    
    if storage.killedCreatures[monster] then
        storage.killedCreatures[monster] = storage.killedCreatures[monster] + 1
    else
        storage.killedCreatures[monster] = 1
    end
end)