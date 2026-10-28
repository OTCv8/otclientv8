TargetBot.Creature.calculatePriority = function(creature, config, path)
  -- config is based on creature_editor
  local priority = 0
  local currentTarget = g_game.getAttackingCreature()

  -- extra priority if it's current target
  if currentTarget == creature then
    priority = priority + 1
  end

  -- check if distance is ok
  if #path > config.maxDistance then
    if config.rpSafe then
      if currentTarget == creature then
        g_game.cancelAttackAndFollow()  -- if not, stop attack (pvp safe)
      end
    end
    return priority
  end

  -- add config priority
  priority = priority + config.priority

  -- keep current target: another monster needs a priority higher by more
  -- than switchThreshold to make the bot change target
  if currentTarget == creature then
    priority = priority + (config.switchThreshold or 5)
  end

  -- when our health is low, prefer monsters that are more dangerous
  if (config.danger or 0) > 0 and hppercent() <= (config.dangerHp or 50) then
    priority = priority + config.danger * 2
  end
  
  -- extra priority for close distance
  local path_length = #path
  if path_length == 1 then
    priority = priority + 10
  elseif path_length <= 3 then
    priority = priority + 5
  end

  -- extra priority for paladin diamond arrows
  if config.diamondArrows then
    local mobCount = getCreaturesInArea(creature:getPosition(), diamondArrowArea, 2)
    priority = priority + (mobCount * 4)

    if config.rpSafe then
      if getCreaturesInArea(creature:getPosition(), largeRuneArea, 3) > 0 then
        if currentTarget == creature then
          g_game.cancelAttackAndFollow()
        end
        return 0 -- pvp safe
      end
    end
  end

  -- extra priority for low health
  if config.chase and creature:getHealthPercent() < 30 then
    priority = priority + 5
  elseif creature:getHealthPercent() < 20 then
    priority = priority + 2.5
  elseif creature:getHealthPercent() < 40 then
    priority = priority + 1.5
  elseif creature:getHealthPercent() < 60 then
    priority = priority + 0.5
  elseif creature:getHealthPercent() < 80 then
    priority = priority + 0.2
  end

  return priority
end