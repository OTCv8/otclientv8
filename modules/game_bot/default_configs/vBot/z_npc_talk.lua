macro(50, function()
    if not g_game.isAttacking() then return end

    if target() and target():isNpc() then
        NPC.say("hi")
        NPC.say("trade")
    end
    delay(950)

end)