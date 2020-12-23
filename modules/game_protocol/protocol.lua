local registredOpcodes = nil

local ServerPackets = {
	DailyRewardCollectionState = 0xDE,
	OpenRewardWall = 0xE2,
	CloseRewardWall = 0xE3,
	DailyRewardBasic = 0xE4,
	DailyRewardHistory = 0xE5,
	RestingAreaState = 0xA9,
	BestiaryData = 0xd5,
	BestiaryOverview = 0xd6,
	BestiaryMonsterData = 0xd7,
	BestiaryCharmsData = 0xd8,
	BestiaryTracker = 0xd9,
	BestiaryTrackerTab = 0xB9,
	BlessingDialog = 0x9B,
	BlessingStatus = 0x9C,	
	PreyShowDialog = 0xED,
	PreyRerollPrice = 0xE9,
	PreyData = 0xE8,
	PreyTimeLeft = 0xE7,
	HirelingOutfit = 0xC8
}

-- Server Types
local DAILY_REWARD_TYPE_ITEM = 1
local DAILY_REWARD_TYPE_STORAGE = 2
local DAILY_REWARD_TYPE_PREY_REROLL = 3
local DAILY_REWARD_TYPE_XP_BOOST = 4

-- Client Types
local DAILY_REWARD_SYSTEM_SKIP = 1
local DAILY_REWARD_SYSTEM_TYPE_ONE = 1
local DAILY_REWARD_SYSTEM_TYPE_TWO = 2
local DAILY_REWARD_SYSTEM_TYPE_OTHER = 1
local DAILY_REWARD_SYSTEM_TYPE_PREY_REROLL = 2
local DAILY_REWARD_SYSTEM_TYPE_XP_BOOST = 3

-- Prey
local LOCKED = 0
local INACTIVE = 1
local ACTIVE = 2
local SELECTION = 3
local SELECTION_CHANGE_MONSTER = 4
local SELECTION_LIST = 5
local SELECTION_WITH_WILDCARD = 6

-- Hirelings
local HIRELINGS_BUTTON = 1
local HIRELINGS_DRESS = 4

function init()
  connect(g_game, { onEnterGame = registerProtocol,
                    onPendingGame = registerProtocol,
                    onGameEnd = unregisterProtocol })
  if g_game.isOnline() then
    registerProtocol()
  end
end

function terminate()
  disconnect(g_game, { onEnterGame = registerProtocol,
                    onPendingGame = registerProtocol,
                    onGameEnd = unregisterProtocol })
                    
  unregisterProtocol()
end

