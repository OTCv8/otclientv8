setDefaultTab("Main")

-- securing storage namespace
panelName = "extras"
if not storage[panelName] then
  storage[panelName] = {}
end
local settings = storage[panelName]

-- basic elements
extrasWindow = UI.createWindow('ExtrasWindow', rootWidget)
extrasWindow:hide()
extrasWindow.closeButton.onClick = function(widget)
  extrasWindow:hide()
end

-- available options for dest param
local rightPanel = extrasWindow.content.right
local leftPanel = extrasWindow.content.left

-- objects made by Kondrah - taken from creature editor, minor changes to adapt
local addCheckBox = function(id, title, defaultValue, dest)
  local widget = UI.createWidget('ExtrasCheckBox', dest)
  widget.onClick = function()
    widget:setOn(not widget:isOn())
    settings[id] = widget:isOn()
  end
  widget:setText(title)
  if settings[id] == nil then
    widget:setOn(defaultValue)
  else
    widget:setOn(settings[id])
  end
  settings[id] = widget:isOn()
end

local addItem = function(id, title, defaultItem, dest)
  local widget = UI.createWidget('ExtrasItem', dest)
  widget.text:setText(title)
  widget.item:setItemId(settings[id] or defaultItem)
  widget.item.onItemChange = function(widget)
    settings[id] = widget:getItemId()
  end
  settings[id] = settings[id] or defaultItem
end

local addTextEdit = function(id, title, defaultValue, dest)
  local widget = UI.createWidget('ExtrasTextEdit', dest)
  widget.text:setText(title)
  widget.textEdit:setText(settings[id] or defaultValue or "")
  widget.textEdit.onTextChange = function(widget,text)
    settings[id] = text
  end
  settings[id] = settings[id] or defaultValue or ""
end

local addScrollBar = function(id, title, min, max, defaultValue, dest)
  local widget = UI.createWidget('ExtrasScrollBar', dest)
  widget.scroll.onValueChange = function(scroll, value)
    widget.text:setText(title .. ": " .. value)
    if value == 0 then
      value = 1
    end
    settings[id] = value
  end
  widget.scroll:setRange(min, max)
  if max-min > 1000 then
    widget.scroll:setStep(100)
  elseif max-min > 100 then
    widget.scroll:setStep(10)
  end
  widget.scroll:setValue(settings[id] or defaultValue)
  widget.scroll.onValueChange(widget.scroll, widget.scroll:getValue())
end

UI.Button("vBot Settings and Scripts", function()
  extrasWindow:show()
  extrasWindow:raise()
  extrasWindow:focus()
end)
UI.Separator()

---- to maintain order, add options right after another:
--- add object
--- add variables for function (optional)
--- add callback (optional)
--- optionals should be addionaly sandboxed (if true then end)

addItem("rope", "Rope Item", 9596, leftPanel)
addItem("shovel", "Shovel Item", 9596, leftPanel)
addItem("machete", "Machete Item", 9596, leftPanel)
addItem("scythe", "Scythe Item", 9596, leftPanel)
addScrollBar("talkDelay", "Global NPC Talk Delay", 0, 2000, 1000, leftPanel)
addScrollBar("looting", "Max Loot Distance", 0, 50, 40, leftPanel)

addCheckBox("title", "Custom Window Title", true, rightPanel)
if true then
  local vocText = ""

  if voc() == 1 or voc() == 11 then
      vocText = "- EK"
  elseif voc() == 2 or voc() == 12 then
      vocText = "- RP"
  elseif voc() == 3 or voc() == 13 then
      vocText = "- MS"
  elseif voc() == 4 or voc() == 14 then
      vocText = "- ED"
  end

  macro(2000, function()
    if settings.title then
      if hppercent() > 0 then
          g_window.setTitle("Tibia - " .. name() .. " - " .. lvl() .. "lvl " .. vocText)
      else
          g_window.setTitle("Tibia - " .. name() .. " - DEAD")
      end
    else
      g_window.setTitle("Tibia - " .. name())
    end
  end)
end


