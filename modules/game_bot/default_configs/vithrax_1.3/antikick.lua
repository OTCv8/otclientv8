local lastMove = now
onPlayerPositionChange(function(newPos, oldPos)
    if now - lastMove > 13*60*1000 then
        turn(math.random(0,3))
        lastMove = now
    end
end)