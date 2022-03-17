local panelName = "EquipperPanel"
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: switch
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('EQ Manager')

  Button
    id: setup
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]])
ui:setId(panelName)

if not storage[panelName] then
    storage[panelName] = {
        enabled = false,
        rules = {}
    }
end

local config = storage[panelName]

ui.switch:setOn(config.enabled)
ui.switch.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
end

local conditions = { -- always add new conditions at the bottom
    "Item is available and not worn.", -- nothing 1
    "Monsters around is more than: ", -- spinbox 2
    "Monsters around is less than: ", -- spinbox 3
    "Health precent is below:", -- spinbox 4
    "Health precent is above:", -- spinbox 5
    "Mana precent is below:", -- spinbox 6
    "Mana precent is above:", -- spinbox 7
    "Target name is:", -- BotTextEdit 8
    "Hotkey is being pressed:", -- BotTextEdit 9
    "Player is paralyzed", -- nothing 10
    "Player is in protection zone", -- nothing 11
    "Players around is more than:", -- spinbox 12
    "Players around is less than:", -- spinbox 13
    "TargetBot Danger is Above:", -- spinbox 14
    "Blacklist player in range (sqm)" -- spinbox 15
}

local conditionNumber = 1
local optionalConditionNumber = 2

local mainWindow = UI.createWindow("EquipWindow")
mainWindow:hide()

ui.setup.onClick = function()
    mainWindow:show()
    mainWindow:raise()
    mainWindow:focus()
end

mainWindow.closeButton.onClick = function()
    mainWindow:hide()
    resetFields()
end

local inputPanel = mainWindow.inputPanel
local listPanel = mainWindow.listPanel

inputPanel.optionalCondition:hide()
inputPanel.useSecondCondition.onOptionChange = function(widget, option, data)
    if option ~= "-" then
        inputPanel.optionalCondition:show()
    else
        inputPanel.optionalCondition:hide()
    end
end

inputPanel.unequip.onClick = function()
    local value = 115
    local panel = inputPanel.unequipPanel
    local height = panel:getHeight()
    if height == 0 then
        panel:setHeight(value)
        mainWindow:setHeight(mainWindow:getHeight()+value)
        inputPanel:setHeight(inputPanel:getHeight()+value)
        listPanel:setHeight(listPanel:getHeight()+value)
    else
        panel:setHeight(0)
        mainWindow:setHeight(mainWindow:getHeight()-value)
        inputPanel:setHeight(inputPanel:getHeight()-value)
        listPanel:setHeight(listPanel:getHeight()-value)
    end
end

local function setCondition(first, n)
    local widget
    local spinBox 
    local textEdit

    if first then
        widget = inputPanel.condition.description.text
        spinBox = inputPanel.condition.spinbox
        textEdit = inputPanel.condition.text
    else
        widget = inputPanel.optionalCondition.description.text
        spinBox = inputPanel.optionalCondition.spinbox
        textEdit = inputPanel.optionalCondition.text
    end

    -- reset values after change
    spinBox:setValue(0)
    textEdit:setText('')

    if n == 1 or n == 10 or n == 11 then
        spinBox:hide()
        textEdit:hide()
    elseif n == 9 or n == 8 then
        spinBox:hide()
        textEdit:show()
        if n == 9 then
            textEdit:setWidth(75)
        else
            textEdit:setWidth(200)
        end
    else
        spinBox:show()
        textEdit:hide()
    end
    widget:setText(conditions[n])
end

-- add default text & windows
setCondition(true, 1)
setCondition(false, 2)

