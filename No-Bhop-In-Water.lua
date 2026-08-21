local function NoWaterHop()
    local me = entities.GetLocalPlayer()
    if not me then return end

    local flags = me:GetPropInt("m_fFlags")
    
    client.ChatPrintf(flags .. " | " .. tostring(flags))
end

callbacks.Register("Draw", "nowaterhop", NoWaterHop)