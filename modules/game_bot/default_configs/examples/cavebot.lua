local caveTab = addTab("Cave")

local waypoints = Panels.Waypoints(caveTab)
local attacking = Panels.Attacking(caveTab)
local looting = Panels.Looting(caveTab) 
addButton("tutorial", "Help & Tutorials", function()
  g_platform.openUrl("https://github.com/OTCv8/otclientv8_bot")
end, caveTab)
