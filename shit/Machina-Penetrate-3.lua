local function DetectMultiHitShot()
    local numPlayersDetected = 0
    local me = entities.GetLocalPlayer()
    if not me then
        return
    end

    local source = me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]")
    local forwardVector = engine.GetViewAngles():Forward()
    local destination = source + forwardVector * 10000

    local trace = engine.TraceLine(source, destination, MASK_SHOT)
    if trace.entity and trace.entity:IsValid() and trace.entity:IsPlayer() then
        numPlayersDetected = numPlayersDetected + 1
        local previousEntity = trace.entity

        for i = 1, 4 do
            local nextTraceStart = trace.endpos + forwardVector * 10
            local nextTrace = engine.TraceLine(nextTraceStart, destination, MASK_SHOT, function(entity)
                return entity:IsPlayer() and entity:GetIndex() ~= previousEntity:GetIndex()
            end)

            if nextTrace.entity and nextTrace.entity:IsValid() and nextTrace.entity:IsPlayer() then
                numPlayersDetected = numPlayersDetected + 1
                previousEntity = nextTrace.entity
            end
        end
    end

    return numPlayersDetected
end

callbacks.Register("CreateMove", function(cmd)
    local me = entities.GetLocalPlayer()
    if not me then
        return
    end

    local weapon = me:GetPropEntity("m_hActiveWeapon")
    if not weapon then
        return
    end

    local chargedDamage = weapon:GetPropFloat("m_flChargedDamage")
    if chargedDamage and chargedDamage >= 150 then
        local numPlayersDetected = DetectMultiHitShot()
        if numPlayersDetected > 1 then
            cmd:SetButtons(cmd.buttons | IN_ATTACK)
        end
    end
end)