setDefaultTab("Tools")
local panelName = "renameContainers"
if type(storage[panelName]) ~= "table" then
    storage[panelName] = {
        enabled = false;
        purse = true;
        list = {
            {
                value = "Main Backpack",
                enabled = true,
                item = 9601,
                min = false,
                items = { 3081, 3048 }
            },
            {
                value = "Runes",
                enabled = true,
                item = 2866,
                min = true,
                items = { 3161, 3180 }
            },
            {
                value = "Money",
                enabled = true,
                item = 2871,
                min = true,
                items = { 3031, 3035, 3043 }
            },
            {
                value = "Purse",
                enabled = true,
                item = 23396,
                min = true,
                items = {}
            },
        }
    }
end

local config = storage[panelName]

local renameContui = setupUI([[
Panel
  height: 38

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Minimise Containers')

  Button
    id: editContList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

  Button
    id: reopenCont
    !text: tr('Reopen Containers')
    anchors.left: parent.left
    anchors.top: prev.bottom
    anchors.right: parent.right
    height: 17
    margin-top: 3

  ]])
renameContui:setId(panelName)

g_ui.loadUIFromString([[
BackpackName < Label
  background-color: alpha
  text-offset: 18 0
  focusable: true
  height: 16

  CheckBox
    id: enabled
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 15
    height: 15
    margin-top: 2
    margin-left: 3

  $focus:
    background-color: #00000055

  Button
    id: state
    !text: tr('M')
    anchors.right: remove.left
    margin-right: 5
    width: 15
    height: 15

  Button
    id: remove
    !text: tr('x')
    !tooltip: tr('Remove')
    anchors.right: parent.right
    margin-right: 15
    width: 15
    height: 15

ContListsWindow < MainWindow
  !text: tr('Container Names')
  size: 445 170
  @onEscape: self:hide()

  TextList
    id: itemList
    anchors.left: parent.left
    anchors.top: parent.top
    size: 180 83
    margin-top: 3
    margin-bottom: 3
    margin-left: 3
    vertical-scrollbar: itemListScrollBar

  VerticalScrollBar
    id: itemListScrollBar
    anchors.top: itemList.top
    anchors.bottom: itemList.bottom
    anchors.right: itemList.right
    step: 14
    pixels-scroll: true

  VerticalSeparator
    id: sep
    anchors.top: parent.top
    anchors.left: itemList.right
    anchors.bottom: separator.top
    margin-top: 3
    margin-bottom: 6
    margin-left: 10

  Label
    id: lblName
    anchors.left: sep.right
    anchors.top: sep.top
    width: 70
    text: Name:
    margin-left: 10
    margin-top: 3

  TextEdit
    id: contName
    anchors.left: lblName.right
    anchors.top: sep.top
    anchors.right: parent.right

  Label
    id: lblCont
    anchors.left: lblName.left
    anchors.verticalCenter: contId.verticalCenter
    width: 70
    text: Container:

  BotItem
    id: contId
    anchors.left: contName.left
    anchors.top: contName.bottom
    margin-top: 3

  BotContainer
    id: sortList
    anchors.left: prev.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 3
    height: 32

  Label
    anchors.left: lblCont.left
    anchors.verticalCenter: prev.verticalCenter
    width: 70
    text: Items: 

  Button
    id: addItem
    anchors.right: contName.right
    anchors.top: contName.bottom
    margin-top: 5
    text: Add
    width: 40
    font: cipsoftFont

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8

  CheckBox
    id: purse
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    text: Open Purse
    tooltip: Opens Store/Charm Purse
    width: 85
    height: 15
    margin-top: 2
    margin-left: 3

  CheckBox
    id: sort
    anchors.left: prev.right
    anchors.bottom: parent.bottom
    text: Sort Items
    tooltip: Sort items based on items widget
    width: 85
    height: 15
    margin-top: 2
    margin-left: 15

  CheckBox
    id: forceOpen
    anchors.left: prev.right
    anchors.bottom: parent.bottom
    text: Keep Open
    tooltip: Will keep open containers all the time
    width: 85
    height: 15
    margin-top: 2
    margin-left: 15

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-top: 15
]])

