if player:getBlessings() == 0 then
    say("!bless")
    schedule(2000, function() 
        if player:getBlessings() == 0 then
            warn("!! Blessings not bought !!")
        end
    end)
end
