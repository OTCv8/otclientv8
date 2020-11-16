if player:getBlessings() == 0 then
    say("!bless")
    schedule(2000, function() 
        if player:getBlessings() == 0 then
            error("!! Blessings not bought !!")
        end
    end)
end
