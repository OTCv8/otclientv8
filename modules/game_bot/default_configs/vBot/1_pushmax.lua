setDefaultTab("Main")

pushPanelName = "pushmax"
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('PUSHMAX')

  Button
    id: push
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

]])
ui:setId(pushPanelName)

if not storage[pushPanelName] then
  storage[pushPanelName] = {
    enabled = true,
    pushDelay = 1060,
    pushMaxRuneId = 3188,
    mwallBlockId = 2128,
    pushMaxKey = "PageUp"
  }
end

ui.title:setOn(storage[pushPanelName].enabled)
ui.title.onClick = function(widget)
storage[pushPanelName].enabled = not storage[pushPanelName].enabled
widget:setOn(storage[pushPanelName].enabled)
end

ui.push.onClick = function(widget)
  pushWindow:show()
  pushWindow:raise()
  pushWindow:focus()
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  pushWindow = g_ui.createWidget('PushMaxWindow', rootWidget)
  pushWindow:hide()

  pushWindow.closeButton.onClick = function(widget)
    pushWindow:hide()
  end

  local updateDelayText = function()
    pushWindow.delayText:setText("Push Delay: ".. storage[pushPanelName].pushDelay)
  end
  updateDelayText()
  pushWindow.delay.onValueChange = function(scroll, value)
    storage[pushPanelName].pushDelay = value
    updateDelayText()
  end
  pushWindow.delay:setValue(storage[pushPanelName].pushDelay)

  pushWindow.runeId.onItemChange = function(widget)
    storage[pushPanelName].pushMaxRuneId = widget:getItemId()
  end
  pushWindow.runeId:setItemId(storage[pushPanelName].pushMaxRuneId)
  pushWindow.mwallId.onItemChange = function(widget)
    storage[pushPanelName].mwallBlockId = widget:getItemId()
  end
  pushWindow.mwallId:setItemId(storage[pushPanelName].mwallBlockId)

  pushWindow.hotkey.onTextChange = function(widget, text)
    storage[pushPanelName].pushMaxKey = text
  end
  pushWindow.hotkey:setText(storage[pushPanelName].pushMaxKey)
end


function matchPosition(curX, curY, destX, destY)
  return (curX == destX and curY == destY)
end

local target
local targetTile
local targetOldPos
macro(10, function()
  if not storage[pushPanelName].enabled then return end
  if target and targetTile then
    if not matchPosition(target:getPosition().x, target:getPosition().y, targetTile:getPosition().x,  targetTile:getPosition().y) then
      local tile = g_map.getTile(target:getPosition())
      targetOldPos = tile:getPosition()
      if tile then
        if tile:getTopUseThing():isPickupable() or not tile:getTopUseThing():isNotMoveable() then
          useWith(tonumber(storage[pushPanelName].pushMaxRuneId), target)
          delay(10)
        end
        if targetTile:getTopThing():getId() == 2129 or targetTile:getTopThing():getId() == 2130 or targetTile:getTopThing():getId() == tonumber(storage[pushPanelName].mwallBlockId) then
          if targetTile:getTimer() <= tonumber(storage[pushPanelName].pushDelay) then
            info("now")
            g_game.move(target, targetTile:getPosition())
            tile:setText("")
            targetTile:setText("")
            target = nil
            targetTile = nil
          end
        else
          g_game.move(target, targetTile:getPosition())
          delay(1250)
        end
      end
    else
      if targetOldPos then
        local tile = g_map.getTile(targetOldPos)
        if tile then
          tile:setText("")
          targetTile:setText("")
        end
      end
      target = nil
      targetTile = nil
    end
  end
end)

local resetTimer = now
onKeyDown(function(keys)
  if not storage[pushPanelName].enabled then return end
  if keys == storage[pushPanelName].pushMaxKey and resetTimer == 0 then
    if not target then
      local tile = getTileUnderCursor()
      if tile and getDistanceBetween(pos(), tile:getPosition()) <= 1 then
        if tile:getCreatures()[1] then
          target = tile:getCreatures()[1]
          tile:setText("PUSH TARGET")
        end
      end
    else
      local tile = getTileUnderCursor()
      if tile and not tile:getCreatures()[1] then
        targetTile = tile
        tile:setText("DESTINATION")
      end
    end
    resetTimer = now
  end
end)


onKeyPress(function(keys)
  if not storage[pushPanelName].enabled then return end
  if keys == storage.pushMaxKey and (resetTimer - now) < -10 then
    for _, tile in ipairs(g_map.getTiles(posz())) do
      if getDistanceBetween(pos(), tile:getPosition()) < 3 then
        if tile:getText() ~= "" then
          tile:setText("")
        end
      end
    end
    target = nil
    targetTile = nil
    resetTimer = 0
  else
    resetTimer = 0
  end
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
  if target and storage[pushPanelName].enabled then
    if creature:getName() == target:getName() then
      target = nil
      targetTile = nil
      for _, tile in ipairs(g_map.getTiles(posz())) do
        if getDistanceBetween(pos(), tile:getPosition()) < 3 then
          if tile:getText() ~= "" then
            tile:setText("")
          end
        end
      end
    end
  end
end)