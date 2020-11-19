setDefaultTab("Cave")
UI.Separator()

function containerIsFull(c)
  if not c then return false end

  if c:getCapacity() > #c:getItems() then
    return false
  else
    return true
  end

end

-- config

local ammoBp = "crystal backpack"
local potionBp = "camouflage backpack"
local runeBp = "red backpack"

-- script

local potions = {268, 237, 238, 23373, 266, 236, 239, 7643, 23375, 7642, 23374} 
local runes = {3725, 3203, 3161, 3147, 3178, 3177, 3153, 3148, 3197, 3149, 3164, 3166, 3200, 3192, 3188, 3190, 3189, 3191, 3198, 3182, 3158, 3152, 3174, 3180, 3165, 3173, 3172, 3176, 3195, 3179, 3175, 3155, 3202, 3160, 3156}
local ammo = {3446, 16142, 6528, 7363, 3450, 16141, 25785, 14252, 3447, 3449, 15793, 25757, 774, 16143, 763, 761, 7365, 3448, 762, 21470, 7364, 14251, 7368, 25759, 3287, 7366, 3298, 25758}

local potionsContainer = nil
local runesContainer = nil
local ammoContainer = nil

macro(500, "Supply Sorter", function()
  
  -- set the containers
  if not potionsContainer or not runesContainer or not ammoContainer then
    for i, container in pairs(getContainers()) do
      if container:getName():lower() == potionBp:lower() then
        potionsContainer = container
      elseif container:getName():lower() == runeBp:lower() then
        runesContainer = container
      elseif container:getName():lower() == ammoBp:lower() then
        ammoContainer = container
      end 
    end
  end



  -- potions
  if potionsContainer then 
    for i, container in pairs(getContainers()) do
      if (container:getName():lower() ~= potionBp:lower() and (string.find(container:getName(), "backpack") or string.find(container:getName(), "bag") or string.find(container:getName(), "chess"))) and not string.find(container:getName():lower(), "loot") then
        for j, item in pairs(container:getItems()) do
          if table.find(potions, item:getId()) and not containerIsFull(potionsContainer) then
            g_game.move(item, potionsContainer:getSlotPosition(potionsContainer:getItemsCount()), item:getCount())
          end
        end
      end
    end
  end

   -- runes
   if runesContainer then 
    for i, container in pairs(getContainers()) do
      if (container:getName():lower() ~= runeBp:lower() and (string.find(container:getName(), "backpack") or string.find(container:getName(), "bag") or string.find(container:getName(), "chess"))) and not string.find(container:getName():lower(), "loot") then
        for j, item in pairs(container:getItems()) do
          if table.find(runes, item:getId()) and not containerIsFull(runesContainer) then
            g_game.move(item, runesContainer:getSlotPosition(runesContainer:getItemsCount()), item:getCount())
          end
        end
      end
    end
  end 

  -- ammo
  if ammoContainer then 
    for i, container in pairs(getContainers()) do
      if (container:getName():lower() ~= ammoBp:lower() and (string.find(container:getName(), "backpack") or string.find(container:getName(), "bag") or string.find(container:getName(), "chess"))) and not string.find(container:getName():lower(), "loot") then
        for j, item in pairs(container:getItems()) do
          if table.find(ammo, item:getId()) and not containerIsFull(ammoContainer) then
            g_game.move(item, ammoContainer:getSlotPosition(ammoContainer:getItemsCount()), item:getCount())
          end
        end
      end
    end
  end

end)