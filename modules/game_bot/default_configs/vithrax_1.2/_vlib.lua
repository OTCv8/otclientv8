-- lib ver 1.41
-- Author: Vithrax
-- contains mostly basic function shortcuts and code shorteners

function isBuffed()
    local var = false
    for i=1,4 do
        if (player:getSkillLevel(i) - player:getSkillBaseLevel(i)) > 5 and (4*(player:getSkillLevel(i) - player:getSkillBaseLevel(i))) < player:getSkillLevel(i) then
            var = true
        end
    end
    return var
end

function killsToRs()
    return math.min(g_game.getUnjustifiedPoints().killsDayRemaining, g_game.getUnjustifiedPoints().killsWeekRemaining, g_game.getUnjustifiedPoints().killsMonthRemaining)
end

function canCast(spell)
    if not spell then return end
    if not getSpellData(spell) then return true end
    if not getSpellCoolDown(spell) and mana() >= getSpellData(spell).manaCost and level() >= getSpellData(spell).level then
        return true
    else
        return false
    end
end

function getSpellData(spell)
    if not spell then return false end
    if Spells[spell] then
        return Spells[spell]
    else
        return false
    end
end

Spells = {
    ["adana ani"] = {level = 54, manaCost = 1400},
    ["adana mort"] = {level = 27, manaCost = 600},
    ["adana pox"] = {level = 15, manaCost = 200},
    ["adeta sio"] = {level = 16, manaCost = 200},
    ["adevo grav flam"] = {level = 15, manaCost = 240},
    ["adevo grav pox"] = {level = 14, manaCost = 200},
    ["adevo grav tera"] = {level = 32, manaCost = 750},
    ["adevo grav vis"] = {level = 18, manaCost = 320},
    ["adevo grav vita"] = {level = 27, manaCost = 600},
    ["adevo ina"] = {level = 27, manaCost = 600},
    ["adevo mas flam"] = {level = 27, manaCost = 600},
    ["adevo mas grav flam"] = {level = 33, manaCost = 780},
    ["adevo mas grav pox"] = {level = 29, manaCost = 640},
    ["adevo mas grav vis"] = {level = 41, manaCost = 1000},
    ["adevo mas hur"] = {level = 31, manaCost = 570},
    ["adevo mas pox"] = {level = 25, manaCost = 520},
    ["adevo mas vis"] = {level = 37, manaCost = 880},
    ["adevo res flam"] = {level = 27, manaCost = 420},
    ["adito grav"] = {level = 17, manaCost = 120},
    ["adito tera"] = {level = 21, manaCost = 200},
    ["adori dis min vis"] = {level = 1, manaCost = 5},
    ["adori flam"] = {level = 27, manaCost = 460},
    ["adori frigo"] = {level = 28, manaCost = 460},
    ["adori gran mort"] = {level = 45, manaCost = 985},
    ["adori mas flam"] = {level = 30, manaCost = 530},
    ["adori mas frigo"] = {level = 30, manaCost = 530},
    ["adori mas tera"] = {level = 28, manaCost = 430},
    ["adori mas vis"] = {level = 28, manaCost = 430},
    ["adori min vis"] = {level = 15, manaCost = 120},
    ["adori san"] = {level = 27, manaCost = 300},
    ["adori tera"] = {level = 24, manaCost = 350},
    ["adori vis"] = {level = 25, manaCost = 350},
    ["adura gran"] = {level = 15, manaCost = 120},
    ["adura vita"] = {level = 24, manaCost = 400},
    ["exana flam"] = {level = 30, manaCost = 30},
    ["exana ina"] = {level = 26, manaCost = 200},
    ["exana kor"] = {level = 45, manaCost = 30},
    ["exana mort"] = {level = 80, manaCost = 40},
    ["exana pox"] = {level = 10, manaCost = 30},
    ["exana vis"] = {level = 22, manaCost = 30},
    ["exani tera"] = {level = 9, manaCost = 20},
    ["exeta con"] = {level = 45, manaCost = 350},
    ["exeta res"] = {level = 20, manaCost = 40},
    ["exevo con"] = {level = 13, manaCost = 100},
    ["exevo con flam"] = {level = 25, manaCost = 290},
    ["exevo dis flam hur"] = {level = 1, manaCost = 5},
    ["exevo flam hur"] = {level = 18, manaCost = 25},
    ["exevo frigo hur"] = {level = 18, manaCost = 25},
    ["exevo gran con hur"] = {level = 150, manaCost = 1000},
    ["exevo gran con vis"] = {level = 150, manaCost = 1000},
    ["exevo gran frigo hur"] = {level = 40, manaCost = 170},
    ["exevo gran mas flam"] = {level = 60, manaCost = 1100},
    ["exevo gran mas frigo"] = {level = 60, manaCost = 1050},
    ["exevo gran mas tera"] = {level = 55, manaCost = 700},
    ["exevo gran mas vis"] = {level = 55, manaCost = 600},
    ["exevo gran mort"] = {level = 41, manaCost = 250},
    ["exevo gran vis lux"] = {level = 29, manaCost = 110},
    ["exevo infir con"] = {level = 1, manaCost = 10},
    ["exevo infir flam hur"] = {level = 1, manaCost = 8},
    ["exevo infir frigo hur"] = {level = 1, manaCost = 8},
    ["exevo mas san"] = {level = 50, manaCost = 160},
    ["exevo pan"] = {level = 14, manaCost = 120},
    ["exevo tera hur"] = {level = 38, manaCost = 210},
    ["exevo vis hur"] = {level = 38, manaCost = 170},
    ["exevo vis lux"] = {level = 23, manaCost = 40},
    ["exori"] = {level = 35, manaCost = 115},
    ["exori amp vis"] = {level = 55, manaCost = 60},
    ["exori con"] = {level = 23, manaCost = 25},
    ["exori flam"] = {level = 14, manaCost = 20},
    ["exori frigo"] = {level = 15, manaCost = 20},
    ["exori gran"] = {level = 90, manaCost = 340},
    ["exori gran con"] = {level = 90, manaCost = 55},
    ["exori gran flam"] = {level = 70, manaCost = 60},
    ["exori gran frigo"] = {level = 80, manaCost = 60},
    ["exori gran ico"] = {level = 110, manaCost = 300},
    ["exori gran tera"] = {level = 70, manaCost = 60},
    ["exori gran vis"] = {level = 80, manaCost = 60},
    ["exori hur"] = {level = 28, manaCost = 40},
    ["exori ico"] = {level = 16, manaCost = 30},
    ["exori infir tera"] = {level = 1, manaCost = 6},
    ["exori infir vis"] = {level = 1, manaCost = 6},
    ["exori mas"] = {level = 33, manaCost = 160},
    ["exori max flam"] = {level = 90, manaCost = 100},
    ["exori max frigo"] = {level = 100, manaCost = 100},
    ["exori max tera"] = {level = 90, manaCost = 100},
    ["exori max vis"] = {level = 100, manaCost = 100},
    ["exori min"] = {level = 70, manaCost = 200},
    ["exori min flam"] = {level = 8, manaCost = 6},
    ["exori moe ico"] = {level = 16, manaCost = 20},
    ["exori mort"] = {level = 16, manaCost = 20},
    ["exori san"] = {level = 40, manaCost = 20},
    ["exori tera"] = {level = 13, manaCost = 20},
    ["exori vis"] = {level = 12, manaCost = 20},
    ["exura"] = {level = 8, manaCost = 20},
    ["exura dis"] = {level = 1, manaCost = 5},
    ["exura gran"] = {level = 20, manaCost = 70},
    ["exura gran ico"] = {level = 80, manaCost = 200},
    ["exura gran mas res"] = {level = 36, manaCost = 150},
    ["exura gran san"] = {level = 60, manaCost = 210},
    ["exura ico"] = {level = 8, manaCost = 40},
    ["exura infir"] = {level = 1, manaCost = 6},
    ["exura infir ico"] = {level = 1, manaCost = 10},
    ["exura san"] = {level = 35, manaCost = 160},
    ["exura vita"] = {level = 30, manaCost = 160},
    ["utamo mas sio"] = {level = 32, manaCost = 0},
    ["utamo tempo"] = {level = 55, manaCost = 200},
    ["utamo tempo san"] = {level = 55, manaCost = 400},
    ["utamo vita"] = {level = 14, manaCost = 50},
    ["utana vid"] = {level = 35, manaCost = 440},
    ["utani gran hur"] = {level = 20, manaCost = 100},
    ["utani hur"] = {level = 14, manaCost = 60},
    ["utani tempo hur"] = {level = 25, manaCost = 100},
    ["utevo gran lux"] = {level = 13, manaCost = 60},
    ["utevo gran res dru"] = {level = 200, manaCost = 3000},
    ["utevo gran res eq"] = {level = 200, manaCost = 1000},
    ["utevo gran res sac"] = {level = 200, manaCost = 2000},
    ["utevo gran res ven"] = {level = 200, manaCost = 3000},
    ["utevo lux"] = {level = 8, manaCost = 20},
    ["utevo vis lux"] = {level = 26, manaCost = 140},
    ["utito mas sio"] = {level = 32, manaCost = 0},
    ["utito tempo"] = {level = 60, manaCost = 290},
    ["utito tempo san"] = {level = 60, manaCost = 450},
    ["utori flam"] = {level = 26, manaCost = 30},
    ["utori kor"] = {level = 40, manaCost = 30},
    ["utori mas sio"] = {level = 32, manaCost = 0},
    ["utori mort"] = {level = 75, manaCost = 30},
    ["utori pox"] = {level = 50, manaCost = 30},
    ["utori san"] = {level = 70, manaCost = 30},
    ["utori vis"] = {level = 34, manaCost = 30},
    ["utura"] = {level = 50, manaCost = 75},
    ["utura gran"] = {level = 100, manaCost = 165},
    ["utura mas sio"] = {level = 32, manaCost = 0}
}

