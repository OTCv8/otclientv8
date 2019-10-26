-- In this file are declared extra functions and variables for bot
-- It has been made to make most common functions shorter, for eg. hp() instead of player:getHealth()

function setupFunctions(context)
  -- player releated
  context.name = function() return context.player:getName() end

  context.hp = function() return context.player:getHealth() end
  context.mana = function() return context.player:getMana() end
  context.hppercent = function() return context.player:getHealthPercent() end
  context.manapercent = function() return context.player:getManaPercent() end
  context.maxhp = function() return context.player:getMaxHealth() end
  context.maxmana = function() return context.player:getMaxMana() end
  context.hpmax = function() return context.player:getMaxHealth() end
  context.manamax = function() return context.player:getMaxMana() end

  context.cap = function() return context.player:getCapacity() end
  context.freecap = function() return context.player:getFreeCapacity() end
  context.maxcap = function() return context.player:getTotalCapacity() end
  context.capmax = function() return context.player:getTotalCapacity() end
    
  context.exp = function() return context.player:getExperience() end
  context.lvl = function() return context.player:getLevel() end
  context.level = function() return context.player:getLevel() end
  
  context.mlev = function() return context.player:getMagicLevel() end
  context.magic = function() return context.player:getMagicLevel() end
  context.mlevel = function() return context.player:getMagicLevel() end
  
  context.soul = function() return context.player:getSoul() end
  context.stamina = function() return context.player:getStamina() end
  context.voc = function() return context.player:getVocation() end
  context.vocation = function() return context.player:getVocation() end

  context.bless = function() return context.player:getBlessings() end
  context.blesses = function() return context.player:getBlessings() end
  context.blessings = function() return context.player:getBlessings() end
  
  
  context.pos = function() return context.player:getPosition() end
  context.posx = function() return context.player:getPosition().x end
  context.posy = function() return context.player:getPosition().y end
  context.posz = function() return context.player:getPosition().z end

  context.direction = function() return context.player:getDirection() end
  context.speed = function() return context.player:getSpeed() end
  context.skull = function() return context.player:getSkull() end
  context.outfit = function() return context.player:getOutfit() end


  context.autoWalk = function(destination) return context.player:autoWalk(destination) end
  context.walk = function(dir) return modules.game_walking.walk(dir) end
  
  -- game releated
  context.say = g_game.talk
  context.talk = g_game.talk
  context.talkPrivate = g_game.talkPrivate
  context.sayPrivate = g_game.talkPrivate
  context.use = g_game.useInventoryItem
  context.usewith = g_game.useInventoryItemWith
  context.useWith = g_game.useInventoryItemWith
  context.findItem = g_game.findItemInContainers

  context.attack = g_game.attack
  context.cancelAttack = g_game.cancelAttack
  context.follow = g_game.follow
  context.cancelFollow = g_game.cancelFollow
  context.cancelAttackAndFollow = g_game.cancelAttackAndFollow
  
  context.logout = g_game.forceLogout
  context.ping = g_game.getPing
  
  -- map releated
  context.zoomIn = function() modules.game_interface.getMapPanel():zoomIn() end
  context.zoomOut = function() modules.game_interface.getMapPanel():zoomOut() end
  
  -- tools
  context.encode = function(data) return json.encode(data) end
  context.decode = function(text) local status, result = pcall(function() return json.decode(text) end) if status then return result end return {} end
end