AntiPush = function(parent)
  if not parent then
    parent = panel
  end
  
  local panelName = "antiPushPanel"  
  local ui = g_ui.createWidget("ItemsPanel", parent)
  ui:setId(panelName)

  if not storage[panelName] then
    storage[panelName] = {}
  end

  ui.title:setText("Anti-Push Items")
  ui.title:setOn(storage[panelName].enabled)
  ui.title.onClick = function(widget)
    storage[panelName].enabled = not storage[panelName].enabled
    widget:setOn(storage[panelName].enabled)
  end
  
  if type(storage[panelName].items) ~= 'table' then
    storage[panelName].items = {3031, 3035, 0, 0, 0}
  end

  for i=1,5 do
    ui.items:getChildByIndex(i).onItemChange = function(widget)
      storage[panelName].items[i] = widget:getItemId()
    end
    ui.items:getChildByIndex(i):setItemId(storage[panelName].items[i])    
  end
  
  macro(100, function()    
    if not storage[panelName].enabled then
      return
    end
    local tile = g_map.getTile(player:getPosition())
    if not tile then
      return
    end
    local topItem = tile:getTopUseThing()
    if topItem and topItem:isStackable() then
      topItem = topItem:getId()
    else
      topItem = 0    
    end
    local candidates = {}
    for i, item in pairs(storage[panelName].items) do
      if item >= 100 and item ~= topItem and findItem(item) then
        table.insert(candidates, item)
      end
    end
    if #candidates == 0 then
      return
    end
    if type(storage[panelName].lastItem) ~= 'number' or storage[panelName].lastItem > #candidates then
      storage[panelName].lastItem = 1
    end
    local item = findItem(candidates[storage[panelName].lastItem])
    g_game.move(item, player:getPosition(), 1)
    storage[panelName].lastItem = storage[panelName].lastItem + 1
  end)

  macro(175, "Pull Nearby Items", function()
    local trashitem = nil
    for _, tile in pairs(g_map.getTiles(posz())) do
        if distanceFromPlayer(tile:getPosition()) == 1 and #tile:getItems() ~= 0 and not tile:getTopUseThing():isNotMoveable() then
            trashitem = tile:getTopUseThing()
            g_game.move(trashitem, pos(), trashitem:getCount())
            return
        end
    end
  end)
end

AntiPush(setDefaultTab("Tools"))
addSeparator()