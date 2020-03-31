local context = G.botContext
if type(context.UI) ~= "table" then
  context.UI = {}
end
local UI = context.UI

UI.Config = function(parent)
  return UI.createWidget("BotConfig", parent)
end

-- call :setItems(table) to set items, call :getItems() to get them
-- unique if true, won't allow duplicates
-- callback (can be nil) gets table with new item list, eg: {{id=2160, count=1}, {id=268, count=100}, {id=269, count=20}}
UI.Container = function(callback, unique, parent)
  local widget = UI.createWidget("BotContainer", parent)
  local oldItems = {}
  
  local updateItems = function()
    local items = widget:getItems()

    -- callback part
    local somethingNew = (#items ~= #oldItems)
    for i, item in ipairs(items) do
      if type(oldItems[i]) ~= "table" then
        somethingNew = true
        break
      end
      if oldItems[i].id ~= item.id or oldItems[i].count ~= item.count then
        somethingNew = true
        break      
      end
    end
    
    if somethingNew then
      oldItems = items
      callback(items)
    end

    widget:setItems(items)
  end
  
  widget.setItems = function(self, items)
    if type(self) == 'table' then
      items = self
    end
    local itemsToShow = math.max(10, #items + 2)
    if itemsToShow % 5 ~= 0 then
      itemsToShow = itemsToShow + 5 - itemsToShow % 5
    end
    widget.items:destroyChildren()
    for i = 1, itemsToShow do 
      local widget = g_ui.createWidget("BotItem", widget.items)
      if type(items[i]) == 'number' then
        items[i] = {id=items[i], count=1}
      end
      if type(items[i]) == 'table' then
        widget:setItem(Item.create(items[i].id, items[i].count))
      end
    end
    oldItems = items
    for i, child in ipairs(widget.items:getChildren()) do
      child.onItemChange = updateItems
    end
  end
  
  widget.getItems = function()
    local items = {}
    local duplicates = {}
    for i, child in ipairs(widget.items:getChildren()) do
      if child:getItemId() >= 100 then
        if not duplicates[child:getItemId()] or not unique then
          table.insert(items, {id=child:getItemId(), count=child:getItemCount()})
          duplicates[child:getItemId()] = true
        end
      end
    end
    return items
  end
  
  return widget
end