function getSpellCoolDown(text)
    if not text then return false end
    if text:lower() == "exura" then
        return modules.game_cooldown.isCooldownIconActive(1)
    elseif text:lower() == "exura gran" then
        return modules.game_cooldown.isCooldownIconActive(2)
    elseif text:lower() == "exura vita" then
        return modules.game_cooldown.isCooldownIconActive(3)
    elseif text:lower() == "exura gran mas res" then
        return modules.game_cooldown.isCooldownIconActive(82)
    elseif string.find(text:lower(), "exura sio") then
        return modules.game_cooldown.isCooldownIconActive(84)
    elseif string.find(text:lower(), "exiva") then
        return modules.game_cooldown.isCooldownIconActive(20)  
    elseif string.find(text:lower(), "exani hur") then
        return modules.game_cooldown.isCooldownIconActive(81)   
    elseif string.find(text:lower(), "utevo res ina") then
        return modules.game_cooldown.isCooldownIconActive(38) 
    elseif string.find(text:lower(), 'utevo res "' ) then
        return modules.game_cooldown.isCooldownIconActive(9)                   
    elseif text:lower() == "exana pox" then
        return modules.game_cooldown.isCooldownIconActive(29)
    elseif text:lower() == "utevo lux" then
        return modules.game_cooldown.isCooldownIconActive(10)
    elseif text:lower() == "exani tera" then
        return modules.game_cooldown.isCooldownIconActive(76)
    elseif text:lower() == "exori vis" then
        return modules.game_cooldown.isCooldownIconActive(88)
    elseif text:lower() == "utevo gran lux" then
        return modules.game_cooldown.isCooldownIconActive(11)
    elseif text:lower() == "utani hur" then
        return modules.game_cooldown.isCooldownIconActive(6)
    elseif text:lower() == "exori tera" then
        return modules.game_cooldown.isCooldownIconActive(113)
    elseif text:lower() == "exevo pan" then
        return modules.game_cooldown.isCooldownIconActive(42)
    elseif text:lower() == "utamo vita" then
        return modules.game_cooldown.isCooldownIconActive(44)
    elseif text:lower() == "exori flam" then
        return modules.game_cooldown.isCooldownIconActive(89)
    elseif text:lower() == "exori frigo" then
        return modules.game_cooldown.isCooldownIconActive(112)
    elseif text:lower() == "exori moe ico" then
        return modules.game_cooldown.isCooldownIconActive(148)
    elseif text:lower() == "exevo frigo hur" then
        return modules.game_cooldown.isCooldownIconActive(121)
    elseif text:lower() == "utani gran hur" then
        return modules.game_cooldown.isCooldownIconActive(39)
    elseif text:lower() == "exana vis" then
        return modules.game_cooldown.isCooldownIconActive(146)
    elseif text:lower() == "utevo vis lux" then
        return modules.game_cooldown.isCooldownIconActive(75)
    elseif text:lower() == "exana flam" then
        return modules.game_cooldown.isCooldownIconActive(145)
    elseif text:lower() == "utana vid" then
        return modules.game_cooldown.isCooldownIconActive(45)
    elseif text:lower() == "exevo tera hur" then
        return modules.game_cooldown.isCooldownIconActive(120)
    elseif text:lower() == "exevo gran frigo hur" then
        return modules.game_cooldown.isCooldownIconActive(43)
    elseif text:lower() == "exana kor" then
        return modules.game_cooldown.isCooldownIconActive(144)
    elseif text:lower() == "utori pox" then
        return modules.game_cooldown.isCooldownIconActive(142)
    elseif text:lower() == "exevo gran mas tera" then
        return modules.game_cooldown.isCooldownIconActive(56)
    elseif text:lower() == "exevo gran mas frigo" then
        return modules.game_cooldown.isCooldownIconActive(118)
    elseif text:lower() == "exevo gran mas tera" then
        return modules.game_cooldown.isCooldownIconActive(56)
    elseif text:lower() == "exori gran tera" then
        return modules.game_cooldown.isCooldownIconActive(153)
    elseif text:lower() == "exori max tera" then
        return modules.game_cooldown.isCooldownIconActive(157)
    elseif text:lower() == "exori gran frigo" then
        return modules.game_cooldown.isCooldownIconActive(152)
    elseif text:lower() == "exori max frigo" then
        return modules.game_cooldown.isCooldownIconActive(156)
    elseif text:lower() == "exori max tera" then
        return modules.game_cooldown.isCooldownIconActive(157)
    elseif text:lower() == "exori con" then
        return modules.game_cooldown.isCooldownIconActive(111)
    elseif text:lower() == "exura san" then
        return modules.game_cooldown.isCooldownIconActive(125)
    elseif text:lower() == "exevo mas san" then
        return modules.game_cooldown.isCooldownIconActive(124)
    elseif text:lower() == "utura" then
        return modules.game_cooldown.isCooldownIconActive(159)
    elseif text:lower() == "utura gran" then
        return modules.game_cooldown.isCooldownIconActive(160)
    elseif text:lower() == "utamo tempo san" then
        return modules.game_cooldown.isCooldownIconActive(134)
    elseif text:lower() == "utito tempo san" then
        return modules.game_cooldown.isCooldownIconActive(135)
    elseif text:lower() == "exura gran san" then
        return modules.game_cooldown.isCooldownIconActive(36)
    elseif text:lower() == "utori san" then
        return modules.game_cooldown.isCooldownIconActive(143)
    elseif text:lower() == "exana mort" then
        return modules.game_cooldown.isCooldownIconActive(147)
    elseif text:lower() == "exori gran con" then
        return modules.game_cooldown.isCooldownIconActive(57)
    elseif text:lower() == "exura ico" then
        return modules.game_cooldown.isCooldownIconActive(123)
    elseif text:lower() == "exeta res" then
        return modules.game_cooldown.isCooldownIconActive(93)
    elseif text:lower() == "utani tempo hur" then
        return modules.game_cooldown.isCooldownIconActive(131)
    elseif text:lower() == "utamo tempo" then
        return modules.game_cooldown.isCooldownIconActive(132)
    elseif text:lower() == "utito tempo" then
        return modules.game_cooldown.isCooldownIconActive(133)
    elseif text:lower() == "exura gran ico" then
        return modules.game_cooldown.isCooldownIconActive(158)
    elseif text:lower() == "exori hur" then
        return modules.game_cooldown.isCooldownIconActive(107)
    elseif text:lower() == "exori ico" then
        return modules.game_cooldown.isCooldownIconActive(61)
    elseif text:lower() == "exori" then
        return modules.game_cooldown.isCooldownIconActive(80)
    elseif text:lower() == "exori mas" then
        return modules.game_cooldown.isCooldownIconActive(106)
    elseif text:lower() == "exori gran" then
        return modules.game_cooldown.isCooldownIconActive(105)
    elseif text:lower() == "exori gran ico" then
        return modules.game_cooldown.isCooldownIconActive(62)
    elseif text:lower() == "exori min" then
        return modules.game_cooldown.isCooldownIconActive(59)
    elseif text:lower() == "exevo gran mas flam" then
        return modules.game_cooldown.isCooldownIconActive(24)
    elseif text:lower() == "exevo gran mas vis" then
        return modules.game_cooldown.isCooldownIconActive(119)
    elseif text:lower() == "exevo vis hur" then
        return modules.game_cooldown.isCooldownIconActive(13)
    elseif text:lower() == "exevo vis lux" then
        return modules.game_cooldown.isCooldownIconActive(22)  
    elseif text:lower() == "exevo gran vis lux" then
        return modules.game_cooldown.isCooldownIconActive(23)
    elseif text:lower() == "exori amp vis" then
        return modules.game_cooldown.isCooldownIconActive(149)
    elseif text:lower() == "exori gran vis" then
        return modules.game_cooldown.isCooldownIconActive(151)   
    elseif text:lower() == "exori gran flam" then
        return modules.game_cooldown.isCooldownIconActive(150)
    elseif text:lower() == "exori max vis" then
        return modules.game_cooldown.isCooldownIconActive(155)
    elseif text:lower() == "exori max flam" then
        return modules.game_cooldown.isCooldownIconActive(154)  
    elseif text:lower() == "exevo gran flam hur" then
        return modules.game_cooldown.isCooldownIconActive(150) 
    else
        return false
    end
