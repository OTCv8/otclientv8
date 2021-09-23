local panelName = "alarms"
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Alarms')

  Button
    id: alerts
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit

]])
ui:setId(panelName)

if not storage[panelName] then
  storage[panelName] = {
    enabled = false,
    playerAttack = false,
    playerDetected = false,
    playerDetectedLogout = false,
    creatureDetected = false,
    healthBelow = false,
    healthValue = 40,
    manaBelow = false,
    manaValue = 50,
    privateMessage = false
}
end

local config = storage[panelName]

ui.title:setOn(config.enabled)
ui.title.onClick = function(widget)
config.enabled = not config.enabled
widget:setOn(config.enabled)
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  alarmsWindow = UI.createWindow('AlarmsWindow', rootWidget)
  alarmsWindow:hide()

  alarmsWindow.closeButton.onClick = function(widget)
    alarmsWindow:hide()
  end

  alarmsWindow.playerAttack:setOn(config.playerAttack)
  alarmsWindow.playerAttack.onClick = function(widget)
    config.playerAttack = not config.playerAttack
    widget:setOn(config.playerAttack)
  end

  alarmsWindow.playerDetected:setOn(config.playerDetected)
  alarmsWindow.playerDetected.onClick = function(widget)
    config.playerDetected = not config.playerDetected
    widget:setOn(config.playerDetected)
  end

  alarmsWindow.playerDetectedLogout:setChecked(config.playerDetectedLogout)
  alarmsWindow.playerDetectedLogout.onClick = function(widget)
    config.playerDetectedLogout = not config.playerDetectedLogout
    widget:setChecked(config.playerDetectedLogout)
  end

  alarmsWindow.creatureDetected:setOn(config.creatureDetected)
  alarmsWindow.creatureDetected.onClick = function(widget)
    config.creatureDetected = not config.creatureDetected
    widget:setOn(config.creatureDetected)
  end

  alarmsWindow.healthBelow:setOn(config.healthBelow)
  alarmsWindow.healthBelow.onClick = function(widget)
    config.healthBelow = not config.healthBelow
    widget:setOn(config.healthBelow)
  end

  alarmsWindow.healthValue.onValueChange = function(scroll, value)
    config.healthValue = value
    alarmsWindow.healthBelow:setText("Health < " .. config.healthValue .. "%")  
  end
  alarmsWindow.healthValue:setValue(config.healthValue)

  alarmsWindow.manaBelow:setOn(config.manaBelow)
  alarmsWindow.manaBelow.onClick = function(widget)
    config.manaBelow = not config.manaBelow
    widget:setOn(config.manaBelow)
  end

  alarmsWindow.manaValue.onValueChange = function(scroll, value)
    config.manaValue = value
    alarmsWindow.manaBelow:setText("Mana < " .. config.manaValue .. "%")  
  end
  alarmsWindow.manaValue:setValue(config.manaValue)

  alarmsWindow.privateMessage:setOn(config.privateMessage)
  alarmsWindow.privateMessage.onClick = function(widget)
    config.privateMessage = not config.privateMessage
    widget:setOn(config.privateMessage)
  end

  local pName = player:getName()
  onTextMessage(function(mode, text)
    if config.enabled and config.playerAttack and mode == 16 and string.match(text, "hitpoints due to an attack") and not string.match(text, "hitpoints due to an attack by a ") then
      playSound("/sounds/Player_Attack.ogg")
      g_window.setTitle(pName .. " - Player Detected!")
    end
  end)

  macro(100, function()
    if not config.enabled then
      return
    end
    if config.playerDetected then
      for _, spec in ipairs(getSpectators()) do
        if spec:isPlayer() and spec:getName() ~= name() then
          specPos = spec:getPosition()
          if math.max(math.abs(posx()-specPos.x), math.abs(posy()-specPos.y)) <= 8 then
            playSound("/sounds/Player_Detected.ogg")
            delay(1500)
            g_window.setTitle(pName .. " - Player Detected!")
            if config.playerDetectedLogout then
              modules.game_interface.tryLogout(false)
            end
            return
          end
        end
      end
    end

    if config.creatureDetected then
      for _, spec in ipairs(getSpectators()) do
        if not spec:isPlayer()then
          specPos = spec:getPosition()
          if math.max(math.abs(posx()-specPos.x), math.abs(posy()-specPos.y)) <= 8 then
            playSound("/sounds/Creature_Detected.ogg")
            delay(1500)
            g_window.setTitle(pName .. " - Creature Detected! ")
            return
          end
        end
      end
    end

    if config.healthBelow then
      if hppercent() <= config.healthValue then
        playSound("/sounds/Low_Health.ogg")
        g_window.setTitle(pName .. " - Low Health!")
        delay(1500)
        return
      end
    end

    if config.manaBelow then
      if manapercent() <= config.manaValue then
        playSound("/sounds/Low_Mana.ogg")
        g_window.setTitle(pName .. " - Low Mana!")
        delay(1500)
        return
      end
    end
  end)

  onTalk(function(name, level, mode, text, channelId, pos)
    if mode == 4 and config.enabled and config.privateMessage then
      playSound("/sounds/Private_Message.ogg")
      g_window.setTitle(pName .. " - Private Message")
      return
    end
  end)
end

ui.alerts.onClick = function(widget)
  alarmsWindow:show()
  alarmsWindow:raise()
  alarmsWindow:focus()
end