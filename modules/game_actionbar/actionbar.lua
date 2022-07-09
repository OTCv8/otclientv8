local actionBars = {}
local settings = {}
local settingsFile = ""
local cachedSettings = nil
local window = nil
local mouseGrabberWidget = nil

local TYPE = {
  BLANK = 0,
  TEXT = 1,
  SPELL = 2,
  ITEM = 3
}

local ACTION = {
  BLANK = 0,
  EQUIP = 1,
  USE = 2,
  USE_SELF = 3,
  USE_TARGET = 4,
  USE_CROSS = 5
}

-- servers may have different id's, change if not working properly (only for protocols 910+)
local function translateVocation(id) 
  if id == 1 or id == 11 then
    return 8 -- ek
  elseif id == 2 or id == 12 then
    return 7 -- rp
  elseif id == 3 or id == 13 then
    return 5 -- ms
  elseif id == 4 or id == 14 then
    return 6 -- ed
  end
end

local function isSpell(text) -- returns bool or table (spelldata, param text)
  text = text:lower():trim()

  for spellName, spellData in pairs(SpellInfo['Default']) do
    local words = spellData.words
    local param = spellData.parameter
    local data = spellData
    data.spellName = spellName

    if not param then
      if words == text then
        return {data=data}
      end
    else
      if text:find(words) then
        text = text:gsub(words, ""):trim()
        text = text:gsub('"', "")
        text = text:gsub("'", "")
        return {data=data, param=text}
      end
    end
  end

  return false
end

function init()
  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onSpellGroupCooldown = onSpellGroupCooldown,
    onSpellCooldown = onSpellCooldown
  })

  if g_game.isOnline() then
    online()
  end

  -- taken from game_hotkeys
  mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)
  mouseGrabberWidget.onMouseRelease = onDropActionButton
end

function terminate()
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
    onSpellGroupCooldown = onSpellGroupCooldown,
    onSpellCooldown = onSpellCooldown
  })
end

function createActionBars()
  local bottomPanel = modules.game_interface.getBottomActionPanel()
  local leftPanel = modules.game_interface.getLeftActionPanel()
  local rightPanel = modules.game_interface.getRightActionPanel()

  -- 1-3: bottom
  -- 4-6: left
  -- 7-9: right
  for i=1,9 do
    local parent
    local index
    local layout

    if i <= 3 then
      parent = bottomPanel
      index = i
      layout = 'actionbar'
    elseif i <= 6 then
      parent = leftPanel
      index = i - 3
      layout = 'sideactionbar'
    else
      parent = rightPanel
      index = i - 6
      layout = 'sideactionbar'
    end

    actionBars[i] = g_ui.loadUI(layout, parent)
    actionBars[i]:setId("actionbar."..i)
    actionBars[i].n = i
    parent:moveChildToIndex(actionBars[i], index)
  end
end

function offline()
  -- save settings to json
  save()

  -- destroy windows
  destroyAssignWindows()
  mouseGrabberWidget:destroy()

  -- remove binds
  for index, actionbar in ipairs(actionBars) do
    if actionbar.tabBar then
      for i, actionButton in ipairs(actionbar.tabBar:getChildren()) do
        local callback = actionButton.callback
        local hotkey = actionButton.hotkey and actionButton.hotkey:len() > 0 and actionButton.hotkey or false

        if callback and hotkey then
          local gameRootPanel = modules.game_interface.getRootPanel()
          g_keyboard.unbindKeyPress(hotkey, callback, gameRootPanel)
        end
      end
    end
  end

  -- destroy actionbars
  for i, panel in ipairs(actionBars) do
    panel:destroy()
  end
end

function online()
  settingsFile = modules.client_profiles.getSettingsFilePath("actionbar_v2.json")
  -- load settings
  load()

  -- create actionbars
  createActionBars()

  -- show & setup actionbars
  show()

  destroyAssignWindows()
end

function show()
  for i=1,#actionBars do
    local actionbar = actionBars[i]
    local enabled = g_settings.getBoolean("actionbar"..i, false)

    actionbar:setOn(enabled)
    setupActionBar(i)
  end
end

function refresh()
  -- first save
  save()

  -- recheck file
  settingsFile = modules.client_profiles.getSettingsFilePath("actionbar_v2.json")

  -- load settings
  load()

  -- setup actionbars
  show()

  destroyAssignWindows()
end

