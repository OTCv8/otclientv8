local version = "4.4"
local currentVersion
local hashcode
local available = false

storage.checkVersion = storage.checkVersion or 0

-- check max once per 12hours
if os.time() > storage.checkVersion + (12 * 60 * 60) then

    storage.checkVersion = os.time()
    
    HTTP.get("https://raw.githubusercontent.com/Vithrax/vBot/main/vBot/version.txt", function(data, err)
        if err then
          warn("[vBot updater]: Unable to check version:\n" .. err)
          return
        end

        local t = string.split(data, ",")
        currentVersion = t[1]:trim()
        hashcode = t[2]:trim()
        available = true
    end)

end

UI.Label("vBot v".. version .." \n Vithrax#5814")
UI.Button("Official OTCv8 Discord!", function() g_platform.openUrl("https://discord.gg/yhqBE4A") end)
UI.Separator()

schedule(5000, function()
    if not available then return end
    if currentVersion ~= version then
        
        UI.Separator()
        local label = UI.Label("New vBot is available for download! v"..currentVersion)
        label:setColor()
        UI.Button("Get Hash Code", function() 
            g_window.setClipboardText(hashcode)
            info("Hashcode copied to clipboard!")
        end)
        UI.Button("Go to vBot GitHub Page", function() g_platform.openUrl("https://github.com/Vithrax/vBot") end)
        UI.Separator()
    end

end)