-- Author: Vithrax
-- contains mostly basic function shortcuts and code shorteners

function containerIsFull(c)
    if not c then return false end
  
    if c:getCapacity() > #c:getItems() then
      return false
    else
      return true
    end
  
end

function isBuffed()
    local var = false
    for i=1,4 do
        local premium = (player:getSkillLevel(i) - player:getSkillBaseLevel(i))
        local base = player:getSkillBaseLevel(i)
        if hasPartyBuff() and (premium/100)*305 > base then
            var = true
        end
    end
    return var
end

function reindexTable(t)
    if not t or type(t) ~= "table" then return end

    local i = 0
    for _, e in pairs(t) do
        i = i + 1
        e.index = i
    end
end

function killsToRs()
    return math.min(g_game.getUnjustifiedPoints().killsDayRemaining, g_game.getUnjustifiedPoints().killsWeekRemaining, g_game.getUnjustifiedPoints().killsMonthRemaining)
end

local Spells = modules.gamelib.SpellInfo['Default']

function canCast(spell, ignoreMana)
    if type(spell) ~= "string" then return end
    if not getSpellData(spell) then return true end
    if not getSpellCoolDown(spell) and level() >= getSpellData(spell).level and (ignoreMana or mana() >= getSpellData(spell).mana) then
        return true
    else
        return false
    end
end

function getSpellData(spell)
    if not spell then return false end
    local t = nil
    for k,v in pairs(Spells) do
        if v.words == spell then
            t = k
            break
        end
    end
    if t then
        return Spells[t]
    else
        return false
    end
end

function getSpellCoolDown(text)
    if not text then return false end
    if not getSpellData(text) then return false end
    for i,v in pairs(Spells) do
        if v.words == text then
            return modules.game_cooldown.isCooldownIconActive(v.id)
        end
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

    if table.find(storage.playerList.friendList, name) then
        return true
    elseif string.find(storage.serverMembers, name) then
        return true
    elseif storage.playerList.groupMembers then
        local p = getCreatureByName(name, true)
        if p:isLocalPlayer() then return true end
        if p:isPlayer() then
            if ((p:getShield() >= 3 and p:getShield() <= 10) or p:getEmblem() == 2) then
                return true
            else
                return false
            end
        end
    else
        return false
    end
end

function isEnemy(name)
    if not name then return false end
    local p = getCreatureByName(name, true)
    if p:isLocalPlayer() then return end

    if p:isPlayer() and table.find(storage.playerList.enemyList, name) or (storage.playerList.marks and not isFriend(name)) then
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
            if spec:isMonster() and spec:getType() ~= 3 then
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


    local bestTile = nil
    local best = nil
    -- best area tile to use
    for _, tile in pairs(g_map.getTiles(posz())) do
        if distanceFromPlayer(tile:getPosition()) <= maxDist then
            local minimapColor = g_map.getMinimapColor(tile:getPosition())
            local stairs = (minimapColor >= 210 and minimapColor <= 213)
            if tile:canShoot() and tile:isWalkable() and not stairs then
                if getCreaturesInArea(tile:getPosition(), pattern, specType) > 0 then
                    if (not safe or getCreaturesInArea(tile:getPosition(), pattern, 3) == 0) then 
                        local candidate = {pos = tile, count = getCreaturesInArea(tile:getPosition(), pattern, specType)}
                        if not best or best.count <= candidate.count then
                            best = candidate
                        end
                    end
                end
            end
        end
    end

    bestTile = best
    
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