function translateHotkeyDesc(text)
  -- formatting similar to cip Tibia 12
  if not text then 
    return ""
  end

  local values = {
    {"Shift", "S"},
    {"Ctrl", "C"},
    {"+", ""},
    {"PageUp", "PgUp"},
    {"PageDown", "PgDown"},
    {"Enter", "Return"},
    {"Insert", "Ins"},
    {"Delete", "Del"},
    {"Escape", "Esc"}
  }

  for i, v in pairs(values) do
    text = text:gsub(v[1], v[2])
  end

  if text:len() > 6 then
    text = text:sub(text:len()-3,text:len())
    text = "..."..text
  end

  return text
end

function destroyAssignWindows()
  local windows = {
    'assignItemWindow',
    'assignSpellWindow',
    'assignTextWindow',
    'assignHotkeyWindow'
  }

  local rootWidget = g_ui.getRootWidget()
  for i, id in ipairs(windows) do
    local widget = rootWidget[id]

    if widget then
      widget:destroy()
    end
  end
end

function changeLockState(widget)
  local actionbar = widget:getParent():getParent()

  widget:setOn(not widget:isOn())
  widget.image:setOn(widget:isOn())
  actionbar.locked = not widget:isOn()

  settings[actionbar:getId()] = not widget:isOn() or nil
end

function moveActionButtons(widget)
  local dir = widget:getId()
  local actionBar = widget:getParent():getParent()
  local scroll = actionBar.actionScroll
  local buttons = {actionBar.prevPanel.prev, actionBar.prevPanel.first, actionBar.nextPanel.next, actionBar.nextPanel.last}

  if dir == "next" then
    scroll:increment(37)
  elseif dir == "last" then
    scroll:setValue(scroll:getMaximum())
  elseif dir == "prev" then
    scroll:decrement(37)
  else
    scroll:setValue(scroll:getMinimum())
  end

  local prevEnabled = scroll:getValue() > 0
  local nextEnabled = scroll:getValue() < scroll:getMaximum()
  
  buttons[1]:setOn(prevEnabled)
  buttons[2]:setOn(prevEnabled)
  buttons[3]:setOn(nextEnabled)
  buttons[4]:setOn(nextEnabled)
  buttons[1].image:setOn(prevEnabled)
  buttons[2].image:setOn(prevEnabled)
  buttons[3].image:setOn(nextEnabled)
  buttons[4].image:setOn(nextEnabled)
end

function onDropActionButton(self, mousePosition, mouseButton)
  if not g_ui.isMouseGrabbed() then return end

  local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
  if clickedWidget and clickedWidget:getParent() and clickedWidget:getParent():getStyleName():find('ActionButton') then
    if cachedSettings then
      clickedWidget = clickedWidget:getParent()
      if clickedWidget ~= cachedSettings.widget then
        local clickedHotkey = clickedWidget.hotkey
        local cachedHotkey = cachedSettings.widget.hotkey

        settings[cachedSettings.id] = settings[clickedWidget:getId()]
        settings[clickedWidget:getId()] = cachedSettings.data
        
        local clickedTill = clickedWidget.cooldownTill or 0
        local clickedStart = clickedWidget.cooldownStart or 0
        local cachedTill = cachedSettings.widget.cooldownTill or 0
        local cachedStart = cachedSettings.widget.cooldownStart or 0

        cachedSettings.widget.cooldownTill = clickedTill
        cachedSettings.widget.cooldownStart = clickedStart
        clickedWidget.cooldownTill = cachedTill
        clickedWidget.cooldownStart = cachedStart

        -- hotkeys remain unchanged
        settings[cachedSettings.id] = settings[cachedSettings.id] or {}
        settings[cachedSettings.id].hotkey = cachedHotkey
        settings[clickedWidget:getId()] = settings[clickedWidget:getId()] or {}
        settings[clickedWidget:getId()].hotkey = clickedHotkey

        updateCooldown(clickedWidget)
        updateCooldown(cachedSettings.widget)
        setupButton(cachedSettings.widget)
        setupButton(clickedWidget)
      end
    end
  end

  cachedSettings.widget.item:setBorderColor('#00000000')
  cachedSettings = nil
  g_mouse.popCursor('target')
  self:ungrabMouse()
end

function setupActionBar(n)
  local actionbar = actionBars[n]
  local visible = actionbar:isVisible()
  locked = settings[actionbar:getId()]
  actionbar.tabBar.onMouseWheel = nil -- disable scroll wheel

  actionbar.locked = locked
  actionbar.nextPanel.lock:setOn(not locked)
  actionbar.nextPanel.lock.image:setOn(not locked)

  if not visible then
    return actionbar.tabBar:destroyChildren() -- will hopefully lower stress
  else
    actionbar.tabBar:destroyChildren()
    for i=1,50 do
      local layout = n < 4 and 'ActionButton' or 'SideActionButton'
      local widget = g_ui.createWidget(layout, actionbar.tabBar)
      widget:setId(actionbar.n.."."..i)

      setupButton(widget)
    end
  end
