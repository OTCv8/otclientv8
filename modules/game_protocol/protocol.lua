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
	BestiaryTrackerTab = 0xB9  
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