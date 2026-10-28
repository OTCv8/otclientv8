setDefaultTab("Cave")

-- Hunt Guard: reacts to danger while hunting (players, staff, low HP, chosen
-- creatures) by stopping the bots, running to a CaveBot label, casting a spell
-- and/or logging out. Optionally turns the bots back on once it is safe again.

local panelName = "huntGuard"
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Hunt Guard')

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

if type(storage[panelName]) ~= "table" then
  storage[panelName] = {}
end
local config = storage[panelName]

local window = UI.createWindow("HuntGuardWindow")
window:hide()

ui.title:setOn(config.enabled)
ui.title.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
end

ui.setup.onClick = function()
  window:show()
  window:raise()
  window:focus()
end

-- rows reuse the widget styles from alarms.otui
local rowStyles = { "AlarmCheckBox", "AlarmCheckBoxAndSpinBox", "AlarmCheckBoxAndTextEdit" }

local function addRow(parent, id, title, defaultEnabled, defaultValue, rowType, tooltip, minimum, maximum)
  local widget = UI.createWidget(rowStyles[rowType], parent)
  widget:setId(id)

  if type(config[id]) ~= "table" then
    config[id] = { enabled = defaultEnabled, value = defaultValue }
  end
  local entry = config[id]

  widget.tick:setText(title)
  widget.tick:setChecked(entry.enabled)
  if tooltip then
    widget.tick:setTooltip(tooltip)
  end
  widget.tick.onClick = function()
    entry.enabled = not entry.enabled
    widget.tick:setChecked(entry.enabled)
  end

  if rowType == 2 then
    if minimum then widget.value:setMinimum(minimum) end
    if maximum then widget.value:setMaximum(maximum) end
    widget.value:setValue(entry.value or defaultValue)
    widget.value.onValueChange = function(_, value)
      entry.value = value
    end
  elseif rowType == 3 then
    widget.text:setText(entry.value or "")
    widget.text.onTextChange = function(_, newText)
      entry.value = newText
    end
  end
end

-- triggers
addRow(window.triggers, "playerOnScreen", "Player on screen", true, nil, 1, "Any player that is not you, a friend (Player List / BotServer) or a party member.")
addRow(window.triggers, "playerAttack", "Attacked by player", true, nil, 1, "A player has you targeted (white square around him).")
addRow(window.triggers, "staffOnScreen", "GM / CM / God on screen", true, nil, 1)
addRow(window.triggers, "lowHealth", "HP below %", false, 30, 2, "Trigger when your health drops below this percent.", 1, 99)
addRow(window.triggers, "creatureName", "Creature:", false, "", 3, "Names (or parts of names) separated by comma, e.g. boss names.")

-- actions
addRow(window.actions, "stopBots", "Stop CaveBot & TargetBot", true, nil, 1)
addRow(window.actions, "gotoLabel", "Go to label:", false, "escape", 3, "CaveBot keeps running and jumps to this label (e.g. your refill or exit route). Used instead of stopping the bots.")
addRow(window.actions, "castSpell", "Cast:", false, "utani hur", 3, "Spell to cast once when triggered, e.g. utani hur or exura vita.")
addRow(window.actions, "logout", "Logout when possible", false, nil, 1, "Keeps trying to log out until it works (not possible while in battle).")
addRow(window.actions, "sound", "Play alarm sound", true, nil, 1)
addRow(window.actions, "resume", "Resume bots after safe (sec)", false, 60, 2, "Turn the bots back on when nothing has triggered for this many seconds.", 10, 600)

-- state
local triggered = false
local lastDanger = 0
local stoppedCave = false
local stoppedTarget = false
local logoutPending = false
local lastLogoutTry = 0
local lastSound = 0
local lastReason = nil

local staffPrefixes = { "gm ", "cm ", "god ", "gamemaster", "community manager", "[gm]", "[cm]" }

local function setStatus(text, color)
  window.status:setText(text)
  window.status:setColor(color or "#FFFFFF")
end
setStatus("Waiting. Nothing triggered yet.", "#AAAAAA")

