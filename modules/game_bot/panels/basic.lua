local context = G.botContext
local Panels = context.Panels

Panels.Haste = function(parent)
  context.macro(500, "Auto Haste", nil, function()
    if not context.hasHaste() and context.storage.autoHasteText:len() > 0 then
      if context.saySpell(context.storage.autoHasteText, 2500) then
        context.delay(5000)
      end
    end
  end, parent)
  context.addTextEdit("autoHasteText", context.storage.autoHasteText or "utani hur", function(widget, text)    
    context.storage.autoHasteText = text
  end, parent)
end

Panels.ManaShield = function(parent)
  context.macro(500, "Auto ManaShield", nil, function()
    if not context.hasManaShield() then
      if context.saySpell("utamo vita", 1000) then
        context.delay(5000)
      end
    end
  end, parent)
end

Panels.AntiParalyze = function(parent)
  context.macro(500, "Anti Paralyze", nil, function()
    if context.isParalyzed() and context.storage.autoAntiParalyzeText:len() > 0 then
      if context.saySpell(context.storage.autoAntiParalyzeText, 2500) then
        context.delay(5000)
      end
    end
  end, parent)
  context.addTextEdit("autoHasteText", context.storage.autoAntiParalyzeText or "utani hur", function(widget, text)    
    context.storage.autoAntiParalyzeText = text
  end, parent)
end


Panels.Health = function(parent)
  if not parent then
    parent = context.panel
  end
  
  local panelName = "autoHealthPanel"
  local panelId = 1
  while parent:getChildById(panelName .. panelId) do
    panelId = panelId + 1
  end
  panelName = panelName .. panelId
  
  local ui = context.setupUI([[
Panel
  height: 70
  margin-top: 2
  
  Label
    id: info
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text: Auto Healing
    text-align: center
    
  Label
    id: label
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin: 0 5 0 5
    text-align: center
    
  HorizontalScrollBar
    id: scroll1
    anchors.left: label.left
    anchors.right: label.horizontalCenter
    anchors.top: label.bottom
    margin-top: 5
    margin-right: 2
    minimum: 0
    maximum: 100
    step: 1
    
  HorizontalScrollBar
    id: scroll2
    anchors.left: label.horizontalCenter
    anchors.right: label.right
    anchors.top: label.bottom
    margin-top: 5
    margin-left: 2
    minimum: 0
    maximum: 100
    step: 1      
    
  BotTextEdit
    id: text
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: scroll1.bottom
]], parent)
  ui:setId(panelName)
  
  ui.text.onTextChange = function(widget, text)
    context.storage["healthText" .. panelId] = text    
  end
  ui.text:setText(context.storage["healthText" .. panelId] or "exura")
  
  local updateText = function()
    ui.label:setText("" .. (context.storage["healthPercentMin" .. panelId] or "") .. "% <= hp <= " .. (context.storage["healthPercentMax" .. panelId] or "") .. "%")  
  end
  
  ui.scroll1.onValueChange = function(scroll, value)
    context.storage["healthPercentMin" .. panelId] = value
    updateText()
  end
  ui.scroll2.onValueChange = function(scroll, value)
    context.storage["healthPercentMax" .. panelId] = value
    updateText()
  end

  ui.scroll1:setValue(context.storage["healthPercentMin" .. panelId] or 20)
  ui.scroll2:setValue(context.storage["healthPercentMax" .. panelId] or 60)
  
  context.macro(25, function()
    if context.storage["healthText" .. panelId]:len() > 0 and context.storage["healthPercentMin" .. panelId] <= context.hppercent() and context.hppercent() <= context.storage["healthPercentMax" .. panelId] then
      if context.saySpell(context.storage["healthText" .. panelId], 500) then
        context.delay(200)
      end
    end
  end)
end

