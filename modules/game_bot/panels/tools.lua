local context = G.botContext
local Panels = context.Panels

Panels.TradeMessage = function(parent)
  context.macro(60000, "Send message on trade", nil, function()
    local trade = context.getChannelId("advertising")
    if not trade then
      trade = context.getChannelId("trade")
    end
    if context.storage.autoTradeMessage:len() > 0 and trade then    
      context.sayChannel(trade, context.storage.autoTradeMessage)
    end
  end, parent)
  context.addTextEdit("autoTradeMessage", context.storage.autoTradeMessage or "I'm using OTClientV8 - https://github.com/OTCv8/otclientv8", function(widget, text)    
    context.storage.autoTradeMessage = text
  end, parent)
end