end

storage.isUsing = false

onUse(function(pos, itemId, stackPos, subType)
    if pos.x < 65000 then
        storage.isUsing = true
    end
    schedule(1500, function() storage.isUsing = false end)
end)

function string.starts(String,Start)
 return string.sub(String,1,string.len(Start))==Start
end

function isFriend(name)
    if not name then return false end

    if getCreatureByName(name, true):isPlayer() and not getCreatureByName(name, true):isLocalPlayer() and table.find(storage.playerList.friendList, name) or string.find(storage.serverMembers, name) or table.find(storage.playerList.friendList, name:lower()) or (storage.playerList.groupMembers and ((getCreatureByName(name, true):getShield() >= 3 and getCreatureByName(name, true):getShield() <= 10) or getCreatureByName(name, true):getEmblem() == 2)) then
        return true
    else
        return false
    end
end

function isEnemy(name)
    if not name then return false end

    if getCreatureByName(name, true):isPlayer() and not getCreatureByName(name, true):isLocalPlayer() and table.find(storage.playerList.enemyList, name) or table.find(storage.playerList.enemyList, name:lower()) or (storage.playerList.marks and not isFriend(name)) then
        return true
    else
        return false
    end
end
  
function isAttSpell(expr)
  if string.starts(expr, "exori") or string.starts(expr, "exevo") then
    return true
  else 
    return false
  end
