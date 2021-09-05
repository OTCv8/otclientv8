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
	OpenStashSupply = 0x29,
	UpdateLootTracker = 0xCF,
	UpdateTrackerAnalyzer = 0xCC,
	UpdateSupplyTracker = 0xCE,
	KillTracker = 0xD1,
	SpecialContainer = 0x2A,
	isUpdateCoinBalance = 0xF2,
	UpdateCoinBalance = 0xDF,
	PartyAnalyzer = 0x2B,
	GameNews = 0x98,
	ClientCheck = 0x63,
	LootStats = 0xCF,
	LootContainer = 0xC0,
	TournamentLeaderBoard = 0xC5,
	CyclopediaCharacterInfo = 0xDA,
	Tutorial = 0xDC,
	Highscores = 0xB1,
	Inspection = 0x76,
	TeamFinderList = 0x2D,
	TeamFinderLeader = 0x2C
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

  registerOpcode(ServerPackets.TeamFinderLeader, function(protocol, msg)
	local bool = msg:getU8() -- reset
	if bool > 0 then
		return -- Server internal changes
	end

	msg:getU16() -- Min level
	msg:getU16() -- Max level
	msg:getU8() -- Vocation flag
	msg:getU16() -- Slots
	msg:getU16() -- Free slots
	msg:getU32() -- Timestamp
	local type = msg:getU8() -- Team type
	msg:getU16() -- Type flag
	if type == 2 then
		msg:getU16() -- Hunt area
	end

	local size = msg:getU16() -- Members size
	for i = 1, size do
		msg:getU32() -- Character id
		msg:getString() -- Character name
		msg:getU16() -- Character level
		msg:getU8() -- Vocation
		msg:getU8() -- Member type (Leader == 3)
	end
  end)

  registerOpcode(ServerPackets.TeamFinderList, function(protocol, msg)
	msg:getU8()
	local size = msg:getU32() -- List size
	for i = 1, size do
		msg:getU32() -- Leader Id
		msg:addString() -- Leader name
		msg:getU16() -- Min level
		msg:getU16() -- Max level
		msg:getU8() -- Vocations flag
		msg:getU16() -- Slots
		msg:getU16() -- Used slots
		msg:getU32() -- Timestamp
		local type = msg:getU8() -- Team type [1]: Boss, [2]: Hunt and [3]: Quest
		msg:getU16() -- Type flag
		if type == 2 then
			msg:getU16() -- Hunt area
		end
		msg:getU8() -- Player status
	end
  end)

  registerOpcode(ServerPackets.Inspection, function(protocol, msg)
	local bool = msg:getU8() -- IsPlayer
	if g_game.getProtocolVersion() >= 1230 then
		msg:getU8()
	end
	local size = msg:getU8() -- List
	for i = 1, size do
		if bool > 0 then
			msg:getU8()
		end
		msg:getString() -- Name
		readAddItem(msg)
		local size_2 = msg:getU8() -- Imbuements
		for u = 1, size_2 do
			msg:getU16() -- Imbue
		end
		local size_3 = msg:getU8() -- Details
		for j = 1, size_3 do
			msg:getString() -- Name
			msg:getString() -- Description
		end
	end

	if bool > 0 then
		msg:getString() -- Player name
		local outfit = msg:getU16() -- lookType
		if outfit ~= 0 then
			msg:getU8() -- lookHead
			msg:getU8() -- lookBody
			msg:getU8() -- lookLegs
			msg:getU8() -- lookFeet
			msg:getU8() -- lookAddons
		else
			msg:getU16() -- lookTypeEx
		end
		local size_4 = msg:getU8() -- Detail
		for l = 1, size_4 do
			msg:getString() -- Name
			msg:getString() -- Description
		end
	end
  end)

  registerOpcode(ServerPackets.Highscores, function(protocol, msg)
	msg:getU8()
	local size = msg:getU8() -- Worlds
	for i = 1, size do
		msg:getString() --  World name
	end
	msg:getString() -- Selected world
	local size_2 = msg:getU8() -- Vocations
	for u = 1, size_2 do
		msg:getU32() -- Id
		msg:getString() -- Name
	end
	msg:getU32() -- Vocation selected Id
	local size_3 = msg:getU8() -- Categories
	for j = 1, size_3 do
		msg:getU8() -- Id
		msg:getString() -- Name
	end
	msg:getU8() -- Category selected Id
	msg:getU16() -- Pages
	msg:getU16() -- Selected page
	local size_4 = msg:getU8() -- Entries
	for l = 1, size_4 do
		msg:getU32() -- Rank
		msg:getString() -- Character name
		msg:getString() -- Character title
		msg:getU8() -- Vocation
		msg:getString() -- World
		msg:getU16() -- Level
		msg:getU8() -- Is player? then highlight
		msg:getU64() -- Points
	end
	msg:getU8()
	msg:getU8()
	msg:getU8()
	msg:getU32() -- Last update
  end)

  registerOpcode(ServerPackets.Tutorial, function(protocol, msg)
	msg:getU8() -- Tutorial id
  end)

  registerOpcode(ServerPackets.CyclopediaCharacterInfo, function(protocol, msg)
	local type = msg:getU8()
	if g_game.getProtocolVersion() >= 1215 then
		local error = msg:getU8()
		if error > 0 then
			-- [1] 'No data available at the moment.'
			-- [2] 'You are not allowed to see this character's data.'
			-- [3] 'You are not allowed to inspect this character.'
		end
	end
	if type == 0 then -- Basic Information
		msg:getString() -- Player name
		msg:getString() -- Vocation
		msg:getU16() -- Level
		local outfit = msg:getU16() -- lookType
		if outfit ~= 0 then
			msg:getU8() -- lookHead
			msg:getU8() -- lookBody
			msg:getU8() -- lookLegs
			msg:getU8() -- lookFeet
			msg:getU8() -- lookAddons
		else
			msg:getU16() -- lookTypeEx
		end
		msg:getU8() -- Hide stamina
		if g_game.getProtocolVersion() >= 1220 then
			msg:getU8() -- Personal habs
			msg:getString() -- Title
		end
	elseif type == 1 then -- Character Stats
		msg:getU64() -- Experience
		msg:getU16() -- Level
		msg:getU8() -- LevelPercent
		msg:getU16() -- BaseXpGain
		msg:getU32() -- Tournament
		msg:getU16() -- Grinding
		msg:getU16() -- Store XP
		msg:getU16() -- Hunting
		msg:getU16() -- Store XP Time
		msg:getU8() -- Show store XP button (bool)
		msg:getU16() -- Health
		msg:getU16() -- Health max
		msg:getU16() -- Mana
		msg:getU16() -- Mana max
		msg:getU8() -- Soul
		msg:getU16() -- Stamina
		msg:getU16() -- Food
		msg:getU16() -- Offline training
		msg:getU16() -- Speed
		msg:getU16() -- Speed base
		msg:getU32() -- Capacity bonus
		msg:getU32() -- Capacity
		msg:getU32() -- Capacity max
		local size = msg:getU8() -- Skills
		for i = 1, size do
			msg:getU8() -- Skill id
			msg:getU16() -- Skill level
			msg:getU16() -- Base skill
			msg:getU16() -- Base skill
			msg:getU16() -- Skill percent
		end
		if g_game.getProtocolVersion() < 1215 then
			msg:getU16()
			msg:getString() -- Player name
			msg:getString() -- Vocation
			msg:getU16() -- Level
			local outfit = msg:getU16() -- lookType
			if outfit ~= 0 then
				msg:getU8() -- lookHead
				msg:getU8() -- lookBody
				msg:getU8() -- lookLegs
				msg:getU8() -- lookFeet
				msg:getU8() -- lookAddons
			else
				msg:getU16() -- lookTypeEx
			end
		end
	elseif type == 2 then -- Combat Stats
		msg:getU16() -- Critical chance base
		msg:getU16() -- Critical chance bonus
		msg:getU16() -- Critical damage base
		msg:getU16() -- Critical damage bonus
		msg:getU16() -- Life leech chance base
		msg:getU16() -- Life leech chance bonus
		msg:getU16() -- Life leech amount base
		msg:getU16() -- Life leech amount bonus
		msg:getU16() -- Mana leech chance base
		msg:getU16() -- Mana leech chance bonus
		msg:getU16() -- Mana leech amount base
		msg:getU16() -- Mana leech amount bonus
		msg:getU8() -- Blessing amount
		msg:getU8() -- Blessing max
		msg:getU16() -- Attack
		msg:getU8() -- Attack type
		msg:getU8() -- Convert damage
		msg:getU8() -- Convert damage type
		msg:getU16() -- Armor
		msg:getU16() -- Defense
		local size = msg:getU8() -- Reductions
		for i = 1, size do
			msg:getU8() -- Element
			msg:getU8() -- Percent
		end
	elseif type == 3 then -- Recent Deaths
		msg:getU16() -- Page
		msg:getU16() -- Page max
		local size = msg:getU16()
		for i = 1, size do
			msg:getU32() -- Timestamp
			msg:getString() -- Cause
		end
	elseif type == 4 then -- Recent PvP Kills
		msg:getU16() -- Page
		msg:getU16() -- Page max
		local size = msg:getU16()
		for i = 1, size do
			msg:getU32() -- Timestamp
			msg:getString() -- Description
			msg:getU8() -- Status
		end
	elseif type == 5 then -- Achievements
		msg:getU16() -- Points
		msg:getU16() -- Secret max
		local size = msg:getU16() -- Unlocked
		for i = 1, size do
			msg:getU16() -- Id
			msg:getU32() -- Timestamp
			local size_2 = msg:getU8() -- Is secret
			if size_2 > 0 then
				msg:getString() -- Name
				msg:getString() -- Description
				msg:getU8() -- Grade
			end
		end
	elseif type == 6 then -- Item Summary
		local size = msg:getU16() -- Item list size
		for i = 1, size do
			msg:getU16() -- Item client Id
			msg:getU32() -- Item count
		end
	elseif type == 7 then -- Outfits and Mounts
		local size = msg:getU16() -- Outfit list size
		for i = 1, size do
			msg:getU16() -- Id
			msg:getString() -- Name
			msg:getU8() -- Addon
			msg:getU8() -- Category 0 = Standard, 1 = Quest, 2 = Store
			msg:getU32() -- Is current ? then 1000 or 0
		end
		msg:getU8() -- lookHead
		msg:getU8() -- lookBody
		msg:getU8() -- lookLegs
		msg:getU8() -- lookFeet

		local size_2 = msg:getU16() -- Mount list size
		for u = 1, size_2 do
			msg:getU16() -- Id
			msg:getString() -- Name
			msg:getU8() -- Addon
			msg:getU8() -- Category 0 = Standard, 1 = Quest, 2 = Store
			msg:getU32() -- Is current ? then 1000 or 0
		end
		if g_game.getProtocolVersion() >= 1260 then
			msg:getU8() -- Mount lookHead
			msg:getU8() -- Mount lookBody
			msg:getU8() -- Mount lookLegs
			msg:getU8() -- Mount lookFeet
		end
	elseif type == 8 then -- Store Summary
		msg:getU32() -- Store XP boost time
		msg:getU32() -- Daily reward XP boost time
		local size = msg:getU8() -- Blessings
		for i = 1, size do
			msg:getString() -- Name
			msg:getU8() -- Amount
		end
		msg:getU8() -- Prey slots
		msg:getU8() -- Prey wildcard
		msg:getU8() -- Instant reward
		msg:getU8() -- Charm expansion
		msg:getU8() -- Hireling
		local size_2 = msg:getU8() -- Hireling jogs
		for u = 1, size_2 do
			msg:getU8() -- Job id
		end
		local size_3 = msg:getU8() -- Hireling outfit
		for j = 1, size_3 do
			msg:getU8() -- Outfit id
		end
		msg:getU16() -- House items
	elseif type == 9 then -- Inspect
		local size = msg:getU8() -- Items
		for i = 1, size do
			msg:getU8() -- Slot index
			msg:getString() -- Item name
			readAddItem(msg)
			local size_2 = msg:getU8() -- Imbuements
			for u = 1, size_2 do
				msg:getU16() -- Imbue
			end
			local size_3 = msg:getU8() -- Detail
			for j = 1, size_3 do
				msg:getString() -- Name
				msg:getString() -- Description
			end
		end
		msg:getString() -- Player name
		local outfit = msg:getU16() -- lookType
		if outfit ~= 0 then
			msg:getU8() -- lookHead
			msg:getU8() -- lookBody
			msg:getU8() -- lookLegs
			msg:getU8() -- lookFeet
			msg:getU8() -- lookAddons
		else
			msg:getU16() -- lookTypeEx
		end
		local size_4 = msg:getU8() -- Player detail
		for k = 1, size_4 do
			msg:getString() -- Name
			msg:getString() -- Description
		end
	elseif type == 10 then -- Badges
		local bool = msg:getU8() -- Show account
		if bool > 0 then
			msg:getU8() -- Is online
			msg:getU8() -- Is premium
			msg:getString() -- Loyality title
			local size = msg:getU8() -- Badges
			for i = 1, size do
				msg:getU32() -- Id
				msg:getString() -- Name
			end
		end
	elseif type == 11 then -- Titles
		msg:getU8() -- Title
		local size = msg:getU8() -- Titles
		for i = 1, size do
			msg:getU8() -- Id
			msg:getString() -- Name
			msg:getString() -- Description
			msg:getU8() -- Permanent
			msg:getU8() -- Unlocked
		end
	end
  end)

  registerOpcode(ServerPackets.TournamentLeaderBoard, function(protocol, msg)
	msg:getU16()
	local capacity = msg:getU8() -- Worlds
	for i = 1, capacity do
		msg:getString() -- World name
	end

	msg:getString() -- World selected
	msg:getU16() -- Refresh rate
	msg:getU16() -- Current page
	msg:getU16() -- Total pages
	local size = msg:getU8() -- Players on page
	for u = 1, size do
		msg:getU32() -- Rank
		msg:getU32() -- Previous rank
		msg:getString() -- Name
		msg:getU8() -- Vocation
		msg:getU64() -- Points
		msg:getU8() -- Rank chance direction (arrow0
		msg:getU8() -- Rank chance bool
	end
	msg:getU8()
	msg:getString() -- Rewards
  end)

  registerOpcode(ServerPackets.LootContainer, function(protocol, msg)
	msg:getU8() -- Fallback
	local size = msg:getU8() -- Quickloot size
	for i = 1, size do
		msg:getU8() -- Category Id
		msg:getU16() -- Client Id
	end
  end)

  registerOpcode(ServerPackets.LootStats, function(protocol, msg)
	readAddItem(msg)
	msg:getString() -- Item name
  end)

  registerOpcode(ServerPackets.ClientCheck, function(protocol, msg)
	local size = msg:getU32() -- Data size
	for i = 1, size do
		msg:getU8() -- Data
	end
  end)

  registerOpcode(ServerPackets.GameNews, function(protocol, msg)
	msg:getU32() -- Category
	msg:getU8() -- Page
  end)

  registerOpcode(ServerPackets.PartyAnalyzer, function(protocol, msg)
	msg:getU32() -- Timestamp
	msg:getU32() -- Party leader id
	msg:getU8() -- Price type (client/market)
	local size = msg:getU8() -- Party size
	for i = 1, size do
		msg:getU32() -- Player ID
		msg:getU8() -- (Highlight text bool)

		msg:getU64() -- Loot count
		msg:getU64() -- Supply count
		msg:getU64() -- Impact count
		msg:getU64() -- Heal count
	end

	msg:getU8()
	local size_2 = msg:getU8() -- Size
	for u = 1, size_2 do
		msg:getU32() -- Player ID
		msg:getString() -- Player name
	end
  end)

  registerOpcode(ServerPackets.UpdateCoinBalance, function(protocol, msg)
	msg:getU8() -- Is updating
	msg:getU32() -- Normal coin
	msg:getU32() -- Transferable coin
	if g_game.getProtocolVersion() >= 1220 then
		msg:getU32() -- Reserved auction coin
		msg:getU32() -- Tournament coin
	end
  end)

  registerOpcode(ServerPackets.isUpdateCoinBalance, function(protocol, msg)
	msg:getU8() -- Is updating
  end)

  registerOpcode(ServerPackets.SpecialContainer, function(protocol, msg)
	local supplyStashMenu = msg:getU8() -- ('Stow item', 'Stow container' ...)
	local marketMenu = msg:getU8() -- ('Show in market')
  end)

  registerOpcode(ServerPackets.KillTracker, function(protocol, msg)
	msg:getString() -- Name
	msg:getU16() -- lookType
	msg:getU8() -- lookHead
	msg:getU8() -- lookBody
	msg:getU8() -- lookLegs
	msg:getU8() -- lookFeet
	msg:getU8() -- lookAddons
	local size = msg:getU8() -- Corpse size
	if size > 0 then
		for i = 1, size do
			readAddItem(msg)
		end
	end
  end)

  registerOpcode(ServerPackets.UpdateSupplyTracker, function(protocol, msg)
	msg:getU16() -- Item client ID
  end)

  registerOpcode(ServerPackets.UpdateTrackerAnalyzer, function(protocol, msg)
	local type = msg:getU8()
	msg:getU32() -- Amount
	if type > 0 then -- ANALYZER_DAMAGE_DEALT
		msg:getU8() -- Element
		if type > 1 then -- 
			msg:getString() -- Target
		end
	end
  end)
  
  registerOpcode(ServerPackets.UpdateLootTracker, function(protocol, msg)
	readAddItem(msg)
	msg:getString() -- Item name
  end)
  
  registerOpcode(ServerPackets.OpenStashSupply, function(protocol, msg)
    local count = msg:getU16() -- List size
    for i = 1, count do
      msg:getU16() -- Item client ID
      msg:getU32() -- Item count
    end

	msg:getU16() -- Stash size left (total - used)
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
  
  
end

function readAddItem(msg)
	msg:getU16() -- Item client ID
 
	if g_game.getProtocolVersion() < 1150 then
		msg:getU8() -- Unmarked
	end

	local var = msg:getU8()
	if g_game.getProtocolVersion() > 1150 then
		if var == 1 then
			msg:getU32() -- Loot flag
		end

		if g_game.getProtocolVersion() >= 1260 then
			local isQuiver = msg:getU8()
			if isQuiver == 1 then
				msg:getU32() -- Quiver count
			end
		end
	else
		msg:getU8()
	end
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
