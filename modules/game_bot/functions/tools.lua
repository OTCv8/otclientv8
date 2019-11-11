local context = G.botContext

context.encode = function(data) return json.encode(data) end
context.decode = function(text) local status, result = pcall(function() return json.decode(text) end) if status then return result end return {} end

context.displayGeneralBox = function(title, message, buttons, onEnterCallback, onEscapeCallback)
  local box = displayGeneralBox(title, message, buttons, onEnterCallback, onEscapeCallback)
  box.botWidget = true
  return box
end