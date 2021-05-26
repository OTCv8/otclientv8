setDefaultTab("Tools")
local m = macro(1000, "AntiRS & Msg", function() end)

local frags = 0
onTextMessage(function(mode, text)
    if not m.isOn() then return end
    if not text:lower():find("warning! the murder of") then return end
    info(text)
    say("Don't bother, I have anti-rs and shit EQ. Don't waste our time.")
    frags = frags + 1
    if killsToRs() < 6 or frags > 1 then
        modules.game_interface.forceExit()
    end
end)