-- in/de/crementation buttons
inputPanel.condition.nex.onClick = function()
    local max = #conditions

    if inputPanel.optionalCondition:isVisible() then
        if conditionNumber == max then
            if optionalConditionNumber == 1 then
                conditionNumber = 2
            else
                conditionNumber = 1
            end
        else
            local futureNumber = conditionNumber + 1
            local safeFutureNumber = conditionNumber + 2 > max and 1 or conditionNumber + 2
            conditionNumber = futureNumber ~= optionalConditionNumber and futureNumber or safeFutureNumber
        end
    else
        conditionNumber = conditionNumber == max and 1 or conditionNumber + 1
        if optionalConditionNumber == conditionNumber then
            optionalConditionNumber = optionalConditionNumber == max and 1 or optionalConditionNumber + 1
            setCondition(false, optionalConditionNumber)
        end
    end
    setCondition(true, conditionNumber)
end

inputPanel.condition.pre.onClick = function()
    local max = #conditions

    if inputPanel.optionalCondition:isVisible() then
        if conditionNumber == 1 then
            if optionalConditionNumber == max then
                conditionNumber = max-1
            else
                conditionNumber = max
            end
        else
            local futureNumber = conditionNumber - 1
            local safeFutureNumber = conditionNumber - 2 < 1 and max or conditionNumber - 2
            conditionNumber = futureNumber ~= optionalConditionNumber and futureNumber or safeFutureNumber
        end
    else
        conditionNumber = conditionNumber == 1 and max or conditionNumber - 1
        if optionalConditionNumber == conditionNumber then
            optionalConditionNumber = optionalConditionNumber == 1 and max or optionalConditionNumber - 1
            setCondition(false, optionalConditionNumber)
        end
    end
    setCondition(true, conditionNumber)
end

inputPanel.optionalCondition.nex.onClick = function()
    local max = #conditions

    if optionalConditionNumber == max then
        if conditionNumber == 1 then
            optionalConditionNumber = 2
        else
            optionalConditionNumber = 1
        end
    else
        local futureNumber = optionalConditionNumber + 1
        local safeFutureNumber = optionalConditionNumber + 2 > max and 1 or optionalConditionNumber + 2
        optionalConditionNumber = futureNumber ~= conditionNumber and futureNumber or safeFutureNumber
    end
    setCondition(false, optionalConditionNumber)
end

inputPanel.optionalCondition.pre.onClick = function()
    local max = #conditions

    if optionalConditionNumber == 1 then
        if conditionNumber == max then
            optionalConditionNumber = max-1
        else
            optionalConditionNumber = max
        end
    else
        local futureNumber = optionalConditionNumber - 1
        local safeFutureNumber = optionalConditionNumber - 2 < 1 and max or optionalConditionNumber - 2
        optionalConditionNumber = futureNumber ~= conditionNumber and futureNumber or safeFutureNumber
    end
    setCondition(false, optionalConditionNumber)
end

listPanel.up.onClick = function(widget)
    local focused = listPanel.list:getFocusedChild()
    local n = listPanel.list:getChildIndex(focused)
    local t = config.rules

    t[n], t[n-1] = t[n-1], t[n]
    if n-1 == 1 then
      widget:setEnabled(false)
    end
    listPanel.down:setEnabled(true)
    listPanel.list:moveChildToIndex(focused, n-1)
    listPanel.list:ensureChildVisible(focused)
end

listPanel.down.onClick = function(widget)
    local focused = listPanel.list:getFocusedChild()    
    local n = listPanel.list:getChildIndex(focused)
    local t = config.rules

    t[n], t[n+1] = t[n+1], t[n]
    if n + 1 == listPanel.list:getChildCount() then
      widget:setEnabled(false)
    end
    listPanel.up:setEnabled(true)
    listPanel.list:moveChildToIndex(focused, n+1)
    listPanel.list:ensureChildVisible(focused)
  end

function getItemsFromBox()
    local t = {}

    for i, child in ipairs(inputPanel.itemBox:getChildren()) do
        local id = child:getItemId()
        if id > 100 then
            table.insert(t, id)
        end
    end
    return t
end

