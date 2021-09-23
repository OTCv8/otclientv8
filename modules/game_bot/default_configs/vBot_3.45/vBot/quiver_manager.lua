setDefaultTab("Tools")
function quiverManager()
  local panelName = "quiverManager"

  local ui = setupUI([[
Panel
  height: 33
  margin-top: 2

  BotItem
    id: BoltsID
    anchors.left: parent.left
    anchors.top: parent.top

  BotItem
    id: ArrowsID
    anchors.left: prev.right
    anchors.verticalCenter: prev.verticalCenter

  BotSwitch
    id: BoltsSwitch
    anchors.top: parent.top
    anchors.bottom: prev.verticalCenter
    anchors.right: parent.right
    text: Sort Bolts

  BotSwitch
    id: ArrowsSwitch
    anchors.top: prev.bottom
    anchors.bottom: ArrowsID.bottom
    anchors.right: parent.right
    text: Sort Arrows

  ]]
  )
  ui:setId(panelName)

  if not storage[panelName] then
    storage[panelName] = {
      arrowsId = 35848,
      boltsId = 35849,
      bolts = false,
      arrows = false
    }
  end

  local config = storage[panelName]

  ui.BoltsSwitch:setOn(config.bolts)
  ui.BoltsSwitch.onClick = function(widget)
    config.bolts = not config.bolts
    widget:setOn(config.bolts)
  end
  ui.ArrowsSwitch:setOn(config.arrows)
  ui.ArrowsSwitch.onClick = function(widget)
    config.arrows = not config.arrows
    widget:setOn(config.arrows)
  end
  ui.BoltsID:setItemId(config.boltsId)
  ui.BoltsID.onItemChange = function(widget)
    config.boltsId = widget:getItemId()
  end
  ui.ArrowsID:setItemId(config.arrowsId)
  ui.ArrowsID.onItemChange = function(widget)
    config.arrowsId = widget:getItemId()
  end

  local arrows = {16143, 763, 761, 7365, 3448, 762, 21470, 7364, 14251, 3447, 3449, 15793, 25757, 774, 35901}
  local bolts = {6528, 7363, 3450, 16141, 25758, 14252, 3446, 16142, 35902}

  macro(100, function()
    local dArrow
    local dBolt
    for _, c in pairs(getContainers()) do
      if not containerIsFull(c) then
        if c:getContainerItem():getId() == config.arrowsId and config.arrows then
          dArrow = c
        elseif c:getContainerItem():getId() == config.boltsId and config.bolts then
          dBolt = c
        end
      end
    end
    for _, c in pairs(getContainers()) do
      if c:getName():lower():find("backpack") or c:getName():lower():find("bag") or c:getName():lower():find("chess") then
        for _, i in pairs(c:getItems()) do
          -- arrows
          if dArrow and config.arrows then
            if table.find(arrows, i:getId()) and c ~= dArrow then
              return g_game.move(i, dArrow:getSlotPosition(dArrow:getItemsCount()), i:getCount())
            end
          end
          -- bolts
          if dBolt and config.bolts then
            if table.find(bolts, i:getId()) and c ~= dBolt then
              return g_game.move(i, dBolt:getSlotPosition(dBolt:getItemsCount()), i:getCount())
            end
          end
        end
      end
    end
    delay(900)
  end)
end

addSeparator()
if voc() == 2 or voc() == 12 then
  UI.Label("[[ Quiver Manager ]]")
  addSeparator()
  quiverManager()
  addSeparator()
end
