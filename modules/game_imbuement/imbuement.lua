 function init()
  connect(g_game, {
    onImbuementWindow = onImbuementWindow,
    onCloseImbuementWindow = onCloseImbuementWindow
  })
end

function terminate()
  disconnect(g_game, {
    onImbuementWindow = onImbuementWindow,
    onCloseImbuementWindow = onCloseImbuementWindow
  })
  
end

function onImbuementWindow(itemId, slots, activeSlots, imbuements, needItems)
  print("window " .. slots)
  for i, slot in pairs(activeSlots) do
    local duration = slot.duration
    local removalCost = slot.removalCost 
    local imbuement = slot.imbuement
    for i, source in pairs(imbuement.sources) do
      print(source.description, source.item:getId(), source.item:getCount())
    end

  end
  for i, imbuement in ipairs(imbuements) do
    for i, source in pairs(imbuement.sources) do
      print(source.description, source.item:getId(), source.item:getCount())
    end
  end
  for i, item in ipairs(needItems) do
    print(item:getId(), item:getCount())
  end
end

function onCloseImbuementWindow()
  print("close")
end