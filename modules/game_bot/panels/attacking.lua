local context = G.botContext
local Panels = context.Panels

Panels.Attacking = function(parent)
  context.setupUI([[
Panel
  id: attacking
  height: 150
  
  BotLabel
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text: Attacking
  
]], parent)

end

