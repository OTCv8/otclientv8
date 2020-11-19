ComboPanelName = "combobot"
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('ComboBot')

  Button
    id: combos
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

]])
ui:setId(ComboPanelName)

if not storage[ComboPanelName] then
  storage[ComboPanelName] = {
    enabled = false,
    onSayEnabled = false,
    onShootEnabled = false,
    onCastEnabled = false,
    followLeaderEnabled = false,
    attackLeaderTargetEnabled = false,
    attackSpellEnabled = false,
    attackItemToggle = false,
    sayLeader = "",
    shootLeader = "",
    castLeader = "",
    sayPhrase = "",
    spell = "",
    serverLeader = "",
    item = 3155,
    attack = "",
    follow = "",
    commandsEnabled = true,
    serverEnabled = false,
    serverLeaderTarget = false,
    serverTriggers = true
  }
end

ui.title:setOn(storage[ComboPanelName].enabled)
ui.title.onClick = function(widget)
storage[ComboPanelName].enabled = not storage[ComboPanelName].enabled
widget:setOn(storage[ComboPanelName].enabled)
end

ui.combos.onClick = function(widget)
  comboWindow:show()
  comboWindow:raise()
  comboWindow:focus()
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  comboWindow = g_ui.createWidget('ComboWindow', rootWidget)
  comboWindow:hide()

  -- bot item

  comboWindow.actions.attackItem:setItemId(storage[ComboPanelName].item)
  comboWindow.actions.attackItem.onItemChange = function(widget)
    storage[ComboPanelName].item = widget:getItemId()
  end

  -- switches

  comboWindow.actions.commandsToggle:setOn(storage[ComboPanelName].commandsEnabled)
  comboWindow.actions.commandsToggle.onClick = function(widget)
    storage[ComboPanelName].commandsEnabled = not storage[ComboPanelName].commandsEnabled
    widget:setOn(storage[ComboPanelName].commandsEnabled)
  end

  comboWindow.server.botServerToggle:setOn(storage[ComboPanelName].serverEnabled)
  comboWindow.server.botServerToggle.onClick = function(widget)
    storage[ComboPanelName].serverEnabled = not storage[ComboPanelName].serverEnabled
    widget:setOn(storage[ComboPanelName].serverEnabled)
  end

  comboWindow.server.Triggers:setOn(storage[ComboPanelName].serverTriggers)
  comboWindow.server.Triggers.onClick = function(widget)
    storage[ComboPanelName].serverTriggers = not storage[ComboPanelName].serverTriggers
    widget:setOn(storage[ComboPanelName].serverTriggers)
  end

  comboWindow.server.targetServerLeaderToggle:setOn(storage[ComboPanelName].serverLeaderTarget)
  comboWindow.server.targetServerLeaderToggle.onClick = function(widget)
    storage[ComboPanelName].serverLeaderTarget = not storage[ComboPanelName].serverLeaderTarget
    widget:setOn(storage[ComboPanelName].serverLeaderTarget)
  end  

  -- buttons
  comboWindow.closeButton.onClick = function(widget)
    comboWindow:hide()
  end

  -- combo boxes

  comboWindow.actions.followLeader:setOption(storage[ComboPanelName].follow)
  comboWindow.actions.followLeader.onOptionChange = function(widget)
    storage[ComboPanelName].follow = widget:getCurrentOption().text
  end

  comboWindow.actions.attackLeaderTarget:setOption(storage[ComboPanelName].attack)
  comboWindow.actions.attackLeaderTarget.onOptionChange = function(widget)
    storage[ComboPanelName].attack = widget:getCurrentOption().text
  end

  -- checkboxes
  comboWindow.trigger.onSayToggle:setChecked(storage[ComboPanelName].onSayEnabled)
  comboWindow.trigger.onSayToggle.onClick = function(widget)
    storage[ComboPanelName].onSayEnabled = not storage[ComboPanelName].onSayEnabled
    widget:setChecked(storage[ComboPanelName].onSayEnabled)
  end

  comboWindow.trigger.onShootToggle:setChecked(storage[ComboPanelName].onShootEnabled)
  comboWindow.trigger.onShootToggle.onClick = function(widget)
    storage[ComboPanelName].onShootEnabled = not storage[ComboPanelName].onShootEnabled
    widget:setChecked(storage[ComboPanelName].onShootEnabled)
  end

  comboWindow.trigger.onCastToggle:setChecked(storage[ComboPanelName].onCastEnabled)
  comboWindow.trigger.onCastToggle.onClick = function(widget)
    storage[ComboPanelName].onCastEnabled = not storage[ComboPanelName].onCastEnabled
    widget:setChecked(storage[ComboPanelName].onCastEnabled)
  end  

  comboWindow.actions.followLeaderToggle:setChecked(storage[ComboPanelName].followLeaderEnabled)
  comboWindow.actions.followLeaderToggle.onClick = function(widget)
    storage[ComboPanelName].followLeaderEnabled = not storage[ComboPanelName].followLeaderEnabled
    widget:setChecked(storage[ComboPanelName].followLeaderEnabled)
  end
  
  comboWindow.actions.attackLeaderTargetToggle:setChecked(storage[ComboPanelName].attackLeaderTargetEnabled)
  comboWindow.actions.attackLeaderTargetToggle.onClick = function(widget)
    storage[ComboPanelName].attackLeaderTargetEnabled = not storage[ComboPanelName].attackLeaderTargetEnabled
    widget:setChecked(storage[ComboPanelName].attackLeaderTargetEnabled)
  end 
  
  comboWindow.actions.attackSpellToggle:setChecked(storage[ComboPanelName].attackSpellEnabled)
  comboWindow.actions.attackSpellToggle.onClick = function(widget)
    storage[ComboPanelName].attackSpellEnabled = not storage[ComboPanelName].attackSpellEnabled
    widget:setChecked(storage[ComboPanelName].attackSpellEnabled)
  end
  
  comboWindow.actions.attackItemToggle:setChecked(storage[ComboPanelName].attackItemEnabled)
  comboWindow.actions.attackItemToggle.onClick = function(widget)
    storage[ComboPanelName].attackItemEnabled = not storage[ComboPanelName].attackItemEnabled
    widget:setChecked(storage[ComboPanelName].attackItemEnabled)
  end
  
  -- text edits
  comboWindow.trigger.onSayLeader:setText(storage[ComboPanelName].sayLeader)
  comboWindow.trigger.onSayLeader.onTextChange = function(widget, text)
    storage[ComboPanelName].sayLeader = text
  end
  
  comboWindow.trigger.onShootLeader:setText(storage[ComboPanelName].shootLeader)
  comboWindow.trigger.onShootLeader.onTextChange = function(widget, text)
    storage[ComboPanelName].shootLeader = text
  end

  comboWindow.trigger.onCastLeader:setText(storage[ComboPanelName].castLeader)
  comboWindow.trigger.onCastLeader.onTextChange = function(widget, text)
    storage[ComboPanelName].castLeader = text
  end

  comboWindow.trigger.onSayPhrase:setText(storage[ComboPanelName].sayPhrase)
  comboWindow.trigger.onSayPhrase.onTextChange = function(widget, text)
    storage[ComboPanelName].sayPhrase = text
  end
  
  comboWindow.actions.attackSpell:setText(storage[ComboPanelName].spell)
  comboWindow.actions.attackSpell.onTextChange = function(widget, text)
    storage[ComboPanelName].spell = text
  end

  comboWindow.server.botServerLeader:setText(storage[ComboPanelName].serverLeader)
  comboWindow.server.botServerLeader.onTextChange = function(widget, text)
    storage[ComboPanelName].serverLeader = text
  end  