end

function getPlayerByName(name)
    if not name then
        return false
    end

    local creature
    for i, spec in pairs(getSpectators()) do
        if spec:isPlayer() and spec:getName():lower() == name:lower() then
            creature = spec
        end
    end

    if creature then
        return creature
    end
end

function getActiveItemId(id)
    if not id then
        return false
    end

    if id == 3049 then
        return 3086
    elseif id == 3050 then
        return 3087
    elseif id == 3051 then
        return 3088
    elseif id == 3052 then
        return 3089
    elseif id == 3053 then
        return 3090
    elseif id == 3091 then
        return 3094
    elseif id == 3092 then
        return 3095
    elseif id == 3093 then
        return 3096
    elseif id == 3097 then
        return 3099
    elseif id == 3098 then
        return 3100
    elseif id == 16114 then
        return 16264
    elseif id == 23531 then
        return 23532
    elseif id == 23533 then
        return 23534
    elseif id == 23529 then
        return  23530
    else
        return id
    end
end

function getInactiveItemId(id)
    if not id then
        return false
    end

    if id == 3086 then
        return 3049
    elseif id == 3087 then
        return 3050
    elseif id == 3088 then
        return 3051
    elseif id == 3089 then
        return 3052
    elseif id == 3090 then
        return 3053
    elseif id == 3094 then
        return 3091
    elseif id == 3095 then
        return 3092
    elseif id == 3096 then
        return 3093
    elseif id == 3099 then
        return 3097
    elseif id == 3100 then
        return 3098
    elseif id == 16264 then
        return 16114
    elseif id == 23532 then
        return 23531
    elseif id == 23534 then
        return 23533
    elseif id == 23530 then
        return  23529
    else
        return id
    end
