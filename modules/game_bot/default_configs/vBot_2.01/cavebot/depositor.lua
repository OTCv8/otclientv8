CaveBot.Extensions.Depositor = {}

local depotIDs = {3497, 3498, 3499, 3500}
local reset = function()
	storage.stopSearch = false
	storage.lootContainerOpen = false
	storage.containersClosed = false
	storage.containersReset = false
	storage.currentStack = 0
	storage.currentNonStack = nonStackMin
	storage.lastTry = nil
	storage.lootItemsCount = 0
	storage.depositDone = false
end
local i = 1

local ifPing = function()
	if ping() and ping() > 150 then
		return ping()
	else
		return 1
	end
end

CaveBot.Extensions.Depositor.setup = function()
	CaveBot.registerAction("depositor", "#002FFF", function(value, retries)
	if retries > 400 then 
		print("CaveBot[Depositor]: Depositor actions limit reached, proceeding")
		reset()
		return true 
	end
		
	local name = storage["_configs"]["targetbot_configs"]["selected"]
	local file = configDir .. "/targetbot_configs/" .. name .. ".json"
	local data = g_resources.readFileContents(file)
	local lootList = Config.parse(data)['looting']['items']
	local lootContainers = Config.parse(data)['looting']['containers']
	local mainBp
	local stackBp
	local nonStackBp

	local valueString = string.split(value, ",") -- if 3 then it's old tibia

	-- if old tibia then setup backpacks
	if #valueString == 3 then
		mainBp = tonumber(valueString[1]:trim())
		stackBp = tonumber(valueString[2]:trim()) -- non-stack bp count
		nonStackBp = tonumber(valueString[3]:trim()) -- stack bp count

		if not mainBp or not stackBp or not nonStackBp then
			warn("CaveBot[Depositor]: incorrect values! should be 3x ID of containers!")
			reset()
			return false
		end
	end

	-- start with checking the containers
	local lootDestination = {}
	for _, container in pairs(lootContainers) do
		if not table.find(lootDestination, container['id']) then
			table.insert(lootDestination, container['id'])
		end
	end

	-- pretty much every container action is needed only if you want to work with containers
	if (value:lower() == "yes" or #valueString == 3) and not storage.containersReset then 

		-- what is open and what's not
		local currentContainers = {}
		for i, container in pairs(getContainers()) do
			if not table.find(currentContainers, container:getContainerItem():getId()) then
				table.insert(currentContainers, container:getContainerItem():getId())
			end
		end

		delay(500 + 2*ifPing()) -- slow down this function until containers reset 
		if #lootDestination > 0 then
			-- first closing all that are opened
			if not storage.containersClosed then
				for i, container in pairs(getContainers()) do
					if table.find(lootDestination, container:getContainerItem():getId()) then
						g_game.close(container)
						return "retry"
					end
				end
				storage.containersClosed = true
			end
			-- now reopen them
			if not storage.containersReset and storage.containersClosed then
				for i, container in pairs(getContainers()) do
					for j, item in pairs(container:getItems()) do
						if table.find(lootDestination, item:getId()) and not table.find(currentContainers, item:getId()) then
							g_game.open(item)
							return "retry"
						end
					end
				end
				storage.containersReset = true
			end
		end
	end

	if storage.depositDone then
		reset()
		print("CaveBot[Depositor]: Deposit finished, proceeding")
		return true
	end

	local tileList = {}
	local tPos
	local depotClear = false
	local depotOpen = false
	local depotBoxOpen = false
	for _,tile in pairs(g_map.getTiles(posz())) do
		for i,thing in pairs(tile:getThings()) do
			if table.find(depotIDs, thing:getId()) then
				table.insert(tileList, {tileObj = tile, distance = getDistanceBetween(pos(), tile:getPosition()), depotID = thing:getId()})
			end
		end
	end
	table.sort(tileList, function(a,b) return a.distance < b.distance end)
	::findEmptyDP::
	if tileList[i] and not storage.stopSearch then
		if tileList[i].depotID == 3498 then
			tPos = {x = tileList[i].tileObj:getPosition().x + 1, y = tileList[i].tileObj:getPosition().y, z = tileList[i].tileObj:getPosition().z}
		elseif tileList[i].depotID == 3499 then
			tPos = {x = tileList[i].tileObj:getPosition().x, y = tileList[i].tileObj:getPosition().y + 1, z = tileList[i].tileObj:getPosition().z}
		elseif tileList[i].depotID == 3500 then
			tPos = {x = tileList[i].tileObj:getPosition().x - 1, y = tileList[i].tileObj:getPosition().y, z = tileList[i].tileObj:getPosition().z}
		elseif tileList[i].depotID == 3497 then
			tPos = {x = tileList[i].tileObj:getPosition().x, y = tileList[i].tileObj:getPosition().y - 1, z = tileList[i].tileObj:getPosition().z}
		end
		if tPos then
			local dest = g_map.getTile(tPos)
			if not (getDistanceBetween(pos(), dest:getPosition()) <= 1)  then
				if not dest:getCreatures()[1] and dest:isWalkable() then
					if CaveBot.walkTo(dest:getPosition(), {ignoreNonPathable=true}) then
						storage.stopSearch = true
						delay(100+ifPing())
					end
				else
					i = i + 1
					goto findEmptyDP
				end
			end
		end
	end
	if tileList[i] and not table.find(depotIDs, tileList[i].tileObj:getTopLookThing():getId()) and (getDistanceBetween(pos(), tileList[i].tileObj:getPosition()) <= 1) then
		for j=1,table.getn(tileList[i].tileObj:getThings()),1 do
			if not tileList[i].tileObj:getThings()[j]:isNotMoveable() then
				delay(500+2*ifPing())
				g_game.move(tileList[i].tileObj:getThings()[j], pos(), tileList[i].tileObj:getThings()[j]:getCount())
			end
		end
		if table.find(depotIDs, tileList[i].tileObj:getTopLookThing():getId()) then
			depotClear = true
		end
	else
		depotClear = true
	end
	if depotClear then
		for _, container in pairs(getContainers()) do
			if container:getName():lower() == "locker" then
				depotOpen = true
			end
		end
	end
	if tileList[i] and depotClear and not depotOpen and not storage.lootContainerOpen then
		delay(500+2*ifPing())
		g_game.use(tileList[i].tileObj:getTopUseThing())
		depotOpen = true
	end
	i = 1
	
	-- finding depot
	if depotOpen then
		for _, container in pairs(getContainers()) do
			if container:getName():lower() == "depot chest" then
				depotBoxOpen = true
			end
		end
		if findItem(3502) and not depotBoxOpen then
			delay(500+2*ifPing())
			g_game.use(findItem(3502))
			depotBoxOpen = true
		end
	end
	if depotBoxOpen and not storage.lootContainerOpen then
		for _, container in pairs(getContainers()) do
			if container:getName():lower() == "depot chest" then
				for _, item in ipairs(container:getItems()) do
					if #valueString ~= 3 then -- new depot
						if item:isContainer() and table.find({22797, 22798}, item:getId()) then
							delay(500+2*ifPing())
							storage.lootContainerOpen = true
							break
						end
					else
						if item:isContainer() and item:getId() == mainBp then
							delay(500+2*ifPing())
							g_game.use(item, container)
							storage.lootContainerOpen = true
							break
						end
					end
				end
				break
			end
		end
	end

	if #valueString == 3 then
		delay(150+ifPing())
		for _, container in pairs(getContainers()) do
			if container:getContainerItem():getId() == mainBp then
				storage.lootContainerOpen = true
				storage.isDepositing = true
				break
			end
		end
	end

	
	local looting = {}
	for _, lootItem in pairs(lootList) do
		if not table.find(looting, lootItem['id']) and not table.find({3031, 3035, 3043}, lootItem['id']) then
			table.insert(looting, lootItem['id'])
		end
	end
	delay(200+ifPing())
	local currentItems = 0
	for _, container in pairs(getContainers()) do
		for _, item in ipairs(container:getItems()) do
			if table.find(looting, item:getId()) then
		  currentItems = currentItems + item:getCount()   
		end
		end
	end

	if currentItems == 0 then
		if value:lower() ~= "yes" and #valueString ~= 3 then
			storage.containersClosed = false
			storage.containersReset = false
			storage.depositDone = true
			return "retry"
		end
		
		for i, container in pairs(getContainers()) do
			for j, item in pairs(container:getItems()) do
				if table.find(lootDestination, container:getContainerItem():getId()) and table.find(lootDestination, item:getId()) then
					g_game.open(item, container)
					return "retry"
				end
			end
		end

		storage.containersClosed = false
		storage.containersReset = false
		storage.depositDone = true
		return "retry"
	end

	-- only if old depot
	local stackMin 
	local stackMax 
	local nonStackMin
	local nonStackMax
	if #valueString == 3 then
		-- backpacks setup
		local stack = 0
		local nonStack = 0
		for i, container in pairs(getContainers()) do 
			if container:getContainerItem():getId() == mainBp then
				for i, item in pairs(container:getItems()) do
					if item:getId() == stackBp then
						stack = stack + 1
					elseif item:getId() == nonStackBp then
						nonStack = nonStack + 1
					end
				end
			end
		end

		stackMax = stack - 1
		nonStackMin = stack
		nonStackMax = (stack + nonStack) - 1

		storage.currentStack = 0
		storage.currentNonStack = nonStackMin

		if storage.lootItemsCount == currentItems then
			if storage.lastTry == 1 then
				if storage.currentStack < stackMax then
					storage.currentStack = storage.currentStack + 1
				else
					warn("CaveBot[Depositer]: Stack Backpack full! Proceeding.")
					reset()
					return true
				end
			elseif storage.lastTry == 2 then
				if storage.currentNonStack < nonStackMax then
					storage.currentNonStack = storage.currentNonStack + 1
				else
					warn("CaveBot[Depositer]: Non-Stack Backpack full! Proceeding.")
					reset()
					return true
				end
			end
		end
		storage.lootItemsCount = currentItems
	end

	if #looting > 0 then
		if #valueString ~= 3 then -- version check, if value is set of 3 i
			for i, depotcontainer in pairs(getContainers()) do
				containerItemId = depotcontainer:getContainerItem():getId()
				--check if open depot
				if containerItemId == 3502 then
					-- check all containers and items
					for l, lootcontainer in pairs(getContainers()) do
						for j, item in ipairs(lootcontainer:getItems()) do
							-- now the criteria
							if table.find(looting, item:getId()) then
								-- move the item
								if item:isStackable() then
									g_game.move(item, depotcontainer:getSlotPosition(1), item:getCount())
									return "retry"
								else
									g_game.move(item, depotcontainer:getSlotPosition(0), item:getCount())	
									return "retry"
								end
							end
						end
					end
				end
			end
		else -- to be written, last part missing is stashing items for old depots
			for i, depotcontainer in pairs(getContainers()) do
				containerItemId = depotcontainer:getContainerItem():getId()
				--check if open depot
				if containerItemId == mainBp then
					-- check all containers and items
					for l, lootcontainer in pairs(getContainers()) do
						for j, item in ipairs(lootcontainer:getItems()) do
							-- now the criteria
							if table.find(looting, item:getId()) then
								-- move the item
								if item:isStackable() then
									g_game.move(item, depotcontainer:getSlotPosition(storage.currentStack), item:getCount())
									storage.lastTry = 1
									return "retry"
								else
									g_game.move(item, depotcontainer:getSlotPosition(storage.currentNonStack), item:getCount())	
									storage.lastTry = 2
									return "retry"
								end
							end
						end
					end
				end
			end


		end
	else
		warn("no items in looting list!")
		reset()
		return false
	end
	return "retry"
  end)

 CaveBot.Editor.registerAction("depositor", "depositor", {
  value="no",
  title="Depositor",
  description="No - just deposit \n Yes - also reopen loot containers \n mainID, stackId, nonStackId - for older tibia",
 })
end

onPlayerPositionChange(function(newPos, oldPos)
	if CaveBot.isOn() then
		reset()
	end
end)