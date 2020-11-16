setDefaultTab("Tools")
local panelName = "killSteal"
local ui = setupUI([[
Panel
  height: 50
  
  BotItem
    id: item
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 2
    
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: item.right
    anchors.bottom: item.verticalCenter
    text-align: center
    !text: tr('Kill Steal')
    margin-left: 2
    width: 90
  
  Button
    id: Target
    anchors.top: item.top
    anchors.left: title.right
    anchors.right: parent.right
    anchors.bottom: item.verticalCenter
    margin-left: 3
    text-align: center
    !text: tr('Switch')
  
  BotLabel
    id: help
    anchors.top: item.verticalCenter
    anchors.left: item.right
    anchors.right: parent.right
    anchors.bottom: item.bottom
    text-align: center
    margin-left: 2

  HorizontalScrollBar
    id: HP
    anchors.top: item.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 3
    minimum: 1
    maximum: 100
    step: 1
    
]], parent)
ui:setId(panelName)

if not storage[panelName] then
  storage[panelName] = {
      id = 3155,
      title = enabled,
      enabled = false,
      setting = true,
      hp = 20
  }
end

ui.title:setOn(storage[panelName].enabled)
ui.title.onClick = function(widget)
  storage[panelName].enabled = not storage[panelName].enabled
  widget:setOn(storage[panelName].enabled)
end
local updateHpText = function()
    local desc
    if storage[panelName].setting then
        desc = "Target"
    else
        desc = "Enemy"
    end
    ui.help:setText("If " .. desc .. " HP<" .. storage[panelName].hp .. "%")
end
updateHpText()
ui.HP.onValueChange = function(scroll, value)
  storage[panelName].hp = value
  updateHpText()
end
ui.item:setItemId(storage[panelName].id)
ui.item.onItemChange = function(widget)
  storage[panelName].id = widget:getItemId()
end
ui.HP:setValue(storage[panelName].hp)

ui.Target.onClick = function(widget)
    storage[panelName].setting = not storage[panelName].setting
    updateHpText()
end

macro(200, function()
 if not storage[panelName].enabled then return end

 if storage[panelName].setting then
    if target() and target():canShoot() and target():getHealthPercent() <= storage[panelName].hp then
        useWith(storage[panelName].id, target())
    end
 else
    for _, spec in pairs(getSpectators()) do
        if spec:isPlayer() and spec:canShoot() and isEnemy(spec:getName()) and spec:getHealthPercent() <= storage[panelName].hp then
            useWith(storage[panelName].id, spec)
        end
    end
 end
end)

addSeparator()