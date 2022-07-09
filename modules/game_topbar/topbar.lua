Icons = {}
Icons[PlayerStates.Poison] = {
    tooltip = tr('You are poisoned'),
    path = '/images/game/states/poisoned',
    id = 'condition_poisoned'
}
Icons[PlayerStates.Burn] = {
    tooltip = tr('You are burning'),
    path = '/images/game/states/burning',
    id = 'condition_burning'
}
Icons[PlayerStates.Energy] = {
    tooltip = tr('You are electrified'),
    path = '/images/game/states/electrified',
    id = 'condition_electrified'
}
Icons[PlayerStates.Drunk] = {
    tooltip = tr('You are drunk'),
    path = '/images/game/states/drunk',
    id = 'condition_drunk'
}
Icons[PlayerStates.ManaShield] = {
    tooltip = tr('You are protected by a magic shield'),
    path = '/images/game/states/magic_shield',
    id = 'condition_magic_shield'
}
Icons[PlayerStates.Paralyze] = {
    tooltip = tr('You are paralysed'),
    path = '/images/game/states/slowed',
    id = 'condition_slowed'
}
Icons[PlayerStates.Haste] = {
    tooltip = tr('You are hasted'),
    path = '/images/game/states/haste',
    id = 'condition_haste'
}
Icons[PlayerStates.Swords] = {
    tooltip = tr('You may not logout during a fight'),
    path = '/images/game/states/logout_block',
    id = 'condition_logout_block'
}
Icons[PlayerStates.Drowning] = {
    tooltip = tr('You are drowning'),
    path = '/images/game/states/drowning',
    id = 'condition_drowning'
}
Icons[PlayerStates.Freezing] = {
    tooltip = tr('You are freezing'),
    path = '/images/game/states/freezing',
    id = 'condition_freezing'
}
Icons[PlayerStates.Dazzled] = {
    tooltip = tr('You are dazzled'),
    path = '/images/game/states/dazzled',
    id = 'condition_dazzled'
}
Icons[PlayerStates.Cursed] = {
    tooltip = tr('You are cursed'),
    path = '/images/game/states/cursed',
    id = 'condition_cursed'
}
Icons[PlayerStates.PartyBuff] = {
    tooltip = tr('You are strengthened'),
    path = '/images/game/states/strengthened',
    id = 'condition_strengthened'
}
Icons[PlayerStates.PzBlock] = {
    tooltip = tr('You may not logout or enter a protection zone'),
    path = '/images/game/states/protection_zone_block',
    id = 'condition_protection_zone_block'
}
Icons[PlayerStates.Pz] = {
    tooltip = tr('You are within a protection zone'),
    path = '/images/game/states/protection_zone',
    id = 'condition_protection_zone'
}
Icons[PlayerStates.Bleeding] = {
    tooltip = tr('You are bleeding'),
    path = '/images/game/states/bleeding',
    id = 'condition_bleeding'
}
Icons[PlayerStates.Hungry] = {
    tooltip = tr('You are hungry'),
    path = '/images/game/states/hungry',
    id = 'condition_hungry'
}

local iconsTable = {
    ["Experience"] = 8,
    ["Magic"] = 0,
    ["Axe"] = 2,
    ["Club"] = 1,
    ["Distance"] = 3,
    ["Fist"] = 4,
    ["Shielding"] = 5,
    ["Sword"] = 6,
    ["Fishing"] = 7
}

local healthBar = nil
local manaBar = nil
local topBar = nil
local states = nil
local experienceTooltip = 'You have %d%% to advance to level %d.'
local settings = {}

function init()
    
    connect(LocalPlayer, {
        onHealthChange = onHealthChange,
        onManaChange = onManaChange,
        onLevelChange = onLevelChange,
        onStatesChange = onStatesChange,
        onMagicLevelChange = onMagicLevelChange,
        onBaseMagicLevelChange = onBaseMagicLevelChange,
        onSkillChange = onSkillChange,
        onBaseSkillChange = onBaseSkillChange
    })
    connect(g_game, {onGameStart = refresh, onGameEnd = offline})

    -- load condition icons
    for k, v in pairs(Icons) do g_textures.preload(v.path) end

    if g_game.isOnline() then refresh() end
