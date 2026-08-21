local teleporterPos
local closestDistance
local pdaOpen = false
local me

local function ComputeMove(userCmd, a, b)
    local diff = b - a
    if diff:Length() == 0 then 
        return Vector3(0, 0, 0) 
    end

    local x = diff.x
    local y = diff.y
    local vSilent = Vector3(x, y, 0)

    local ang = vSilent:Angles()
    local cPitch, cYaw, cRoll = userCmd:GetViewAngles()
    local yaw = math.rad(ang.y - cYaw)
    local pitch = math.rad(ang.x - cPitch)
    local move = Vector3(math.cos(yaw) * 450, -math.sin(yaw) * 450, -math.cos(pitch) * 450)

    return move
end

local function WalkTo(userCmd, localPlayer, destination)
    local localPos = localPlayer:GetAbsOrigin() 
    local result = ComputeMove(userCmd, localPos, destination)

    userCmd:SetForwardMove(result.x)
    userCmd:SetSideMove(result.y)
end

local function CalculateDistance(vec1, vec2)
    local diff = vec2 - vec1
    return diff:Length()
end

-- Main function
local function WalkToTeleporter(userCmd)
    me = entities.GetLocalPlayer()
    if not me then 
        print("Local player not found.")
        return 
    end
    
    local className = "CObjectTeleporter"
    local highestIndex = entities.GetHighestEntityIndex()
    local teleporters = {}

    for i = 0, highestIndex do
        local entity = entities.GetByIndex(i)
        if entity and entity:GetClass() == className then
            if entity:GetPropBool("m_flYawToExit") then
                table.insert(teleporters, entity)
            end
        end
    end
    
    if #teleporters > 0 then
        local closest = nil
        closestDistance = math.huge
        for _, teleporter in ipairs(teleporters) do
            teleporterPos = teleporter:GetAbsOrigin()
            local distance = CalculateDistance(me:GetAbsOrigin(), teleporterPos)
            
            local flYawToExit = tostring(teleporter:GetPropBool("m_flYawToExit"))
            local t_iState = teleporter:GetPropInt("m_iState")
            local t_iTeamNum = teleporter:GetPropInt("m_iTeamNum")

            if distance < closestDistance then
                closest = teleporter
                closestDistance = distance
            end
        end

        local source = me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]")
        local destination = closest:GetAbsOrigin()
        trace = engine.TraceLine(source, destination, MASK_SHOT_HULL)

        local tolerance = 20.0

        if closest and not me:InCond(6) and trace.fraction == 1 then
            if closestDistance > tolerance then
                WalkTo(userCmd, me, closest:GetAbsOrigin())
            elseif closestDistance <= tolerance then
                if not pdaOpen and shouldOpenPDA then
                client.Command("cyoa_pda_open", true)
                pdaOpen = true
                end
            else if pdaOpen and not shouldOpenPDA then
                    client.Command("cyoa_pda_open", false)
                    pdaOpen = false
                end
                userCmd:SetForwardMove(0)
                userCmd:SetSideMove(0)
            end
            return
        end
    end
end

callbacks.Register("CreateMove", WalkToTeleporter)

draw.SetFont(draw.CreateFont("Tahoma", 16, 800))
callbacks.Register("Draw", function()
    if not me then
        me = entities.GetLocalPlayer()
    end
    if closestDistance then
        draw.Color(255, 255, 255, 255)
        draw.Text(50, 50, "Closest teleporter distance: " .. closestDistance)
    end
    local playerPos = me:GetAbsOrigin()
    local traceEndPos = playerPos - Vector3(0, 0, 1)
    local trace = engine.TraceHull(playerPos, traceEndPos, Vector3(-16, -16, -16), Vector3(16, 16, 16), MASK_ALL)
    if trace.entity and (trace.entity:GetClass() == "CObjectTeleporter") then
        shouldOpenPDA = true
    else
        shouldOpenPDA = false
    end

end)