function registerProtocol()
  if registredOpcodes ~= nil or not g_game.getFeature(GameTibia12Protocol) then
    return
  end
  
  registredOpcodes = {}

  registerOpcode(ServerPackets.DailyRewardCollectionState, function(protocol, msg)
    msg:getU8()
  end)
  
  registerOpcode(ServerPackets.OpenRewardWall, function(protocol, msg)
    msg:getU8()
    msg:getU32()
    msg:getU8()
    local taken = msg:getU8()
    if taken > 0 then
      msg:getString()
    end
    if g_game.getClientVersion() >= 1260 then
        local token = msg:getU8()
        if token == 1 then
            msg:getU16()
        elseif token == 2 then
            msg:getU32()
            msg:getU16()
        end
    else
        msg:getU32()
        msg:getU16()
    end
    msg:getU16()
  end)

  registerOpcode(ServerPackets.CloseRewardWall, function(protocol, msg)

  end)

  registerOpcode(ServerPackets.DailyRewardBasic, function(protocol, msg)
    local count = msg:getU8()
    for i = 1, count do
      readDailyReward(msg)
      readDailyReward(msg)
    end
    local maxBonus = msg:getU8()
    for i = 1, maxBonus do
      msg:getString()
      msg:getU8()
    end
    msg:getU8()
  end)
  
  registerOpcode(ServerPackets.DailyRewardHistory, function(protocol, msg)
    local count = msg:getU8()
    for i=1,count do
      msg:getU32()
      msg:getU8()
      msg:getString()
      msg:getU16()
    end
  end)
  
  registerOpcode(ServerPackets.RestingAreaState, function(protocol, msg)
	msg:getU8()
	msg:getU8()
    msg:getString()
  end)
  
  registerOpcode(ServerPackets.BestiaryData, function(protocol, msg)
	local count = msg:getU16()
    for i = 1, count do
		msg:getString()
		msg:getU16()
		msg:getU16()
	end
  end)
  
  registerOpcode(ServerPackets.BestiaryOverview, function(protocol, msg)
	msg:getString()
	local size = msg:getU16()
    for i = 1, size do
		msg:getU16()
		local progress = msg:getU8()
		if progress > 0 and g_game.getClientVersion() >= 1180 then
			msg:getU8()
		end
	end
  end)
  
  registerOpcode(ServerPackets.BestiaryMonsterData, function(protocol, msg)
	msg:getU16()
	msg:getString()
	
	local progresslevel = msg:getU8()
	msg:getU32()
	
	msg:getU16()
	msg:getU16()
	msg:getU16()
	
	local diff = msg:getU8()
	if g_game.getClientVersion() >= 1180 then
		msg:getU8()
	end
	
	local lootsize = msg:getU8()
    for i = 1, lootsize do
		msg:getU16()
		msg:getU8()
		if g_game.getClientVersion() >= 1180 then
			msg:getU8()
		end
		
		if progresslevel > 1 then
			msg:getString()
			msg:getU8()
		end
	end
	
	if g_game.getClientVersion() >= 1180 then
		if progresslevel > 1 then
			msg:getU32()
			msg:getU32()
			msg:getU32()
			msg:getU16()
			msg:getU16()
			if progresslevel > 2 then
				local elements = msg:getU8()
				for i = 1, elements do
					msg:getU8()
					msg:getU16()
				end
		
				local locations = msg:getU16()
				for i = 1, locations do
					msg:getString()
				end
				if progresslevel > 3 then
					local hascharm = msg:getU8()
					if hascharm > 0 then
						msg:getU8()
						msg:getU32()
					else
						msg:getU8()
					end
				end
			end
		end
	else

		if diff == 3 or (diff == 2 and progresslevel > 1) then
			msg:getU32()
			msg:getU32()
			msg:getU32()
			msg:getU16()
			msg:getU16()
		end

		if (diff == 3 and progresslevel > 2) or (diff == 2 and progresslevel > 2) then
			local stats = msg:getU8()
			for i = 1, elements do
				msg:getU8()
				msg:getU16()
			end

			local loc = msg:getU16()
			for i = 1, elements do
				msg:getString()
			end

			if (diff == 3 and progresslevel ~= 3) or (diff == 2 and progresslevel > 1) then
				msg:getU16()
			end
		end
		
	end
  end)
  
  registerOpcode(ServerPackets.BestiaryCharmsData, function(protocol, msg)
	sendBestiaryCharmsData(msg)
  end)
  
  registerOpcode(ServerPackets.BestiaryTracker, function(protocol, msg)
	msg:getU16()
	if g_game.getClientVersion() >= 1159 and g_game.getClientVersion() <= 1190 then
		msg:getU8()
	end
  end)

  registerOpcode(ServerPackets.BestiaryTrackerTab, function(protocol, msg)
    local count = msg:getU8()
    for i = 1, count do
      msg:getU16()
      msg:getU32()
      msg:getU16()
      msg:getU16()
      msg:getU16()
      msg:getU8()
    end
  end)

  registerOpcode(ServerPackets.BlessingDialog, function(protocol, msg)
	local size = msg:getU8()
    for i = 1, size do
		msg:getU16()
		msg:getU8()
		if g_game.getClientVersion() >= 1220 then
			msg:getU8()
		end
	end
	
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU8()
	
	local history = msg:getU8()
    for i = 1, history do
		msg:getU32()
		msg:getU8()
		msg:getString()
	end
  end)
  
  registerOpcode(ServerPackets.BlessingStatus, function(protocol, msg)
	msg:getU8()
	msg:getU16()
  end)
  
  registerOpcode(ServerPackets.PreyShowDialog, function(protocol, msg)
	msg:getU8()
	msg:getString()
  end)
  
  registerOpcode(ServerPackets.PreyRerollPrice, function(protocol, msg)
	msg:getU32()
	if g_game.getClientVersion() >= 1190 then
		msg:getU8()
		msg:getU8()	
		if g_game.getClientVersion() >= 1230 then
			msg:getU32()
			msg:getU32()
			msg:getU8()
			msg:getU8()
		end
	end
  end)
  
  registerOpcode(ServerPackets.PreyData, function(protocol, msg)
	msg:getU8()
	local state = msg:getU8()
	if state == SELECTION_CHANGE_MONSTER then
		msg:getU8()
		msg:getU16()
		msg:getU8()
		
		local list = msg:getU8()
		for i = 1, list do
			msg:getString()
			msg:getU16()
			msg:getU8()
			msg:getU8()
			msg:getU8()
			msg:getU8()
			msg:getU8()
		end
	elseif state == SELECTION_LIST then
		local sizelist = msg:getU16()
		for i = 1, sizelist do
			msg:getU16()
		end
	elseif state == SELECTION then
		local list = msg:getU8()
		for i = 1, list do
			msg:getString()
			msg:getU16()
			msg:getU8()
			msg:getU8()
			msg:getU8()
			msg:getU8()
			msg:getU8()
		end
	elseif state == ACTIVE then
		msg:getString()
		msg:getU16()
		msg:getU8()
		msg:getU8()
		msg:getU8()
		msg:getU8()
		msg:getU8()
		msg:getU8()
		msg:getU16()
		msg:getU8()
		msg:getU16()
	elseif state == INACTIVE then
		
	elseif state == LOCKED then
		msg:getU8()
	elseif state == SELECTION_WITH_WILDCARD then
		msg:getU8()
		msg:getU16()
		msg:getU8()
		local list = msg:getU16()
		for i = 1, list do
			msg:getU16()
		end
	end

	if g_game.getClientVersion() >= 1251 then
		msg:getU32()
	else
		msg:getU16()
	end

	if g_game.getClientVersion() >= 1160 then
		msg:getU8()
	end
  end)
 
  registerOpcode(ServerPackets.PreyTimeLeft, function(protocol, msg)
	msg:getU8()
	msg:getU16()
  end)  
  
  registerOpcode(ServerPackets.HirelingOutfit, function(protocol, msg)
	msg:getU16()
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU16()
	
	local outfitsize = 0
	if g_game.getClientVersion() >= 1175 then
		outfitsize = msg:getU16()
	else
		outfitsize = msg:getU8()
	end
    for i = 1, outfitsize do
		msg:getU16()
		msg:getString()
		msg:getU8()
		
		if g_game.getClientVersion() >= 1175 then
		local buttontype_o = msg:getU8()
			if buttontype_o == HIRELINGS_BUTTON then
				msg:getU32()
			end
		end
	end

	local mountsize = 0
	if g_game.getClientVersion() >= 1175 then
		mountsize = msg:getU16()
	else
		mountsize = msg:getU8()
	end
    for i = 1, mountsize do
		msg:getU16()
		msg:getString()
		if g_game.getClientVersion() >= 1175 then
			local buttontype_m = msg:getU8()
			if buttontype_m == HIRELINGS_BUTTON then
				msg:getU32()
			end
		end
	end
	
	local htype = msg:getU16()
	if htype == HIRELINGS_DRESS then
		local dresses = msg:getU16()
		for i = 1, dresses do
			msg:getU16()
			msg:getU16()
		end
	end
	
  end)

