Test = {
    tests = {},
    activeTest = 0,
    screenShot = 1    
}

Test.Test = function(name, func)
    local testId = #Test.tests + 1
    Test.tests[testId] = {
        name = name,
        actions = {},
        delay = 0,
        start = 0
    }
    local test = function(testFunc)
        table.insert(Test.tests[testId].actions, {type = "test", value = testFunc})
    end
    local wait = function(millis)
        Test.tests[testId].delay = Test.tests[testId].delay + millis
        table.insert(Test.tests[testId].actions, {type = "wait", value = Test.tests[testId].delay})
    end
    local ss = function()
        table.insert(Test.tests[testId].actions, {type = "screenshot"})
    end
    local fail = function(message)
        g_logger.fatal("Test " .. name .. " failed: " .. message)
    end
    func(test, wait, ss, fail)
end

Test.run = function()
    if Test.activeTest > #Test.tests then
        g_logger.info("[TEST] Finished tests. Exiting...")
        return g_app.exit()
    end
    local test = Test.tests[Test.activeTest]
    if not test or #test.actions == 0 then
        Test.activeTest = Test.activeTest + 1
        local nextTest = Test.tests[Test.activeTest]
        if nextTest then
            nextTest.start = g_clock.millis()
            g_logger.info("[TEST] Starting test: " .. nextTest.name)
        end
        return scheduleEvent(Test.run, 500)
    end

    local action = test.actions[1]
    if action.type == "test" then
        table.remove(test.actions, 1)        
        action.value()
    elseif action.type == "screenshot" then
        table.remove(test.actions, 1)        
        g_app.doScreenshot(Test.screenShot .. ".png")
        Test.screenShot = Test.screenShot + 1
    elseif action.type == "wait" then
        if action.value + test.start < g_clock.millis() then
            table.remove(test.actions, 1)        
        end
    end

    scheduleEvent(Test.run, 100)
end