end

function getMonstersInRange(pos, range)
    if not pos or not range then
        return false
    end
    local monsters = 0
    for i, spec in pairs(getSpectators()) do
        if spec:isMonster() and spec:getType() ~= 3 and getDistanceBetween(pos, spec:getPosition()) < range then
            monsters = monsters + 1
        end
    end
    return monsters
end

function distanceFromPlayer(coords)
    if not coords then
        return false
    end
    return getDistanceBetween(pos(), coords)
end

function getMonsters(range, multifloor)
    if not range then
        range = 10
    end
    local mobs = 0;
    for _, spec in pairs(getSpectators(multifloor)) do
      mobs = spec:getType() ~= 3 and spec:isMonster() and distanceFromPlayer(spec:getPosition()) <= range and mobs + 1 or mobs;
    end
    return mobs;
end

function getPlayers(range, multifloor)
    if not range then
        range = 10
    end
    local specs = 0;
    for _, spec in pairs(getSpectators(multifloor)) do
        specs = not spec:isLocalPlayer() and spec:isPlayer() and distanceFromPlayer(spec:getPosition()) <= range and not ((spec:getShield() >= 3 and spec:getShield() <= 10) or spec:getEmblem() == 1) and specs + 1 or specs;
    end
    return specs;
end

function isSafe(range, multifloor, padding)
    local onSame = 0
    local onAnother = 0
    if not multifloor and padding then
        multifloor = false
        padding = false
    end

    for _, spec in pairs(getSpectators(multifloor)) do
        if spec:isPlayer() and not spec:isLocalPlayer() and not isFriend(spec:getName()) then
            if spec:getPosition().z == posz() and distanceFromPlayer(spec:getPosition()) <= range then
                onSame = onSame + 1
            end
            if multifloor and padding and spec:getPosition().z ~= posz() and distanceFromPlayer(spec:getPosition()) <= (range + padding) then
                onAnother = onAnother + 1
            end
        end
    end

    if onSame + onAnother > 0 then
        return false
    else
        return true
    end
