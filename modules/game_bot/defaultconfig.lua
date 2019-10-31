botDefaultConfig = {
  configs = {
    {name = "Example", script = [=[
--Example

--#main

Panels.Haste()
Panels.ManaShield()
Panels.Health()
Panels.HealthItem()
Panels.ManaItem()
Panels.ManaItem()
Panels.AntiParalyze()

local tab2 = addTab("Another Tab")
addButton("button1", "test button on 2nd tab", nil, tab2)

local tab3 = addTab("3th tab")
addLabel("label1", "Label on 3th tab", tab3)
Panels.Turning(tab3)

--#macros

local helloLabel = addLabel("helloLabel", "", tab2)

macro(1000, "example macro (time)", nil, function()
  helloLabel:setText("Time from start: " .. now)
end, tab2)
--#hotkeys

hotkey("f5", "example hotkey", function()
  info("Wow, you clicked f5 hotkey")
end)

singlehotkey("f6", "example hotkey2", function()
  info("Wow, you clicked f6 singlehotkey")
end)
--#callbacks

local positionLabel = addLabel("positionLabel", "")
onPlayerPositionChange(function()
  positionLabel:setText("Pos: " .. posx() .. "," .. posy() .. "," .. posz())
end)

listen(player:getName(), function(text)
  info("you said: " .. text)
end)
--#other

HTTP.getJSON("https://api.ipify.org/?format=json", function(data, err)
    if err then
        warn("Whoops! Error occured: " .. err)
        return
    end
    info("HTTP: My IP is: " .. tostring(data['ip']))
end)


]=]},
  {name = "UI & Healing", script = [=[
-- UI & healing
info("Tested on 10.99")

--#main
local healthPanel = setupUI([[
Panel
  id: healingPanel
  height: 150
  margin-top: 3
  
  Label
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text: Use item if
    text-align: center
  
  BotItem
    id: item1
    anchors.left: parent.left
    anchors.top: prev.bottom

  Label
    id: label1  
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: prev.top
    margin: 0 5 0 5
    text-align: center
    
  HorizontalScrollBar
    id: scroll1
    anchors.left: prev.left
    anchors.right: prev.right
    anchors.top: prev.bottom
    margin-top: 5
    minimum: 0
    maximum: 100
    step: 1
    
  BotItem
    id: item2
    anchors.left: parent.left
    anchors.top: item1.bottom
    margin-top: 3

  Label
    id: label2
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: prev.top
    margin: 0 5 0 5
    text-align: center
    
  HorizontalScrollBar
    id: scroll2
    anchors.left: label2.left
    anchors.right: label2.horizontalCenter
    anchors.top: label2.bottom
    margin-top: 5
    minimum: 0
    maximum: 100
    step: 1
    
  HorizontalScrollBar
    id: scroll3
    anchors.left: label2.horizontalCenter
    anchors.right: label2.right
    anchors.top: label2.bottom
    margin-top: 5
    minimum: 0
    maximum: 100
    step: 1
    
  Label
    anchors.top: item2.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 3
    text: Drag item to change it
    text-align: center
    
  HorizontalSeparator
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 3
]])

healthPanel.item1:setItemId(storage.healItem1 or 266)
healthPanel.item1.onItemChange = function(widget, item)
  storage.healItem1 = item:getId()
  widget:setItemId(storage.healItem1)
end

healthPanel.item2:setItemId(storage.healItem2 or 268)
healthPanel.item2.onItemChange = function(widget, item)
  storage.healItem2 = item:getId()
  widget:setItemId(storage.healItem2)
end

healthPanel.scroll1.onValueChange = function(scroll, value)
  storage.healPercent1 = value
  healthPanel.label1:setText("0% <= hp <= " .. storage.healPercent1 .. "%")
end
healthPanel.scroll1:setValue(storage.healPercent1 or 50)

healthPanel.scroll2.onValueChange = function(scroll, value)
  storage.healPercent2 = value
  healthPanel.label2:setText("" .. storage.healPercent2 .. "% <= mana <= " .. storage.healPercent3 .. "%")
end
healthPanel.scroll3.onValueChange = function(scroll, value)
  storage.healPercent3 = value
  healthPanel.label2:setText("" .. storage.healPercent2 .. "% <= mana <= " .. storage.healPercent3 .. "%")
end
healthPanel.scroll2:setValue(storage.healPercent2 or 40)
healthPanel.scroll3:setValue(storage.healPercent3 or 60)

macro(25, function()
  if not storage.healItem1 then
    return
  end
  if healthPanel.scroll1:getValue() >= hppercent() then
    useWith(storage.healItem1, player)      
    delay(500)
  end
end)
macro(25, function()
  if not storage.healItem2 then
    return
  end
  if storage.healPercent2 <= manapercent() and manapercent() <= storage.healPercent3 then
    useWith(storage.healItem2, player)      
    delay(500)
  end  
end)

--#macros

--#hotkeys

--#callbacks

--#other
]=]},
  {}, {}, {}
  },
  enabled = false,
  selectedConfig = 1
}