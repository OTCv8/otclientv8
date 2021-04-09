setDefaultTab("Tools")
UI.Separator()
UI.Label("Items Management")
UI.Separator()

UI.Label("Trash items:")
if type(storage.trashItems) ~= "table" or not storage.trashItems then
  storage.trashItems = {283, 284, 285}
end

local dropContainer = UI.Container(function(widget, items)
  storage.trashItems = items
end, true)
dropContainer:setHeight(35)
dropContainer:setItems(storage.trashItems)

macro(200, "Drop Items", function()
  if not storage.trashItems[1] then return end
  for _, container in pairs(g_game.getContainers()) do
    for __, item in ipairs(container:getItems()) do
      for i, trashItem in ipairs(storage.trashItems) do
        if item:getId() == trashItem.id then
          return g_game.move(item, pos(), item:getCount())
        end
      end
    end
  end
end)

UI.Label("Items to use:")
if type(storage.useItems) ~= "table" or not storage.useItems then
  storage.useItems = {21203, 14758}
end

local useContainer = UI.Container(function(widget, items)
  storage.useItems = items
end, true)
useContainer:setHeight(35)
useContainer:setItems(storage.useItems)

macro(200, "Use Items", function()
  if not storage.useItems[1] then return end
  for _, container in pairs(g_game.getContainers()) do
    for __, item in ipairs(container:getItems()) do
      for i, useItem in ipairs(storage.useItems) do
        if item:getId() == useItem.id then
          return use(item)
        end
      end
    end
  end
end)

UI.Label("Items to drop below 150 cap:")
if type(storage.lowCapDrop) ~= "table" or not storage.lowCapDrop then
  storage.lowCapDrop = {21175}
end

local useContainer = UI.Container(function(widget, items)
  storage.lowCapDrop = items
end, true)
useContainer:setHeight(35)
useContainer:setItems(storage.lowCapDrop)

macro(200, "Drop Items", function()
  if not storage.lowCapDrop[1] then return end
  if freecap() > 150 then return end
  for _, container in pairs(g_game.getContainers()) do
    for __, item in ipairs(container:getItems()) do
      for i, dropItem in ipairs(storage.lowCapDrop) do
        if item:getId() == dropItem.id then
          return g_game.move(item, pos(), item:getCount())
        end
      end
    end
  end
end)

UI.Separator()