end

function getAllPlayers(range, multifloor)
    if not range then
        range = 10
    end
    local specs = 0;
    for _, spec in pairs(g_map.getSpectators(multifloor)) do
        specs = not spec:isLocalPlayer() and spec:isPlayer() and distanceFromPlayer(spec:getPosition()) <= range and specs + 1 or specs;
    end
    return specs;
end

function getNpcs(range, multifloor)
    if not range then
        range = 10
    end
    local npcs = 0;
    for _, spec in pairs(g_map.getSpectators(multifloor)) do
        npcs = spec:isNpc() and distanceFromPlayer(spec:getPosition()) <= range and npcs + 1 or npcs;
    end
    return npcs;
end

function itemAmount(id)
    local totalItemCount = 0
    for _, container in pairs(getContainers()) do
        for _, item in ipairs(container:getItems()) do
            totalItemCount = item:getId() == id and totalItemCount + item:getCount() or totalItemCount 
        end
    end
    if getHead() and getHead():getId() == id then
        totalItemCount = totalItemCount + getHead():getCount()
    end
    if getNeck() and getNeck():getId() == id then
        totalItemCount = totalItemCount + getNeck():getCount()
    end
    if getBack() and getBack():getId() == id then
        totalItemCount = totalItemCount + getBack():getCount()
    end
    if getBody() and getBody():getId() == id then
        totalItemCount = totalItemCount + getBody():getCount()
    end
    if getRight() and getRight():getId() == id then
        totalItemCount = totalItemCount + getRight():getCount()
    end
    if getLeft() and getLeft():getId() == id then
        totalItemCount = totalItemCount + getLeft():getCount()
    end
    if getLeg() and getLeg():getId() == id then
        totalItemCount = totalItemCount + getLeg():getCount()
    end
    if getFeet() and getFeet():getId() == id then
        totalItemCount = totalItemCount + getFeet():getCount()
    end
    if getFinger() and getFinger():getId() == id then
        totalItemCount = totalItemCount + getFinger():getCount()
    end
    if getAmmo() and getAmmo():getId() == id then
        totalItemCount = totalItemCount + getAmmo():getCount()
    end
    return totalItemCount
