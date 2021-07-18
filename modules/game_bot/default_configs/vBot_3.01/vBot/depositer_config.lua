setDefaultTab("Cave")
local panelName = "specialDeposit"
local depositerPanel

UI.Button("Depositer Settings", function()  
    depositerPanel:show()
    depositerPanel:raise()
    depositerPanel:focus()
end)

if not storage[panelName] then
    storage[panelName] = {
        items = {}
    }
end

local config = storage[panelName]


local rootWidget = g_ui.getRootWidget()
if rootWidget then
    depositerPanel = UI.createWindow('DepositerPanel', rootWidget)
    depositerPanel:hide()

    -- basic one
    depositerPanel.CloseButton.onClick = function()
        depositerPanel:hide()
    end

    if config.items and #config.items > 0 then
        for _, value in ipairs(config.items) do
          local label = g_ui.createWidget("ItemLabel", depositerPanel.DepositerList)
          label.remove.onClick = function(widget)
            table.remove(config.items, table.find(value))
            label:destroy()
          end
          label:setText("Stash (".. value.id .. ") to depot: (" .. value.index .. ")")
        end
    end

    depositerPanel.Add.onClick = function(widget)
        local itemId = depositerPanel.ID:getItemId()
        local index = tonumber(depositerPanel.Index:getText())
        if index and itemId > 100 and not config.items[itemId] then
            local value = {id=itemId,index=index}
          table.insert(config.items, value)
          local label = g_ui.createWidget("ItemLabel", depositerPanel.DepositerList)
          label.remove.onClick = function(widget)
            table.remove(config.items, table.find(value))
            label:destroy()
          end
          label:setText("Stash (".. itemId .. ") to depot: (" .. index..")")
          depositerPanel.ID:setItemId(0)
          depositerPanel.Index:setText(0)
        end
    end
end

function getStashingIndex(id)
    for _, v in pairs(config.items) do
        if v.id == id then
            return v.index - 1
        end
    end
end