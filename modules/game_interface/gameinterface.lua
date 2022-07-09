gameRootPanel = nil
gameMapPanel = nil
gameRightPanels = nil
gameLeftPanels = nil
gameBottomPanel = nil
gameBottomActionPanel = nil
gameLeftActionPanel = nil
gameRightActionPanel = nil
gameLeftActions = nil
gameTopBar = nil
logoutButton = nil
mouseGrabberWidget = nil
countWindow = nil
logoutWindow = nil
exitWindow = nil
bottomSplitter = nil
limitedZoom = false
hookedMenuOptions = {}
lastDirTime = g_clock.millis()

function init()
  g_ui.importStyle('styles/countwindow')

  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
    onLoginAdvice = onLoginAdvice,
  }, true)

  -- Call load AFTER game window has been created and 
  -- resized to a stable state, otherwise the saved 
  -- settings can get overridden by false onGeometryChange
  -- events
  connect(g_app, {
    onRun = load,
    onExit = save
  })
  
  gameRootPanel = g_ui.displayUI('gameinterface')
  gameRootPanel:hide()
  gameRootPanel:lower()
  gameRootPanel.onGeometryChange = updateStretchShrink

  mouseGrabberWidget = gameRootPanel:getChildById('mouseGrabber')
  mouseGrabberWidget.onMouseRelease = onMouseGrabberRelease
  mouseGrabberWidget.onTouchRelease = mouseGrabberWidget.onMouseRelease

  bottomSplitter = gameRootPanel:getChildById('bottomSplitter')
  gameMapPanel = gameRootPanel:getChildById('gameMapPanel')
  gameRightPanels = gameRootPanel:getChildById('gameRightPanels')
  gameLeftPanels = gameRootPanel:getChildById('gameLeftPanels')
  gameBottomPanel = gameRootPanel:getChildById('gameBottomPanel')
  gameBottomActionPanel = gameRootPanel:getChildById('gameBottomActionPanel')
  gameRightActionPanel = gameRootPanel:getChildById('gameRightActionPanel')
  gameLeftActionPanel = gameRootPanel:getChildById('gameLeftActionPanel')  
  gameTopBar = gameRootPanel:getChildById('gameTopBar')
  gameLeftActions = gameRootPanel:getChildById('gameLeftActions')
  connect(gameLeftPanel, { onVisibilityChange = onLeftPanelVisibilityChange })

  logoutButton = modules.client_topmenu.addLeftButton('logoutButton', tr('Exit'),
    '/images/topbuttons/logout', tryLogout, true)


  gameRightPanels:addChild(g_ui.createWidget('GameSidePanel'))
 
  setupLeftActions()
  refreshViewMode()

  bindKeys()
  
  connect(gameMapPanel, { onGeometryChange = updateSize, onVisibleDimensionChange = updateSize })
  connect(g_game, { onMapChangeAwareRange = updateSize })

  if g_game.isOnline() then
    show()
  end
end

function bindKeys()
  gameRootPanel:setAutoRepeatDelay(10)

  local lastAction = 0
  g_keyboard.bindKeyPress('Escape', function() 
    if lastAction + 50 > g_clock.millis() then return end 
    lastAction = g_clock.millis()
    g_game.cancelAttackAndFollow() 
  end, gameRootPanel)
  g_keyboard.bindKeyPress('Ctrl+=', function() if g_game.getFeature(GameNoDebug) then return end gameMapPanel:zoomIn() end, gameRootPanel)
  g_keyboard.bindKeyPress('Ctrl+-', function() if g_game.getFeature(GameNoDebug) then return end gameMapPanel:zoomOut() end, gameRootPanel)
  g_keyboard.bindKeyDown('Ctrl+Q', function() tryLogout(false) end, gameRootPanel)
  g_keyboard.bindKeyDown('Ctrl+L', function() tryLogout(false) end, gameRootPanel)
  g_keyboard.bindKeyDown('Ctrl+W', function() g_map.cleanTexts() modules.game_textmessage.clearMessages() end, gameRootPanel)
end

function terminate()
  hide()

  hookedMenuOptions = {}
  markThing = nil
  

  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd,
    onLoginAdvice = onLoginAdvice
  })

  disconnect(gameMapPanel, { onGeometryChange = updateSize })
  connect(gameMapPanel, { onGeometryChange = updateSize, onVisibleDimensionChange = updateSize })

  logoutButton:destroy()
  gameRootPanel:destroy()
end

function onGameStart()
  refreshViewMode()
  show()
  
  -- open tibia has delay in auto walking
  if not g_game.isOfficialTibia() then
    g_game.enableFeature(GameForceFirstAutoWalkStep)
  else
    g_game.disableFeature(GameForceFirstAutoWalkStep)
  end
end

function onGameEnd()
  hide()
  modules.client_topmenu.getTopMenu():setImageColor('white')
end