end

function terminate()

    disconnect(LocalPlayer, {
        onHealthChange = onHealthChange,
        onManaChange = onManaChange,
        onLevelChange = onLevelChange,
        onStatesChange = onStatesChange,
        onMagicLevelChange = onMagicLevelChange,
        onBaseMagicLevelChange = onBaseMagicLevelChange,
        onSkillChange = onSkillChange,
        onBaseSkillChange = onBaseSkillChange
    })
    disconnect(g_game, {onGameStart = refresh, onGameEnd = offline})
end

function setupTopBar()
    local topPanel = modules.game_interface.getTopBar()
    topBar = topBar or g_ui.loadUI('topbar', topPanel)

    manaBar = topBar.stats.mana
    healthBar = topBar.stats.health
    states = topBar.stats.states.box

    topBar.onMouseRelease = function(widget, mousePos, mouseButton)
        menu(mouseButton)
    end
end

function refresh(profileChange)
    local player = g_game.getLocalPlayer()
    if not player then return end

    setupTopBar()
    load()
    setupSkills()
    show()
    refreshVisibleBars()

    onLevelChange(player, player:getLevel(), player:getLevelPercent())
    onHealthChange(player, player:getHealth(), player:getMaxHealth())
    onManaChange(player, player:getMana(), player:getMaxMana())
    onMagicLevelChange(player, player:getMagicLevel(), player:getMagicLevelPercent())
    if not profileChange then
        onStatesChange(player, player:getStates(), 0)
    end
    onHealthChange(player, player:getHealth(), player:getMaxHealth())
    onManaChange(player, player:getMana(), player:getMaxMana())
    onLevelChange(player, player:getLevel(), player:getLevelPercent())

    for i = Skill.Fist, Skill.ManaLeechAmount do
        onSkillChange(player, i, player:getSkillLevel(i), player:getSkillLevelPercent(i))
        onBaseSkillChange(player, i, player:getSkillBaseLevel(i))
    end

    topBar.skills.onGeometryChange = setSkillsLayout
end

function refreshVisibleBars()
    local ids = {"Experience", "Magic", "Axe", "Club", "Distance", "Fist", "Shielding",
    "Sword", "Fishing"}

    for i, id in ipairs(ids) do
        local panel = topBar[id] or topBar.skills[id]

        if panel then
            -- experience is exeption
            if id == "Experience" then
                if not settings[id] then
                    panel:setVisible(true)
                end
            else
                panel:setVisible(settings[id] or false)
            end
        end
    end
end

function setSkillsLayout()
    local visible = 0
    local skills = topBar.skills
    local width = skills:getWidth()

    for i, child in ipairs(skills:getChildren()) do
        visible = child:isVisible() and visible + 1 or visible
    end

    local many = visible > 1
    width = many and (width / 2) or width

    skills:getLayout():setCellSize({width = width, height = 19})
end

function offline()
    local player = g_game.getLocalPlayer()

    if player then onStatesChange(player, 0, player:getStates()) end
    save()
end

function toggleIcon(bitChanged)
    local content = states
    if not content then return end

    local icon = content:getChildById(Icons[bitChanged].id)
    if icon then
        icon:destroy()
    else
        icon = loadIcon(bitChanged)
        icon:setParent(content)
    end
end

function loadIcon(bitChanged)
    local icon = g_ui.createWidget('ConditionWidget', content)
    icon:setId(Icons[bitChanged].id)
    icon:setImageSource(Icons[bitChanged].path)
    icon:setTooltip(Icons[bitChanged].tooltip)
    return icon
end

