local entities = entities
local callbacks = callbacks
local input = input
local vector = vector

local cachedSentry = nil
local isMouse5Down = false

local function aimAt(cmd, me, targetPos)
    local eyePosition = me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]")
    local direction = vector.Subtract(targetPos, eyePosition)
    direction:Normalize()
    local newAngles = direction:Angles()
    newAngles:Normalize()
    cmd.viewangles = newAngles
end

local function on_create_move(cmd)
    
    if input.IsButtonDown(MOUSE_5) then
        
        if not isMouse5Down then
            isMouse5Down = true

            cachedSentry = nil

            local localPlayer = entities.GetLocalPlayer()
            if localPlayer and localPlayer:IsValid() then
                for i = 1, entities.GetHighestEntityIndex() do
                    local entity = entities.GetByIndex(i)
                    if entity and entity:IsValid() and entity:GetClass() == "CObjectSentrygun" then
                        local builder = entity:GetPropEntity("m_hBuilder")
                        if builder and builder:IsValid() and builder == localPlayer then
                            cachedSentry = entity
                            break
                        end
                    end
                end
            end
        end

       
        local localPlayer = entities.GetLocalPlayer()
        if not localPlayer or not localPlayer:IsValid() or not localPlayer:IsAlive() then return end
        if localPlayer:GetPropInt("m_PlayerClass", "m_iClass") ~= E_Character.TF2_Engineer then return end
        
        local activeWeapon = localPlayer:GetPropEntity("m_hActiveWeapon")
        if not activeWeapon or not activeWeapon:IsValid() or activeWeapon:GetPropInt("m_iItemDefinitionIndex") ~= 140 then return end

        if not cachedSentry or not cachedSentry:IsValid() or cachedSentry:GetPropInt("m_bBuilding") == 1 then return end

        local playerPos = localPlayer:GetAbsOrigin()
        local sentryPos = cachedSentry:GetAbsOrigin()
        
        local awayDirection = vector.Subtract(playerPos, sentryPos)
        awayDirection.z = awayDirection.z + 2
        awayDirection:Normalize()

        local aimTarget = vector.Add(playerPos, vector.Multiply(awayDirection, 2000))
        
        aimAt(cmd, localPlayer, aimTarget)
    
        cmd.buttons = cmd.buttons | IN_ATTACK

        if (localPlayer:GetPropInt("m_fFlags") & FL_ONGROUND) == 0 then
            cmd.buttons = cmd.buttons | IN_DUCK
        end

    else
        if isMouse5Down then
            isMouse5Down = false
            cachedSentry = nil
        end
    end
end

callbacks.Register("CreateMove", "MySentryJumpLogic", on_create_move)