local context = G.botContext
local Panels = context.Panels

Panels.MonsterEditor = function(monster, config, callback, parent)
  local otherWindow = g_ui.getRootWidget():getChildById('monsterEditor')
  if otherWindow then
    otherWindow:destory()
  end

  local window = context.setupUI([[
MainWindow
  id: monsterEditor
  size: 400 300
  !text: tr("Edit monster")
  
  Label
    id: info
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    text: Use monster name * for any other monster not on the list

  TextEdit
    id: name
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-left: 100
    margin-top: 5
    multiline: false

  Label
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: parent.left
    text: Monster name:

  Label
    id: priorityText
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: prev.bottom
    margin-right: 10
    margin-top: 10
    text: Priority
    text-align: center

  HorizontalScrollBar
    id: priority
    anchors.left: prev.left
    anchors.right: prev.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 10
    step: 1      

  Label
    id: dangerText
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: prev.bottom
    margin-right: 10
    margin-top: 10
    text: Danger
    text-align: center

  HorizontalScrollBar
    id: danger
    anchors.left: prev.left
    anchors.right: prev.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 10
    step: 1     

  Label
    id: distanceText
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: prev.bottom
    margin-right: 10
    margin-top: 10
    text: Distance
    text-align: center

  HorizontalScrollBar
    id: distance
    anchors.left: prev.left
    anchors.right: prev.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 5
    step: 1

  Label
    id: minHealthText
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: prev.bottom
    margin-right: 10
    margin-top: 10
    text: Minimum Health
    text-align: center

  HorizontalScrollBar
    id: minHealth
    anchors.left: prev.left
    anchors.right: prev.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 100
    step: 1

  Label
    id: maxHealthText
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: prev.bottom
    margin-right: 10
    margin-top: 10
    text: Maximum Health
    text-align: center

  HorizontalScrollBar
    id: maxHealth
    anchors.left: prev.left
    anchors.right: prev.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 100
    step: 1

  BotSwitch
    id: attack
    anchors.left: parent.horizontalCenter
    anchors.top: name.bottom
    margin-left: 10
    margin-top: 10
    width: 55
    text: Attack

  BotSwitch
    id: ignore
    anchors.left: prev.right
    anchors.top: name.bottom
    margin-left: 5
    margin-top: 10
    width: 55
    text: Ignore

  BotSwitch
    id: avoid
    anchors.left: prev.right
    anchors.top: name.bottom
    margin-left: 5
    margin-top: 10
    width: 55
    text: Avoid    

  BotSwitch
    id: keepDistance
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-left: 10
    margin-top: 10
    text: Keep distance

  BotSwitch
    id: avoidAttacks
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-left: 10
    margin-top: 10
    text: Avoid monster attacks

  BotSwitch
    id: chase
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-left: 10
    margin-top: 10
    text: Chase when running away

  BotSwitch
    id: loot
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-left: 10
    margin-top: 10
    text: Loot corpse

  Button
    id: okButton
    !text: tr('Ok')
    anchors.bottom: parent.bottom
    anchors.right: next.left
    margin-right: 10
    width: 60

  Button
    id: cancelButton
    !text: tr('Cancel')
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    width: 60
  ]], g_ui.getRootWidget())

  local destroy = function()
    window:destroy()
  end
  local doneFunc = function()    
    local monster = window.name:getText()
    local config = {
      priority = window.priority:getValue(),
      danger = window.danger:getValue(),
      distance = window.distance:getValue(),
      minHealth = window.minHealth:getValue(),
      maxHealth = window.maxHealth:getValue(),
      attack = window.attack:isOn(),
      ignore = window.ignore:isOn(),
      avoid = window.avoid:isOn(),
      keepDistance = window.keepDistance:isOn(),
      avoidAttacks = window.avoidAttacks:isOn(),
      chase = window.chase:isOn(),
      loot = window.loot:isOn()
    }    
    destroy()
    callback(monster, config)
  end

  window.okButton.onClick = doneFunc
  window.cancelButton.onClick = destroy
  window.onEnter = doneFunc
  window.onEscape = destroy

   
  window.priority.onValueChange = function(scroll, value)
    window.priorityText:setText("Priority: " .. value)
  end
  window.danger.onValueChange = function(scroll, value)
    window.dangerText:setText("Danger: " .. value)
  end
  window.distance.onValueChange = function(scroll, value)
    window.distanceText:setText("Distance: " .. value)
  end
  window.minHealth.onValueChange = function(scroll, value)
    window.minHealthText:setText("Minimum health: " .. value .. "%")
  end
  window.maxHealth.onValueChange = function(scroll, value)
    window.maxHealthText:setText("Maximum health: " .. value .. "%")
  end

  window.priority:setValue(config.priority or 1)
  window.danger:setValue(config.danger or 1)
  window.distance:setValue(config.distance or 1)
  window.minHealth:setValue(1) -- to force onValueChange update
  window.maxHealth:setValue(1) -- to force onValueChange update
  window.minHealth:setValue(config.minHealth or 0)
  window.maxHealth:setValue(config.maxHealth or 100)

  window.attack.onClick = function(widget)
    if widget:isOn() then
      return
    end
    widget:setOn(true)
    window.ignore:setOn(false)
    window.avoid:setOn(false)
  end
  window.ignore.onClick = function(widget)
    if widget:isOn() then
      return
    end
    widget:setOn(true)
    window.attack:setOn(false)
    window.avoid:setOn(false)
  end
  window.avoid.onClick = function(widget)
    if widget:isOn() then
      return
    end
    widget:setOn(true)
    window.attack:setOn(false)
    window.ignore:setOn(false)
  end 

  window.attack:setOn(config.attack)
  window.ignore:setOn(config.ignore)
  window.avoid:setOn(config.avoid)
  if not window.attack:isOn() and not window.ignore:isOn() and not window.avoid:isOn() then
    window.attack:setOn(true)
  end

  window.keepDistance.onClick = function(widget)
    widget:setOn(not widget:isOn())
  end
  window.avoidAttacks.onClick = function(widget)
    widget:setOn(not widget:isOn())
  end
  window.chase.onClick = function(widget)
    widget:setOn(not widget:isOn())
  end
  window.loot.onClick = function(widget)
    widget:setOn(not widget:isOn())
  end

  window.keepDistance:setOn(config.keepDistance)
  window.avoidAttacks:setOn(config.avoidAttacks)
  window.chase:setOn(config.chase)
  window.loot:setOn(config.loot)
  if config.loot == nil then
    window.loot:setOn(true)  
  end

  window.name:setText(monster)

  window:show()
  window:raise()
  window:focus()
