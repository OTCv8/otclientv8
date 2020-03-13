local context = G.botContext
if type(context.UI) ~= "table" then
  context.UI = {}
end
local UI = context.UI

UI.createWidget = function(name, parent)
  if parent == nil then      
    parent = context.panel
  end
  return g_ui.createWidget(name, parent)
end