end

-- bot server
-- [[ join party made by Frosty ]] --

local shouldCloseWindow = false
local firstInvitee = true
local isInComboTeam = false
macro(10, function()
  if shouldCloseWindow and storage[ComboPanelName].serverEnabled and storage[ComboPanelName].enabled then
    local channelsWindow = modules.game_console.channelsWindow
    if channelsWindow then
      local child = channelsWindow:getChildById("buttonCancel")
      if child then
        child:onClick()
        shouldCloseWindow = false
        isInComboTeam = true
      end
    end
  end
end)

comboWindow.server.partyButton.onClick = function(widget)
  if storage[ComboPanelName].serverEnabled and storage[ComboPanelName].enabled then 
    if storage[ComboPanelName].serverLeader:len() > 0 and storage.BotServerChannel:len() > 0 then 
      talkPrivate(storage[ComboPanelName].serverLeader, "request invite " .. storage.BotServerChannel)
    else
      error("Request failed. Lack of data.")
    end
  end
end

onTextMessage(function(mode, text)
  if storage[ComboPanelName].serverEnabled and storage[ComboPanelName].enabled then
    if mode == 20 then
      if string.find(text, "invited you to") then
        local regex = "[a-zA-Z]*"
        local regexData = regexMatch(text, regex)
        if regexData[1][1]:lower() == storage[ComboPanelName].serverLeader:lower() then
          local leader = getCreatureByName(regexData[1][1])
          if leader then
            g_game.partyJoin(leader:getId())
            g_game.requestChannels()
            g_game.joinChannel(1)
            shouldCloseWindow = true
          end
        end
      end
    end
  end
end)