addTextEdit("useAll", "Use All Hotkey", "space", rightPanel)
if true then
  local useId = {34847, 1764, 21051, 30823, 6264, 5282, 20453, 20454, 20474, 11708, 11705, 
                 6257, 6256, 2772, 27260, 2773, 1632, 1633, 1948, 435, 6252, 6253, 5007, 4911, 
                 1629, 1630, 5108, 5107, 5281, 1968, 435, 1948, 5542, 31116, 31120, 30742, 31115, 
                 31118, 20474, 5737, 5736, 5734, 5733, 31202, 31228, 31199, 31200, 33262, 30824, 
                 5125, 5126, 5116, 5117, 8257, 8258, 8255, 8256, 5120, 30777, 30776}
  local shovelId = {606, 593, 867}
  local ropeId = {17238, 12202, 12935, 386, 421, 21966, 14238}
  local macheteId = {2130, 3696}
  local scytheId = {3653}

  setDefaultTab("Tools")
  -- script
  if settings.useAll and settings.useAll:len() > 0 then
    hotkey(settings.useAll, function()
        if not modules.game_walking.wsadWalking then return end
        for _, tile in pairs(g_map.getTiles(posz())) do
            if distanceFromPlayer(tile:getPosition()) < 2 then
                for _, item in pairs(tile:getItems()) do
                    -- use
                    if table.find(useId, item:getId()) then
                        use(item)
                        return
                    elseif table.find(shovelId, item:getId()) then
                        useWith(settings.shovel, item)
                        return
                    elseif table.find(ropeId, item:getId()) then
                        useWith(settings.rope, item) 
                        return
                    elseif table.find(macheteId, item:getId()) then
                        useWith(settings.machete, item)
                        return
                    elseif table.find(scytheId, item:getId()) then
                        useWith(settings.scythe, item)
                        return
                    end
                end
            end
        end
    end)
  end
end


addCheckBox("timers", "MW & WG Timers", true, rightPanel)
if true then
  local activeTimers = {}

  onAddThing(function(tile, thing)
    if not settings.timers then return end
    if not thing:isItem() then
      return
    end
    local timer = 0
    if thing:getId() == 2129 then -- mwall id
      timer = 20000 -- mwall time
    elseif thing:getId() == 2130 then -- wg id
      timer = 45000 -- wg time
    else
      return
    end

    local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
    if not activeTimers[pos] or activeTimers[pos] < now then    
      activeTimers[pos] = now + timer
    end
    tile:setTimer(activeTimers[pos] - now)
  end)

  onRemoveThing(function(tile, thing)
    if not settings.timers then return end
    if not thing:isItem() then
      return
    end
    if (thing:getId() == 2129 or thing:getId() == 2130) and tile:getGround() then
      local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
      activeTimers[pos] = nil
      tile:setTimer(0)
    end  
  end)
end


addCheckBox("antiKick", "Anti - Kick", true, rightPanel)
if true then
  macro(600*1000, function()
    if not settings.antiKick then return end
    local dir = player:getDirection()
    turn((dir + 1) % 4)
    schedule(50, function() turn(dir) end)
  end)
end


addCheckBox("stake", "Skin Monsters", false, leftPanel)
if true then
  local knifeBodies = {4272, 4173, 4011, 4025, 4047, 4052, 4057, 4062, 4112, 4212, 4321, 4324, 4327, 10352, 10356, 10360, 10364} 
  local stakeBodies = {4097, 4137, 8738, 18958}
  local fishingBodies = {9582}
  macro(500, function()
      if not CaveBot.isOn() or not settings.stake then return end
      for i, tile in ipairs(g_map.getTiles(posz())) do
          for u,item in ipairs(tile:getItems()) do
              if table.find(knifeBodies, item:getId()) and findItem(5908) then
                  CaveBot.delay(550)
                  useWith(5908, item)
                  return
              end
              if table.find(stakeBodies, item:getId()) and findItem(5942) then
                  CaveBot.delay(550)
                  useWith(5942, item)
                  return
              end
              if table.find(fishingBodies, item:getId()) and findItem(3483) then
                  CaveBot.delay(550)
                  useWith(3483, item)
                  return
              end
          end
      end
  end)
end


addCheckBox("oberon", "Auto Reply Oberon", true, rightPanel)
if true then
  onTalk(function(name, level, mode, text, channelId, pos)
    if not settings.oberon then return end
    if mode == 34 then
        if string.find(text, "world will suffer for") then
            say("Are you ever going to fight or do you prefer talking!")
        elseif string.find(text, "feet when they see me") then
            say("Even before they smell your breath?")
        elseif string.find(text, "from this plane") then
            say("Too bad you barely exist at all!") 
        elseif string.find(text, "ESDO LO") then
            say("SEHWO ASIMO, TOLIDO ESD") 
        elseif string.find(text, "will soon rule this world") then
            say("Excuse me but I still do not get the message!") 
        elseif string.find(text, "honourable and formidable") then
            say("Then why are we fighting alone right now?") 
        elseif string.find(text, "appear like a worm") then
            say("How appropriate, you look like something worms already got the better of!") 
        elseif string.find(text, "will be the end of mortal") then
            say("Then let me show you the concept of mortality before it!") 
        elseif string.find(text, "virtues of chivalry") then
            say("Dare strike up a Minnesang and you will receive your last accolade!") 
        end
    end
  end)
end


