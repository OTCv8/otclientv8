CaveBot.Extensions.Lure = {}

CaveBot.Extensions.Lure.setup = function()
  CaveBot.registerAction("lure", "#00FFFF", function(value, retries)
    if value == "start" then
        TargetBot.setOff()
        return true
    elseif value == "stop" then
        TargetBot.setOn()
        return true
    else
        warn("incorrect lure value!")
        return false
    end
  end)

  CaveBot.Editor.registerAction("lure", "lure", {
    value="start",
    title="Lure",
    description="start/stop",
    multiline=false,
})
end