function onHealthChange(localPlayer, health, maxHealth)
    if not healthBar then return end
    if health > maxHealth then maxHealth = health end

    local healthPercent = (health / maxHealth) * 100
    healthBar:setText(comma_value(health) .. ' / ' .. comma_value(maxHealth))
    healthBar:setValue(health, 0, maxHealth)
    healthBar:setPercent(healthPercent)

    if healthPercent > 92 then
        healthBar:setBackgroundColor("#00BC00FF")
    elseif healthPercent > 60 then
        healthBar:setBackgroundColor("#50A150FF")
    elseif healthPercent > 30 then
        healthBar:setBackgroundColor("#A1A100FF")
    elseif healthPercent > 8 then
        healthBar:setBackgroundColor("#BF0A0AFF")
    elseif healthPercent > 3 then
        healthBar:setBackgroundColor("#910F0FFF")
    else
        healthBar:setBackgroundColor("#850C0CFF")
    end
end

function onManaChange(localPlayer, mana, maxMana)
    if not manaBar then return end
    if mana > maxMana then maxMana = mana end

    local manaPercent = (mana / maxMana) * 100
    if manaPercent < 0 then return end
    manaBar:setText(comma_value(mana) .. ' / ' .. comma_value(maxMana))
    manaBar:setValue(mana, 0, maxMana)
    manaBar:setPercent(manaPercent)
end

function onLevelChange(localPlayer, value, percent)
    if not topBar then return end
    local experienceBar = topBar.Experience.progress
    local levelLabel = topBar.Experience.level
    experienceBar:setTooltip(tr(experienceTooltip, 100-percent, value + 1))
    experienceBar:setPercent(percent)
    levelLabel:setText(value)
    levelLabel:setTextAutoResize(true)
end

function onStatesChange(localPlayer, now, old)
    if now == old then return end

    local bitsChanged = bit32.bxor(now, old)
    for i = 1, 32 do
        local pow = math.pow(2, i - 1)
        if pow > bitsChanged then break end
        local bitChanged = bit32.band(bitsChanged, pow)
        if bitChanged ~= 0 then toggleIcon(bitChanged) end
    end
end

function show()
    if not g_game.isOnline() then return end
    topBar:setVisible(g_settings.getBoolean("topBar", false))
end

function setupSkillPanel(id, parent, experience, defaultOff)
    local widget = g_ui.createWidget('SkillPanel', parent)
    widget:setId(id)
    widget.level:setTooltip(id)
    widget.icon:setTooltip(id)
    widget.icon:setImageClip({x = iconsTable[id]*9, y = 0, width = 9,height = 9})

    if not experience then 
        widget.progress:setBackgroundColor('#00c000') 
        widget.shop:setVisible(false)
        widget.shop:disable()
        widget.shop:setWidth(0)
        widget.progress:setMarginRight(1)
    end

    settings[id] = settings[id] ~= nil and settings[id] or defaultOff
    if settings[id] == false then widget:setVisible(false) end

    -- breakers
    widget.onGeometryChange = function()
        local margin = widget.progress:getWidth() / 4
        local left = widget.left
        local right = widget.right

        left:setMarginRight(margin)
        right:setMarginRight(margin)
    end

end

function menu(mouseButton)
    if mouseButton ~= 2 then return end

    local menu = g_ui.createWidget('PopupMenu')
    menu:setId("topBarMenu")
    menu:setGameMenu(true)

    local expPanel = topBar.Experience
    local start = expPanel:isVisible() and "Hide" or "Show"
    menu:addOption(start .. " Experience Level",
                   function() toggleSkillPanel(id) end)
    for i, child in ipairs(topBar.skills:getChildren()) do
        local id = child:getId()
        if id ~= "stats" then
            local start = child:isVisible() and "Hide" or "Show"
            menu:addOption(start .. " " .. id .. " Level",
                           function() toggleSkillPanel(id) end)
        end
    end

    menu:display(mousePos)
    return true
end