end

function cordsToPos(x, y, z)
    if not x or not y or not z then
        return false
    end
    local tilePos = pos()
     tilePos.x = x
     tilePos.y = y
     tilePos.z = z
    return tilePos
end

function reachGroundItem(id)
    local targetTile
    for _, tile in ipairs(g_map.getTiles(posz())) do
        if tile:getTopUseThing():getId() == id then
            targetTile = tile:getPosition()
        end
    end
    if distanceFromPlayer(targetTile) > 1 then
        if CaveBot.walkTo(targetTile, 10, {ignoreNonPathable = true, precision=1}) then
            delay(200)
        end
    else
        return true
    end
end

function useGroundItem(id)
    if not id then
        return false
    end
    local targetTile = nil
    for _, tile in ipairs(g_map.getTiles(posz())) do
        if tile:getTopUseThing():getId() == id then
            targetTile = tile:getPosition()
        end
    end
    if targetTile then
        if distanceFromPlayer(targetTile) > 1 then
            if CaveBot.walkTo(targetTile, 20, {ignoreNonWalkable = true, ignoreNonPathable = true, precision=1}) then
                delay(200)
            end
        else
            g_game.use(g_map.getTile(targetTile):getTopUseThing())
         return true
        end
    else
        return "retry"
    end
end

function target()
    if not g_game.isAttacking() then
        return 
    else
        return g_game.getAttackingCreature()
    end
end

function getTarget()
    return target()
end

function targetPos(dist)
    if not g_game.isAttacking() then
        return
    end
    if dist then
        return distanceFromPlayer(target():getPosition())
    else
        return target():getPosition()
    end
end

-- for gunzodus
function reopenPurse()
    schedule(100, function() g_game.open(findItem(23721)) return true end)
    schedule(1400, function() g_game.open(findItem(23721)) return true end)
    CaveBot.delay(1500)
	return true
end

-- getSpectator patterns