function show()
  connect(g_app, { onClose = tryExit })
  modules.client_background.hide()
  gameRootPanel:show()
  gameRootPanel:focus()
  gameMapPanel:followCreature(g_game.getLocalPlayer())
    
  updateStretchShrink()
  logoutButton:setTooltip(tr('Logout'))
  
  addEvent(function()
    if not limitedZoom or g_game.isGM() then
      gameMapPanel:setMaxZoomOut(513)
      gameMapPanel:setLimitVisibleRange(false)
    else
      gameMapPanel:setMaxZoomOut(15)
      gameMapPanel:setLimitVisibleRange(true)
    end
  end)
end

function hide()
  disconnect(g_app, { onClose = tryExit })
  logoutButton:setTooltip(tr('Exit'))

  if logoutWindow then
    logoutWindow:destroy()
    logoutWindow = nil
  end
  if exitWindow then
    exitWindow:destroy()
    exitWindow = nil
  end
  if countWindow then
    countWindow:destroy()
    countWindow = nil
  end
  gameRootPanel:hide()
  gameMapPanel:setShader("")
  modules.client_background.show()
end

function save()
  local settings = {}
  settings.splitterMarginBottom = bottomSplitter:getMarginBottom()
  g_settings.setNode('game_interface', settings)
end

function load()
  local settings = g_settings.getNode('game_interface')
  if settings then
    if settings.splitterMarginBottom then
      bottomSplitter:setMarginBottom(settings.splitterMarginBottom)
    end
  end
end

function onLoginAdvice(message)
  displayInfoBox(tr("For Your Information"), message)
end

function forceExit()
  g_game.cancelLogin()
  scheduleEvent(exit, 10)
  return true
end

function tryExit()
  if exitWindow then
    return true
  end

  local exitFunc = function() scheduleEvent(exit, 10) end
  local logoutFunc = function() g_game.safeLogout() exitWindow:destroy() exitWindow = nil end
  local cancelFunc = function() exitWindow:destroy() exitWindow = nil end

  exitWindow = displayGeneralBox(tr('Exit'), tr("If you shut down the program, your character might stay in the game.\nClick on 'Logout' to ensure that you character leaves the game properly.\nClick on 'Exit' if you want to exit the program without logging out your character."),
  { { text=tr('Force Exit'), callback=exitFunc },
    { text=tr('Logout'), callback=logoutFunc },
    { text=tr('Cancel'), callback=cancelFunc },
    anchor=AnchorHorizontalCenter }, logoutFunc, cancelFunc)

  return true
end

function tryLogout(prompt)
  if type(prompt) ~= "boolean" then
    prompt = true
  end
  if not g_game.isOnline() then
    exit()
    return
  end

  if logoutWindow then
    return
  end

  local msg, yesCallback
  if not g_game.isConnectionOk() then
    msg = 'Your connection is failing, if you logout now your character will be still online, do you want to force logout?'

    yesCallback = function()
      g_game.forceLogout()
      if logoutWindow then
        logoutWindow:destroy()
        logoutWindow=nil
      end
    end
  else
    msg = 'Are you sure you want to logout?'

    yesCallback = function()
      g_game.safeLogout()
      if logoutWindow then
        logoutWindow:destroy()
        logoutWindow=nil
      end
    end
  end

  local noCallback = function()
    logoutWindow:destroy()
    logoutWindow=nil
  end

  if prompt then
    logoutWindow = displayGeneralBox(tr('Logout'), tr(msg), {
      { text=tr('Yes'), callback=yesCallback },
      { text=tr('No'), callback=noCallback },
      anchor=AnchorHorizontalCenter}, yesCallback, noCallback)
  else
     yesCallback()
  end
end

function updateStretchShrink()
  if modules.client_options.getOption('dontStretchShrink') and not alternativeView then
    gameMapPanel:setVisibleDimension({ width = 15, height = 11 })

    -- Set gameMapPanel size to height = 11 * 32 + 2
    bottomSplitter:setMarginBottom(bottomSplitter:getMarginBottom() + (gameMapPanel:getHeight() - 32 * 11) - 10)
  end
end

function onMouseGrabberRelease(self, mousePosition, mouseButton)
  if mouseButton == MouseTouch then return end
  if selectedThing == nil then return false end
  if mouseButton == MouseLeftButton then
    local clickedWidget = gameRootPanel:recursiveGetChildByPos(mousePosition, false)
    if clickedWidget then
      if selectedType == 'use' then
        onUseWith(clickedWidget, mousePosition)
      elseif selectedType == 'trade' then
        onTradeWith(clickedWidget, mousePosition)
      end
    end
  end

  selectedThing = nil
  g_mouse.popCursor('target')
  self:ungrabMouse()
  gameMapPanel:blockNextMouseRelease(true)
  return true
end

function onUseWith(clickedWidget, mousePosition)
  if clickedWidget:getClassName() == 'UIGameMap' then
    local tile = clickedWidget:getTile(mousePosition)
    if tile then      
      if selectedThing:isFluidContainer() or selectedThing:isMultiUse() then      
        if selectedThing:getId() == 3180 or selectedThing:getId() == 3156 then
          -- special version for mwall
          g_game.useWith(selectedThing, tile:getTopUseThing(), selectedSubtype)      
        else
          g_game.useWith(selectedThing, tile:getTopMultiUseThingEx(clickedWidget:getPositionOffset(mousePosition)), selectedSubtype)
        end
      else
        g_game.useWith(selectedThing, tile:getTopUseThing(), selectedSubtype)
      end
    end
  elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
    g_game.useWith(selectedThing, clickedWidget:getItem(), selectedSubtype)
  elseif clickedWidget:getClassName() == 'UICreatureButton' then
    local creature = clickedWidget:getCreature()
    if creature then
      g_game.useWith(selectedThing, creature, selectedSubtype)
    end
  end