onTalk(function(name, level, mode, text, channelId, pos)
  if storage[ComboPanelName].serverEnabled and storage[ComboPanelName].enabled then
    if mode == 4 then
      if string.find(text, "request invite") then
        local access = string.match(text, "%d.*")
        if access and access == storage.BotServerChannel then
          local minion = getCreatureByName(name)
          if minion then
            g_game.partyInvite(minion:getId())
            if firstInvitee then
              g_game.requestChannels()
              g_game.joinChannel(1)
              shouldCloseWindow = true
              firstInvitee = false
            end
          end
        else
          talkPrivate(name, "Incorrect access key!")
        end
      end
    end
  end
  -- [[ End of Frosty's Code ]] -- 
  if storage[ComboPanelName].enabled and storage[ComboPanelName].enabled then
    if name:lower() == storage[ComboPanelName].sayLeader:lower() and string.find(text, storage[ComboPanelName].sayPhrase) and storage[ComboPanelName].onSayEnabled then
      startCombo = true
    end
    if (storage[ComboPanelName].castLeader and name:lower() == storage[ComboPanelName].castLeader:lower()) and isAttSpell(text) and storage[ComboPanelName].onCastEnabled then
      startCombo = true
    end
  end
  if storage[ComboPanelName].enabled and storage[ComboPanelName].commandsEnabled and (storage[ComboPanelName].shootLeader and name:lower() == storage[ComboPanelName].shootLeader:lower()) or (storage[ComboPanelName].sayLeader and name:lower() == storage[ComboPanelName].sayLeader:lower()) or (storage[ComboPanelName].castLeader and name:lower() == storage[ComboPanelName].castLeader:lower()) then
    if string.find(text, "ue") then
      say(storage[ComboPanelName].spell)
    elseif string.find(text, "sd") then
      local params = string.split(text, ",")
      if #params == 2 then
        local target = params[2]:trim()
        if getCreatureByName(target) then
          useWith(3155, getCreatureByName(target))
        end
      end
    elseif string.find(text, "att") then
      local attParams = string.split(text, ",")
      if #attParams == 2 then
        local atTarget = attParams[2]:trim()
        if getCreatureByName(atTarget) and storage[ComboPanelName].attack == "COMMAND TARGET" then
          g_game.attack(getCreatureByName(atTarget))
        end
      end
    end
  end
  if isAttSpell(text) and storage[ComboPanelName].enabled and storage[ComboPanelName].serverEnabled then
    BotServer.send("trigger", "start")
  end
end)

onMissle(function(missle)
  if storage[ComboPanelName].enabled and storage[ComboPanelName].onShootEnabled then 
    if not storage[ComboPanelName].shootLeader or storage[ComboPanelName].shootLeader:len() == 0 then
      return
    end
    local src = missle:getSource()
    if src.z ~= posz() then
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
    local t1 = toCreatures[1]
    leaderTarget = t1
    if c1:getName():lower() == storage[ComboPanelName].shootLeader:lower() then
      if storage[ComboPanelName].attackItemEnabled and storage[ComboPanelName].item and storage[ComboPanelName].item > 100 and findItem(storage[ComboPanelName].item) then
        useWith(storage[ComboPanelName].item, t1)
      end
      if storage[ComboPanelName].attackSpellEnabled and storage[ComboPanelName].spell:len() > 1 then
        say(storage[ComboPanelName].spell)
      end 
    end
  end
end)

macro(10, function()
  if not storage[ComboPanelName].enabled or not storage[ComboPanelName].attackLeaderTargetEnabled then return end
  if leaderTarget and storage[ComboPanelName].attack == "LEADER TARGET" then
    if not getTarget() or (getTarget() and getTarget():getName() ~= leaderTarget:getName()) then
      g_game.attack(leaderTarget)
    end
  end
  if storage[ComboPanelName].enabled and storage[ComboPanelName].serverEnabled and storage[ComboPanelName].attack == "SERVER LEADER TARGET" and serverTarget then
    if serverTarget and not getTarget() or (getTarget() and getTarget():getname() ~= serverTarget)
    then
      g_game.attack(serverTarget)
    end
  end
end)


local toFollow
local toFollowPos = {}

macro(100, function()
  toFollow = nil
  if not storage[ComboPanelName].enabled or not storage[ComboPanelName].followLeaderEnabled then return end
  if leaderTarget and storage[ComboPanelName].follow == "LEADER TARGET" and leaderTarget:isPlayer() then
    toFollow = leaderTarget:getName()
  elseif storage[ComboPanelName].follow == "SERVER LEADER TARGET" and storage[ComboPanelName].serverLeader:len() ~= 0 then
    toFollow = serverTarget
  elseif storage[ComboPanelName].follow == "SERVER LEADER" and storage[ComboPanelName].serverLeader:len() ~= 0 then
    toFollow = storage[ComboPanelName].serverLeader
  elseif storage[ComboPanelName].follow == "LEADER" then
    if storage[ComboPanelName].onSayEnabled and storage[ComboPanelName].sayLeader:len() ~= 0 then
      toFollow = storage[ComboPanelName].sayLeader
    elseif storage[ComboPanelName].onCastEnabled and storage[ComboPanelName].castLeader:len() ~= 0 then
      toFollow = storage[ComboPanelName].castLeader
    elseif storage[ComboPanelName].onShootEnabled and storage[ComboPanelName].shootLeader:len() ~= 0 then
      toFollow = storage[ComboPanelName].shootLeader
    end
  end
  if not toFollow then return end
  local target = getCreatureByName(toFollow)
  if target then
    local tpos = target:getPosition()
    toFollowPos[tpos.z] = tpos
  end
  if player:isWalking() then return end
  local p = toFollowPos[posz()]
  if not p then return end
  if CaveBot.walkTo(p, 20, {ignoreNonPathable=true, precision=1, ignoreStairs=false}) then
    delay(100)
  end
end)

onCreaturePositionChange(function(creature, oldPos, newPos)
  if creature:getName() == toFollow and newPos then
    toFollowPos[newPos.z] = newPos
  end
end)

local timeout = now
macro(10, function()
  if storage[ComboPanelName].enabled and startCombo then
    if storage[ComboPanelName].attackItemEnabled and storage[ComboPanelName].item and storage[ComboPanelName].item > 100 and findItem(storage[ComboPanelName].item) then
      useWith(storage[ComboPanelName].item, getTarget())
    end
    if storage[ComboPanelName].attackSpellEnabled and storage[ComboPanelName].spell:len() > 1 then
      say(storage[ComboPanelName].spell)
    end
    startCombo = false
  end
  -- attack part / server
  if BotServer._websocket and storage[ComboPanelName].enabled and storage[ComboPanelName].serverEnabled then
    if target() and now - timeout > 500 then
      targetPos = target():getName()
      BotServer.send("target", targetPos)
      timeout = now
    end
  end
end)

onUseWith(function(pos, itemId, target, subType)
  if BotServer._websocket and itemId == 3155 then
    BotServer.send("useWith", target:getPosition())
  end
end)

if BotServer._websocket and storage[ComboPanelName].enabled and storage[ComboPanelName].serverEnabled then
  BotServer.listen("trigger", function(name, message)
    if message == "start" and name:lower() ~= player:getName():lower() and name:lower() == storage[ComboPanelName].serverLeader:lower() and storage[ComboPanelName].serverTriggers then
      startCombo = true
    end
  end)
  BotServer.listen("target", function(name, message)
    if name:lower() ~= player:getName():lower() and name:lower() == storage[ComboPanelName].serverLeader:lower() then
      if not target() or target():getName() == getCreatureByName(message) then
        if storage[ComboPanelName].serverLeaderTarget then
          serverTarget = getCreatureByName(message)
          g_game.attack(getCreatureByName(message))
        end
      end
    end
  end)
  BotServer.listen("useWith", function(name, message)
   local tile = g_map.getTile(message)
   if storage[ComboPanelName].serverTriggers and name:lower() ~= player:getName():lower() and name:lower() == storage[ComboPanelName].serverLeader:lower() and storage[ComboPanelName].attackItemEnabled and storage[ComboPanelName].item and findItem(storage[ComboPanelName].item) then
    useWith(storage[ComboPanelName].item, tile:getTopUseThing())
   end
  end)
end