function setupSkills()
    local t = {
        "Experience", "Magic", "Axe", "Club", "Distance", "Fist", "Shielding",
        "Sword", "Fishing"
    }

    for i, id in ipairs(t) do
        if not topBar[id] and not topBar.skills[id] then
            setupSkillPanel(id, i == 1 and topBar or topBar.skills, i == 1,
                            i == 1)
        end
    end

    local child = topBar.Experience
    topBar:moveChildToIndex(child, 2)
end

function toggleSkillPanel(id)
    if not topBar then return end
    local panel = topBar.skills[id]
    panel = panel or topBar.Experience
    if not panel then return end

    panel:setVisible(not panel:isVisible())
    settings[id] = panel:isVisible()
    setSkillsLayout()
end

function setSkillValue(id, value)
    if not topBar then return end
    local panel = topBar.skills[id]
    if not panel then return end

    panel.level:setText(value)
    panel.level:setTextAutoResize(true)
end

function setSkillPercent(id, percent, tooltip)
    if not topBar then return end
    local panel = topBar.skills[id]
    if not panel then return end

    panel.progress:setPercent(math.floor(percent))
end

function setSkillBase(id, value, baseValue)
    if not topBar then return end
    local panel = topBar.skills[id]
    if not panel then return end

    local progress = topBar.skills[id].progress
    local progressDesc = "You have " .. 100 - math.floor(progress:getPercent()) .. " percent to go"
    local level = topBar.skills[id].level

    if baseValue <= 0 or value < 0 then return end

    if value > baseValue then
        level:setColor('#008b00') -- green
        progress:setTooltip(value .. " = " .. baseValue .. ' + ' ..
                                (value - baseValue) .. "\n" .. progressDesc)
    elseif value < baseValue then
        level:setColor('#b22222') -- red
        progress:setTooltip(baseValue .. ' ' .. (value - baseValue))
    else
        level:setColor('#bbbbbb') -- default
        progress:removeTooltip()
    end

end

function onMagicLevelChange(localPlayer, magiclevel, percent)
    setSkillValue('Magic', magiclevel)
    setSkillPercent('Magic', percent)

    onBaseMagicLevelChange(localPlayer, localPlayer:getBaseMagicLevel())
end

function onBaseMagicLevelChange(localPlayer, baseMagicLevel)
    setSkillBase('Magic', localPlayer:getMagicLevel(), baseMagicLevel)
end

function onSkillChange(localPlayer, id, level, percent)
    id = id + 1
    local t = {
        "Fist", "Club", "Sword", "Axe", "Distance", "Shielding", "Fishing"
    }

    -- imbues, ignore
    if id > #t then return end

    setSkillValue(t[id], level)
    setSkillPercent(t[id], percent)

    setSkillBase(t[id], level, localPlayer:getSkillBaseLevel(id - 1))
end

function onBaseSkillChange(localPlayer, id, baseLevel)
    id = id + 1
    local t = {
        "Fist", "Club", "Sword", "Axe", "Distance", "Shielding", "Fishing"
    }

    -- imbues, ignore
    if id > #t then return end

    setSkillBase(id, localPlayer:getSkillLevel(id), baseLevel)
end

function save()
    local settingsFile = modules.client_profiles.getSettingsFilePath("topbar.json")

    local status, result = pcall(function() return json.encode(settings, 2) end)
    if not status then
        return onError(
                   "Error while saving top bar settings. Data won't be saved. Details: " ..
                       result)
    end

    if result:len() > 100 * 1024 * 1024 then
        return onError(
                   "Something went wrong, file is above 100MB, won't be saved")
    end

    g_resources.writeFileContents(settingsFile, result)
end

function load()
    local settingsFile = modules.client_profiles.getSettingsFilePath("topbar.json")

    if g_resources.fileExists(settingsFile) then
        local status, result = pcall(function()
            return json.decode(g_resources.readFileContents(settingsFile))
        end)
        if not status then
            return onError(
                       "Error while reading top bar settings file. To fix this problem you can delete storage.json. Details: " ..
                           result)
        end
        settings = result
    else
        settings = {}
    end
end