function refreshItemBox(reset)
    local max = 8
    local box = inputPanel.itemBox
    local childAmount = box:getChildCount()

    --height
    if #getItemsFromBox() < 7 then
        mainWindow:setHeight(345)
        inputPanel:setHeight(265)
        listPanel:setHeight(265)
        box:setHeight(40)
    else
        mainWindow:setHeight(370)
        inputPanel:setHeight(300)
        listPanel:setHeight(300)
        box:setHeight(80)
    end

    if reset then
        box:destroyChildren()
        local widget = UI.createWidget("BotItem", box)
        widget.onItemChange = function(widget)
            local id = widget:getItemId()
            local index = box:getChildIndex(widget)
            if id < 100 or (table.find(getItemsFromBox(), id) ~= index) then
                widget:destroy()
            end
            refreshItemBox()
        end
        return
    end

    if childAmount == 0 then
        local widget = UI.createWidget("BotItem", box)
        widget.onItemChange = function(widget)
            local id = widget:getItemId()
            local index = box:getChildIndex(widget)
            if id < 100 or (table.find(getItemsFromBox(), id) ~= index) then
                widget:destroy()
            end
            refreshItemBox()
        end
    elseif box:getLastChild():getItemId() > 100 and childAmount <= max then
        local widget = UI.createWidget("BotItem", box)
        widget.onItemChange = function(widget)
            local id = widget:getItemId()
            local index = box:getChildIndex(widget)
            if id < 100 or (table.find(getItemsFromBox(), id) ~= index) then
                widget:destroy()
            end
            refreshItemBox()
        end
    end
end
refreshItemBox()

local function resetFields()
    refreshItemBox(true)
    inputPanel.name:setText('')
    conditionNumber = 1
    optionalConditionNumber = 2
    setCondition(false, optionalConditionNumber)
    setCondition(true, conditionNumber)
    inputPanel.useSecondCondition:setCurrentOption("-")
    for i, child in pairs(inputPanel.unequipPanel:getChildren()) do
        child:setChecked(false)
    end
end

-- buttons disabled by default
listPanel.up:setEnabled(false)
listPanel.down:setEnabled(false)
function refreshRules()
    local list = listPanel.list

    list:destroyChildren()
    for i,v in pairs(config.rules) do
        local widget = UI.createWidget('Rule', list)
        widget:setId(v.name)
        widget:setText(v.name)
        widget.remove.onClick = function()
            widget:destroy()
            table.remove(config.rules, table.find(config.rules, v))
            listPanel.up:setEnabled(false)
            listPanel.down:setEnabled(false)
            refreshRules()
        end
        widget.visible:setColor(v.visible and "green" or "red")
        widget.visible.onClick = function()
            v.visible = not v.visible
            widget.visible:setColor(v.visible and "green" or "red")
        end
        widget.enabled:setChecked(v.enabled)
        widget.enabled.onClick = function()
            v.enabled = not v.enabled
            widget.enabled:setChecked(v.enabled)
        end
        local desc 
        for i, v in ipairs(v.items) do
            if i == 1 then
                desc = "items: " .. v
            else
                desc = desc .. ", " .. v
            end
        end
        widget:setTooltip(desc)
        widget.onClick = function()
            local panel = listPanel
            if #panel.list:getChildren() == 1 then
                panel.up:setEnabled(false)
                panel.down:setEnabled(false)
            elseif panel.list:getChildIndex(panel.list:getFocusedChild()) == 1 then
                panel.up:setEnabled(false)
                panel.down:setEnabled(true)
            elseif panel.list:getChildIndex(panel.list:getFocusedChild()) == #panel.list:getChildren() then
                panel.up:setEnabled(true)
                panel.down:setEnabled(false)
            else
                panel.up:setEnabled(true)
                panel.down:setEnabled(true)
            end
        end
        widget.onDoubleClick = function()
            -- main
            conditionNumber = v.mainCondition
            setCondition(true, conditionNumber)
            if conditionNumber == 8 or conditionNumber == 9 then
                inputPanel.condition.text:setText(v.mainValue)
            elseif conditionNumber ~= 1 then
                inputPanel.condition.spinbox:setValue(v.mainValue)
            end
            -- relation
            inputPanel.useSecondCondition:setCurrentOption(v.relation)
            -- optional
            if v.relation ~= "-" then
                optionalConditionNumber = v.optionalCondition
                setCondition(false, optionalConditionNumber)
                if optionalConditionNumber == 8 or optionalConditionNumber == 9 then
                    inputPanel.optionalCondition.text:setText(v.optValue)
                elseif optionalConditionNumber ~= 1 then
                    inputPanel.optionalCondition.spinbox:setValue(v.optValue)
                end
            end
            -- name
            inputPanel.name:setText(v.name)
            -- items
            inputPanel.itemBox:destroyChildren()
            for i, item in ipairs(v.items) do
                local widget = UI.createWidget("BotItem", inputPanel.itemBox)
                widget:setItemId(item)
                widget.onItemChange = function(widget)
                    local id = widget:getItemId()
                    local index = box:getChildIndex(widget)
                    if id < 100 or (table.find(getItemsFromBox(), id) ~= index) then
                        widget:destroy()
                    end
                    refreshItemBox()
                end
            end
            -- unequip
            if type(v.unequip) == "table" then
                for i, tick in ipairs(v.unequip) do
                    local checkbox = inputPanel.unequipPanel:getChildren()[i]
                    checkbox:setChecked(tick)
                end
            end
            refreshItemBox()
            -- remove value
            table.remove(config.rules, table.find(config.rules, v))
            refreshRules()
        end
    end
