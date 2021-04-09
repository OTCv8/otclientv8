CaveBot.Extensions.Withdraw = {}

comparePosition = function(pPos, tPos)
	return (getDistanceBetween(pPos, tPos) <= 1)
end

local depotContainers = {22797, 22798, 22799, 22800, 22801, 22802, 22803, 22804, 22805, 22806, 22807, 22808, 22809, 22810, 22811, 22812, 22813}
local depotIDs = {3497, 3498, 3499, 3500}
storage.stopSearch = false
storage.lootContainerOpen = false
local i = 1


CaveBot.Extensions.Withdraw.setup = function()
	CaveBot.registerAction("withdraw", "#002FFF", function(value, retries)
		local data = string.split(value, ",")
		local stashIndex
		local withdrawId
		local count
		local itemCount = 0
		local depotAmount
		if #data ~= 3 then
			warn("incorrect withdraw value")
			return false
		else
			stashIndex = tonumber(data[1])
			withdrawId = tonumber(data[2])
			count = tonumber(data[3])
		end
		local withdrawSource = depotContainers[stashIndex]

		for i, container in pairs(getContainers()) do
			if not string.find(container:getName():lower(), "depot") then
				for j, item in pairs(container:getItems()) do
					if item:getId() == withdrawId then
						itemCount = itemCount + item:getCount()
					end
				end
			end
		end

		if itemCount >= count then
			for i, container in pairs(getContainers()) do
				if string.find(container:getName():lower(), "depot box") then
					g_game.close(container)
				end
			end
			print("enough items")
			return true
		end

		if retries > 400 then
			return true
		end

		delay(200)
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
								delay(500)
								storage.lootContainerOpen = true
								break
							end
						end
						break
					end
				end
			end

			local boxOpened = false
			for _, container in pairs(getContainers()) do
				if string.find(container:getName():lower(), "depot box") then
					boxOpened = true
				end
			end

			if not boxOpened then
				for _, container in pairs(getContainers()) do
					if container:getName():lower() == "depot chest" then
						for _, item in pairs(container:getItems()) do
							if item:getId() == withdrawSource then
								g_game.open(item)						
								break
							end
						end
					end
				end
			end

			for i, container in pairs(getContainers()) do
				if string.find(container:getName():lower(), "depot") then
					for j, item in pairs(container:getItems()) do
						if item:getId() == withdrawId then
							depotAmount = depotAmount + item:getCount()
						end
					end
					break
				end
			end			

			if depotAmount == 0 then
				print("lack of withdraw items!")
				return false
			end

			local destination
			for i, container in pairs(getContainers()) do
				if container:getCapacity() > #container:getItems() and not string.find(container:getName():lower(), "depot") and not string.find(container:getName():lower(), "loot") and not string.find(container:getName():lower(), "inbox") then
					destination = container 
				end
			end

			if itemCount < count and destination then
				for i, container in pairs(getContainers()) do
					if string.find(container:getName():lower(), "depot box") then
						for j, item in pairs(container:getItems()) do
							if item:getId() == withdrawId then
								if item:isStackable() then
									g_game.move(item, destination:getSlotPosition(destination:getItemsCount()), math.min(item:getCount(), (count - itemCount)))
									return "retry"
								else
									g_game.move(item, destination:getSlotPosition(destination:getItemsCount()), 1)
									return "retry"
								end
								return "retry"
							end
						end
					end
				end
			end
			return "retry"
		end
  end)

 CaveBot.Editor.registerAction("withdraw", "withdraw", {
  value="index,id,amount",
  title="Withdraw Items",
  description="insert source index, item id and amount",
 })
end