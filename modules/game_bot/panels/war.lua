local context = G.botContext
local Panels = context.Panels

Panels.AttackLeaderTarget = function(parent)
  local toAttack = nil
  context.onMissle(function(missle)
    if not context.storage.attackLeader or context.storage.attackLeader:len() == 0 then
      return
    end
    local src = missle:getSource()
    if src.z ~= context.posz() then
      return
    end
    local from = g_map.getTile(src)
    local to = g_map.getTile(missle:getDestination())
    if not from or not to then
      return
    end
    local fromCreatures = from:getCreatures()
    local toCreatures = to:getCreatures()
    if #fromCreatures ~= 1 or #toCreatures ~= 1 then
      return
    end
    local c1 = fromCreatures[1]
    if c1:getName():lower() == context.storage.attackLeader:lower() then
      toAttack = toCreatures[1]
    end
  end)
  context.macro(50, "Attack leader's target", nil, function()
    if toAttack and context.storage.attackLeader:len() > 0 then    
      g_game.attack(toAttack)
      toAttack = nil
    end
  end, parent)
  context.addTextEdit("attackLeader", context.storage.attackLeader or "player name", function(widget, text)    
    context.storage.attackLeader = text
  end, parent)  
end


Panels.LimitFloor = function(parent)  
  context.onPlayerPositionChange(function(pos)
    if context.storage.limitFloor then
      local gameMapPanel = modules.game_interface.getMapPanel()
      if gameMapPanel then
        gameMapPanel:lockVisibleFloor(pos.z)
      end
    end
  end)

  local switch = context.addSwitch("limitFloor", "Don't show higher floors", function(widget)
    widget:setOn(not widget:isOn())
    context.storage.limitFloor = widget:isOn()
    local gameMapPanel = modules.game_interface.getMapPanel()
    if gameMapPanel then
      if context.storage.limitFloor then
        gameMapPanel:lockVisibleFloor(context.posz())
      else
        gameMapPanel:unlockVisibleFloor()      
      end
    end
  end, parent)
  switch:setOn(context.storage.limitFloor)
end