function findItemsInArray(t, tfind)
    local tArray = {}
    for x,v in pairs(t) do
        if type(v) == "table" then
            local aItem = t[x].item
            local aEnabled = t[x].enabled
                if aItem then
                    if tfind and aItem == tfind then
                        return x
                    elseif not tfind then
                        if aEnabled then
                            table.insert(tArray, aItem)
                        end
                    end
                end
            end
        end
    if not tfind then return tArray end
end

local lstBPs


local openContainer = function(id)
    local t = {getRight(), getLeft(), getAmmo()} -- if more slots needed then add them here
    for i=1,#t do
        local slotItem = t[i]
        if slotItem and slotItem:getId() == id then
            return g_game.open(slotItem, nil)
        end
    end

    for i, container in pairs(g_game.getContainers()) do
        for i, item in ipairs(container:getItems()) do
            if item:isContainer() and item:getId() == id then
                return g_game.open(item, nil)
            end
        end
    end
end

function reopenBackpacks()
    lstBPs = findItemsInArray(config.list)

    for _, container in pairs(g_game.getContainers()) do g_game.close(container) end
    bpItem = getBack()
    if bpItem ~= nil then
        g_game.open(bpItem)
    end

    schedule(500, function()
        local delay = 200

        if config.purse then
            local item = getPurse()
            if item then
                use(item)
            end
        end
        for i=1,#lstBPs do
            schedule(delay, function()
                openContainer(lstBPs[i])
            end)
            delay = delay + 250
        end
    end)
    

end

rootWidget = g_ui.getRootWidget()
if rootWidget then
    contListWindow = UI.createWindow('ContListsWindow', rootWidget)
    contListWindow:hide()

    renameContui.editContList.onClick = function(widget)
        contListWindow:show()
        contListWindow:raise()
        contListWindow:focus()
    end

    renameContui.reopenCont.onClick = function(widget)
        reopenBackpacks()
    end

    renameContui.title:setOn(config.enabled)
    renameContui.title.onClick = function(widget)
        config.enabled = not config.enabled
        widget:setOn(config.enabled)
    end

    contListWindow.closeButton.onClick = function(widget)
        contListWindow:hide()
    end

    contListWindow.purse.onClick = function(widget)
        config.purse = not config.purse
        contListWindow.purse:setChecked(config.purse)
    end
    contListWindow.purse:setChecked(config.purse)

    contListWindow.sort.onClick = function(widget)
        config.sort = not config.sort
        contListWindow.sort:setChecked(config.sort)
    end
    contListWindow.sort:setChecked(config.sort)

    contListWindow.forceOpen.onClick = function(widget)
        config.forceOpen = not config.forceOpen
        contListWindow.forceOpen:setChecked(config.forceOpen)
    end
    contListWindow.forceOpen:setChecked(config.forceOpen)  

    local function refreshSortList(k, t)
        t = t or {}
        UI.Container(function()
            t = contListWindow.sortList:getItems()
            config.list[k].items = t
            end, true, nil, contListWindow.sortList) 
        contListWindow.sortList:setItems(t)
    end
    refreshSortList(t)

    local refreshContNames = function(tFocus)
        local storageVal = config.list
        if storageVal and #storageVal > 0 then
            for i, child in pairs(contListWindow.itemList:getChildren()) do
                child:destroy()
            end
            for k, entry in pairs(storageVal) do
                local label = g_ui.createWidget("BackpackName", contListWindow.itemList)
                label.onMouseRelease = function()
                    contListWindow.contId:setItemId(entry.item)
                    contListWindow.contName:setText(entry.value)
                    if not entry.items then
                        entry.items = {}
                    end
                    contListWindow.sortList:setItems(entry.items)
                    refreshSortList(k, entry.items)
                end
                label.enabled.onClick = function(widget)
                    entry.enabled = not entry.enabled
                    label.enabled:setChecked(entry.enabled)
                    label.enabled:setTooltip(entry.enabled and 'Disable' or 'Enable')
                    label.enabled:setImageColor(entry.enabled and '#00FF00' or '#FF0000')
                end
                label.remove.onClick = function(widget)
                    table.removevalue(config.list, entry)
                    label:destroy()
                end
                label.state:setChecked(entry.min)
                label.state.onClick = function(widget)
                    entry.min = not entry.min
                    label.state:setChecked(entry.min)
                    label.state:setColor(entry.min and '#00FF00' or '#FF0000')
                    label.state:setTooltip(entry.min and 'Open Minimised' or 'Do not minimise')
                end

                label:setText(entry.value)
                label.enabled:setChecked(entry.enabled)
                label.enabled:setTooltip(entry.enabled and 'Disable' or 'Enable')
                label.enabled:setImageColor(entry.enabled and '#00FF00' or '#FF0000')
                label.state:setColor(entry.min and '#00FF00' or '#FF0000')
                label.state:setTooltip(entry.min and 'Open Minimised' or 'Do not minimise')

                if tFocus and entry.item == tFocus then
                    tFocus = label
                end
            end
            if tFocus then contListWindow.itemList:focusChild(tFocus) end
        end
    end
    contListWindow.addItem.onClick = function(widget)
        local id = contListWindow.contId:getItemId()
        local trigger = contListWindow.contName:getText()

        if id > 100 and trigger:len() > 0 then
            local ifind = findItemsInArray(config.list, id)
            if ifind then
                config.list[ifind] = { item = id, value = trigger, enabled = config.list[ifind].enabled, min = config.list[ifind].min, items = config.list[ifind].items}
            else
                table.insert(config.list, { item = id, value = trigger, enabled = true, min = false, items = {} })
            end
            contListWindow.contId:setItemId(0)
            contListWindow.contName:setText('')
            contListWindow.contName:setColor('white')
            contListWindow.contName:setImageColor('#ffffff')
            contListWindow.contId:setImageColor('#ffffff')
            refreshContNames(id)
        else
            contListWindow.contId:setImageColor('red')
            contListWindow.contName:setImageColor('red')
            contListWindow.contName:setColor('red')
        end
    end
    refreshContNames()
