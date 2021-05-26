-- load all otui files, order doesn't matter
local configName = modules.game_bot.contentsPanel.config:getCurrentOption().text

local configFiles = g_resources.listDirectoryFiles("/bot/" .. configName .."/vBot/", true, false)  
for i, file in ipairs(configFiles) do
  local ext = file:split(".")
  if ext[#ext]:lower() == "ui" or ext[#ext]:lower() == "otui" then
    g_ui.importStyle(file)
  end
end

local function loadScript(name)
    return dofile("/vBot/" .. name .. ".lua")
end

-- here you can set manually order of scripts
-- libraries should be loaded first
local luaFiles = {
    "main", 
    "vlib", 
    "new_cavebot_lib",
    "configs", -- do not change this and above
    "extras",
    "playerlist",
    "BotServer",
    "alarms",
    "Conditions",
    "pushmax",
    "combo",
    "HealBot",
    "Sio",
    "AttackBot", -- last of major modules
    "ingame_editor",
    "items_management",
    "quiver_manager",
    "tools",
    "antiRs",
    "cavebot",
    "depot_withdraw",
    "eat_food",
    "equip",
    "exeta",
    "info",
    "items",
    "jewellery_equipper",
    "spy_level",
    "supplies"
}

for i, file in ipairs(luaFiles) do
    loadScript(file)
end

setDefaultTab("Main")
UI.Separator()
UI.Label("Private Scripts:")
UI.Separator()