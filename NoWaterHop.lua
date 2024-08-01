local FL_INWATER = 1 << 10

local function NoWaterHop()
    local me = entities.GetLocalPlayer()
    if not me then return end

    local flags = me:GetPropInt("m_fFlags")
    
    if (flags & FL_INWATER == FL_INWATER) then
        gui.SetValue("Bunny Hop", 0)
    else
        gui.SetValue("Bunny Hop", 1)
    end
end

callbacks.Register("Draw", "nowaterhop", NoWaterHop)