end

function onTradeWith(clickedWidget, mousePosition)
  if clickedWidget:getClassName() == 'UIGameMap' then
    local tile = clickedWidget:getTile(mousePosition)
    if tile then
      g_game.requestTrade(selectedThing, tile:getTopCreatureEx(clickedWidget:getPositionOffset(mousePosition)))
    end
  elseif clickedWidget:getClassName() == 'UICreatureButton' then
    local creature = clickedWidget:getCreature()
    if creature then
      g_game.requestTrade(selectedThing, creature)
    end
  end
end

function startUseWith(thing, subType)
  gameMapPanel:blockNextMouseRelease()
  if not thing then return end
  if g_ui.isMouseGrabbed() then
    if selectedThing then
      selectedThing = thing
      selectedType = 'use'
    end
    return
  end
  selectedType = 'use'
  selectedThing = thing
  selectedSubtype = subType or 0
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
end

function startTradeWith(thing)
  if not thing then return end
  if g_ui.isMouseGrabbed() then
    if selectedThing then
      selectedThing = thing
      selectedType = 'trade'
    end
    return
  end
  selectedType = 'trade'
  selectedThing = thing
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
end

function isMenuHookCategoryEmpty(category)
  if category then
    for _,opt in pairs(category) do
      if opt then return false end
    end
  end
  return true
end

function addMenuHook(category, name, callback, condition, shortcut)
  if not hookedMenuOptions[category] then
    hookedMenuOptions[category] = {}
  end
  hookedMenuOptions[category][name] = {
    callback = callback,
    condition = condition,
    shortcut = shortcut
  }
end

function removeMenuHook(category, name)
  if not name then
    hookedMenuOptions[category] = {}
  else
    hookedMenuOptions[category][name] = nil
  end
end

