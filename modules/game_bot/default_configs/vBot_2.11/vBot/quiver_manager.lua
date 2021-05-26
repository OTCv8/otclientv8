setDefaultTab("Tools")
function quiverManager()
    quiverPanelName = "quiverManager"

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

  ]])
    ui:setId(quiverPanelName)

    if not storage[quiverPanelName]  then
        storage[quiverPanelName] = {
           arrowsId = 35848,
           boltsId = 35849,
           bolts = false,
           arrows = false
        }
    end

    ui.BoltsSwitch:setOn(storage[quiverPanelName].bolts)
    ui.BoltsSwitch.onClick = function(widget)
      storage[quiverPanelName].bolts = not storage[quiverPanelName].bolts
      widget:setOn(storage[quiverPanelName].bolts)
    end
    ui.ArrowsSwitch:setOn(storage[quiverPanelName].arrows)
    ui.ArrowsSwitch.onClick = function(widget)
      storage[quiverPanelName].arrows = not storage[quiverPanelName].arrows
      widget:setOn(storage[quiverPanelName].arrows)
    end
    ui.BoltsID:setItemId(storage[quiverPanelName].boltsId)
    ui.BoltsID.onItemChange = function(widget)
        storage[quiverPanelName].boltsId = widget:getItemId()
      end
    ui.ArrowsID:setItemId(storage[quiverPanelName].arrowsId)
    ui.ArrowsID.onItemChange = function(widget)
      storage[quiverPanelName].arrowsId = widget:getItemId()
    end

    local arrows = {16143, 763, 761, 7365, 3448, 762, 21470, 7364, 14251, 3447, 3449, 15793, 25757, 774}
    local bolts = {6528, 7363, 3450, 16141, 25758, 14252, 3446, 16142}

    macro(200, function()
        local dArrow
        local dBolt
        for _, c in pairs(getContainers()) do
            if not containerIsFull(c) then
                if c:getContainerItem():getId() == storage[quiverPanelName].arrowsId and storage[quiverPanelName].arrows then
                    dArrow = c
                elseif c:getContainerItem():getId() == storage[quiverPanelName].boltsId and storage[quiverPanelName].bolts then
                    dBolt = c
                end
            end
        end
    
        if dArrow and storage[quiverPanelName].arrows then
            for _, c in pairs(getContainers()) do
                if c:getName():lower():find("backpack") or c:getName():lower():find("bag") or c:getName():lower():find("chess") then
                    for _, i in pairs(c:getItems()) do
                        if table.find(arrows, i:getId()) then
                            return g_game.move(i, dArrow:getSlotPosition(dArrow:getItemsCount()), i:getCount())
                        end
                    end
                end
            end
        end

        if dBolt and storage[quiverPanelName].bolts then
            for _, c in pairs(getContainers()) do
                if c:getName():lower():find("backpack") or c:getName():lower():find("bag") or c:getName():lower():find("chess") then
                    for _, i in pairs(c:getItems()) do
                        if table.find(bolts, i:getId()) then
                            return g_game.move(i, dBolt:getSlotPosition(dBolt:getItemsCount()), i:getCount())
                        end
                    end
                end
            end
        end

    end)

end


if voc() == 2 or voc() == 12 then
addSeparator()
UI.Label("[[ Quiver Manager ]]")
addSeparator()
quiverManager()
end