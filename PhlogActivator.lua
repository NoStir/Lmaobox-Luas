local player = entities.GetLocalPlayer()
if not player then return end

local onEnemy = false
local commandSent = false
local rage, wep

function main()
    if not player:IsValid() then player = entities.GetLocalPlayer() end

    local playerPos = player:GetAbsOrigin()
    local traceEndPos = playerPos - Vector3(0, 0, 1)

    local trace = engine.TraceHull(playerPos, traceEndPos, Vector3(-16, -16, -16), Vector3(16, 16, 16), MASK_ALL, function(ent)
        return ent:IsPlayer()
    end)

    if trace.entity and trace.entity:IsPlayer() and trace.entity:GetTeamNumber() ~= player:GetTeamNumber() then
        if not onEnemy then
            wep = player:GetPropEntity("m_hActiveWeapon")
            if wep ~= nil then
                local itemDefinitionIndex = wep:GetPropInt("m_iItemDefinitionIndex")
                if itemDefinitionIndex ~= 594 then
                    return
                end
            end
            rage = tostring(player:GetPropFloat("m_flRageMeter"))
            onEnemy = true
            commandSent = false
        end
    else
        onEnemy = false
        commandSent = false
    end

    if onEnemy and not commandSent then
        client.Command("cyoa_pda_open", "0")
        commandSent = true
    end
end

callbacks.Register("Draw", "PhlogPDA", main)

callbacks.Register("CreateMove", function(cmd)
    if onEnemy and rage == "100.0" then
        cmd:SetButtons(cmd.buttons | IN_ATTACK2)
    end
end)