end

function setupButton(widget)
  local id = widget:getId()
  local config = settings[id]
  local actionbar = widget:getParent():getParent()

  -- disable count
  widget.item:setShowCount(false)

  -- remove callback to avoid recurrency
  widget.item.onItemChange = nil

  -- clear settings
  widget.type = TYPE.BLANK
  widget.text:setText("")
  widget.parameterText:setText("")
  if widget.item:getItemId() ~= 0 then
    widget.item:setItemId(0)
  end
  widget.item:setOn(false)
  widget.autoSay = nil
  widget.action = ACTION.BLANK
  widget.spellData = nil
  widget.item:setItemVisible(true)
  widget.text:setImageSource('')
  widget.hotkey = config and config.hotkey or ""
  widget.callback = nil

  -- add new settings
  if config and config.type then
    widget.item:setOn(true)
    widget.type = config.type
    widget.text:setText(config.sayText or "")
    if widget.item:getItemId() ~= (config.itemId and config.itemId > 100 and config.itemId or 0) then
      widget.item:setItem(Item.create(config.itemId, 50))
    end
    widget.sayText = config.sayText
    widget.autoSay = config.autoSay
    widget.action = config.action
    widget.spellData = config.spellData
    if config.type ~= 0 and config.type ~= 3 then
      widget.item:setItemVisible(false)
    end
  end

  -- callback
  setupAction(widget)

  --hotkey
  widget.hotkeyLabel:setText(translateHotkeyDesc(widget.hotkey))
  
  if widget.spellData then
    --image
    widget.text:setImageSource(widget.spellData.source)
    widget.text:setImageClip(widget.spellData.clip)

    --param
    local param = widget.spellData.param
    if param and param:len() > 6 then
      param = param:sub(1,5) .. "..."
    end
    widget.parameterText:setText(param or "")
  else
    widget.text:setImageSource('')
  end

  widget.item.onDragEnter = function(self)
    if g_ui.isMouseGrabbed() or actionbar.locked then return end
    mouseGrabberWidget:grabMouse()
    g_mouse.pushCursor('target')

    self:setBorderColor('#FFFFFF')
    cachedSettings = {id=widget:getId(), data=settings[widget:getId()], widget=widget}
  end

  -- popupmenu & execute action
  widget.onMouseRelease = function(widget, mousePos, mouseButton)
    if mouseButton == MouseRightButton then 

      local menu = g_ui.createWidget('PopupMenu')
      menu:setGameMenu(true)
      menu:addOption(widget.spellId and tr('Edit Spell') or tr('Assign Spell'), function() assignSpell(widget) end)
      menu:addOption(widget.item:getItemId() > 100 and tr('Edit Object') or tr('Assign Object'), function() assignItem(widget) end)
      menu:addOption(widget.text:getText():len() > 0 and tr('Edit Text') or tr('Assign Text'), function() assignText(widget) end)
      menu:addOption(widget.hotkey and tr('Edit Hotkey') or tr('Assign Hotkey'), function() assignHotkey(widget) end)

      if widget.type > 0 then
        menu:addSeparator()
        menu:addOption(tr('Clear Action'), function() resetSlot(widget) end)
      end
      menu:display(mousePos)
    elseif mouseButton == MouseLeftButton and widget.callback then 
      widget.callback()
    end
  end

  widget.item.onItemChange = function(widget)
    widget:setOn(true)
    assignItem(widget:getParent())
  end

  -- tooltip
  local itemAction
  if widget.type == TYPE.ITEM then
    if widget.action == ACTION.EQUIP then
      itemAction = "Equip/Unequip this object"
    elseif widget.action == ACTION.USE then
      itemAction = "Use this object"
    elseif widget.action == ACTION.USE_SELF then
      itemAction = "Use this object on Yourself"
    elseif widget.action == ACTION.USE_TARGET then
      itemAction = "Use this object on Attack Target"
    elseif widget.action == ACTION.USE_CROSS then
      itemAction = "Use this object with Crosshair"
    end
  end

  local actionDesc
  local spellData = widget.spellData
  if widget.type == TYPE.BLANK then
    actionDesc = "None"
  elseif widget.type == TYPE.TEXT then
    actionDesc = 'Say: "'..widget.text:getText()..'"\n'
    actionDesc = actionDesc.. "Auto sent:  " .. (widget.autoSay and "Yes" or "No")
  elseif widget.type == TYPE.SPELL then
    local paramText 
    if spellData.param and spellData.param:len() > 0 then
      paramText = ' "'.. spellData.param ..'"' 
    else 
      paramText = ""
    end
    actionDesc = "Cast " .. spellData.name .."\n"
    actionDesc = actionDesc.. "Formula:  ".. spellData.words .. paramText.."\n"
    actionDesc = actionDesc.. "Cooldown:  "..spellData.cd.."s\n"
    actionDesc = actionDesc.. "Mana:  "..spellData.mana
  elseif widget.type == TYPE.ITEM then
    actionDesc = itemAction
  end

  local hotkeyDesc = widget.hotkey and widget.hotkey:len() > 0 and widget.hotkey or "None"
  local tooltip = "Action Button "..id
  tooltip = tooltip.."\n\n\tAction:  ".. actionDesc
  tooltip = tooltip.."\nHotkeys:  ".. hotkeyDesc

  widget.item:setTooltip(tooltip)