function createThingMenu(menuPosition, lookThing, useThing, creatureThing)
  if not g_game.isOnline() then return end

  local menu = g_ui.createWidget('PopupMenu')
  menu:setGameMenu(true)

  local classic = modules.client_options.getOption('classicControl')
  local shortcut = nil

  if not classic and not g_app.isMobile() then shortcut = '(Shift)' else shortcut = nil end
  if lookThing then
    menu:addOption(tr('Look'), function() g_game.look(lookThing) end, shortcut)
  end

  if not classic and not g_app.isMobile() then shortcut = '(Ctrl)' else shortcut = nil end
  if useThing then
    if useThing:isContainer() then
      if useThing:getParentContainer() then
        menu:addOption(tr('Open'), function() g_game.open(useThing, useThing:getParentContainer()) end, shortcut)
        menu:addOption(tr('Open in new window'), function() g_game.open(useThing) end)
      else
        menu:addOption(tr('Open'), function() g_game.open(useThing) end, shortcut)
      end
    else
      if useThing:isMultiUse() then
        menu:addOption(tr('Use with ...'), function() startUseWith(useThing) end, shortcut)
      else
        menu:addOption(tr('Use'), function() g_game.use(useThing) end, shortcut)
      end
    end

    if useThing:isRotateable() then
      menu:addOption(tr('Rotate'), function() g_game.rotate(useThing) end)
    end
    if useThing:isWrapable() then
      menu:addOption(tr('Wrap'), function() g_game.wrap(useThing) end)
    end
    if useThing:isUnwrapable() then
      menu:addOption(tr('Unwrap'), function() g_game.wrap(useThing) end)
    end

    if g_game.getFeature(GameBrowseField) and useThing:getPosition().x ~= 0xffff then
      menu:addOption(tr('Browse Field'), function() g_game.browseField(useThing:getPosition()) end)
    end
  end

  if lookThing and not lookThing:isCreature() and not lookThing:isNotMoveable() and lookThing:isPickupable() then
    menu:addSeparator()
    menu:addOption(tr('Trade with ...'), function() startTradeWith(lookThing) end)
  end

  if lookThing then
    local parentContainer = lookThing:getParentContainer()
    if parentContainer and parentContainer:hasParent() then
      menu:addOption(tr('Move up'), function() g_game.moveToParentContainer(lookThing, lookThing:getCount()) end)
    end
  end

  if creatureThing then
    local localPlayer = g_game.getLocalPlayer()
    menu:addSeparator()

    if creatureThing:isLocalPlayer() then
      menu:addOption(tr('Set Outfit'), function() g_game.requestOutfit() end)

      if g_game.getFeature(GamePlayerMounts) then
        if not localPlayer:isMounted() then
          menu:addOption(tr('Mount'), function() localPlayer:mount() end)
        else
          menu:addOption(tr('Dismount'), function() localPlayer:dismount() end)
        end
      end
      
      if g_game.getFeature(GamePrey) and modules.game_prey then
        menu:addOption(tr('Open Prey Dialog'), function() modules.game_prey.show() end)
      end
      
      if creatureThing:isPartyMember() then
        if creatureThing:isPartyLeader() then
          if creatureThing:isPartySharedExperienceActive() then
            menu:addOption(tr('Disable Shared Experience'), function() g_game.partyShareExperience(false) end)
          else
            menu:addOption(tr('Enable Shared Experience'), function() g_game.partyShareExperience(true) end)
          end
        end
        menu:addOption(tr('Leave Party'), function() g_game.partyLeave() end)
      end

    else
      local localPosition = localPlayer:getPosition()
      if not classic and not g_app.isMobile() then shortcut = '(Alt)' else shortcut = nil end
      if creatureThing:getPosition().z == localPosition.z then
        if g_game.getAttackingCreature() ~= creatureThing then
          menu:addOption(tr('Attack'), function() g_game.attack(creatureThing) end, shortcut)
        else
          menu:addOption(tr('Stop Attack'), function() g_game.cancelAttack() end, shortcut)
        end

        if g_game.getFollowingCreature() ~= creatureThing then
          menu:addOption(tr('Follow'), function() g_game.follow(creatureThing) end)
        else
          menu:addOption(tr('Stop Follow'), function() g_game.cancelFollow() end)
        end
      end

      if creatureThing:isPlayer() then
        menu:addSeparator()
        local creatureName = creatureThing:getName()
        menu:addOption(tr('Message to %s', creatureName), function() g_game.openPrivateChannel(creatureName) end)
        if modules.game_console.getOwnPrivateTab() then
          menu:addOption(tr('Invite to private chat'), function() g_game.inviteToOwnChannel(creatureName) end)
          menu:addOption(tr('Exclude from private chat'), function() g_game.excludeFromOwnChannel(creatureName) end) -- [TODO] must be removed after message's popup labels been implemented
        end
        if not localPlayer:hasVip(creatureName) then
          menu:addOption(tr('Add to VIP list'), function() g_game.addVip(creatureName) end)
        end

        if modules.game_console.isIgnored(creatureName) then
          menu:addOption(tr('Unignore') .. ' ' .. creatureName, function() modules.game_console.removeIgnoredPlayer(creatureName) end)
        else
          menu:addOption(tr('Ignore') .. ' ' .. creatureName, function() modules.game_console.addIgnoredPlayer(creatureName) end)
        end

        local localPlayerShield = localPlayer:getShield()
        local creatureShield = creatureThing:getShield()

        if localPlayerShield == ShieldNone or localPlayerShield == ShieldWhiteBlue then
          if creatureShield == ShieldWhiteYellow then
            menu:addOption(tr('Join %s\'s Party', creatureThing:getName()), function() g_game.partyJoin(creatureThing:getId()) end)
          else
            menu:addOption(tr('Invite to Party'), function() g_game.partyInvite(creatureThing:getId()) end)
          end
        elseif localPlayerShield == ShieldWhiteYellow then
          if creatureShield == ShieldWhiteBlue then
            menu:addOption(tr('Revoke %s\'s Invitation', creatureThing:getName()), function() g_game.partyRevokeInvitation(creatureThing:getId()) end)
          end
        elseif localPlayerShield == ShieldYellow or localPlayerShield == ShieldYellowSharedExp or localPlayerShield == ShieldYellowNoSharedExpBlink or localPlayerShield == ShieldYellowNoSharedExp then
          if creatureShield == ShieldWhiteBlue then
            menu:addOption(tr('Revoke %s\'s Invitation', creatureThing:getName()), function() g_game.partyRevokeInvitation(creatureThing:getId()) end)
          elseif creatureShield == ShieldBlue or creatureShield == ShieldBlueSharedExp or creatureShield == ShieldBlueNoSharedExpBlink or creatureShield == ShieldBlueNoSharedExp then
            menu:addOption(tr('Pass Leadership to %s', creatureThing:getName()), function() g_game.partyPassLeadership(creatureThing:getId()) end)
          else
            menu:addOption(tr('Invite to Party'), function() g_game.partyInvite(creatureThing:getId()) end)
          end
        end
      end
    end

    if modules.game_ruleviolation.hasWindowAccess() and creatureThing:isPlayer() then
      menu:addSeparator()
      menu:addOption(tr('Rule Violation'), function() modules.game_ruleviolation.show(creatureThing:getName()) end)
    end

    menu:addSeparator()
    menu:addOption(tr('Copy Name'), function() g_window.setClipboardText(creatureThing:getName()) end)
  end

  -- hooked menu options
  for _,category in pairs(hookedMenuOptions) do
    if not isMenuHookCategoryEmpty(category) then
      menu:addSeparator()
      for name,opt in pairs(category) do
        if opt and opt.condition(menuPosition, lookThing, useThing, creatureThing) then
          menu:addOption(name, function() opt.callback(menuPosition, 
            lookThing, useThing, creatureThing) end, opt.shortcut)
        end
      end
    end
  end

  if g_game.getFeature(GameBot) and useThing and useThing:isItem() then
    menu:addSeparator()
    local useThingId = useThing:getId()
    if useThing:getSubType() > 1 then
      menu:addOption("ID: " .. useThingId .. " SubType: " .. g_game..setClipboardText(useThingId), function() end)    
    else
      menu:addOption("ID: " .. useThingId, function() g_game.setClipboardText(useThingId) end)
    end
  end

  menu:display(menuPosition)
