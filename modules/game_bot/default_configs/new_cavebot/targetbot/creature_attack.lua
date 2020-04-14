TargetBot.Creature.attack = function(params, targets, isLooting) -- params {config, creature, danger, priority}
  if player:isWalking() then
    lastWalk = now
  end

  local config = params.config
  local creature = params.creature
  
  if g_game.getAttackingCreature() ~= creature then
    g_game.attack(creature)
  end

  if not isLooting then -- walk only when not looting
    TargetBot.Creature.walk(creature, config, targets)
  end

  -- attacks
  local mana = player:getMana()
  if config.useGroupAttack and config.groupAttackSpell:len() > 1 and mana > config.minManaGroup then
    local creatures = g_map.getSpectatorsInRange(player:getPosition(), false, config.groupAttackRadius, config.groupAttackRadius)
    local playersAround = false
    local monsters = 0
    for _, creature in ipairs(creatures) do
      if not creature:isLocalPlayer() and creature:isPlayer() then
        playersAround = true
      elseif creature:isMonster() then
        monsters = monsters + 1
      end
    end
    if monsters >= config.groupAttackTargets and (not playersAround or config.groupAttackIgnorePlayers) then
      if TargetBot.sayAttackSpell(config.groupAttackSpell, config.groupAttackDelay) then
        return
      end
    end
  end
  if config.useSpellAttack and config.attackSpell:len() > 1 and mana > config.minMana then
    if TargetBot.sayAttackSpell(config.attackSpell, config.attackSpellDelay) then
      return
    end
  end
  if config.useRuneAttack and config.attackRune > 100 then
    if TargetBot.useAttackItem(config.attackRune, creature, config.attackRuneDelay) then
      return
    end
  end
end

TargetBot.Creature.walk = function(creature, config, targets)
  -- luring
  if config.lure and not (config.chase and creature:getHealthPercent() < 30) then
    local monsters = 0
    if targets < config.lureCount then
      local path = findPath(player:getPosition(), creature:getPosition(), 5, {ignoreNonPathable=true, precision=2})
      if path then
        return TargetBot.walkTo(creature:getPosition(), 10, {marginMin=5, marginMax=6, ignoreNonPathable=true})
      end
    end
  end

  local currentDistance = findPath(player:getPosition(), creature:getPosition(), 10, {ignoreCreatures=true, ignoreNonPathable=true, ignoreCost=true})
  if config.chase and (creature:getHealthPercent() < 30 or not config.keepDistance) then
    if #currentDistance > 1 then
      return TargetBot.walkTo(creature:getPosition(), 10, {ignoreNonPathable=true, precision=1})
    end
  elseif config.keepDistance then
    if #currentDistance ~= config.keepDistanceRange and #currentDistance ~= config.keepDistanceRange + 1 then
      return TargetBot.walkTo(creature:getPosition(), 10, {ignoreNonPathable=true, marginMin=config.keepDistanceRange, marginMax=config.keepDistanceRange + 1})
    end
  end
end