end

function resetSlot(widget)
  local hotkey = settings[widget:getId()] and settings[widget:getId()].hotkey or nil
  if hotkey and hotkey:len() > 0 and widget.callback then
    local gameRootPanel = modules.game_interface.getRootPanel()
    g_keyboard.unbindKeyPress(widget.hotkey, widget.callback, gameRootPanel)
  end
  
  if hotkey then
    settings[widget:getId()] = {hotkey=hotkey}
  else
    settings[widget:getId()] = nil
  end

  setupButton(widget)
end

function assignItem(widget)
  destroyAssignWindows()
  local radio = UIRadioGroup.create()
  local item = widget.item:getItem()
  local id = widget.item:getItemId()

  -- check if item wasn't cleared
  if id == 0 and widget.item:isOn() then
    return resetSlot(widget) 
  end

  -- create window
  window = g_ui.loadUI('object', g_ui.getRootWidget())
  window:show()
  window:raise()
  window:focus()

  -- basics
  window:setText("Assign Object to Action Button "..widget:getId())
  window:setId("assignItemWindow")

  -- select item
  window.select.onClick = function()
    modules.game_itemselector.show(widget.item)
  end

  -- checks
  window.item:setShowCount(false)
  window.item.onItemChange = function(widget)
    local item = window.item:getItem()

    if item then
      for i, child in ipairs(window.checks:getChildren()) do
        -- add to radio grouo
        radio:addWidget(child)

        -- enabled
        if item:getId() < 100 then
          child:setEnabled(false)
        elseif i < 4 then
          local check = item:isMultiUse()
          child:setEnabled(check)
          if check then
            radio:selectWidget(child)
          end
        elseif g_game.getClientVersion() >= 910 then
          if i == 4 then
  --           local check = item:getClothSlot() > 0
            local check = true -- unfortunately two handed weapons returns cloth 0, so we have to disable this check
            child:setEnabled(check)
            if check then
              radio:selectWidget(child)
            end
          else
            child:setEnabled(true)
            radio:selectWidget(child)
          end
        else
          child:setVisible(false)
        end
      end
    end

    -- validation
    window.buttonOk:setEnabled(item and item:getId() > 100)
    window.buttonApply:setEnabled(item and item:getId() > 100)
  end

  window.item:setItemId(id)

  -- select current action, if exists
  local actionType = widget.action or 0
  if actionType > ACTION.BLANK then
    local id
    if actionType == ACTION.USE_SELF then
      id = "useSelf"
    elseif actionType == ACTION.USE_TARGET then
      id = "useTarget"
    elseif actionType == ACTION.USE_CROSS then
      id = "useCross"
    elseif actionType == ACTION.EQUIP then
      id = "equip"
    elseif actionType == ACTION.USE then
      id = "use"
    end

    for i, child in ipairs(radio.widgets) do
      local childId = child:getId()
      if childId == id then
        radio:selectWidget(child)
        break
      end
    end
  end

  -- functions
  local okFunc = function(destroy)
    local hotkey = settings[widget:getId()] and settings[widget:getId()].hotkey
    if hotkey and hotkey:len() > 0 and widget.callback then
      local gameRootPanel = modules.game_interface.getRootPanel()
      g_keyboard.unbindKeyPress(widget.hotkey, widget.callback, gameRootPanel)
    end

    settings[widget:getId()] = {hotkey=hotkey}
    settings[widget:getId()].itemId = window.item:getItemId()
    settings[widget:getId()].type = TYPE.ITEM

    local selected = radio:getSelectedWidget():getId()
    if selected == "useSelf" then
      settings[widget:getId()].action = ACTION.USE_SELF
    elseif selected == "useTarget" then
      settings[widget:getId()].action = ACTION.USE_TARGET
    elseif selected == "useCross" then
      settings[widget:getId()].action = ACTION.USE_CROSS
    elseif selected == "equip" then
      settings[widget:getId()].action = ACTION.EQUIP
    else
      settings[widget:getId()].action = ACTION.USE
    end

    if destroy then
      window:destroy()
      radio:destroy()
    end
    setupButton(widget)
  end

  local cancelFunc = function()
    setupButton(widget)
    window:destroy()
    radio:destroy()
  end

  -- callbacks
  window.buttonOk.onClick = function() okFunc(true) end
  window.onEnter = function() okFunc(true) end
  window.buttonApply.onClick = function() okFunc(false) end
  window.buttonClose.onClick = cancelFunc
  window.onEscape = cancelFunc

  local actionbar = widget:getParent():getParent()
  if actionbar.locked then
    cancelFunc()
  end
