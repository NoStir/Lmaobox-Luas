local function main()
    local me = entities.GetLocalPlayer()
    if not me then return end

    local groundEntity = me:GetPropEntity("m_hGroundEntity")
    local onEnemy = groundEntity and groundEntity:IsPlayer() and groundEntity:GetTeamNumber() ~= me:GetTeamNumber()

    if onEnemy and not me:InCond(44) then
        local wep = me:GetPropEntity("m_hActiveWeapon")
        if wep and wep:GetPropInt("m_iItemDefinitionIndex") == 594 then
            local rage = tostring(me:GetPropFloat("m_flRageMeter"))
            return rage, onEnemy
        end
    end
    return nil, nil
end

local rage, onEnemy = nil, nil

callbacks.Register("Draw", "PhlogPDA", function()
    rage, onEnemy = main()
end)

callbacks.Register("CreateMove", "PhlogAttack", function(cmd)
    if onEnemy and rage == "100.0" then
        cmd:SetButtons(cmd:GetButtons() | IN_ATTACK2)
    end
end)
