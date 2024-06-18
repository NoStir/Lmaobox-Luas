local function NoWaterHop()
    local me = entities.GetLocalPlayer()
    if not me then return end

    local flags = me:GetPropInt("m_fFlags")
    
    if flags == 1280 or flags == 1281 then
        gui.SetValue("Bunny Hop", 0)
    else
        gui.SetValue("Bunny Hop", 1)
    end
end

callbacks.Register("Draw", "nowaterhop", NoWaterHop)