end

function assignText(widget)
  destroyAssignWindows()

  -- create window
  window = g_ui.loadUI('text', g_ui.getRootWidget())
  window:show()
  window:raise()
  window:focus()

  window.text.onTextChange = function(self, text)
    window.buttonOk:setEnabled(text:len() > 0)
    window.buttonApply:setEnabled(text:len() > 0)
  end

  -- copy settings from current widget
  window.text:setText(widget.text:getText())
  if widget.type > 0 then
    window.checkPanel.tick:setChecked(widget.autoSay)
  end

  -- functions
  local okFunc = function(destroy) 
    local autoSay = window.checkPanel.tick:isChecked()
    local text = window.text:getText()

    local hotkey = settings[widget:getId()] and settings[widget:getId()].hotkey
    if hotkey and hotkey:len() > 0 and widget.callback then
      local gameRootPanel = modules.game_interface.getRootPanel()
      g_keyboard.unbindKeyPress(hotkey, widget.callback, gameRootPanel)
    end

    settings[widget:getId()] = {hotkey=hotkey}

    local spell = isSpell(text)
    if spell then -- entered text is spell
      local paramText = spell.param
      local spellData = spell.data
      local newGroup = {}
      for groupId, duration in pairs(spellData.group) do
        table.insert(newGroup, groupId)
      end
      spellData.group = newGroup

  
      settings[widget:getId()].type = TYPE.SPELL
      settings[widget:getId()].spellData = {
        words = spellData.words,
        cd = spellData.exhaustion/1000,
        mana = spellData.mana,
        source = SpelllistSettings['Default'].iconFile,
        clip = Spells.getImageClip(SpellIcons[spellData.icon][1], 'Default'),
        name = spellData.spellName,
        param = paramText,
        group = spellData.group,
        id = spellData.id
      }
    else -- is just text
      settings[widget:getId()].sayText = text
      settings[widget:getId()].type = TYPE.TEXT
      settings[widget:getId()].autoSay = autoSay
    end
  
    if destroy then
      window:destroy()
    end
    setupButton(widget)
  end
  local cancelFunc = function()
    window:destroy()
    setupButton(widget)
  end

  -- buttons
  window.buttonOk.onClick = function() okFunc(true) end
  window.buttonApply.onClick = function() okFunc(false) end
  window.buttonClose.onClick = cancelFunc
  window.onEscape = cancelFunc
  window.onEnter = function() okFunc(true) end

  local actionbar = widget:getParent():getParent()
  if actionbar.locked then
    cancelFunc()
  end
end