end

function unregisterProtocol()
  if registredOpcodes == nil then
    return
  end
  for _, opcode in ipairs(registredOpcodes) do
    ProtocolGame.unregisterOpcode(opcode)
  end
  registredOpcodes = nil
end

function registerOpcode(code, func)
  if registredOpcodes[code] ~= nil then
    error("Duplicated registed opcode: " .. code)
  end
  registredOpcodes[code] = func
  ProtocolGame.registerOpcode(code, func)
end

function readDailyReward(msg)
	local systemType = msg:getU8()
	if (systemType == 1) then
    msg:getU8()
    local count = msg:getU8()
    for i = 1, count do
      msg:getU16()
      msg:getString()				
      msg:getU32()
    end
	elseif (systemType == 2) then
    msg:getU8()
    local type = msg:getU8()
    
		if (type == DAILY_REWARD_SYSTEM_TYPE_PREY_REROLL) then
      msg:getU8()
		elseif (type == DAILY_REWARD_SYSTEM_TYPE_XP_BOOST) then
      msg:getU16()
		end
	end
end

function sendBestiaryCharmsData(msg)
	msg:getU32()
	local size = msg:getU8()
	for i = 1, size do
		msg:getU8()
		msg:getString()
		msg:getString()
		msg:getU8()
		msg:getU16()
		
		msg:getU8()
		local activated = msg:getU8()
		if activated > 0 then
			msg:getU16()
			msg:getU32()
		end
	end
	
	msg:getU8()
	local finished = msg:getU16()
	for i = 1, finished do
		msg:getU16()
	end
end