Panels.HealthItem = function(parent)
  if not parent then
    parent = context.panel
  end
  
  local panelName = "autoHealthItemPanel"
  local panelId = 1
  while parent:getChildById(panelName .. panelId) do
    panelId = panelId + 1
  end
  panelName = panelName .. panelId
  
  local ui = context.setupUI([[
Panel
  height: 55
  margin-top: 2
  
  Label
    id: info
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text: Auto Healing
    text-align: center
    
  BotItem
    id: item
    anchors.left: parent.left
    anchors.top: prev.bottom
    margin-top: 3

  Label
    id: label
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: prev.top
    margin: 0 5 0 5
    text-align: center
    
  HorizontalScrollBar
    id: scroll1
    anchors.left: label.left
    anchors.right: label.horizontalCenter
    anchors.top: label.bottom
    margin-top: 5
    margin-right: 2
    minimum: 0
    maximum: 100
    step: 1
    
  HorizontalScrollBar
    id: scroll2
    anchors.left: label.horizontalCenter
    anchors.right: label.right
    anchors.top: label.bottom
    margin-top: 5
    margin-left: 2
    minimum: 0
    maximum: 100
    step: 1      
]], parent)
  ui:setId(panelName)
  
  ui.item.onItemChange = function(widget)
    context.storage["healthItem" .. panelId] = widget:getItemId()
  end
  ui.item:setItemId(context.storage["healthItem" .. panelId] or 266)
  
  local updateText = function()
    ui.label:setText("" .. (context.storage["healthItemPercentMin" .. panelId] or "") .. "% <= hp <= " .. (context.storage["healthItemPercentMax" .. panelId] or "") .. "%")  
  end
  
  ui.scroll1.onValueChange = function(scroll, value)
    context.storage["healthItemPercentMin" .. panelId] = value
    updateText()
  end
  ui.scroll2.onValueChange = function(scroll, value)
    context.storage["healthItemPercentMax" .. panelId] = value
    updateText()
  end

  ui.scroll1:setValue(context.storage["healthItemPercentMin" .. panelId] or 20)
  ui.scroll2:setValue(context.storage["healthItemPercentMax" .. panelId] or 60)
  
  context.macro(25, function()
    if context.storage["healthItem" .. panelId] > 0 and context.storage["healthItemPercentMin" .. panelId] <= context.hppercent() and context.hppercent() <= context.storage["healthItemPercentMax" .. panelId] then
      context.useWith(context.storage["healthItem" .. panelId], context.player)
      context.delay(300)
    end
  end)
end

Panels.Mana = function(parent)
  if not parent then
    parent = context.panel
  end
  
  local panelName = "autoManaItemPanel"
  local panelId = 1
  while parent:getChildById(panelName .. panelId) do
    panelId = panelId + 1
  end
  panelName = panelName .. panelId
  
  local ui = context.setupUI([[
Panel
  height: 55
  margin-top: 2
  
  Label
    id: info
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text: Auto Mana
    text-align: center
    
  BotItem
    id: item
    anchors.left: parent.left
    anchors.top: prev.bottom
    margin-top: 3

  Label
    id: label
    anchors.left: prev.right
    anchors.right: parent.right
    anchors.top: prev.top
    margin: 0 5 0 5
    text-align: center
    
  HorizontalScrollBar
    id: scroll1
    anchors.left: label.left
    anchors.right: label.horizontalCenter
    anchors.top: label.bottom
    margin-top: 5
    margin-right: 2
    minimum: 0
    maximum: 100
    step: 1
    
  HorizontalScrollBar
    id: scroll2
    anchors.left: label.horizontalCenter
    anchors.right: label.right
    anchors.top: label.bottom
    margin-top: 5
    margin-left: 2
    minimum: 0
    maximum: 100
    step: 1      
]], parent)
  ui:setId(panelName)
  
  ui.item.onItemChange = function(widget)
    context.storage["manaItem" .. panelId] = widget:getItemId()
  end
  ui.item:setItemId(context.storage["manaItem" .. panelId] or 268)
  
  local updateText = function()
    ui.label:setText("" .. (context.storage["manaItemPercentMin" .. panelId] or "") .. "% <= mana <= " .. (context.storage["manaItemPercentMax" .. panelId] or "") .. "%")  
  end
  
  ui.scroll1.onValueChange = function(scroll, value)
    context.storage["manaItemPercentMin" .. panelId] = value
    updateText()
  end
  ui.scroll2.onValueChange = function(scroll, value)
    context.storage["manaItemPercentMax" .. panelId] = value
    updateText()
  end

  ui.scroll1:setValue(context.storage["manaItemPercentMin" .. panelId] or 20)
  ui.scroll2:setValue(context.storage["manaItemPercentMax" .. panelId] or 60)
  
  context.macro(25, function()
    if context.storage["manaItem" .. panelId] > 0 and context.storage["manaItemPercentMin" .. panelId] <= context.manapercent() and context.manapercent() <= context.storage["manaItemPercentMax" .. panelId] then
      context.useWith(context.storage["manaItem" .. panelId], context.player)
      context.delay(300)
    end
  end)
end
Panels.ManaItem = Panels.Mana

Panels.Turning = function(parent)
  context.macro(1000, "Turning / AntiIdle", nil, function()
    context.turn(math.random(1, 4))
  end, parent)
end
Panels.AntiIdle = Panels.Turning