addCheckBox("autoOpenDoors", "Auto Open Doors", true, rightPanel)
if true then
  local wsadWalking = modules.game_walking.wsadWalking
  local doorsIds = { 5007, 8265, 1629, 1632, 5129, 6252, 6249, 7715, 7712, 7714, 
                     7719, 6256, 1669, 1672, 5125, 5115, 5124, 17701, 17710, 1642, 
                     6260, 5107, 4912, 6251, 5291, 1683, 1696, 1692, 5006, 2179, 5116, 
                     1632, 11705, 30772, 30774, 6248, 5735, 5732, 5120 }

  function checkForDoors(pos)
    local tile = g_map.getTile(pos)
    if tile then
      local useThing = tile:getTopUseThing()
      if useThing and table.find(doorsIds, useThing:getId()) then
        g_game.use(useThing)
      end
    end
  end

  onKeyPress(function(keys)
    if not settings.autoOpenDoors then return end
    local pos = player:getPosition()
    if keys == 'Up' or (wsadWalking and keys == 'W') then
      pos.y = pos.y - 1
    elseif keys == 'Down' or (wsadWalking and keys == 'S') then
      pos.y = pos.y + 1
    elseif keys == 'Left' or (wsadWalking and keys == 'A') then
      pos.x = pos.x - 1
    elseif keys == 'Right' or (wsadWalking and keys == 'D') then
      pos.x = pos.x + 1
    elseif wsadWalking and keys == "Q" then
      pos.y = pos.y - 1
      pos.x = pos.x - 1
    elseif wsadWalking and keys == "E" then
      pos.y = pos.y - 1
      pos.x = pos.x + 1
    elseif wsadWalking and keys == "Z" then
      pos.y = pos.y + 1
      pos.x = pos.x - 1
    elseif wsadWalking and keys == "C" then
      pos.y = pos.y + 1
      pos.x = pos.x + 1
    end
    checkForDoors(pos)
  end)
end


addCheckBox("bless", "Buy bless at login", true, rightPanel)
if true then
  if settings.bless then
    if player:getBlessings() == 0 then
      say("!bless")
      schedule(2000, function() 
          if g_game.getClientVersion() > 1000 then
            if player:getBlessings() == 0 then
                warn("!! Blessings not bought !!")
            end
          end
      end)
    end
  end
end


addCheckBox("reUse", "Keep Crosshair", false, rightPanel)
if true then
  local excluded = {268, 237, 238, 23373, 266, 236, 239, 7643, 23375, 7642, 23374, 5908, 5942} 

  onUseWith(function(pos, itemId, target, subType)
    if settings.reUse and not table.find(excluded, itemId) then
      schedule(50, function()
        item = findItem(itemId)
        if item then
          modules.game_interface.startUseWith(item)
        end
      end)
    end
  end)
end


addCheckBox("suppliesControl", "TargetBot off if low supply", false, leftPanel)
if true then
  macro(500, function()
    if not settings.suppliesControl then return end
    if TargetBot.isOff() then return end
    if CaveBot.isOff() then return end
    if not hasSupplies() then
        TargetBot.setOff()
    end
  end)
end

addCheckBox("holdMwall", "Hold MW/WG [ , ][ . ]", true, rightPanel)
if true then
  local mwHot = ","
  local wgHot = "."

  local candidates = {}

  local m = macro(20, function()
    if not settings.holdMwall then return end
      if #candidates == 0 then return end

      for i, tile in pairs(candidates) do
          if tile:getText():len() == 0 then 
              table.remove(candidates, i)
          end
          local rune = tile:getText() == "HOLD MW" and 3180 or 3156
          if tile:canShoot() and not isInPz() and tile:isWalkable() and tile:getTopUseThing():getId() ~= 2130 then
              return useWith(rune, tile:getTopUseThing())
          end
      end
  end)

  onRemoveThing(function(tile, thing)
    if not settings.holdMwall then return end
      if thing:getId() ~= 2129 then return end
      if tile:getText():len() > 0 then
          table.insert(candidates, tile)
          useWith(3180, tile:getTopUseThing())
      end
  end)

  onAddThing(function(tile, thing)
    if not settings.holdMwall then return end
      if m.isOff() then return end
      if thing:getId() ~= 2129 then return end
      if tile:getText():len() > 0 then
          table.remove(candidates, table.find(candidates,tile))
      end
  end)

  onKeyPress(function(keys)
    local wsadWalking = modules.game_walking.wsadWalking
    if not wsadWalking then return end
    if not settings.holdMwall then return end
    if m.isOff() then return end
    if keys ~= mwHot and keys ~= wgHot then return end


    local tile = getTileUnderCursor()
    if not tile then return end

    if tile:getText():len() > 0 then
        tile:setText("")
    else
        if keys == mwHot then
            tile:setText("HOLD MW")
        else
            tile:setText("HOLD WG")
        end
        table.insert(candidates, tile)
    end
  end)
end

