Container = {}

--- returns all open containers
-- @return table
function Container:getAll() return getContainers() end

--- gets first open container
-- @return userdata
function Container:getFirst() return getContainers()[1] end

--- gets last open container
-- @return userdata
function Container:getLast() return getContainers()[#getContainers()] end

-- returns open containers count
-- @return number
function Container:getOpenContainersCount() return #getContainers() end

--- returns given container item id
-- @param container is userdata
-- @return number
function Container:getItemId() end

--- closes all open container windows
-- @return void
function Container:closeAllContainers()
    for i, container in ipairs(Container:getContainers()) do
        container:close()
    end
end

--- checks if container has any free slots
-- @param container is userdata
-- @return boolean
function Container:isFull(container)
    return container:getCapacity() > #container:getItems()
end

--- returns free slots count in given container
-- @param container is userdata
-- @return number
function Container:getFreeSlots(container)
    return #container:getItems() - container:getCapacity()
end

--- returns first free slot position
-- @param container is userdata
-- @return table
function Container:getFreeSlotPosition(container)
    return container:getSlotPosition(container:getItems())
end

--- opens given container parent
-- @param container is userdata
-- @return void
function Container:openParent(container) g_game.openParent(container) end

--- finds open container object based on the id
-- @param itemId is number
-- @return userdata
function Container:getContainerByItemId(itemId)

    for i, container in ipairs(getContainers()) do
        local cId = container:getContainerItem():getId()
        if cId == itemId then return container end
    end

end

--- finds open container object based on the name
-- @param name is string
-- @return userdata
function Container:getContainerByName(name)
    name = name:lower():trim()

    for i, container in ipairs(getContainers()) do
        local cName = container:getName():lower()
        if cName == name then return container end
    end

end

--- checks if given container is declared as loot container in TargetBot
-- @param container is userdata / integer / string
-- @returns boolean
function Container:isLootContainer(container)
    local id

    if type(container) == "number" then
        id = container
    elseif type(container) == "string" then
        id = Container:getContainerByName(container)
        id = id and id:getContainerItem():getId()
    elseif type(container) == "userdata" then
        id = container:getContainerItem():getId()
    end

    if not id then return false end

    if table.find(vBot.lootConainers, id) then
        return true
    else
        return false
    end
end

--- returns the amount of open loot containers
-- @return amount
function Container:getOpenLootContainersCount()
    local amount = 0

    for i, container in ipairs(getContainers()) do
        amount = Container:isLootContainer(container) and amount + 1 or amount
    end

    return amount
end

--- opens child container with the same id inside given one
-- @param container is userdata
-- @param newWindow is boolean
-- @return void
function Container:openChild(container, newWindow)
    local parentId = container:getContaierItem():getId()

    for i, item in ipairs(container:getItems()) do
        local id = item:getId()

        if id == parentId then
            return g_game.open(item, newWindow and container or nil)
        end
    end
end

-- returns all items inside given container
-- @param container is userdata
-- @return table
function Container:getItems(container) return container:getItems() end

--- checks if given container helds item with given id
-- @param container is userdata
-- @param id is number
-- @return boolean
function Container:hasItem(container, id)
    local isInsideContainer = false

    for i, item in ipairs(container:getItems()) do
        if item:getId() == id then
            isInsideContainer = true
            break
        end
    end

    return isInsideContainer
end

function Container:reOpenAllContainers()
    -- TODO, extract function from containers.lua
end