function assignSpell(widget)
  destroyAssignWindows()
  local radio = UIRadioGroup.create()

  -- create window
  window = g_ui.loadUI('spell', g_ui.getRootWidget())
  window:show()
  window:raise()
  window:focus()

  window:setText("Assign Spell to Action Button "..widget:getId())

  -- old tibia does not send vocation
  if g_game.getClientVersion() < 910 then
    window.checkPanel:setVisible(false)
  end

  local spells = modules.gamelib.SpellInfo['Default']
  for spellName, spellData in pairs(spells) do
    local widget = g_ui.createWidget('SpellPreview', window.spellList)
    -- radio
    radio:addWidget(widget)
    local newGroup = {}
    for groupId, duration in pairs(spellData.group) do
      table.insert(newGroup, groupId)
    end
    spellData.group = newGroup
    
    widget:setId(spellData.id)
    widget:setText(spellName.."\n"..spellData.words)
    widget.voc = spellData.vocations
    widget.param = spellData.parameter
    widget.source = SpelllistSettings['Default'].iconFile
    widget.clip = Spells.getImageClip(SpellIcons[spellData.icon][1], 'Default')
    widget.image:setImageSource(widget.source)
    widget.image:setImageClip(widget.clip)

    widget.spellData = {
      words = spellData.words,
      cd = spellData.exhaustion/1000,
      mana = spellData.mana,
      source = widget.source,
      clip = widget.clip,
      name = spellName,
      param = spellData.parameter,
      group = spellData.group,
      id = spellData.id
    }
  end

  -- sort alphabetically
  local widgets = window.spellList:getChildren()
  table.sort(widgets, function(a, b) return a.spellData.name < b.spellData.name end)
  for i, widget in ipairs(widgets) do
    window.spellList:moveChildToIndex(widget, i)
  end

  local function filterByVocation(a, filter)
     -- disable callback
    window.spellList.onChildFocusChange = nil

    local widgets = window.spellList:getChildren()
    local vocation = translateVocation(g_game.getLocalPlayer():getVocation())

    -- visible
    local fistVisible = nil
    for i, widget in ipairs(widgets) do
      local viable = not filter or table.find(widget.voc, vocation) and true or false
      widget:setVisible(viable)
      if viable and not fistVisible then
        fistVisible = widget
        radio:selectWidget(fistVisible)
      end
    end

    -- select current one if exist
    local currentSpell = widget.spellData and widget.spellData.id or 0
    if currentSpell > 0 then
      for i, child in ipairs(radio.widgets) do
        local childId = child.spellData.id

        if childId == currentSpell then
          child:setVisible(true)
          window.spellList:ensureChildVisible(child)
          radio:selectWidget(child)
          break
        end
      end
    end
  end

  -- callback
  radio.onSelectionChange = function(widget, selected)
    if selected then
      local name = selected:getText()
      local source = selected.source
      local clip = selected.clip
      local param = selected.param

      -- preview
      window.preview:setText(name)
      window.preview.image:setImageSource(source)
      window.preview.image:setImageClip(clip)

      -- param
      window.paramLabel:setOn(param)
      window.paramText:setEnabled(param)
      window.spellList:ensureChildVisible(widget)
    end
  end

  window.checkPanel.tick.onCheckChange = filterByVocation
  filterByVocation(nil, true)

  local okFunc = function(destroy) 
    local selected = radio:getSelectedWidget()
    local paramWidgetText = window.paramText:getText()
    if not selected then return end

    selected.spellData.param = paramWidgetText

    local hotkey = settings[widget:getId()] and settings[widget:getId()].hotkey   
    if hotkey and hotkey:len() > 0 and widget.callback then
      local gameRootPanel = modules.game_interface.getRootPanel()
      g_keyboard.unbindKeyPress(widget.hotkey, widget.callback, gameRootPanel)
    end

    settings[widget:getId()] = {hotkey=hotkey}
    settings[widget:getId()].spellData = selected.spellData
    settings[widget:getId()].type = TYPE.SPELL
 
    if destroy then
      window:destroy()
    end
    setupButton(widget)
  end
  local cancelFunc = function() 
    window:destroy()
    setupButton(widget)
  end

  window.buttonOk.onClick = function() okFunc(true) end
  window.buttonApply.onClick = function() okFunc(false) end
  window.buttonClose.onClick = cancelFunc
  window.onEscape = cancelFunc
  window.onEnter = function() okFunc(true) end

  local actionbar = widget:getParent():getParent()
  if actionbar.locked then
    cancelFunc()
  end
end

