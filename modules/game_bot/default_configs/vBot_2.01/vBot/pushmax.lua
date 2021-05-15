setDefaultTab("Main")

local panelName = "pushmax"
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
ui:setId(panelName)

if not storage[panelName] then
  storage[panelName] = {
    enabled = true,
    pushDelay = 1060,
    pushMaxRuneId = 3188,
    mwallBlockId = 2128,
    pushMaxKey = "PageUp"
  }
end

ui.title:setOn(storage[panelName].enabled)
ui.title.onClick = function(widget)
storage[panelName].enabled = not storage[panelName].enabled
widget:setOn(storage[panelName].enabled)
end

ui.push.onClick = function(widget)
  pushWindow:show()
  pushWindow:raise()
  pushWindow:focus()
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  pushWindow = UI.createWindow('PushMaxWindow', rootWidget)
  pushWindow:hide()

  pushWindow.closeButton.onClick = function(widget)
    pushWindow:hide()
  end

  local updateDelayText = function()
    pushWindow.delayText:setText("Push Delay: ".. storage[panelName].pushDelay)
  end
  updateDelayText()
  pushWindow.delay.onValueChange = function(scroll, value)
    storage[panelName].pushDelay = value
    updateDelayText()
  end
  pushWindow.delay:setValue(storage[panelName].pushDelay)

  pushWindow.runeId.onItemChange = function(widget)
    storage[panelName].pushMaxRuneId = widget:getItemId()
  end
  pushWindow.runeId:setItemId(storage[panelName].pushMaxRuneId)
  pushWindow.mwallId.onItemChange = function(widget)
    storage[panelName].mwallBlockId = widget:getItemId()
  end
  pushWindow.mwallId:setItemId(storage[panelName].mwallBlockId)

  pushWindow.hotkey.onTextChange = function(widget, text)
    storage[panelName].pushMaxKey = text
  end
  pushWindow.hotkey:setText(storage[panelName].pushMaxKey)
end


-- variables for config

local config = storage[panelName]
local pushDelay = tonumber(config.pushDelay)
local rune = tonumber(config.pushMaxRuneId)
local customMwall = config.mwallBlockId
local key = config.pushMaxKey
local enabled = config.enabled
local fieldTable = {2118, 105, 2122}

-- scripts 

local targetTile
local pushTarget
local targetid

local resetData = function()
  for i, tile in pairs(g_map.getTiles(posz())) do
    if tile:getText() == "TARGET" or tile:getText() == "DEST" then
      tile:setText('')
    end
  end
  pushTarget = nil
  targetTile = nil
  targetId = nil
end

local getCreatureById = function(id)
  for i, spec in ipairs(getSpectators()) do
    if spec:getId() == id then
      return spec
    end
  end
  return false
end

local isNotOk = function(t,tile)
  local tileItems = {}

  for i, item in pairs(tile:getItems()) do
    table.insert(tileItems, item:getId())
  end
  for i, field in ipairs(t) do
    if table.find(tileItems, field) then
      return true
    end
  end
  return false
end

local isOk = function(a,b)
  return getDistanceBetween(a,b) == 1
end

-- to mark
onKeyDown(function(keys)
  if not enabled then return end
  if keys ~= key then return end
  local tile = getTileUnderCursor()
  if not tile then return end
  if pushTarget and targetTile then
    resetData()
    return
  end
  local creature = tile:getCreatures()[1]
  if not pushTarget and creature then
    pushTarget = creature
    targetId = creature:getId()
    if pushTarget then
      tile:setText('TARGET')
      pushTarget:setMarked('#00FF00')
    end
  elseif not targetTile and pushTarget then
    if pushTarget and getDistanceBetween(tile:getPosition(),pushTarget:getPosition()) ~= 1 then
      resetData()
      return
    else
      tile:setText('DEST')
      targetTile = tile
    end
  end
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
  if not enabled then return end
  if creature == player then
    resetData()
  end
  if not pushTarget or not targetTile then return end
  if creature == pushTarget and newPos == targetTile then
    resetData()
  end
end)

macro(20, function()
  if not enabled then return end
  if not pushTarget or not targetTile then return end
  tilePos = targetTile:getPosition()
  targetPos = pushTarget:getPosition()
  if not isOk(tilePos,targetPos) then return end
  
  local tileOfTarget = g_map.getTile(targetPos)
  
  if not targetTile:isWalkable() then
    local topThing = targetTile:getTopUseThing():getId()
    if topThing == 2129 or topThing == 2130 or topThing == customMwall then
      if targetTile:getTimer() < pushDelay+500 then
        storage.isUsing = true
        schedule(pushDelay+700, function()
          storage.isUsing = false
        end)
      end
      if targetTile:getTimer() > pushDelay then
        return
      end
    else
      return resetData()
    end
  end

  if not tileOfTarget:getTopUseThing():isNotMoveable() then
    return useWith(rune, pushTarget)
  end
  if isNotOk(fieldTable, targetTile) then
    if targetTile:canShoot() then
      return useWith(3148, targetTile:getTopUseThing())
    else
      return
    end
  end
    g_game.move(pushTarget,tilePos)
    delay(2000)
end)