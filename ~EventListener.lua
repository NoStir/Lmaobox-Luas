-- Registers the callback for handling game events
callbacks.Register("FireGameEvent", function(event)
    local eventname = event:GetName()
    print(eventname)
    end)
