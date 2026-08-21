callbacks.Register("FireGameEvent", "DeathSoundHook", function(event)
    if event:GetName() == "player_death" then
        local victimUserID = event:GetInt("userid")
        
        local me = entities.GetLocalPlayer()
        if not me then return end
        
        local myIndex = me:GetIndex()
        local pInfo = client.GetPlayerInfo(myIndex)
        local myUID = pInfo.UserID

        if victimUserID == myUID then
            local rand = engine.RandomInt(1, 5)
            engine.PlaySound("player/crit_death" .. rand .. ".wav")
        end
    end
end)