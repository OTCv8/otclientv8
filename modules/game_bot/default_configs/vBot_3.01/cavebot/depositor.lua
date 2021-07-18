CaveBot.Extensions.Depositor = {}

--local variables
local closedContainers = false
local reopenedContainers = false
local destination = nil
local lootTable = nil

local function resetCache()
	closedContainers = false
	reopenedContainers = false
	destination = nil
	lootTable = nil
end

local description = g_game.getClientVersion() > 960 and "No - just deposit \n Yes - also reopen loot containers" or "currently not supported, will be added in near future"

CaveBot.Extensions.Depositor.setup = function()
	CaveBot.registerAction("depositor", "#002FFF", function(value, retries)
		-- version check, TODO old tibia
		if g_game.getClientVersion() < 960 then
			warn("CaveBot[Depositor]: unsupported Tibia version, will be added in near future")
			return false
		end

		-- loot list check
		lootTable = lootTable or CaveBot.GetLootItems()
		if #lootTable == 0 then
			print("CaveBot[Depositor]: no items in loot list. Wrong TargetBot Config? Proceeding")
			resetCache()
			return true
		end

		-- backpacks etc
		if value:lower() == "yes" then
			-- reopening backpacks
			if not reopenedContainers then
				if not closedContainers then
					if not CaveBot.CloseLootContainer() then
						return "retry"
					else
						closedContainers = true
					end
				else
					if not CaveBot.OpenLootContainer() then
						return "retry"
					else
						reopenedContainers = true
					end
				end
			end
			-- open next backpacks if no more loot
			if not CaveBot.HasLootItems() then
				local lootContainers = CaveBot.GetLootContainers()
				for _, container in ipairs(getContainers()) do
					local cId = container:getContainerItem():getId()
					if table.find(lootContainers, cId) then
						for i, item in ipairs(container:getItems()) do
							if item:getId() == cId then
								g_game.open(item, container)
								delay(100)
								return "retry"
							end
						end
						-- couldn't find next container, so we done
						print("CaveBot[Depositor]: all items stashed, no backpack to open next, proceeding")
						resetCache()
						return true
					end
				end
			end
		end

		-- first check items
		if retries == 0 then
			if not CaveBot.HasLootItems() then -- resource consuming function
				print("CaveBot[Depositor]: no items to stash, proceeding")
				resetCache()
				return true
			end
		end

		-- next check retries
		if retries > 400 then 
			print("CaveBot[Depositor]: Depositor actions limit reached, proceeding")
			resetCache()
			return true 
		end

		-- reaching and opening depot 
		if not CaveBot.ReachAndOpenDepot() then
			return "retry"
		end

		-- add delay to prevent bugging
		CaveBot.PingDelay(2)

		-- prep time and stashing
		destination = destination or getContainerByName("Depot chest")
		if not destination then return "retry" end

		for _, container in pairs(getContainers()) do
    	    local name = container:getName():lower()
    	    if not name:find("depot") and not name:find("your inbox") then
    	        for _, item in pairs(container:getItems()) do
    	            local id = item:getId()
					if table.find(lootTable, id) then
						local index = getStashingIndex(id) or item:isStackable() and 1 or 0
						CaveBot.StashItem(item, index, destination)
						return "retry"
					end
				end
			end
		end

		-- we gucci
		return true
	end)

	CaveBot.Editor.registerAction("depositor", "depositor", {
	 value="no",
	 title="Depositor",
	 description=description,
	})
end