end

function processMouseAction(menuPosition, mouseButton, autoWalkPos, lookThing, useThing, creatureThing, attackCreature, marking)
  local keyboardModifiers = g_keyboard.getModifiers()

  if g_app.isMobile() then
    if mouseButton == MouseRightButton then
      createThingMenu(menuPosition, lookThing, useThing, creatureThing)
      return true      
    end
    if mouseButton ~= MouseLeftButton and mouseButton ~= MouseTouch2 and mouseButton ~= MouseTouch3 then
      return false
    end
    local action = getLeftAction()
    if action == "look" then
      if lookThing then
        resetLeftActions()
        g_game.look(lookThing)
        return true    
      end
      return true    
    elseif action == "use" then
      if useThing then
        resetLeftActions()
        if useThing:isContainer() then
          if useThing:getParentContainer() then
            g_game.open(useThing, useThing:getParentContainer())
          else
            g_game.open(useThing)
          end
          return true
        elseif useThing:isMultiUse() then
          startUseWith(useThing)
          return true
        else
          g_game.use(useThing)
          return true
        end
      end
      return true
    elseif action == "attack" then
      if attackCreature and attackCreature ~= player then
        resetLeftActions()
        g_game.attack(attackCreature)
        return true
      elseif creatureThing and creatureThing ~= player and creatureThing:getPosition().z == autoWalkPos.z then
        resetLeftActions()
        g_game.attack(creatureThing)
        return true
      end
      return true
    elseif action == "follow" then
      if attackCreature and attackCreature ~= player then
        resetLeftActions()
        g_game.follow(attackCreature)
        return true
      elseif creatureThing and creatureThing ~= player and creatureThing:getPosition().z == autoWalkPos.z then
        resetLeftActions()
        g_game.follow(creatureThing)
        return true
      end
      return true
    elseif not autoWalkPos and useThing then
      createThingMenu(menuPosition, lookThing, useThing, creatureThing)      
      return true
    end
  elseif not modules.client_options.getOption('classicControl') then
    if keyboardModifiers == KeyboardNoModifier and mouseButton == MouseRightButton then
      createThingMenu(menuPosition, lookThing, useThing, creatureThing)
      return true
    elseif lookThing and keyboardModifiers == KeyboardShiftModifier and (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
      g_game.look(lookThing)
      return true
    elseif useThing and keyboardModifiers == KeyboardCtrlModifier and (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
      if useThing:isContainer() then
        if useThing:getParentContainer() then
          g_game.open(useThing, useThing:getParentContainer())
        else
          g_game.open(useThing)
        end
        return true
      elseif useThing:isMultiUse() then
        startUseWith(useThing)
        return true
      else
        g_game.use(useThing)
        return true
      end
      return true
    elseif attackCreature and g_keyboard.isAltPressed() and (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
      g_game.attack(attackCreature)
      return true
    elseif creatureThing and creatureThing:getPosition().z == autoWalkPos.z and g_keyboard.isAltPressed() and (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
      g_game.attack(creatureThing)
      return true
    end
  else -- classic control
    if useThing and keyboardModifiers == KeyboardNoModifier and mouseButton == MouseRightButton and not g_mouse.isPressed(MouseLeftButton) then
      local player = g_game.getLocalPlayer()
      if attackCreature and attackCreature ~= player then
        g_game.attack(attackCreature)
        return true
      elseif creatureThing and creatureThing ~= player and creatureThing:getPosition().z == autoWalkPos.z then
        g_game.attack(creatureThing)
        return true
      elseif useThing:isContainer() then
        if useThing:getParentContainer() then
          g_game.open(useThing, useThing:getParentContainer())
          return true
        else
          g_game.open(useThing)
          return true
        end
      elseif useThing:isMultiUse() then
        startUseWith(useThing)
        return true
      else
        g_game.use(useThing)
        return true
      end
      return true
    elseif lookThing and keyboardModifiers == KeyboardShiftModifier and (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
      g_game.look(lookThing)
      return true
    elseif lookThing and ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton) or (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
      g_game.look(lookThing)
      return true
    elseif useThing and keyboardModifiers == KeyboardCtrlModifier and (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
      createThingMenu(menuPosition, lookThing, useThing, creatureThing)
      return true
    elseif attackCreature and g_keyboard.isAltPressed() and (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
      g_game.attack(attackCreature)
      return true
    elseif creatureThing and creatureThing:getPosition().z == autoWalkPos.z and g_keyboard.isAltPressed() and (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
      g_game.attack(creatureThing)
      return true
    end
  end

  local player = g_game.getLocalPlayer()
  player:stopAutoWalk()  

  if autoWalkPos and keyboardModifiers == KeyboardNoModifier and (mouseButton == MouseLeftButton or mouseButton == MouseTouch2 or mouseButton == MouseTouch3) then
    local autoWalkTile = g_map.getTile(autoWalkPos)
    if autoWalkTile and not autoWalkTile:isWalkable(true) then
      modules.game_textmessage.displayFailureMessage(tr('Sorry, not possible.'))
      return false
    end
    player:autoWalk(autoWalkPos)
    return true
  end

  return false
end

function moveStackableItem(item, toPos)
  if countWindow then
    return
  end
  if g_keyboard.isCtrlPressed() then
    g_game.move(item, toPos, item:getCount())
    return
  elseif g_keyboard.isShiftPressed() then
    g_game.move(item, toPos, 1)
    return
  end
  local count = item:getCount()

  countWindow = g_ui.createWidget('CountWindow', rootWidget)
  local itembox = countWindow:getChildById('item')
  local scrollbar = countWindow:getChildById('countScrollBar')
  itembox:setItemId(item:getId())
  itembox:setItemCount(count)
  scrollbar:setMaximum(count)
  scrollbar:setMinimum(1)
  scrollbar:setValue(count)

  local spinbox = countWindow:getChildById('spinBox')
  spinbox:setMaximum(count)
  spinbox:setMinimum(0)
  spinbox:setValue(0)
  spinbox:hideButtons()
  spinbox:focus()
  spinbox.firstEdit = true

  local spinBoxValueChange = function(self, value)
    spinbox.firstEdit = false
    scrollbar:setValue(value)
  end
  spinbox.onValueChange = spinBoxValueChange

  local check = function()
    if spinbox.firstEdit then
      spinbox:setValue(spinbox:getMaximum())
      spinbox.firstEdit = false
    end
  end
  local okButton = countWindow:getChildById('buttonOk')
  local moveFunc = function()
    g_game.move(item, toPos, itembox:getItemCount())
    okButton:getParent():destroy()
    countWindow = nil
  end
  local cancelButton = countWindow:getChildById('buttonCancel')
  local cancelFunc = function()
    cancelButton:getParent():destroy()
    countWindow = nil
  end

  
  g_keyboard.bindKeyPress("Up", function() check() spinbox:up() end, spinbox)
  g_keyboard.bindKeyPress("Down", function() check() spinbox:down() end, spinbox)
  g_keyboard.bindKeyPress("Right", function() check() spinbox:up() end, spinbox)
  g_keyboard.bindKeyPress("Left", function() check() spinbox:down() end, spinbox)
  g_keyboard.bindKeyPress("PageUp", function() check() spinbox:setValue(spinbox:getValue()+10) end, spinbox)
  g_keyboard.bindKeyPress("PageDown", function() check() spinbox:setValue(spinbox:getValue()-10) end, spinbox)
  g_keyboard.bindKeyPress("Enter", function() moveFunc() end, spinbox)

  scrollbar.onValueChange = function(self, value)
    itembox:setItemCount(value)
    spinbox.onValueChange = nil
    spinbox:setValue(value)
    spinbox.onValueChange = spinBoxValueChange
  end
  countWindow.onEnter = moveFunc
  countWindow.onEscape = cancelFunc

  okButton.onClick = moveFunc
  cancelButton.onClick = cancelFunc
end

function getRootPanel()
  return gameRootPanel
end

function getMapPanel()
  return gameMapPanel
end

function getRightPanel()
  if gameRightPanels:getChildCount() == 0 then
    addRightPanel()
  end
  return gameRightPanels:getChildByIndex(-1)
end

function getLeftPanel()
  if gameLeftPanels:getChildCount() >= 1 then
    return gameLeftPanels:getChildByIndex(-1)
  end
  return getRightPanel()
end

function getContainerPanel()
  local containerPanel = g_settings.getNumber("containerPanel")
  if containerPanel >= 5 then
    containerPanel = containerPanel - 4
    return gameRightPanels:getChildByIndex(math.min(containerPanel, gameRightPanels:getChildCount()))
  end
  if gameLeftPanels:getChildCount() == 0 then
    return getRightPanel()
  end
  return gameLeftPanels:getChildByIndex(math.min(containerPanel, gameLeftPanels:getChildCount()))
end

local function addRightPanel()
  if gameRightPanels:getChildCount() >= 4 then
    return
  end
  local panel = g_ui.createWidget('GameSidePanel')
  panel:setId("rightPanel" .. (gameRightPanels:getChildCount() + 1))
  gameRightPanels:insertChild(1, panel)
end

local function addLeftPanel()
  if gameLeftPanels:getChildCount() >= 4 then
    return
  end
  local panel = g_ui.createWidget('GameSidePanel')
  panel:setId("leftPanel" .. (gameLeftPanels:getChildCount() + 1))
  gameLeftPanels:addChild(panel)
end

local function removeRightPanel()
  if gameRightPanels:getChildCount() <= 1 then
    return
  end
  local panel = gameRightPanels:getChildByIndex(1)
  panel:moveTo(gameRightPanels:getChildByIndex(2))
  gameRightPanels:removeChild(panel)
end

local function removeLeftPanel()
  if gameLeftPanels:getChildCount() == 0 then
    return
  end
  local panel = gameLeftPanels:getChildByIndex(-1)
  if gameLeftPanels:getChildCount() >= 2 then
    panel:moveTo(gameLeftPanels:getChildByIndex(-2))
  else
    panel:moveTo(gameRightPanels:getChildByIndex(1))
  end
  gameLeftPanels:removeChild(panel)
end

function getBottomPanel()
  return gameBottomPanel
end

function getBottomActionPanel()
  return gameBottomActionPanel
end

function getLeftActionPanel()
  return gameLeftActionPanel
end

function getRightActionPanel()
  return gameRightActionPanel
end

function getTopBar()
  return gameTopBar
end

function refreshViewMode()  
  local classic = g_settings.getBoolean("classicView") and not g_app.isMobile()
  local rightPanels = g_settings.getNumber("rightPanels") - gameRightPanels:getChildCount()
  local leftPanels = g_settings.getNumber("leftPanels") - 1 - gameLeftPanels:getChildCount()

  while rightPanels ~= 0 do
    if rightPanels > 0 then
      addRightPanel()
      rightPanels = rightPanels - 1
    else
      removeRightPanel()
      rightPanels = rightPanels + 1
    end
  end
  while leftPanels ~= 0 do
    if leftPanels > 0 then
      addLeftPanel()
      leftPanels = leftPanels - 1
    else
      removeLeftPanel()
      leftPanels = leftPanels + 1
    end
  end
  
  if not g_game.isOnline() then
    return
  end

  local minimumWidth = (g_settings.getNumber("rightPanels") + g_settings.getNumber("leftPanels") - 1) * 200 + 200
  minimumWidth = math.max(minimumWidth, g_resources.getLayout() == "mobile" and 640 or 800)
  g_window.setMinimumSize({ width = minimumWidth, height = (g_resources.getLayout() == "mobile" and 360 or 600)})
  if g_window.getWidth() < minimumWidth then
    local oldPos = g_window.getPosition()
    local size = { width = minimumWidth, height = g_window.getHeight() }
    g_window.resize(size)
    g_window.move(oldPos)
  end

  for i=1,gameRightPanels:getChildCount()+gameLeftPanels:getChildCount() do
    local panel
    if i > gameRightPanels:getChildCount() then
      panel = gameLeftPanels:getChildByIndex(i - gameRightPanels:getChildCount())
    else
      panel = gameRightPanels:getChildByIndex(i)
    end
    if classic then
      panel:setImageColor('white')
    else
      panel:setImageColor('alpha')
    end
  end
  
  if classic then
    gameRightPanels:setMarginTop(0)
    gameLeftPanels:setMarginTop(0)
    gameMapPanel:setMarginLeft(0)
    gameMapPanel:setMarginRight(0)
    gameMapPanel:setMarginTop(0)
  end

  gameMapPanel:setVisibleDimension({ width = 15, height = 11 })
  
  if classic then  
    g_game.changeMapAwareRange(19, 15)
    gameMapPanel:addAnchor(AnchorLeft, 'gameLeftActionPanel', AnchorRight)
    gameMapPanel:addAnchor(AnchorRight, 'gameRightActionPanel', AnchorLeft)
    gameMapPanel:addAnchor(AnchorBottom, 'gameBottomActionPanel', AnchorTop)
    gameMapPanel:addAnchor(AnchorTop, 'gameTopBar', AnchorBottom)
    gameMapPanel:setKeepAspectRatio(true)
    gameMapPanel:setLimitVisibleRange(false)
    gameMapPanel:setZoom(11)
    gameMapPanel:setOn(false) -- frame

    modules.client_topmenu.getTopMenu():setImageColor('white')
  
    if modules.game_console then
      modules.game_console.switchMode(false)
    end
  else
    g_game.changeMapAwareRange(31, 21)
    gameMapPanel:fill('parent')
    gameMapPanel:setKeepAspectRatio(false)
    gameMapPanel:setLimitVisibleRange(false)
    gameMapPanel:setOn(true)
    if g_app.isMobile() then
      gameMapPanel:setZoom(11)
    else
      gameMapPanel:setZoom(15)
    end
               
    modules.client_topmenu.getTopMenu():setImageColor('#ffffff66')  
    if g_app.isMobile() then
      gameMapPanel:setMarginTop(-32)   
    end
    if modules.game_console then
      modules.game_console.switchMode(true)
    end
  end
--  if modules.game_actionbar then
--    modules.game_actionbar.switchMode(not classic)    
--  end
  
  if g_settings.getBoolean("cacheMap") then
    g_game.enableFeature(GameBiggerMapCache)
  end
  
  updateSize()
end

function limitZoom()
  limitedZoom = true
end

function updateSize()
  if g_app.isMobile() then return end

  local classic = g_settings.getBoolean("classicView")
  local height = gameMapPanel:getHeight()
  local width = gameMapPanel:getWidth()
     
  if not classic then
    local rheight = gameRootPanel:getHeight()
    local rwidth = gameRootPanel:getWidth()

    local dimenstion = gameMapPanel:getVisibleDimension()  
    local zoom = gameMapPanel:getZoom()  
    local awareRange = g_map.getAwareRange()
    local dheight = dimenstion.height
    local dwidth = dimenstion.width
    local tileSize = rheight / dheight
    local maxWidth = tileSize * (awareRange.width + 1)
    if g_game.getFeature(GameChangeMapAwareRange) and g_game.getFeature(GameNewWalking) then
      maxWidth = tileSize * (awareRange.width - 1)
    end
    gameMapPanel:setMarginTop(-tileSize)
    if modules.game_stats then
      modules.game_stats.ui:setMarginTop(tileSize)
    end
    if g_settings.getBoolean("cacheMap") then
      gameMapPanel:setMarginLeft(0)
      gameMapPanel:setMarginRight(0)    
    else
      local margin = math.max(0, math.floor((rwidth - maxWidth) / 2))
      gameMapPanel:setMarginLeft(margin)
      gameMapPanel:setMarginRight(margin)
    end
      
    if modules.game_bot then
      for i, child in ipairs(gameMapPanel:getChildren()) do
        if child.botIcon and child.onGeometryChange then
          child.onGeometryChange(child)
        end
      end
    end
  else
    if modules.game_stats then
      modules.game_stats.ui:setMarginTop(0)
    end  
  end
  
    --[[
  local maxWidth = math.floor(height * 2)
  local extraMargin = 0
  if width >= maxWidth then
    extraMargin = math.ceil((width - maxWidth) / 2)
  end
  local bottomMaxWidth = 1200  -- something broken, it's not pixels
  local bottomMargin = 0
  if width > bottomMaxWidth then
    bottomMargin = math.ceil((width - bottomMaxWidth) / 2)
  end
  gameMapPanel:setMarginLeft(extraMargin)
  gameMapPanel:setMarginRight(extraMargin) ]]
end

function setupLeftActions()
  if not g_app.isMobile() then return end
  for _, widget in ipairs(gameLeftActions:getChildren()) do
    widget.image:setChecked(false)
    widget.lastClicked = 0
    widget.onClick = function()
      if widget.image:isChecked() then
        widget.image:setChecked(false)
        if widget.doubleClickAction and widget.lastClicked + 200 > g_clock.millis() then
          widget.doubleClickAction()
        end
        return
      end
      resetLeftActions()
      widget.image:setChecked(true)
      widget.lastClicked = g_clock.millis()
    end
  end
  if gameLeftActions.use then
    gameLeftActions.use.doubleClickAction = function()
      local player = g_game.getLocalPlayer()
      local dir = player:getDirection()
      local usePos = player:getPrewalkingPosition(true)
      if dir == North then
        usePos.y = usePos.y - 1
      elseif dir == East then
        usePos.x = usePos.x + 1
      elseif dir == South then
        usePos.y = usePos.y + 1
      elseif dir == West then
        usePos.x = usePos.x - 1
      end
      local tile = g_map.getTile(usePos)
      if not tile then return end
      local thing = tile:getTopUseThing()
      if thing then
        g_game.use(thing)
      end
    end
  end
  if gameLeftActions.attack then
    gameLeftActions.attack.doubleClickAction = function()
      local battlePanel = modules.game_battle.battlePanel
      local attackedCreature = g_game.getAttackingCreature()
      local child = battlePanel:getFirstChild()
      if child and (not child.creature or not child:isOn()) then
        child = nil
      end
      if child then
        g_game.attack(child.creature)
      else
        g_game.attack(nil)
      end
    end
  end
  if gameLeftActions.follow then
    gameLeftActions.follow.doubleClickAction = function()
      local battlePanel = modules.game_battle.battlePanel
      local attackedCreature = g_game.getAttackingCreature()
      local child = battlePanel:getFirstChild()
      if child and (not child.creature or not child:isOn()) then
        child = nil
      end
      if child then
        g_game.follow(child.creature)
      else
        g_game.follow(nil)
      end
    end
  end
  if gameLeftActions.look then
    gameLeftActions.look.doubleClickAction = function()
      local battlePanel = modules.game_battle.battlePanel
      local attackedCreature = g_game.getAttackingCreature()
      local child = battlePanel:getFirstChild()
      if child and (not child.creature or child:isHidden()) then
        child = nil
      end
      if child then
        g_game.look(child.creature)
      end
    end
  end  
  if not gameLeftActions.chat then return end
  gameLeftActions.chat.onClick = function()
    if gameBottomPanel:getHeight() <= 5 then
      gameBottomPanel:setHeight(90)
    else
      gameBottomPanel:setHeight(0)    
    end
  end
end

function resetLeftActions()
  for _, widget in ipairs(gameLeftActions:getChildren()) do
    widget.image:setChecked(false)
    widget.lastClicked = 0
  end
end

function getLeftAction()
  for _, widget in ipairs(gameLeftActions:getChildren()) do
    if widget.image:isChecked() then
      return widget:getId()
    end
  end
  return ""
end

function isChatVisible()
  return gameBottomPanel:getHeight() >= 5
end