end
refreshRules()

inputPanel.addButton.onClick = function()
    local mainVal
    local optVal
    local relation = inputPanel.useSecondCondition:getText()
    local name = inputPanel.name:getText()
    local items = getItemsFromBox()
    local unequip = {}
    local hasUnequip = false

    for i, child in pairs(inputPanel.unequipPanel:getChildren()) do
        if child:isChecked() then
            table.insert(unequip, true)
            hasUnequip = true
        else
            table.insert(unequip, false)
        end
    end

    if conditionNumber == 1 then
        mainVal = nil
    elseif conditionNumber == 8 then
        mainVal = inputPanel.condition.text:getText()
        if mainVal:len() == 0 then
            return warn("[vBot Equipper] Please fill the name of the creature.")
        end
    elseif conditionNumber == 9 then
        mainVal = inputPanel.condition.text:getText()
        if mainVal:len() == 0 then
            return warn("[vBot Equipper] Please set correct hotkey.")
        end
    else
        mainVal = inputPanel.condition.spinbox:getValue()
    end

    if relation ~= "-" then
        if optionalConditionNumber == 1 then
            optVal = nil
        elseif optionalConditionNumber == 8 then
            optVal = inputPanel.optionalCondition.text:getText()
            if optVal:len() == 0 then
                return warn("[vBot Equipper] Please fill the name of the creature.")
            end
        elseif optionalConditionNumber == 9 then
            optVal = inputPanel.optionalCondition.text:getText()
            if optVal:len() == 0 then
                return warn("[vBot Equipper] Please set correct hotkey.")
            end
        else
            optVal = inputPanel.optionalCondition.spinbox:getValue()
        end
    end

    if #items == 0 and not hasUnequip then
        return warn("[vBot Equipper] Please add items or select unequip slots.")
    end

    if #name == 0 then
        return warn("[vBot Equipper] Please fill name of the profile.")
    end
    for i, child in pairs(listPanel.list:getChildren()) do
        if child:getText() == name then
            return warn("[vBot Equipper] There is already rule with this name! Choose different or remove old one.")
        end
    end

    -- add
    table.insert(config.rules, {
        enabled = true,
        visible = true,
        mainCondition = conditionNumber,
        optionalCondition = optionalConditionNumber,
        mainValue = mainVal,
        optValue = optVal,
        relation = relation,
        items = items,
        name = name,
        unequip = unequip
    })

    refreshRules()
    resetFields()
end

