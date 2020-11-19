setDefaultTab("Cave")

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

UI.Separator()