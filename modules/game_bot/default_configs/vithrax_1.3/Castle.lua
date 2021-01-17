setDefaultTab("Tools")
UI.Label("-- [[ ANTI PUSH Panel ]] --")
addSeparator()
  local panelName = "castle"
  local ui = setupUI([[
Panel
  height: 40

  BotItem
    id: item
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 2
    
  BotSwitch
    id: skip
    anchors.top: parent.top
    anchors.left: item.right
    anchors.right: parent.right
    anchors.bottom: item.verticalCenter
    text-align: center
    !text: tr('Skip Tiles Near Target')
    margin-left: 2

  BotSwitch
    id: title
    anchors.top: item.verticalCenter
    anchors.left: item.right
    anchors.right: parent.right
    anchors.bottom: item.bottom
    text-align: center
    !text: tr('Drop Items Around')
    margin-left: 2
      
  ]], parent)
  ui:setId(panelName)

  if not storage[panelName] then
    storage[panelName] = {
        id = 2983,
        around = false,
        enabled = false
    }
  end

  ui.skip:setOn(storage[panelName].around)
  ui.skip.onClick = function(widget)
    storage[panelName].around = not storage[panelName].around
    widget:setOn(storage[panelName].around)
  end
  ui.title:setOn(storage[panelName].enabled)
  ui.title.onClick = function(widget)
    storage[panelName].enabled = not storage[panelName].enabled
    widget:setOn(storage[panelName].enabled)
  end

  ui.item:setItemId(storage[panelName].id)
  ui.item.onItemChange = function(widget)
    storage[panelName].id = widget:getItemId()
  end


macro(175, function() 
    if storage[panelName].enabled then
        local blockItem = findItem(storage[panelName].id)
        for _, tile in pairs(g_map.getTiles(posz())) do
            if distanceFromPlayer(tile:getPosition()) == 1 and tile:isWalkable() and tile:getTopUseThing():getId() ~= storage[panelName].id and (not storage[panelName].around or not target() or (target() and getDistanceBetween(targetPos(), tile:getPosition() > 1))) then
                g_game.move(blockItem, tile:getPosition())
                return
            end
        end
        storage[panelName].enabled = false
        ui.title:setOn(storage[panelName].enabled)
    end
end)
addSeparator()