local function isStaff(name)
  name = name:lower()
  for _, prefix in ipairs(staffPrefixes) do
    if name:sub(1, #prefix) == prefix then
      return true
    end
  end
  return false
end

local function isSafePlayer(spec)
  if isFriend(spec) then return true end
  -- party members (shield 1 = no party)
  if spec:getShield() ~= 1 and spec:isPartyMember() then return true end
  return false
end

-- returns a reason text if something dangerous is going on
local function checkDanger()
  if config.lowHealth.enabled and hppercent() < (config.lowHealth.value or 30) then
    return "HP below " .. config.lowHealth.value .. "%"
  end

  local fragments = {}
  if config.creatureName.enabled and (config.creatureName.value or ""):len() > 0 then
    for _, frag in ipairs(string.split(config.creatureName.value, ",")) do
      frag = frag:trim():lower()
      if frag:len() > 0 then
        table.insert(fragments, frag)
      end
    end
  end

  for _, spec in ipairs(getSpectators()) do
    if not spec:isLocalPlayer() then
      local name = spec:getName()
      if spec:isPlayer() then
        if config.staffOnScreen.enabled and isStaff(name) then
          return "Staff on screen: " .. name
        end
        if not isSafePlayer(spec) then
          if config.playerAttack.enabled and spec:isTimedSquareVisible() then
            return "Attacked by player: " .. name
          end
          if config.playerOnScreen.enabled then
            return "Player on screen: " .. name
          end
        end
      end
      if #fragments > 0 then
        local lowerName = name:lower()
        for _, frag in ipairs(fragments) do
          if lowerName:find(frag, 1, true) then
            return "Creature on screen: " .. name
          end
        end
      end
    end
  end
end

local function react(reason)
  if not triggered then
    triggered = true
    lastReason = reason
    warn("[Hunt Guard] " .. reason)

    local labelName = config.gotoLabel.enabled and (config.gotoLabel.value or ""):trim() or ""
    if labelName:len() > 0 then
      if not CaveBot.gotoLabel(labelName) then
        warn("[Hunt Guard] CaveBot label '" .. labelName .. "' not found")
      end
    elseif config.stopBots.enabled then
      if CaveBot.isOn() then
        CaveBot.setOff()
        stoppedCave = true
      end
      if TargetBot.isOn() then
        TargetBot.setOff()
        stoppedTarget = true
      end
    end

    local spell = config.castSpell.enabled and (config.castSpell.value or ""):trim() or ""
    if spell:len() > 0 then
      say(spell)
    end

    if config.logout.enabled then
      logoutPending = true
    end

    if modules.game_bot.g_app.getOs() == "windows" then
      g_window.flash()
    end
  end

  if config.sound.enabled and now - lastSound > 6000 then
    lastSound = now
    playSound("/sounds/alarm.ogg")
  end

  setStatus(os.date("%H:%M:%S") .. " " .. reason, "#FF5050")
end

local function resetGuard()
  triggered = false
  stoppedCave = false
  stoppedTarget = false
  logoutPending = false
  lastReason = nil
  setStatus("Waiting. Nothing triggered yet.", "#AAAAAA")
end

window.resetButton.onClick = resetGuard

macro(250, function()
  if not config.enabled then return end

  if logoutPending and now - lastLogoutTry > 2000 then
    lastLogoutTry = now
    g_game.safeLogout()
  end

  local reason = checkDanger()
  if reason then
    lastDanger = now
    return react(reason)
  end

  -- safe again: without auto resume, re-arm after 10s so a new danger reacts again
  if triggered and not config.resume.enabled and not logoutPending and now - lastDanger > 10000 then
    triggered = false
    stoppedCave = false
    stoppedTarget = false
    return
  end

  if triggered and config.resume.enabled and not logoutPending then
    local wait = (config.resume.value or 60) * 1000
    local left = math.ceil((wait - (now - lastDanger)) / 1000)
    if left <= 0 then
      if stoppedCave then CaveBot.setOn() end
      if stoppedTarget then TargetBot.setOn() end
      warn("[Hunt Guard] Safe again, bots resumed")
      resetGuard()
      setStatus(os.date("%H:%M:%S") .. " Safe again, bots resumed.", "#50FF50")
    else
      setStatus("Last: " .. (lastReason or "?") .. "\nResuming in " .. left .. "s if it stays safe.", "#FFAA00")
    end
  end
end)

-- turning the guard off clears its state
local oldTitleClick = ui.title.onClick
ui.title.onClick = function(widget)
  oldTitleClick(widget)
  if not config.enabled then
    resetGuard()
  end
end
