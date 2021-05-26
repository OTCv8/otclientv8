CaveBot = {} -- global namespace

-------------------------------------------------------------------
-- CaveBot lib 1.0
-- Contains a universal set of functions to be used in CaveBot

----------------------[[ basic assumption ]]-----------------------
-- in general, functions cannot be slowed from within, only externally, by event calls, delays etc.
-- considering that and the fact that there is no while loop, every function return action
-- thus, functions will need to be verified outside themselfs or by another function
-- overall tips to creating extension:
--   - functions return action(nil) or true(done)
--   - extensions are controlled by retries var
-------------------------------------------------------------------

-- local variables, constants and functions, used by global functions
local LOCKERS_LIST = {3497, 3498, 3499, 3500}

local function CaveBotConfigParse()
	local name = storage["_configs"]["targetbot_configs"]["selected"]
	local file = configDir .. "/targetbot_configs/" .. name .. ".json"
	local data = g_resources.readFileContents(file)
	return Config.parse(data)['looting']
end

local function getNearTiles(pos)
    if type(pos) ~= "table" then
        pos = pos:getPosition()
    end

    local tiles = {}
    local dirs = {
        {-1, 1},
        {0, 1},
        {1, 1},
        {-1, 0},
        {1, 0},
        {-1, -1},
        {0, -1},
        {1, -1}
    }
    for i = 1, #dirs do
        local tile =
            g_map.getTile(
            {
                x = pos.x - dirs[i][1],
                y = pos.y - dirs[i][2],
                z = pos.z
            }
        )
        if tile then
            table.insert(tiles, tile)
        end
    end

    return tiles
end

-- ##################### --
-- [[ Information class ]] --
-- ##################### --

--- global variable to reflect current CaveBot status
CaveBot.Status = "waiting"

--- Parses config and extracts loot list.
-- @return table
function CaveBot.GetLootItems()
    local t = CaveBotConfigParse()["items"]

    local returnTable = {}
    for i, item in pairs(t) do
        table.insert(returnTable, item["id"])
    end

    return returnTable
end

--- Parses config and extracts loot containers.
-- @return table
function CaveBot.GetLootContainers()
    local t = CaveBotConfigParse()["containers"]

    local returnTable = {}
    for i, container in pairs(t) do
        table.insert(returnTable, container["id"])
    end

    return returnTable
end

--- Information about open containers.
-- @param amount is boolean
-- @return table or integer
function CaveBot.GetOpenedLootContainers(containerTable)
    local containers = CaveBot.GetLootContainers()

    local t = {}
    for i, container in pairs(getContainers()) do
        local containerId = container:getContainerItem():getId()
        if table.find(containers, containerId) then
            table.insert(t, container)
        end
    end

    return containerTable and t or #t
end

--- Some actions needs to be additionally slowed down in case of high ping.
-- Maximum at 2000ms in case of lag spike.
-- @param multiplayer is integer
-- @return void
function CaveBot.PingDelay(multiplayer)
    multiplayer = multiplayer or 1
    if ping() and ping() > 150 then -- in most cases ping above 150 affects CaveBot
        local value = math.min(ping() * multiplayer, 2000)
        return delay(value)
    end
end

-- ##################### --
-- [[ Container class ]] --
-- ##################### --

--- Closes any loot container that is open.
-- @return void or boolean
function CaveBot.CloseLootContainer()
    local containers = CaveBot.GetLootContainers()

    for i, container in pairs(getContainers()) do
        local containerId = container:getContainerItem():getId()
        if table.find(containers, containerId) then
            return g_game.close(container)
        end
    end

    return true
end

--- Opens any loot container that isn't already opened.
-- @return void or boolean
function CaveBot.OpenLootContainer()
    local containers = CaveBot.GetLootContainers()

    local t = {}
    for i, container in pairs(getContainers()) do
        local containerId = container:getContainerItem():getId()
        table.insert(t, containerId)
    end

    for _, container in pairs(getContainers()) do
        for _, item in pairs(container:getItems()) do
            local id = item:getId()
            if table.find(containers, id) and not table.find(t, id) then
                test()
                return g_game.open(item)
            end
        end
    end

    return true