function assignHotkey(widget)
  destroyAssignWindows()

  -- create window
  window = g_ui.loadUI('hotkey', g_ui.getRootWidget())
  window:show()
  window:raise()
  window:focus()

  local barN = widget:getParent():getParent().n
  local barDesc
  if barN < 4 then
    barDesc = "Bottom"
  elseif barN < 7 then
    barDesc = "Left"
  else
    barDesc = "Right"
  end

  -- things
  barDesc = barDesc.." Action Bar: Action Button "..widget:getId()
  window:setText('Edit Hotkey for "'..barDesc)
  window.desc:setText(window.desc:getText()..barDesc..'"')
  window.display:setText(widget.hotkey or "")
  
  -- hotkey
  window:grabKeyboard()
  window.onKeyDown = function(window, keyCode, keyboardModifiers)
    local keyCombo = determineKeyComboDesc(keyCode, keyboardModifiers)
    window.display:setText(keyCombo)
    return true
  end

  local okFunc = function() 
    local hotkey = window.display:getText()

    if settings[widget:getId()].hotkey and settings[widget:getId()].hotkey:len() > 0 and widget.callback then
      local gameRootPanel = modules.game_interface.getRootPanel()
      g_keyboard.unbindKeyPress(widget.hotkey, widget.callback, gameRootPanel)
    end
    settings[widget:getId()] = settings[widget:getId()] or {}
    settings[widget:getId()].hotkey = hotkey
  
    window:destroy()
    setupButton(widget)
  end
  local clearFunc = function() 
    window.display:setText('')
    local hotkey = window.display:getText()

    if settings[widget:getId()].hotkey and settings[widget:getId()].hotkey:len() > 0 and widget.callback then
      local gameRootPanel = modules.game_interface.getRootPanel()
      g_keyboard.unbindKeyPress(widget.hotkey, widget.callback, gameRootPanel)
    end
    settings[widget:getId()] = settings[widget:getId()] or {}
    settings[widget:getId()].hotkey = hotkey
  
    window:destroy()
    setupButton(widget)
  end
  local closeFunc = function() 
    window:destroy()
    setupButton(widget)
  end

  window.buttonOk.onClick = okFunc
  window.buttonClear.onClick = clearFunc
  window.buttonClose.onClick = closeFunc

  local actionbar = widget:getParent():getParent()
  if actionbar.locked then
    cancelFunc()
  end
end

function setupAction(widget)
  if widget.type == TYPE.BLANK then 
    return
  end
  if widget.type == TYPE.TEXT then
    widget.callback = function()
      if modules.game_interface.isChatVisible() then
        if widget.autoSay then
          modules.game_console.sendMessage(widget.sayText)
        else
          modules.game_console.setTextEditText(widget.sayText)
        end
      elseif widget.autoSay then
        g_game.talk(widget.sayText)
      end
    end
  elseif widget.type == TYPE.SPELL then
    widget.callback = function()
      if g_app.isMobile() then -- turn to direction of targer
        local target = g_game.getAttackingCreature()
        if target then
          local pos = g_game.getLocalPlayer():getPosition()
          local tpos = target:getPosition()
          if pos and tpos then
            local offx = tpos.x - pos.x
            local offy = tpos.y - pos.y
            if offy < 0 and offx <= 0 and math.abs(offx) < math.abs(offy) then
              g_game.turn(Directions.North)
            elseif offy > 0 and offx >= 0 and math.abs(offx) < math.abs(offy) then
              g_game.turn(Directions.South)
            elseif offx < 0 and offy <= 0 and math.abs(offx) > math.abs(offy) then
              g_game.turn(Directions.West)
            elseif offx > 0 and offy >= 0 and math.abs(offx) > math.abs(offy) then
              g_game.turn(Directions.East)
            end
          end
        end
      end
      local paramText 
      if widget.spellData.param and widget.spellData.param:len() > 0 then
        paramText = ' "'.. widget.spellData.param ..'"' 
      else 
        paramText = ""
      end
      g_game.talk(widget.spellData.words..paramText)
    end
  elseif widget.type == TYPE.ITEM then
    widget.callback = function()
      if widget.action == ACTION.BLANK then
        return
      elseif widget.action == ACTION.EQUIP then
        if g_game.getClientVersion() >= 910 then
          local item = Item.create(widget.item:getItemId())
          return g_game.equipItem(item)
        end
      elseif widget.action == ACTION.USE then
        if g_game.getClientVersion() < 780 then
          local item = g_game.findPlayerItem(widget.item:getItemId(), widget.item:getItemSubType() or -1)
          if item then
            g_game.use(item)
          end
        else
          g_game.useInventoryItem(widget.item:getItemId())
        end
      elseif widget.action == ACTION.USE_SELF then
        if g_game.getClientVersion() < 780 then
          local item = g_game.findPlayerItem(widget.item:getItemId(), widget.item:getItemSubType() or -1)
          if item then
            g_game.useWith(item, g_game.getLocalPlayer())
          end
        else
          g_game.useInventoryItemWith(widget.item:getItemId(), g_game.getLocalPlayer(), widget.item:getItemSubType() or -1)
        end
      elseif widget.action == ACTION.USE_TARGET then
        local attackingCreature = g_game.getAttackingCreature()
        if not attackingCreature then
          local item = Item.create(widget.item:getItemId())
          if g_game.getClientVersion() < 780 then
            local tmpItem = g_game.findPlayerItem(widget.item:getItemId(), widget.item:getItemSubType() or -1)
            if not tmpItem then return end
            item = tmpItem
          end
          modules.game_interface.startUseWith(item, widget.item:getItemSubType() or - 1)
          return
        end
        if not attackingCreature:getTile() then return end
        if g_game.getClientVersion() < 780 then
          local item = g_game.findPlayerItem(widget.item:getItemId(), widget.item:getItemSubType() or -1)
          if item then
            g_game.useWith(item, attackingCreature, widget.item:getItemSubType() or -1)
          end
        else
          g_game.useInventoryItemWith(widget.item:getItemId(), attackingCreature, widget.item:getItemSubType() or -1)
        end
      elseif widget.action == ACTION.USE_CROSS then
        local item = Item.create(widget.item:getItemId())
        if g_game.getClientVersion() < 780 then
          local tmpItem = g_game.findPlayerItem(widget.item:getItemId(), widget.item:getItemSubType() or -1)
          if not tmpItem then return true end
          item = tmpItem
        end
        modules.game_interface.startUseWith(item, widget.item:getItemSubType() or - 1)
      end
    end
  end

  if widget.hotkey and widget.hotkey:len() > 0 and widget.callback then
    local gameRootPanel = modules.game_interface.getRootPanel()
    g_keyboard.bindKeyPress(widget.hotkey, widget.callback, gameRootPanel)
  end
