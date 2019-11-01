local context = G.botContext
local Panels = context.Panels


Panels.Looting = function(parent)
  context.setupUI([[
Panel
  id: looting
  height: 150
  
  BotLabel
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text: Looting
  
]], parent)

end

