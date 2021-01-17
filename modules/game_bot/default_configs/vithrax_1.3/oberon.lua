onTalk(function(name, level, mode, text, channelId, pos)
    if mode == 34 then
        if string.find(text, "world will suffer for") then
            say("Are you ever going to fight or do you prefer talking!")
        elseif string.find(text, "feet when they see me") then
            say("Even before they smell your breath?")
        elseif string.find(text, "from this plane") then
            say("Too bad you barely exist at all!") 
        elseif string.find(text, "ESDO LO") then
            say("SEHWO ASIMO, TOLIDO ESD") 
        elseif string.find(text, "will soon rule this world") then
            say("Excuse me but I still do not get the message!") 
        elseif string.find(text, "honourable and formidable") then
            say("Then why are we fighting alone right now?") 
        elseif string.find(text, "appear like a worm") then
            say("How appropriate, you look like something worms already got the better of!") 
        elseif string.find(text, "will be the end of mortal") then
            say("Then let me show you the concept of mortality before it!") 
        elseif string.find(text, "virtues of chivalry") then
            say("Dare strike up a Minnesang and you will receive your last accolade!") 
        end
    end
end)