end

function onSpellCooldown(iconId, duration)
  for index, actionbar in ipairs(actionBars) do
    for i, child in ipairs(actionbar.tabBar:getChildren()) do
      if child.type == 2 and child.spellData.id == iconId then
        startCooldown(child, duration)
      end
    end
  end
end

function onSpellGroupCooldown(groupId, duration)
  for index, actionbar in ipairs(actionBars) do
    for i, child in ipairs(actionbar.tabBar:getChildren()) do
      if child.type == 2 and child.spellData.group then
        for i, group in ipairs(child.spellData.group) do
          if groupId == group then
            startCooldown(child, duration)
          end
        end
      end
    end
  end
end

function startCooldown(action, duration)
  if type(action.cooldownTill) == 'number' and action.cooldownTill > g_clock.millis() + duration then
    return -- already has cooldown with greater duration
  end
  action.cooldownStart = g_clock.millis()
  action.cooldownTill = g_clock.millis() + duration
  updateCooldown(action)
end

function updateCooldown(action)
  if not action or not action.cooldownTill then return end
  local timeleft = action.cooldownTill - g_clock.millis()
  if timeleft <= 50 then
    action.cooldown:setPercent(100)
    action.cooldownEvent = nil
    action.cooldown:setText("")
    return
  end
  local duration = action.cooldownTill - action.cooldownStart
  local formattedText
  if timeleft > 60000 then
    formattedText = math.floor(timeleft / 60000) .. "m"
  else
    formattedText = timeleft/1000
    formattedText = math.floor(formattedText * 10) / 10
    formattedText = math.floor(formattedText) .. "." .. math.floor(formattedText * 10) % 10
  end

  local retry
  if timeleft > 60000 then
    retry = math.min(math.floor(timeleft * 0.1), 60 * 1000) -- max 1min
    retry = math.max(retry, 100) -- min 100
  elseif timeleft > 1000 then
    retry = 100
  else
    retry = 30
  end
  action.cooldown:setText(formattedText) 
  action.cooldown:setPercent(100 - math.floor(100 * timeleft / duration))
  action.cooldownEvent = scheduleEvent(function() updateCooldown(action) end, retry)
end

function save()
  local status, result = pcall(function() return json.encode(settings, 2) end)
  if not status then
      return g_logger.error(
                 "Error while saving top bar settings. Data won't be saved. Details: " ..
                     result)
  end

  if result:len() > 100 * 1024 * 1024 then
      return g_logger.error(
                 "Something went wrong, file is above 100MB, won't be saved")
  end

  g_resources.writeFileContents(settingsFile, result)
end

function load()
  if g_resources.fileExists(settingsFile) then
      local status, result = pcall(function()
          return json.decode(g_resources.readFileContents(settingsFile))
      end)
      if not status then
          return g_logger.error(
                     "Error while reading top bar settings file. To fix this problem you can delete storage.json. Details: " ..
                         result)
      end
      settings = result
  else
      settings = {}
  end
end