end

onContainerOpen(function(container, previousContainer)
    if renameContui.title:isOn() then
        if not container.window then return end
        local containerWindow = container.window
        if not previousContainer then
            containerWindow:setContentHeight(34)
        end
        local storageVal = config.list
        if storageVal and #storageVal > 0 then
            for _, entry in pairs(storageVal) do
                if entry.enabled and string.find(container:getContainerItem():getId(), entry.item) then
                    if entry.min then
                        containerWindow:minimize()
                    end
                    containerWindow:setText(entry.value)
                end
            end
        end
    end
end)

local function moveItem(item, destination)
    return g_game.move(item, destination:getSlotPosition(destination:getItemsCount()), item:getCount())
end

local function properTable(t)
    local r = {}
    for _, entry in pairs(t) do
      if type(entry) == "number" then
        table.insert(r, entry)
      else
        table.insert(r, entry.id)
      end
    end
    return r
end

macro(500, function()
    if not config.sort and not config.purse then return end

    local storageVal = config.list
    for _, entry in pairs(storageVal) do
        local dId = entry.item
        local items = properTable(entry.items)
        -- sorting
        if config.sort then
            for _, container in pairs(getContainers()) do
                local cName = container:getName():lower()
                if not cName:find("depot") and not cName:find("depot") and not cName:find("quiver") then
                    local cId = container:getContainerItem():getId()
                    for __, item in ipairs(container:getItems()) do
                        local id = item:getId()
                        if table.find(items, id) and cId ~= dId then
                            local destination = getContainerByItem(dId, true)
                            if destination and not containerIsFull(destination) then
                                return moveItem(item, destination)
                            end
                        end
                    end
                end
            end
        end
        -- keep open / purse 23396
        if config.forceOpen then
            local container = getContainerByItem(dId)
            if not container then
                local t = {getBack(), getAmmo(), getFinger(), getNeck(), getLeft(), getRight()}
                for i=1,#t do
                    local slot = t[i]
                    if slot and slot:getId() == dId then
                        return g_game.open(slot)
                    end
                end
                local cItem = findItem(dId)
                if cItem then
                    return g_game.open(cItem)
                end
            end
        end
    end
    if config.purse and config.forceOpen and not getContainerByItem(23396) then
        return use(getPurse())
    end
    delay(1500)
end)