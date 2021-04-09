CaveBot.Extensions.DWithdraw = {}

comparePosition = function(pPos, tPos)
	return (getDistanceBetween(pPos, tPos) <= 1)
end

local depotIDs = {3497, 3498, 3499, 3500}
local depotContainers = {22797, 22798, 22799, 22800, 22801, 22802, 22803, 22804, 22805, 22806, 22807, 22808, 22809, 22810, 22811, 22812, 22813}
storage.stopSearch = false
storage.lootContainerOpen = false
local i = 1


CaveBot.Extensions.DWithdraw.setup = function()
	CaveBot.registerAction("dpwithdraw", "#002FFF", function(value, retries)
		local capLimit = nil
		if retries > 600 then
			print("CaveBot[DepotWithdraw]: actions limit reached, proceeding") 
			return true
		end
		delay(50)
		if not value or #string.split(value, ",") ~= 3 and #string.split(value, ",") ~= 4 then
			warn("CaveBot[DepotWithdraw]: incorrect value!")
			return false
		end
		local indexDp = tonumber(string.split(value, ",")[1]:trim())
		local destName = string.split(value, ",")[2]:trim()
		local destId = tonumber(string.split(value, ",")[3]:trim())
		if #string.split(value, ",") == 4 then
			capLimit = tonumber(string.split(value, ",")[4]:trim())
		end
		if freecap() < (capLimit or 200) then
			print("CaveBot[DepotWithdraw]: cap limit reached, proceeding") 
			return true 
		end
		local destContainer

		for i, container in pairs(getContainers()) do
			if container:getName():lower() == destName:lower() then
				destContainer = container
			end
			if string.find(container:getName():lower(), "depot box") then
				if #container:getItems() == 0 then
					print("CaveBot[DepotWithdraw]: all items withdrawn")
					return true
				end
			end
		end
		if not destContainer then 
			print("CaveBot[DepotWithdraw]: container not found!")
			return false
		end

		if destContainer:getCapacity() == destContainer:getSize() then
			for j, item in pairs(destContainer:getItems()) do
				if item:getId() == destId then
					g_game.open(item, destContainer)
					return "retry"
				end
			end
			print("CaveBot[DepotWithdraw]: loot containers full!")
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
				if not comparePosition(pos(), dest:getPosition()) then
					if not dest:getCreatures()[1] and dest:isWalkable() then
						if CaveBot.walkTo(dest:getPosition(), {ignoreNonPathable=true}) then
							storage.stopSearch = true
							delay(100)
						end
					else
						i = i + 1
						goto findEmptyDP
					end
				end
			end
		end
		if tileList[i].tileObj and not table.find(depotIDs, tileList[i].tileObj:getTopLookThing():getId()) and comparePosition(pos(), tileList[i].tileObj:getPosition()) then
			for j=1,table.getn(tileList[i].tileObj:getThings()),1 do
				if not tileList[i].tileObj:getThings()[j]:isNotMoveable() then
					delay(500)
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
			for _, container in pairs(g_game.getContainers()) do
				if container:getName():lower() == "locker" then
					depotOpen = true
				end
			end
		end
		if tileList[i].tileObj and depotClear and not depotOpen and not storage.lootContainerOpen then
			delay(500)
			g_game.use(tileList[i].tileObj:getTopUseThing())
			depotOpen = true
		end
		i = 1
		--Version Check to know what to do with the depot--
		if g_game.getClientVersion() > 910 then
			if depotOpen then
				for _, container in pairs(g_game.getContainers()) do
					if container:getName():lower() == "depot chest" then
						depotBoxOpen = true
					end
				end
				if findItem(3502) and not depotBoxOpen then
					delay(500)
					g_game.use(findItem(3502))
					depotBoxOpen = true
				end
			end
			if depotBoxOpen and not storage.lootContainerOpen then
				for _, container in pairs(g_game.getContainers()) do
					if container:getName():lower() == "depot chest" then
						for _, item in ipairs(container:getItems()) do
							if item:isContainer() and table.find({22797, 22798}, item:getId()) then
								g_game.open(findItem(depotContainers[indexDp]), container)
								delay(500)
								for _, cont in pairs(g_game.getContainers()) do
									if string.find(cont:getName():lower(), "depot box") then
										storage.lootContainerOpen = true
										break
									end
								end
							end
						end
						break
					end
				end
			end
		
			for i, container in pairs(g_game.getContainers()) do
				if string.find(container:getName():lower(), "depot box") then
					for j, item in ipairs(container:getItems()) do
						g_game.move(item, destContainer:getSlotPosition(destContainer:getItemsCount()), item:getCount())
						return "retry"
					end
				end
			end

		end
		return "retry"
  end)

 CaveBot.Editor.registerAction("dpwithdraw", "dpwithdraw", {
  value="1, shopping bag, 21411",
  title="Loot Withdraw",
  description="insert index, destination container name and it's ID",
 })
end

onPlayerPositionChange(function(newPos, oldPos)
	storage.lootContainerOpen = false
	storage.stopSearch = false
end)