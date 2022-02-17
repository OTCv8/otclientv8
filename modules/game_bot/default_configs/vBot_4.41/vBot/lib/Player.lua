Player = {}

--- opens main backpack
-- @return void 
function Player:openMain()
    local back = getBack()

    if back then g_game.open(back) end
end

--- opens purse/store inbox slot
-- @return void
function Player:openPurse()
    local purse = getPurse()

    if item then use(purse) end
end

--- player says certain phrase or sequence
-- @param text is string or table
-- @param npc is boolean
-- @return void
function Player:speak(text, npc, wait)
    if type(text) == "string" then
        if npc then
            return NPC.say(text)
        else
            return say(text)
        end
    end

    -- text is table, therefore sequence
    local talkDelay = 0
    local globalDelay = storage.extras.talkDelay

    for i, string in ipairs(text) do

        schedule(talkDelay, function()

            if npc then
                return NPC.say(string)
            else
                return say(string)
            end

        end)

        talkDelay = talkDelay + globalDelay
    end
    if wait then delay( talkDelay + globalDelay ) end
end


function Player:getId()
    return player:getId()
end

function Player:getName()
    return player:getName()
end

function Player:getTarget()
    return g_game.getAttackingCreature()
end

function Player:getTargetName()
    return Player:getTarget():getName()
end

function Player:getTargetPosition()
    return Player:getTarget():getPosition()
end

function Player:getDistanceFromTarget()
    return getDistanceBetween(Player:getPosition(), Player:getTargetPosition())
end

function Player:getPosition()
    return player:getPosition()
end

function Player:getLookDirection()
    return player:getDirection()
end

function Player:getLookPosition(range)
    local dir = Player:getLookDirection()
    local pos = Player:getPosition()
	local n = range or 1
	if (dir == NORTH) then
		pos.y = pos.y - n
	elseif (dir == SOUTH) then
		pos.y = pos.y + n
	elseif (dir == WEST) then
		pos.x = pos.x - n
	elseif (dir == EAST) then
		pos.x = pos.x + n
	end
	return pos
end