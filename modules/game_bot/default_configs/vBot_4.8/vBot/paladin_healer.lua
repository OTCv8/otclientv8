setDefaultTab("HP")

-- Paladin Healer: one switch that heals a paladin with spells and potions.
--
-- How it decides (every 100 ms):
--  1. It guesses your HP a moment ahead from the damage you took in the last
--     3 seconds ("Predict damage"), so it heals before a big hit lands.
--  2. With many monsters around it heals earlier ("Heal earlier when ...").
--  3. Spells: the strongest tier whose HP % you are under is cast. If that
--     spell can't be cast (cooldown, mana, level) the next weaker one is tried.
--     Light heal is skipped when your mana is under "Save mana".
--  4. Potions run at the same time (they have their own exhaust): health
--     potion when HP is low, mana potion when mana is low, and a mana potion
--     first when mana is so low that the heal spells can't be cast.
--     Each potion row takes item ids, best first; the first one you carry
--     is used. Spirit potions (8472, 23374) heal HP and mana.
--  5. When HP is safe it cures paralysis, poison and curse.
--
-- Default potion ids: 23374 ultimate spirit, 8472 great spirit,
-- 236 strong health, 266 health, 238 great mana, 237 strong mana, 268 mana.
-- Turn off HealBot (or its paladin rows) so both don't heal at once.

local panelName = "paladinHealer"
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Paladin Healer')

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

local window = UI.createWindow("PaladinHealerWindow")
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

-- rows: "spell" = text + spin box, "number" = spin box, "text" = text, "check" = only tick
local rowStyles = {
  spell = "PaladinHealRow",
  number = "AlarmCheckBoxAndSpinBox",
  text = "AlarmCheckBoxAndTextEdit",
  check = "AlarmCheckBox"
}
local rows = {}

local function addRow(parent, id, rowType, title, defaults, tooltip, minimum, maximum)
  local widget = UI.createWidget(rowStyles[rowType], parent)
  widget:setId(id)

  if type(config[id]) ~= "table" then
    config[id] = { enabled = defaults.enabled, text = defaults.text, value = defaults.value }
  end

  widget.tick:setText(title)
  if tooltip then
    widget.tick:setTooltip(tooltip)
  end
  if widget.value then
    if minimum then widget.value:setMinimum(minimum) end
    if maximum then widget.value:setMaximum(maximum) end
  end

  -- puts the saved values into the widgets (also used by the Defaults button)
  local function refresh()
    local entry = config[id]
    widget.tick:setChecked(entry.enabled)
    if widget.text then widget.text:setText(entry.text or "") end
    if widget.value then widget.value:setValue(entry.value or defaults.value or 0) end
  end
  refresh()

  widget.tick.onClick = function()
    config[id].enabled = not config[id].enabled
    widget.tick:setChecked(config[id].enabled)
  end
  if widget.text then
    widget.text.onTextChange = function(_, newText)
      config[id].text = newText
    end
  end
  if widget.value then
    widget.value.onValueChange = function(_, value)
      config[id].value = value
    end
  end

  table.insert(rows, { id = id, defaults = defaults, refresh = refresh })
end

-- healing spells, strongest first
addRow(window.spells, "emergency", "spell", "Emergency", { enabled = true, text = "exura gran san", value = 40 },
  "Salvation (level 60, 210 mana). Cast when HP is under this %.")
addRow(window.spells, "strong", "spell", "Strong heal", { enabled = true, text = "exura san", value = 65 },
  "Divine Healing (level 35, 160 mana). Cast when HP is under this %.")
addRow(window.spells, "light", "spell", "Light heal", { enabled = true, text = "exura gran", value = 88 },
  "Cheap heal to top up HP. Cast when HP is under this %.")

-- potions
addRow(window.potions, "healthPotion", "spell", "Health potion", { enabled = true, text = "23374, 8472, 236, 266", value = 50 },
  "Item ids separated by comma, best first. Used when HP is under this %.")
addRow(window.potions, "manaPotion", "spell", "Mana potion", { enabled = true, text = "238, 237, 268", value = 55 },
  "Item ids separated by comma, best first. Used when mana is under this %.")

-- smart options
addRow(window.smart, "predict", "number", "Predict damage (x100 ms ahead)", { enabled = true, value = 6 },
  "Heals for the HP you will most likely have this long from now, based on the damage of the last 3 seconds. 6 = 0.6 s.", 1, 20)
addRow(window.smart, "crowd", "number", "Heal 10% earlier with monsters near >=", { enabled = true, value = 4 },
  "When this many monsters are within 3 squares, every HP % above is raised by 10.", 1, 15)
addRow(window.smart, "saveMana", "number", "Save mana: light heal only above MP %", { enabled = true, value = 30 },
  "Keeps mana for the big heals. Emergency and strong heal are never held back.", 1, 99)
addRow(window.smart, "lowMana", "number", "Mana potion first when MP % below", { enabled = true, value = 20 },
  "When mana is this low, a mana potion is used before a health potion (unless HP is in emergency).", 1, 99)
