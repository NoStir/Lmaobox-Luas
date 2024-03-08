-- Global variables to maintain the state across frames
local shouldShoot = false
local shootStartTick = 0

-- Main function for triggerbot
local function TriggerBot(cmd)
    local localPlayer = entities.GetLocalPlayer()
    local triggerKey = gui.GetValue("trigger shoot key")
    if not input.IsButtonDown(triggerKey) then -- Stop shooting if the specific button is not down
        shouldShoot = false
        return
    end
    if not localPlayer or not localPlayer:IsAlive() then
        shouldShoot = false
        return
    end

    local weapon = localPlayer:GetPropEntity("m_hActiveWeapon")
    if not weapon then
        shouldShoot = false
        return
    end
    if not CanShoot(localPlayer, weapon) then -- Adjusted to pass localPlayer
        shouldShoot = false
        return
    end

    local viewOffset = localPlayer:GetPropVector("localdata", "m_vecViewOffset[0]")
    local source = localPlayer:GetAbsOrigin() + viewOffset
    local forward = engine.GetViewAngles():Forward()
    local destination = source + forward * 8192

    local trace = engine.TraceLine(source, destination, MASK_ALL)

    if trace.entity ~= nil and trace.entity:IsPlayer() and trace.hitbox ~= nil then
        local hitPlayer = trace.entity
        if hitPlayer:GetTeamNumber() ~= localPlayer:GetTeamNumber() then
            if not shouldShoot then
                shouldShoot = true
                shootStartTick = globals.TickCount()
            end
            -- Shoot only if we have just detected an enemy or a short time has passed since we started
            if globals.TickCount() - shootStartTick < 2 then
                cmd.buttons = cmd.buttons | IN_ATTACK
            else
                shouldShoot = false -- Reset shooting state if time exceeded
            end
        else
            shouldShoot = false
        end
    else
        shouldShoot = false
        print("TriggerBot: No target.")
    end
end

-- Checks if the weapon can shoot
function CanShoot(localPlayer, weapon)
    if not localPlayer or weapon:IsMeleeWeapon() then return false end

    local nextPrimaryAttack = weapon:GetPropFloat("LocalActiveWeaponData", "m_flNextPrimaryAttack")
    local nextAttack = localPlayer:GetPropFloat("bcc_localdata", "m_flNextAttack")
    if (not nextPrimaryAttack) or (not nextAttack) then return false end

    return (nextPrimaryAttack <= globals.CurTime()) and (nextAttack <= globals.CurTime())
end

-- Register the triggerbot function to run every frame in the 'CreateMove' callback
callbacks.Register('CreateMove', 'TriggerBot', TriggerBot)