function getCreaturesInArea(param1, param2, param3)
    -- param1 - pos/creature
    -- param2 - pattern
    -- param3 - type of return
    -- 1 - everyone, 2 - monsters, 3 - players
    local specs = 0
    local monsters = 0
    local players = 0
    for i, spec in pairs(getSpectators(param1, param2)) do
        if spec ~= player then
            specs = specs + 1
            if spec:isMonster() then
                monsters = monsters + 1
            elseif spec:isPlayer() and not isFriend(spec:getName()) then
                players = players +1
            end
        end
    end

    if param3 == 1 then
        return specs
    elseif param3 == 2 then
        return monsters
    else
        return players
    end
end

function getBestTileByPatern(pattern, specType, maxDist, safe)
    if not pattern or not specType then return end
    if not maxDist then maxDist = 4 end
    if not safe then safe = false end

    local fieldList = {}
    local bestTile = nil
    -- best area tile to use
    for _, tile in pairs(g_map.getTiles(posz())) do
      if tile:canShoot() and distanceFromPlayer(tile:getPosition()) <= maxDist and tile:isWalkable() and getCreaturesInArea(tile:getPosition(), pattern, specType) > 0 and (not safe or getCreaturesInArea(tile:getPosition(), pattern, 3) == 0) then 
        table.insert(fieldList, {pos = tile, count = getCreaturesInArea(tile:getPosition(), pattern, specType)})
      end
    end
    table.sort(fieldList, function(a,b) return a.count > b.count end)

        bestTile = fieldList[1]
    
    if bestTile then
        return bestTile
    else
        return false
    end
end

LargeUeArea = [[
    0000001000000
    0000011100000
    0000111110000
    0001111111000
    0011111111100
    0111111111110
    1111111111111
    0111111111110
    0011111111100
    0001111111000
    0000111110000
    0000011100000
    0000001000000
]]

NormalUeAreaMs = [[
    00000100000
    00011111000
    00111111100
    01111111110
    01111111110
    11111111111
    01111111110
    01111111110
    00111111100
    00001110000
    00000100000
]]

NormalUeAreaEd = [[
    00000100000
    00001110000
    00011111000
    00111111100
    01111111110
    11111111111
    01111111110
    00111111100
    00011111000
    00001110000
    00000100000
]]

smallUeArea = [[
    0011100
    0111110
    1111111
    1111111
    1111111
    0111110
    0011100
]]

largeRuneArea = [[
    0011100
    0111110
    1111111
    1111111
    1111111
    0111110
    0011100
]]

adjacentArea = [[
    111
    101
    111
]]

longBeamArea = [[
    0000000N0000000
    0000000N0000000
    0000000N0000000
    0000000N0000000
    0000000N0000000
    0000000N0000000
    0000000N0000000
    WWWWWWW0EEEEEEE
    0000000S0000000
    0000000S0000000
    0000000S0000000
    0000000S0000000
    0000000S0000000
    0000000S0000000
    0000000S0000000
]]

shortBeamArea = [[
    00000100000
    00000100000
    00000100000
    00000100000
    00000100000
    EEEEE0WWWWW
    00000S00000
    00000S00000
    00000S00000
    00000S00000
    00000S00000
]]

newWaveArea = [[
    000NNNNN000
    000NNNNN000
    0000NNN0000
    WW00NNN00EE
    WWWW0N0EEEE
    WWWWW0EEEEE
    WWWW0S0EEEE
    WW00SSS00EE
    0000SSS0000
    000SSSSS000
    000SSSSS000
]]  

bigWaveArea = [[
    0000NNN0000
    0000NNN0000
    0000NNN0000
    00000N00000
    WWW00N00EEE
    WWWWW0EEEEE
    WWW00S00EEE
    00000S00000
    0000SSS0000
    0000SSS0000
    0000SSS0000
]]


smallWaveArea = [[
    00NNN00
    00NNN00
    WW0N0EE
    WWW0EEE
    WW0S0EE
    00SSS00
    00SSS00
]]

diamondArrowArea = [[
    01110
    11111
    11111
    11111
    01110
]]