end

-- ##################### --
-- [[[ Position class ]] --
-- ##################### --

--- Compares distance between player position and given pos.
-- @param position is table
-- @param distance is integer
-- @return boolean
function CaveBot.MatchPosition(position, distance)
    local pPos = player:getPosition()
    distance = distance or 1
    return getDistanceBetween(pPos, position) <= distance
end

--- Stripped down to take less space.
-- Use only to safe position, like pz movement or reaching npc.
-- Needs to be called between 200-500ms to achieve fluid movement.
-- @param position is table
-- @param distance is integer
-- @return void
function CaveBot.GoTo(position, precision)
    if not precision then
        precision = 3
    end
    return CaveBot.walkTo(position, 20, {ignoreNonPathable = true, precision = precision})
end

--- Finds position of npc by name and reaches its position.
-- @return void(acion) or boolean
function CaveBot.ReachNPC(name)
    name = name:lower()
    
    local npc = nil
    for i, spec in pairs(getSpectators()) do
        if spec:isNpc() and spec:getName():lower() == name then
            npc = spec
        end
    end

    if not CaveBot.MatchPosition(npc:getPosition(), 3) then
        CaveBot.GoTo(npc:getPosition())
    else
        return true
    end
end

-- ##################### --
-- [[[[ Depot class ]]]] --
-- ##################### --

--- Reaches closest locker.
-- @return void(acion) or boolean
function CaveBot.ReachDepot()
    local pPos = player:getPosition()
    local tiles = getNearTiles(player:getPosition())

    for i, tile in pairs(tiles) do
        for i, item in pairs(tile:getItems()) do
            if table.find(LOCKERS_LIST, item:getId()) then
                return true -- if near locker already then return function
            end
        end
    end

    local candidate = {}

    for i, tile in pairs(g_map.getTiles(posz())) do
        local tPos = tile:getPosition()
        local distance = getDistanceBetween(pPos, tPos)
        for i, item in pairs(tile:getItems()) do
            if table.find(LOCKERS_LIST, item:getId()) then
                if findPath(pos(), tPos, 10, {ignoreNonPathable = true, precision = 1}) then
                    if #candidate == 0 or candidate.dist < distance then
                        candidate = {pos = tPos, dist = distance}
                    end
                end
            end
        end
    end

    if candidate.pos then
        if not CaveBot.MatchPosition(candidate.pos) then
            CaveBot.GoTo(candidate.pos, 1)
        else
            return true
        end
    end
end

--- Opens locker item.
-- @return void(acion) or boolean
function CaveBot.OpenLocker()
    local pPos = player:getPosition()
    local tiles = getNearTiles(player:getPosition())

    local locker = getContainerByName("Locker")
    if not locker then
        for i, tile in pairs(tiles) do
            for i, item in pairs(tile:getItems()) do
                if table.find(LOCKERS_LIST, item:getId()) then
                    local topThing = tile:getTopUseThing()
                    if not topThing:isNotMoveable() then
                        g_game.move(topThing, pPos, topThing:getCount())
                    else
                        return g_game.open(item)
                    end
                end
            end
        end
    else
        return true
    end
end

--- Opens depot chest.
-- @return void(acion) or boolean
function CaveBot.OpenDepotChest()
    local depot = getContainerByName("Depot chest")
    if not depot then
        local locker = getContainerByName("Locker")
        if not locker then
            return CaveBot.OpenLocker()
        end
        for i, item in pairs(locker:getItems()) do
            if item:getId() == 3502 then
                return g_game.open(item, locker)
            end
        end
    else
        return true
    end
end

--- Opens inbox inside locker.
-- @return void(acion) or boolean
function CaveBot.OpenInbox()
    local inbox = getContainerByName("Your inbox")
    if not inbox then
        local locker = getContainerByName("Locker")
        if not locker then
            return CaveBot.OpenLocker()
        end
        for i, item in pairs(locker:getItems()) do
            if item:getId() == 12902 then
                return g_game.open(item)
            end
        end
    else
        return true
    end
end

--- Opens depot box of given number.
-- @param index is integer
-- @return void or boolean
function CaveBot.OpenDepotBox(index)
    local depot = getContainerByName("Depot chest")
    if not depot then
        return CaveBot.OpenDepotChest()
    end

    local foundParent = false
    for i, container in pairs(getContainers()) do
        if container:getName():lower():find("depot box") then
            foundParent = container
            break
        end
    end
    if foundParent then return true end

    for i, container in pairs(depot:getItems()) do
        if i == index then
            return g_game.open(container)
        end
    end
end

--- Reaches and opens depot.
-- Combined for shorthand usage.
-- @return boolean whether succeed to reach and open depot
function CaveBot.ReachAndOpenDepot()
    if CaveBot.ReachDepot() and CaveBot.OpenDepotChest() then 
        return true 
    end
    return false
end

--- Reaches and opens imbox.
-- Combined for shorthand usage.
-- @return boolean whether succeed to reach and open depot
function CaveBot.ReachAndOpenInbox()
    if CaveBot.ReachDepot() and CaveBot.OpenInbox() then 
        return true 
    end
    return false
end

--- Stripped down function to stash item.
-- @param item is object
-- @param index is integer
-- @param destination is object
-- @return void
function CaveBot.StashItem(item, index, destination)
    local depotContainer
    if not destination then
        depotContainer = getContainerByName("Depot chest")
    end
    if not depotContainer then return false end

    return g_game.move(item, depotContainer:getSlotPosition(index), item:getCount())
end

--- Withdraws item from depot chest or mail inbox.
-- main function for depositer/withdrawer
-- @param id is integer
-- @param amount is integer
-- @param fromDepot is boolean or integer
-- @param destination is object
-- @return void
function CaveBot.WithdrawItem(id, amount, fromDepot, destination)
    if destination and type(destination) == "string" then
        destination = getContainerByName(destination)
    end
    local itemCount = itemAmount(id)

    local depot
    for i, container in pairs(getContainers()) do
        if container:getName():lower():find("depot box") or container:getName():lower():find("your inbox") then
            depot = container
            break
        end
    end
    if not depot then
        if fromDepot then
            if not CaveBot.OpenDepotBox(fromDepot) then return end
        else
            return CaveBot.ReachAndOpenInbox()
        end
        return
    end
    if not destination then
        for i, container in pairs(getContainers()) do
            if container:getCapacity() > #container:getItems() and not string.find(container:getName():lower(), "quiver") and not string.find(container:getName():lower(), "depot") and not string.find(container:getName():lower(), "loot") and not string.find(container:getName():lower(), "inbox") then
                destination = container
            end
        end
    end

    if itemCount >= amount then 
        return true 
    end

    local toMove = amount - itemCount
    info(toMove)
    for i, item in pairs(depot:getItems()) do
        if item:getId() == id then
            return g_game.move(item, destination:getSlotPosition(destination:getItemsCount()), math.min(toMove, item:getCount()))
        end
    end
end

-- ##################### --
-- [[[[[ Talk class ]]]] --
-- ##################### --

--- Controlled by event caller.
-- Simple way to build npc conversations instead of multiline overcopied code.
-- @return void
function CaveBot.Conversation(...)
    local expressions = {...}
    local delay = storage.extras.talkDelay or 1000

    local talkDelay = 0
    for i, expr in ipairs(expressions) do
        schedule(talkDelay, function() NPC.say(expr) end)
        talkDelay = talkDelay + delay
    end
end

--- Says hi trade to NPC.
-- Used as shorthand to open NPC trade window.
-- @return void
function CaveBot.OpenNpcTrade()
    return CaveBot.Conversation("hi", "trade")
end

--- Says hi destination yes to NPC.
-- Used as shorthand to travel.
-- @param destination is string
-- @return void
function CaveBot.Travel(destination)
    return CaveBot.Conversation("hi", destination, "yes")
end