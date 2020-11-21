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
	HirelingOutfit = 0xC8,
	GameStoreCoinBalance = 0xDF,
	GameStoreError = 0xE0,
	GameStoreRequestPurchaseData = 0xE1,
	GameStoreBalanceUpdate = 0xF2,
	GameStoreOpenStore = 0xFB,
	GameStoreOffers = 0xFC,
	GameStoreTransactions = 0xFD,
	GameStoreCompletePurchase = 0xFE
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
local SELECTION_WITH_WILDCARD = 6

-- Hirelings
local HIRELINGS_BUTTON = 1
local HIRELINGS_DRESS = 4

-- GameStore
local GAMESTORE_SHOWNONE = 0
local GAMESTORE_SHOWMOUNT = 1
local GAMESTORE_SHOWOUTFIT = 2
local GAMESTORE_SHOWITEM = 3
local GAMESTORE_SHOWHIRELING = 4

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
    msg:getU32()
    msg:getU16()
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
	sendBestiaryCharmsData(msg)
  end)
  
  registerOpcode(ServerPackets.BestiaryOverview, function(protocol, msg)
	msg:getString()
	local size = msg:getU16()
    for i = 1, size do
		msg:getU16()
		msg:getU16()
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
	
	msg:getU8()
	msg:getU8()
	
	local lootsize = msg:getU8()
    for i = 1, lootsize do
		msg:getItemId()
		msg:getU8()
		msg:getU8()
		
		if progresslevel > 1 then
			msg:getString()
			msg:getU8()
		end
	end
	
	if progresslevel > 1 then
		msg:getU16()
		
		msg:getU8()
		msg:getU8()
		msg:getU32()
		msg:getU32()
		msg:getU16()
		msg:getU16()
	end
	
	if progresslevel > 2 then
		local elements = msg:getU8()
		for i = 1, elements do
			msg:getU8()
			msg:getU16()
		end
		
		msg:getU16()
		msg:getString()
	end
	
	if progresslevel > 3 then
		msg:getU8()
		local charmtype = msg:getU8()
		if charmtype > 0
			msg:getU32()
		else
			msg:getU8()
		end
	end
  end)
  
  registerOpcode(ServerPackets.BestiaryCharmsData, function(protocol, msg)
	sendBestiaryCharmsData(msg)
  end)
  
  registerOpcode(ServerPackets.BestiaryTracker, function(protocol, msg)
	msg:getU16()
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
		msg:getU8()
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
	msg:getU8()
	msg:getU8()	
	msg:getU32()
	msg:getU32()
	msg:getU8()
	msg:getU8()
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
	elseif state = ACTIVE then
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
	elseif state = INACTIVE then
		
	elseif state = LOCKED then
		msg:getU8()
	elseif state = SELECTION_WITH_WILDCARD then
		msg:getU8()
		msg:getU16()
		msg:getU8()
		local list = msg:getU16()
		for i = 1, list do
			msg:getU16()
		end
	end
	
	msg:getU32()
	msg:getU8()
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
	
	local outfitsize = msg:getU16()
    for i = 1, size do
		msg:getU16()
		msg:getString()
		msg:getU8()
		
		local buttontype_o = msg:getU8()
		if buttontype_o == HIRELINGS_BUTTON then
			msg:getU32()
		end
	end

	local mountsize = msg:getU16()
    for i = 1, size do
		msg:getU16()
		msg:getString()
		local buttontype_m = msg:getU8()
		if buttontype_m == HIRELINGS_BUTTON then
			msg:getU32()
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

  registerOpcode(ServerPackets.GameStoreCoinBalance, function(protocol, msg)
	msg:getU8()
	msg:getU32()
	msg:getU32()
	msg:getU32()
	msg:getU32()
  end)
  
  registerOpcode(ServerPackets.GameStoreError, function(protocol, msg)
	msg:getU8()
	msg:getString()
  end)

  registerOpcode(ServerPackets.GameStoreRequestPurchaseData, function(protocol, msg)
	msg:getU32()
	msg:getU8()	
  end)
  
  registerOpcode(ServerPackets.GameStoreBalanceUpdate, function(protocol, msg)
	msg:getU8()	
  end)

  registerOpcode(ServerPackets.GameStoreOpenStore, function(protocol, msg)
	local list = msg:getU16()
    for i = 1, list do
		msg:getString()
		msg:getU8()
		local icons = msg:getU8()
		for i = 1, icons do
			msg:getString()
		end
		msg:getString()
	end
  end)
  
  registerOpcode(ServerPackets.GameStoreOffers, function(protocol, msg)
	msg:getString()
	msg:getU32()
	msg:getU8()
	
	local capacity = msg:getU8()
	for i = 1, capacity do
		msg:getString()
	end
	
	msg:getString()
	local capacity2 = msg:getU16()
	for i = 1, capacity2 do
		msg:getString()
		
		local details = msg:getU8()
		for i = 1, details do
			msg:getU32()
			msg:getU16()
			msg:getU32()
			
			msg:getU8()
			
			local disable = msg:getU8()
			if disable > 0 then
				local reasons = msg:getU8()
				for i = 1, reasons do
					msg:getString()
				end
			end
			
			local highlight = msg:getU8()
			if highlight > 0 then
				msg:getU32()
				msg:getU32()
			end
			
		end

			local display = msg:getU8()
			if display = GAMESTORE_SHOWNONE then
				msg:getString()
			elseif display = GAMESTORE_SHOWMOUNT then
				msg:getU16()
			elseif display = GAMESTORE_SHOWITEM then
				msg:getU16()
			elseif display = GAMESTORE_SHOWOUTFIT then
				msg:getU16()
				msg:getU8()
				msg:getU8()
				msg:getU8()
				msg:getU8()
			elseif display = GAMESTORE_SHOWHIRELING then
				msg:getU8()
				msg:getU16()
				msg:getU16()
				msg:getU8()
				msg:getU8()
				msg:getU8()
				msg:getU8()
			end
			msg:getU8()
			msg:getU16()
			msg:getU16()
			msg:getU32()
			msg:getU8()
			msg:getU16()
	end
  end)
  
  registerOpcode(ServerPackets.GameStoreTransactions, function(protocol, msg)
	msg:getU32()
	msg:getU32()
	local entries = msg:getU8()
	for i = 1, entries do
		msg:getU32()
		msg:getU32()
		msg:getU8()
		msg:getU32()
		msg:getU8()
		msg:getString()
		msg:getU8()
	end
  end)
  
  registerOpcode(ServerPackets.GameStoreCompletePurchase, function(protocol, msg)
	msg:getU8()
	msg:getString()
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
		else
			msg:getU8()
		end
	end
	
	msg:getU8()
	local finished = msg:getU16()
	for i = 1, finished do
		msg:getU16()
	end
end