addRow(window.smart, "paralyze", "text", "Cure paralysis with", { enabled = true, text = "utani hur" })
addRow(window.smart, "poison", "check", "Cure poison (exana pox)", { enabled = true })
addRow(window.smart, "curse", "check", "Cure curse (exana mort, level 80)", { enabled = true })
addRow(window.smart, "pz", "check", "Pause in protection zone", { enabled = true })

window.resetButton.onClick = function()
  for _, row in ipairs(rows) do
    local d = row.defaults
    config[row.id] = { enabled = d.enabled, text = d.text, value = d.value }
    row.refresh()
  end
end

local function setStatus(text, color)
  window.status:setText(text)
  window.status:setColor(color or "#FFFFFF")
end
setStatus("Turn on the switch to start healing.", "#AAAAAA")

-- "23374, 8472" -> {23374, 8472}, cached so it's not parsed every tick
local idCache = {}
local function parseIds(text)
  text = text or ""
  if idCache[text] then return idCache[text] end
  local ids = {}
  for _, part in ipairs(string.split(text, ",")) do
    local id = tonumber(part:trim())
    if id then table.insert(ids, id) end
  end
  idCache[text] = ids
  return ids
end

local lastPotion = 0
local function usePotion(entry)
  if not entry.enabled then return false end
  if vBot.isUsingPotion or now - lastPotion < 1000 then return false end
  for _, id in ipairs(parseIds(entry.text)) do
    if findItem(id) then
      g_game.useInventoryItemWith(id, player)
      lastPotion = now
      return true
    end
  end
  return false
end

local lastSpell = 0
local function castSpell(spell)
  spell = (spell or ""):trim()
  if spell:len() == 0 then return false end
  if now - lastSpell < 400 then return false end
  if not canCast(spell) then return false end
  say(spell)
  lastSpell = now
  return true
end

-- damage per second from the last 3 seconds, made safe for 0/inf/nan
local function damagePerSecond()
  local dps = burstDamageValue()
  if dps ~= dps or dps < 0 then return 0 end
  return math.min(dps, maxhp() * 2)
end

local tiers = { "emergency", "strong", "light" }
local lastStatus = 0
local lastAction = "nothing yet"

macro(100, function()
  if not config.enabled then return end
  if config.pz.enabled and isInPz() then return end

  local maxHealth = math.max(maxhp(), 1)
  local mp = manapercent()
  local dps = damagePerSecond()

  -- HP % we will likely have a moment from now
  local predicted = hp()
  if config.predict.enabled then
    predicted = predicted - dps * (config.predict.value or 6) / 10
  end
  local hpp = math.max(0, predicted * 100 / maxHealth)

  local bonus = 0
  if config.crowd.enabled and getMonsters(3) >= (config.crowd.value or 4) then
    bonus = 10
  end

  local function under(id)
    return config[id].enabled and hpp <= (config[id].value or 0) + bonus
  end

  -- spells: find the strongest tier we need, fall back to weaker ones
  local healed = false
  for i, id in ipairs(tiers) do
    if under(id) then
      for j = i, #tiers do
        local tier = config[tiers[j]]
        local allowed = tier.enabled
        if tiers[j] == "light" and i == #tiers and config.saveMana.enabled and mp < (config.saveMana.value or 0) then
          allowed = false
        end
        if allowed and castSpell(tier.text) then
          healed = true
          lastAction = tier.text
          break
        end
      end
      break
    end
  end

  -- cures, only when HP is not in danger
  if not healed and not under("strong") then
    local cure = nil
    if config.paralyze.enabled and isParalyzed() then
      cure = config.paralyze.text
    elseif config.poison.enabled and isPoisioned() then
      cure = "exana pox"
    elseif config.curse.enabled and isCursed() then
      cure = "exana mort"
    end
    if cure and castSpell(cure) then
      lastAction = cure
    end
  end

  -- potions have their own exhaust, so they can go together with a spell
  local hpPotion = config.healthPotion
  local mpPotion = config.manaPotion
  local needHp = hpPotion.enabled and hpp <= (hpPotion.value or 0) + bonus
  local needMp = mpPotion.enabled and mp <= (mpPotion.value or 0)
  local manaCritical = config.lowMana.enabled and mp < (config.lowMana.value or 0)

  if under("emergency") and needHp then
    if usePotion(hpPotion) then lastAction = "health potion" end
  elseif manaCritical and needMp then
    if usePotion(mpPotion) then lastAction = "mana potion" end
  elseif needHp then
    if usePotion(hpPotion) then lastAction = "health potion" end
  elseif needMp then
    if usePotion(mpPotion) then lastAction = "mana potion" end
  end

  -- status text in the setup window, twice per second is enough
  if window:isVisible() and now - lastStatus > 500 then
    lastStatus = now
    local text = string.format("HP now %d%%, expected %d%%, damage %d/s\nMana %d%%. Last action: %s",
      hppercent(), math.floor(hpp), math.floor(dps), mp, lastAction)
    local color = "#50FF50"
    if HealBot and HealBot.isOn and HealBot.isOn() then
      text = text .. "\nHealBot is also on. Turn it off to avoid double heals."
      color = "#FFAA00"
    end
    setStatus(text, color)
  end
end)

UI.Separator()