--"Item is available and not worn.", -- nothing 1
--"Monsters around is more than: ", -- spinbox 2
--"Monsters around is less than: ", -- spinbox 3
--"Health precent is below:", -- spinbox 4
--"Health precent is above:", -- spinbox 5
--"Mana precent is below:", -- spinbox 6
--"Mana precent is above:", -- spinbox 7
--"Target name is:", -- BotTextEdit 8
--"Hotkey is being pressed:", -- Button 9
--"Player is paralyzed", -- nothing 10

local pressedKey = ""
local lastPress = now
onKeyPress(function(keys)
    pressedKey = keys
    lastPress = now
    schedule(100, function()
        if now - lastPress > 20 then
            pressedKey = ""
        end
    end)
end)

local function interpreteCondition(n, v)

    if n == 1 then
        return true
    elseif n == 2 then
        return getMonsters() > v
    elseif n == 3 then
        return getMonsters() < v
    elseif n == 4 then
        return hppercent() < v
    elseif n == 5 then
        return hppercent() > v
    elseif n == 6 then
        return manapercent() < v
    elseif n == 7 then
        return manapercent() > v
    elseif n == 8 then
        return target() and target():getName():lower() == v:lower() or false
    elseif n == 9 then
        return pressedKey == v
    elseif n == 10 then
        return isParalyzed()
    elseif n == 11 then
        return isInPz()
    elseif n == 12 then
        return getPlayers() > v
    elseif n == 13 then
        return getPlayers() < v
    elseif n == 14 then
        return TargetBot.Danger() > v and TargetBot.isOn()
    elseif n == 15 then
        return isBlackListedPlayerInRange(v)
    end
    
end

local function finalCheck(first,relation,second)
    if relation == "-" then
        return first
    elseif relation == "and" then
        return first and second
    elseif relation == "or" then
        return first or second
    end
end

local function isEquipped(id)
    local t = {getNeck(), getHead(), getBody(), getRight(), getLeft(), getLeg(), getFeet(), getFinger(), getAmmo()}
    local ids = {id, getInactiveItemId(id), getActiveItemId(id)}

    for i, slot in pairs(t) do
        if slot and table.find(ids, slot:getId()) then
            return true
        end
    end
    return false
end

local function unequipItem(table)
    --[[
        head
        neck
        torso
        left
        right
        legs
        finger
        ammo slot
        boots
    ]]
    local slots = {getHead(), getNeck(), getBody(), getLeft(), getRight(), getLeg(), getFinger(), getAmmo(), getFeet()}

    if type(table) ~= "table" then return end
    for i, slot in pairs(table) do
        local physicalSlot = slots[i]

        if slot and physicalSlot then
            g_game.equipItemId(physicalSlot:getId())
            return true
        end
    end
    return false
end

EquipManager = macro(50, function()
    if not config.enabled then return end
    if #config.rules == 0 then return end

    for i, rule in ipairs(config.rules) do
        local widget = listPanel.list:getChildById(rule.name)
        if mainWindow:isVisible() then
            for i, child in ipairs(listPanel.list:getChildren()) do
                if child ~= widget then
                    child:setColor('white')
                end
            end
        end
        if rule.enabled then
            widget:setColor('green')
            local firstCondition = interpreteCondition(rule.mainCondition, rule.mainValue)
            local optionalCondition = nil
            if rule.relation ~= "-" then
                optionalCondition = interpreteCondition(rule.optionalCondition, rule.optValue)
            end

            if finalCheck(firstCondition, rule.relation, optionalCondition) then
                if unequipItem(rule.unequip) == true then
                    delay(200)
                    return
                end
                for i, item in ipairs(rule.items) do
                    if not isEquipped(item) then
                        if rule.visible then
                            if itemAmount(item) > 0 then
                                delay(200)
                                return g_game.equipItemId(item)
                            end
                        else
                            delay(200)
                            return g_game.equipItemId(item)
                        end
                    end
                end
                return
            end
        end
    end
    pressedKey = ""
end)