end

Panels.Attacking = function(parent)
  local ui = context.setupUI([[
Panel
  id: attacking
  height: 150
  
  BotLabel
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text: Attacking

  ComboBox
    id: config
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 5
    text-offset: 3 0
    width: 130

  Button
    id: enableButton
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 5
      
  Button
    margin-top: 1
    id: add
    anchors.top: prev.bottom
    anchors.left: parent.left
    text: Add
    width: 60
    height: 20

  Button
    id: edit
    anchors.top: prev.top
    anchors.horizontalCenter: parent.horizontalCenter
    text: Edit
    width: 60
    height: 20

  Button
    id: remove
    anchors.top: prev.top
    anchors.right: parent.right
    text: Remove
    width: 60
    height: 20
  
  TextList
    id: list
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    vertical-scrollbar: listScrollbar
    margin-right: 15
    margin-top: 2
    height: 60
    focusable: false
    auto-focus: first

  VerticalScrollBar
    id: listScrollbar
    anchors.top: prev.top
    anchors.bottom: prev.bottom
    anchors.right: parent.right
    pixels-scroll: true
    step: 5

  Button
    margin-top: 2
    id: mAdd
    anchors.top: prev.bottom
    anchors.left: parent.left
    text: Add
    width: 60
    height: 20

  Button
    id: mEdit
    anchors.top: prev.top
    anchors.horizontalCenter: parent.horizontalCenter
    text: Edit
    width: 60
    height: 20

  Button
    id: mRemove
    anchors.top: prev.top
    anchors.right: parent.right
    text: Remove
    width: 60
    height: 20

]], parent)
  
  if type(context.storage.attacking) ~= "table" then
    context.storage.attacking = {}
  end
  if type(context.storage.attacking.configs) ~= "table" then
    context.storage.attacking.configs = {}  
  end
  
  local getConfigName = function(config)
    local matches = regexMatch(config, [[name:\s*([^\n]*)$]])
    if matches[1] and matches[1][2] then
      return matches[1][2]:trim()
    end
    return nil
  end

  local commands = {}
  local monsters = {}
  local configName = nil
  local refreshConfig = nil -- declared later

  local createNewConfig = function()
    if not context.storage.attacking.activeConfig or not context.storage.attacking.configs[context.storage.attacking.activeConfig] then
      return
    end
    
    local newConfig = ""
    if configName ~= nil then
      newConfig = "name:" .. configName .. "\n"
    end
    for monster, config in pairs(monsters) do
      newConfig = newConfig .. "\n" .. monster .. ":" .. json.encode(config) .. "\n"
    end    

    context.storage.attacking.configs[context.storage.attacking.activeConfig] = newConfig
    refreshConfig()
  end

  local parseConfig = function(config)
    commands = {}
    monsters = {}
    configName = nil

    local matches = regexMatch(config, [[([^:^\n]+)(:?)([^\n]*)]])
    for i=1,#matches do
      local command = matches[i][2]
      local validation = (matches[i][3] == ":")
      local text = matches[i][4]
      if validation then
        table.insert(commands, {command=command:lower(), text=text})
      elseif #commands > 0 then
        commands[#commands].text = commands[#commands].text .. "\n" .. matches[i][1]
      end
    end
    local labels = {}
    for i, command in ipairs(commands) do
      if commands[i].command == "name" then
        configName = commands[i].text
      else
        local status, result = pcall(function() return json.decode(command.text) end)
        if not status then
          context.error("Invalid monster config: " .. commands[i].command .. ", error: " .. result)
          print(command.text)
        else
          monsters[commands[i].command] = result
          table.insert(labels, commands[i].command)
        end
      end 
    end
    table.sort(labels)
    for i, text in ipairs(labels) do
      local label = g_ui.createWidget("CaveBotLabel", ui.list)
      label:setText(text)    
    end
  end
  
  local ignoreOnOptionChange = true
  refreshConfig = function(scrollDown)
    ignoreOnOptionChange = true
    if context.storage.attacking.enabled then
      ui.enableButton:setText("On")
      ui.enableButton:setColor('#00AA00FF')
    else
      ui.enableButton:setText("Off")
      ui.enableButton:setColor('#FF0000FF')
    end
        
    ui.config:clear()
    for i, config in ipairs(context.storage.attacking.configs) do
      local name = getConfigName(config)
      if not name then
        name = "Unnamed config"
      end
      ui.config:addOption(name)
    end
    
    if not context.storage.attacking.activeConfig and #context.storage.attacking.configs > 0 then
       context.storage.attacking.activeConfig = 1
    end
    
    ui.list:destroyChildren()
    
    if context.storage.attacking.activeConfig and context.storage.attacking.configs[context.storage.attacking.activeConfig] then
      ui.config:setCurrentIndex(context.storage.attacking.activeConfig)
      parseConfig(context.storage.attacking.configs[context.storage.attacking.activeConfig])
    end
    
    context.saveConfig()
    if scrollDown and ui.list:getLastChild() then
      ui.list:focusChild(ui.list:getLastChild())
    end
    
    ignoreOnOptionChange = false
  end

  
  ui.config.onOptionChange = function(widget)
    if not ignoreOnOptionChange then
      context.storage.attacking.activeConfig = widget.currentIndex
      refreshConfig()
    end
  end
  ui.enableButton.onClick = function()
    if not context.storage.attacking.activeConfig or not context.storage.attacking.configs[context.storage.attacking.activeConfig] then
      return
    end
    context.storage.attacking.enabled = not context.storage.attacking.enabled
    refreshConfig()
  end
  ui.add.onClick = function()
    modules.game_textedit.multilineEditor("Target list editor", "name:Config name", function(newText)
      table.insert(context.storage.attacking.configs, newText)
      context.storage.attacking.activeConfig = #context.storage.attacking.configs
      refreshConfig()
    end)
  end
  ui.edit.onClick = function()
    if not context.storage.attacking.activeConfig or not context.storage.attacking.configs[context.storage.attacking.activeConfig] then
      return
    end
    modules.game_textedit.multilineEditor("Target list editor", context.storage.attacking.configs[context.storage.attacking.activeConfig], function(newText)
      context.storage.attacking.configs[context.storage.attacking.activeConfig] = newText
      refreshConfig()
    end)
  end
  ui.remove.onClick = function()
    if not context.storage.attacking.activeConfig or not context.storage.attacking.configs[context.storage.attacking.activeConfig] then
      return
    end
    context.storage.attacking.enabled = false
    table.remove(context.storage.attacking.configs, context.storage.attacking.activeConfig)
    context.storage.attacking.activeConfig = 0
    refreshConfig()
  end

  
  ui.mAdd.onClick = function()
    if not context.storage.attacking.activeConfig or not context.storage.attacking.configs[context.storage.attacking.activeConfig] then
      return
    end
    Panels.MonsterEditor("", {}, function(name, config)
      if name:len() > 0 then
        monsters[name] = config
      end
      createNewConfig()
    end, parent)
  end
  ui.mEdit.onClick = function()
    if not context.storage.attacking.activeConfig or not context.storage.attacking.configs[context.storage.attacking.activeConfig] then
      return
    end
    local monsterWidget = ui.list:getFocusedChild()
    if not monsterWidget or not monsters[monsterWidget:getText()] then
      return
    end
    Panels.MonsterEditor(monsterWidget:getText(), monsters[monsterWidget:getText()], function(name, config)      
      monsters[monsterWidget:getText()] = nil
      if name:len() > 0 then
        monsters[name] = config
      end
      createNewConfig()
    end, parent)
  end
  ui.mRemove.onClick = function()
    if not context.storage.attacking.activeConfig or not context.storage.attacking.configs[context.storage.attacking.activeConfig] then
      return
    end
    local monsterWidget = ui.list:getFocusedChild()
    if not monsterWidget or not monsters[monsterWidget:getText()] then
      return
    end
    monsters[monsterWidget:getText()] = nil
    createNewConfig()
  end

  refreshConfig()

  local getMonsterConfig = function(monster)
    if monsters[monster:getName():lower()] then
      return monsters[monster:getName():lower()]
    end
    return monsters["*"]
  end

  local calculatePriority = function(monster)
    local priority = 0
    local config = getMonsterConfig(monster)
    if not config or type(config.priority) ~= 'number' then
      return -1
    end
    if not config.attack then
      return -1
    end

    local distance = context.getDistanceBetween(context.player:getPosition(), monster:getPosition())
    if distance > 10 then
      return -1
    end
    
    local mpos = monster:getPosition()
    local hasPath = false
    for x=-1,1 do
      for y=-1,1 do
        local pathTo = context.findPath(context.player:getPosition(), {x=mpos.x-x, y=mpos.y-y, z=mpos.z}, 100, true, false)
        if #pathTo > 0 then
          hasPath = true
          break
        end
      end
    end
    if distance > 2 and not hasPath then
      return -1
    end

    if monster == g_game.getAttackingCreature() then
      priority = priority + 10
    end

    if distance <= 4 then
      priority = priority + 10
    end
    if distance <= 2 then
      priority = priority + 20
    end

    if monster:getHealthPercent() <= 10 then
      priority = priority + 10
    end
    if monster:getHealthPercent() <= 25 then
      priority = priority + 10
    end
    if monster:getHealthPercent() <= 50 then
      priority = priority + 10
    end
    if monster:getHealthPercent() <= 75 then
      priority = priority + 10
    end
    
    priority = priority + config.priority * 10      
    return priority
  end

  local calculateMonsterDanger = function(monster)
    local danger = 0
    local config = getMonsterConfig(monster)
    if not config or type(config.danger) ~= 'number' then
      return danger
    end
    danger = danger + config.danger
    return danger
  end

  local lastAttack = context.now
  local lootContainers = {}
  local lootTries = 0
  local openContainerRequest = 0
  local waitForLooting = 0

  local goForLoot = function()
    if #lootContainers == 0 or not context.storage.looting.enabled then
      return false
    end

    local pos = context.player:getPosition()
    table.sort(lootContainers, function(pos1, pos2)
      local dist1 = math.max(math.abs(pos.x-pos1.x), math.abs(pos.y-pos1.y))
      local dist2 = math.max(math.abs(pos.x-pos2.x), math.abs(pos.y-pos2.y))
      return dist1 < dist2
    end)

    local cpos = lootContainers[1]
    if cpos.z ~= pos.z then
      table.remove(lootContainers, 1)
      return true
    end

    if lootTries >= 5 then
      lootTries = 0
      table.remove(lootContainers, 1)
      return true
    end
    local dist = math.max(math.abs(pos.x-cpos.x), math.abs(pos.y-cpos.y))    
    if dist <= 5 then
      local tile = g_map.getTile(cpos)
      if not tile then
        table.remove(lootContainers, 1)
        return true
      end
      
      local topItem = tile:getTopUseThing()
      if not topItem:isContainer() then
        table.remove(lootContainers, 1)
        return true
      end
    
      if dist <= 1 then
        lootTries = lootTries + 1
        openContainerRequest = context.now
        g_game.open(topItem)
        waitForLooting = math.max(waitForLooting, context.now + 500)
        return true
      end
    end

    if dist <= 20 then
      if context.player:isWalking() then
        return true
      end

      lootTries = lootTries + 1
      if context.autoWalk(cpos, 100 + dist * 2) then          
        return true
      end

      if context.autoWalk(cpos, 100 + dist * 2, true) then          
        return true
      end

      for i=1,5 do
        local cpos2 = {x=cpos.x + math.random(-1, 1),y = cpos.y + math.random(-1, 1), z = cpos.z}
        if context.autoWalk(cpos2, 100 + dist * 2) then          
          return true
        end
      end
      -- try again, ignore field
      for i=1,5 do
        local cpos2 = {x=cpos.x + math.random(-1, 1),y = cpos.y + math.random(-1, 1), z = cpos.z}
        if context.autoWalk(cpos2, 100 + dist * 2, true) then          
          return true
        end
      end
      
      -- ignore fields and monsters
      if context.autoWalk(cpos, 100 + dist * 2, true, true) then          
        return true
      end
    else
      table.remove(lootContainers, 1)
      return false
    end
    return true
  end

  context.onCreatureDisappear(function(creature)
    if not creature:isMonster() then
      return
    end
    local pos = context.player:getPosition()
    local tpos = creature:getPosition()
    if tpos.z ~= pos.z then
      return
    end

    local config = getMonsterConfig(creature)
    if not config or not config.loot then
      return
    end
    local distance = math.max(math.abs(pos.x-tpos.x), math.abs(pos.y-tpos.y))
    if distance > 6 then
      return
    end
    
    local tile = g_map.getTile(tpos)
    if not tile then
      return
    end
    
    local topItem = tile:getTopUseThing()
    if not topItem:isContainer() then
      return
    end
    
    table.insert(lootContainers, tpos)
  end)

  context.onContainerOpen(function(container, prevContainer)
    lootTries = 0
    if not context.storage.attacking.enabled then
      return
    end

    if openContainerRequest + 500 > context.now and #lootContainers > 0 then
      waitForLooting = math.max(waitForLooting, context.now + 1000 + container:getItemsCount() * 100)
      table.remove(lootContainers, 1)
    end
    if prevContainer then
      container.autoLooting = prevContainer.autoLooting
    else
      container.autoLooting = (openContainerRequest + 3000 > context.now)
    end
  end)

  context.macro(200, function()
    if not context.storage.attacking.enabled then
      return
    end

    local attacking = nil
    local following = nil
    local attackingCandidate = g_game.getAttackingCreature()
    local followingCandidate = g_game.getFollowingCreature()
    local spectators = context.getSpectators()
    local monsters = {}
    local danger = 0
    
    for i, spec in ipairs(spectators) do
      if attackingCandidate and attackingCandidate:getId() == spec:getId() then
        attacking = spec
      end
      if followingCandidate and followingCandidate:getId() == spec:getId() then
        following = spec
      end
      if spec:isMonster() then
        danger = danger + calculateMonsterDanger(spec)
        spec.attackingPriority = calculatePriority(spec)
        table.insert(monsters, spec)
      end
    end    

    if following then
      return
    end

    if waitForLooting > context.now then
      return
    end

    if #monsters == 0 then
      goForLoot()
      return
    end

    table.sort(monsters, function(a, b)
      return a.attackingPriority > b.attackingPriority
    end)

    local target = monsters[1]
    if target.attackingPriority < 0 then
      return
    end

    local pos = context.player:getPosition()
    local tpos = target:getPosition()
    local config = getMonsterConfig(target)
    local offsetX = pos.x - tpos.x
    local offsetY = pos.y - tpos.y

    if target ~= attacking then
      g_game.attack(target)
      attacking = target
      lastAttack = context.now
    end

    -- proceed attack
    if lastAttack + 15000 < context.now then
      -- stop and attack again, just in case
      g_game.cancelAttack()
      g_game.attack(target)          
      lastAttack = context.now
      return
    end

    if danger < 8 then
      -- low danger, go for loot first
      if goForLoot() then
        return
      end
    end
    
    local distance = math.max(math.abs(offsetX), math.abs(offsetY))
    if config.keepDistance then
      if (distance == config.distance or distance == config.distance + 1) then
        return
      else
        local bestDist = 10
        local bestPos = pos

        for i=1,5 do
          local testPos = {x=pos.x + math.random(-3,3), y=pos.y + math.random(-3,3), z=pos.z}
          local dist = math.abs(config.distance - math.max(math.abs(tpos.x - testPos.x), math.abs(tpos.y - testPos.y)))
          if dist < bestDist then
            local path = context.findPath(pos, testPos, 100, false, false)
            if #path > 0 then
              bestPos = testPos
              bestDist = dist
            end
          end
        end
        if bestDist > 1 then
          for i=1,10 do
            local testPos = {x=pos.x + math.random(-4,4), y=pos.y + math.random(-4,4), z=pos.z}
            local dist = math.abs(config.distance - math.max(math.abs(tpos.x - testPos.x), math.abs(tpos.y - testPos.y)))
            if dist < bestDist then
              local path = context.findPath(pos, testPos, 100, true, false)
              if #path > 0 then
                bestPos = testPos
                bestDist = dist
              end
            end
          end
        end 
        if bestDist < 10 then
          context.autoWalk(bestPos, 100, true, false)
          context.delay(300)
        end
      end
      return
    end

    if config.avoidAttacks and distance <= 1 then
      if (offsetX == 0 and offsetY ~= 0) then
        if context.player:canWalk(Directions.East) then
          g_game.walk(Directions.East)
        elseif context.player:canWalk(Directions.West) then
          g_game.walk(Directions.West)
        end
      elseif (offsetX ~= 0 and offsetY == 0) then
        if context.player:canWalk(Directions.North) then
          g_game.walk(Directions.North)
        elseif context.player:canWalk(Directions.South) then
          g_game.walk(Directions.South)
        end
      end
    end
     
    if distance > 1 then
      for x=-1,1 do
        for y=-1,1 do
          if context.autoWalk({x=tpos.x-x, y=tpos.y-y, z=tpos.z}, 100, true, false) then
            return
          end
        end
      end
      if not context.autoWalk(tpos, 100, false, true) then
        context.autoWalk(tpos, 100, true, true)
      end
    end
  end)
end

