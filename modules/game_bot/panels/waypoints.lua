local context = G.botContext
local Panels = context.Panels

Panels.Waypoints = function(parent)
  local ui = context.setupUI([[
Panel
  id: waypoints
  height: 213
  
  BotLabel
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text: Waypoints
  
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

  Button
    id: edit
    anchors.top: prev.top
    anchors.horizontalCenter: parent.horizontalCenter
    text: Edit
    width: 60

  Button
    id: remove
    anchors.top: prev.top
    anchors.right: parent.right
    text: Remove
    width: 60
  
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
    
  Label
    id: pos
    anchors.top: prev.bottom
    anchors.left: parent.left    
    anchors.right: parent.right
    text-align: center
    margin-top: 2
    
  Button
    id: wGoto
    anchors.top: prev.bottom
    anchors.left: parent.left
    text: Goto
    width: 61
    margin-top: 1

  Button
    id: wUse
    anchors.top: prev.top
    anchors.left: prev.right
    text: Use
    width: 61

  Button
    id: wUseWith
    anchors.top: prev.top
    anchors.left: prev.right
    text: UseWith
    width: 61

  Button
    id: wWait
    anchors.top: prev.bottom
    anchors.left: parent.left
    text: Wait
    width: 61
    margin-top: 1
    
  Button
    id: wSay
    anchors.top: prev.top
    anchors.left: prev.right
    text: Say
    width: 61

  Button
    id: wFunction
    anchors.top: prev.top
    anchors.left: prev.right
    text: Function
    width: 61
    
  BotSwitch
    id: recording
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text: Auto Recording

]], parent)

  if type(context.storage.cavebot) ~= "table" then
    context.storage.cavebot = {}
  end
  if type(context.storage.cavebot.configs) ~= "table" then
    context.storage.cavebot.configs = {}  
  end
  
  local getConfigName = function(config)
    local matches = regexMatch(config, [[name:\s*([^\n]*)$]])
    if matches[1] and matches[1][2] then
      return matches[1][2]:trim()
    end
    return nil
  end
  
  local isValidCommand = function(command)
    if command == "goto" then
      return true
    elseif command == "use" then
      return true
    elseif command == "usewith" then
      return true
    elseif command == "wait" then
      return true
    elseif command == "say" then
      return true
    elseif command == "function" then
      return true
    end
    return false
  end

  local commands = {}
  local waitTo = 0
  local autoRecording = false

  local parseConfig = function(config)
    commands = {}
    local matches = regexMatch(config, [[\s*([^:^\n]+)(:?)([^\n]*)]])
    for i=1,#matches do
      local command = matches[i][2]
      local validation = (matches[i][3] == ":")
      if not validation or isValidCommand(command) then      
        local text = matches[i][4]
        if validation then
          table.insert(commands, {command=command:lower(), text=text})
        elseif #commands > 0 then
          commands[#commands].text = commands[#commands].text .. "\n" .. command
        end
      end
    end
    
    for i=1,#commands do
      local label = g_ui.createWidget("CaveBotLabel", ui.list)
      label:setText(commands[i].command .. ":" .. commands[i].text)
    end        
  end
  
  local ignoreOnOptionChange = true
  local refreshConfig = function(scrollDown)
    ignoreOnOptionChange = true
    if context.storage.cavebot.enabled then
      autoRecording = false
      ui.recording:setOn(false)
      ui.enableButton:setText("On")
      ui.enableButton:setColor('#00AA00FF')
    else
      ui.enableButton:setText("Off")
      ui.enableButton:setColor('#FF0000FF')
      ui.recording:setOn(autoRecording)
    end
        
    ui.config:clear()
    for i, config in ipairs(context.storage.cavebot.configs) do
      local name = getConfigName(config)
      if not name then
        name = "Unnamed config"
      end
      ui.config:addOption(name)
    end
    
    if not context.storage.cavebot.activeConfig and #context.storage.cavebot.configs > 0 then
       context.storage.cavebot.activeConfig = 1
    end
    
    ui.list:destroyChildren()
    
    if context.storage.cavebot.activeConfig then
      ui.config:setCurrentIndex(context.storage.cavebot.activeConfig)
      parseConfig(context.storage.cavebot.configs[context.storage.cavebot.activeConfig])
    end
    
    context.saveConfig()
    if scrollDown and ui.list:getLastChild() then
      ui.list:focusChild(ui.list:getLastChild())
    end
    
    waitTo = 0
    ignoreOnOptionChange = false
  end

  
  ui.config.onOptionChange = function(widget)
    if not ignoreOnOptionChange then
      context.storage.cavebot.activeConfig = widget.currentIndex
      refreshConfig()
    end
  end
  ui.enableButton.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    context.storage.cavebot.enabled = not context.storage.cavebot.enabled
    refreshConfig()
  end
  ui.add.onClick = function()
    modules.game_textedit.multilineEditor("Waypoints editor", "name:Config name\n", function(newText)
      table.insert(context.storage.cavebot.configs, newText)
      context.storage.cavebot.activeConfig = #context.storage.cavebot.configs
      refreshConfig()
    end)
  end
  ui.edit.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    modules.game_textedit.multilineEditor("Waypoints editor", context.storage.cavebot.configs[context.storage.cavebot.activeConfig], function(newText)
      context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = newText
      refreshConfig()
    end)
  end
  ui.remove.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    context.storage.cavebot.enabled = false
    table.remove(context.storage.cavebot.configs, context.storage.cavebot.activeConfig)
    context.storage.cavebot.activeConfig = 0
    refreshConfig()
  end
  
  -- waypoint editor
  -- auto recording
  local stepsSincleLastPos = 0
  
  context.onPlayerPositionChange(function(newPos, oldPos)
    ui.pos:setText("Position: " .. newPos.x .. ", " .. newPos.y .. ", " .. newPos.z)
    if not autoRecording then
      return
    end
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    local newText = ""
    if newPos.z ~= oldPos.z then
      newText = "goto:" .. oldPos.x .. "," .. oldPos.y .. "," .. oldPos.z
      if #commands > 0 then
        local lastCommand = commands[#commands].command .. ":" .. commands[#commands].text
        if lastCommand == newText then
          return
        end
      end      
      stepsSincleLastPos = 0
    else
      stepsSincleLastPos = stepsSincleLastPos + 1
      if stepsSincleLastPos > 10 then
        newText = "goto:" .. oldPos.x .. "," .. oldPos.y .. "," .. oldPos.z
        stepsSincleLastPos = 0
      end
    end

    if newText:len() > 0 then
      context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = context.storage.cavebot.configs[context.storage.cavebot.activeConfig] .. "\n" .. newText
      refreshConfig(true)
    end
  end)
  
  context.onUse(function(pos, itemId, stackPos, subType)
    if not autoRecording then
      return
    end
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    if pos.x == 0xFFFF then
      return
    end
    stepsSincleLastPos = 0
    newText = "use:" .. pos.x .. "," .. pos.y .. "," .. pos.z
    context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = context.storage.cavebot.configs[context.storage.cavebot.activeConfig] .. "\n" .. newText
    refreshConfig(true)
  end)
  context.onUseWith(function(pos, itemId, target, subType)
    if not autoRecording then
      return
    end
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    if not target:isItem() then
      return
    end
    local targetPos = target:getPosition()
    if targetPos.x == 0xFFFF then
      return
    end
    stepsSincleLastPos = 0
    newText = "usewith:" .. itemId .. "," .. targetPos.x .. "," .. targetPos.y .. "," .. targetPos.z
    context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = context.storage.cavebot.configs[context.storage.cavebot.activeConfig] .. "\n" .. newText
    refreshConfig(true)
  end)

  -- ui
  local pos = context.player:getPosition()
  ui.pos:setText("Position: " .. pos.x .. ", " .. pos.y .. ", " .. pos.z)

  ui.wGoto.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    local pos = context.player:getPosition()
    modules.game_textedit.singlelineEditor("" .. pos.x .. "," .. pos.y .. "," .. pos.z, function(newText)
      context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = context.storage.cavebot.configs[context.storage.cavebot.activeConfig] .. "\ngoto:" .. newText
      refreshConfig(true)
    end)
  end

  ui.wUse.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    local pos = context.player:getPosition()
    modules.game_textedit.singlelineEditor("" .. pos.x .. "," .. pos.y .. "," .. pos.z, function(newText)
      context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = context.storage.cavebot.configs[context.storage.cavebot.activeConfig] .. "\nuse:" .. newText
      refreshConfig(true)
    end)
  end
  
  ui.wUseWith.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    local pos = context.player:getPosition()
    modules.game_textedit.singlelineEditor("ITEMID," .. pos.x .. "," .. pos.y .. "," .. pos.z, function(newText)
      context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = context.storage.cavebot.configs[context.storage.cavebot.activeConfig] .. "\nusewith:" .. newText
      refreshConfig(true)
    end)
  end
  
  ui.wWait.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    modules.game_textedit.singlelineEditor("1000", function(newText)
      context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = context.storage.cavebot.configs[context.storage.cavebot.activeConfig] .. "\nwait:" .. newText
      refreshConfig(true)
    end)
  end

  ui.wSay.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    modules.game_textedit.singlelineEditor("text", function(newText)
      context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = context.storage.cavebot.configs[context.storage.cavebot.activeConfig] .. "\nsay:" .. newText
      refreshConfig(true)
    end)
  end
  
  ui.wFunction.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    modules.game_textedit.multilineEditor("Add function", "function(waypoints)\n  --your lua code\n\n  -- must return true to execute next command, othwerwise will run in loop till correct return\n  return true\nend", function(newText)
      context.storage.cavebot.configs[context.storage.cavebot.activeConfig] = context.storage.cavebot.configs[context.storage.cavebot.activeConfig] .. "\nfunction:" .. newText
      refreshConfig(true)
    end)
  end
  
  ui.recording.onClick = function()
    if not context.storage.cavebot.activeConfig or not context.storage.cavebot.configs[context.storage.cavebot.activeConfig] then
      return
    end
    autoRecording = not autoRecording
    if autoRecording then
      context.storage.cavebot.enabled = false
      stepsSincleLastPos = 10
    end
    refreshConfig(true)
  end
  
  refreshConfig()
  
  local functions = {
    enable = function()
      context.storage.cavebot.enabled = true
      refreshConfig()    
    end,
    disable = function()
      context.storage.cavebot.enabled = false
      refreshConfig()        
    end,
    refresh = function()
      refreshConfig()
    end
  }
  
  local executeNextMacroCall = false
  local commandExecutionNo = 0
  local lastGotoSuccesful = true
  
  context.macro(250, function()
    if not context.storage.cavebot.enabled then
      return
    end
    
    if context.player:isWalking() then
      executeNextMacroCall = false
      return
    end
    
    if not executeNextMacroCall then
      executeNextMacroCall = true
      return
    end
    executeNextMacroCall = false
    
    local commandWidget = ui.list:getFocusedChild()
    if not commandWidget then
      if ui.list:getFirstChild() then
        ui.list:focusChild(ui.list:getFirstChild())
      end
      return
    end
    
    local commandIndex = ui.list:getChildIndex(commandWidget)
    local command = commands[commandIndex]
    if not command then
      if ui.list:getFirstChild() then
        ui.list:focusChild(ui.list:getFirstChild())
      end
      return
    end
    if command.command == "goto" then
      local matches = regexMatch(command.text, [[([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)]])
      if #matches == 1 and #matches[1] == 4 then
        local position = {x=tonumber(matches[1][2]), y=tonumber(matches[1][3]), z=tonumber(matches[1][4])}        
        local distance = context.getDistanceBetween(position, context.player:getPosition())
        if distance > 0 and position.z == context.player:getPosition().z then
          commandExecutionNo = commandExecutionNo + 1
          lastGotoSuccesful = false
          if commandExecutionNo <= 3 then -- try max 3 times
            if not context.autoWalk(position, 100 + distance * 2, commandExecutionNo > 1, false) then
              context.autoWalk(position, 100 + distance * 2, true, true)
              context.delay(500)
              return
            end
            return
          elseif commandExecutionNo == 4 then -- try last time, location close to destination
            position.x = position.x + math.random(-1, 1)
            position.y = position.y + math.random(-1, 1)
            if context.autoWalk(position, 100 + distance * 2, true) then
              return
            end
          elseif distance < 2 then
            lastGotoSuccesful = true
          end
        else
          lastGotoSuccesful = (position.z == context.player:getPosition().z)
        end
      else
        context.error("Waypoints: invalid use of goto function")
      end
    elseif command.command == "use" then
      local matches = regexMatch(command.text, [[([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)]])
      if #matches == 1 and #matches[1] == 4 then
        local position = {x=tonumber(matches[1][2]), y=tonumber(matches[1][3]), z=tonumber(matches[1][4])} 
        if context.player:getPosition().z == position.z then
          local tile = g_map.getTile(position)
          if tile then
            local topThing = tile:getTopUseThing()
            if topThing then
              g_game.use(topThing)
              context.delay(500)
            end
          end
        end
      else
        context.error("Waypoints: invalid use of use function")
      end
    elseif command.command == "usewith" then
      local matches = regexMatch(command.text, [[([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)[^0-9]+([0-9]+)]])
      if #matches == 1 and #matches[1] == 5 then
        local itemId = tonumber(matches[1][2])
        local position = {x=tonumber(matches[1][3]), y=tonumber(matches[1][4]), z=tonumber(matches[1][5])}        
        if context.player:getPosition().z == position.z then
          local tile = g_map.getTile(position)
          if tile then
            local topThing = tile:getTopUseThing()
            if topThing then
              context.useWith(itemId, topThing)
              context.delay(500)
            end
          end
        end
      else
        context.error("Waypoints: invalid use of usewith function")
      end
    elseif command.command == "wait" and lastGotoSuccesful then
      if not waitTo or waitTo == 0 then
        waitTo = context.now + tonumber(command.text)
      end
      if context.now < waitTo then
        return
      end
      waitTo = 0
    elseif command.command == "say" and lastGotoSuccesful then
      context.say(command.text)
    elseif command.command == "function" and lastGotoSuccesful then
      local status, result = pcall(function() 
        return assert(load("return " .. command.text, nil, nil, context))()(functions)
      end)
      if not status then
        context.error("Waypoints function execution error:\n" .. result)
        context.delay(2500)
      end
      if not result then
        return
      end
    end
        
    local nextIndex = 1 + commandIndex % #commands    
    local nextChild = ui.list:getChildByIndex(nextIndex)
    if nextChild then
      ui.list:focusChild(nextChild)
      commandExecutionNo = 0
    end
  end)
  
  return functions
end

