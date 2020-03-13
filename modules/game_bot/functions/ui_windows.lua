local context = G.botContext
if type(context.UI) ~= "table" then
  context.UI = {}
end
local UI = context.UI

UI.SinglelineEditorWindow = function(text, callback)
  return modules.game_textedit.singlelineEditor(text, callback)
end

UI.MultilineEditorWindow = function(description, test, callback)
  return modules.game_textedit.multilineEditor(description, test, callback)
end

UI.ConfirmationWindow = function(title, question, callback)
  local window = nil
  local onConfirm = function()
    window:destroy()
    callback()
  end
  local closeWindow = function()
    window:destroy()
  end
  window = context.displayGeneralBox(title, question, {
    { text=tr('Yes'), callback=onConfirm },
    { text=tr('No'), callback=closeWindow },
    anchor=AnchorHorizontalCenter}, onConfirm, closeWindow)
  window.botWidget = true
  return window
end