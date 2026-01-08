local key = KEY_J


local tauntTimer = nil

local function OnUserCmd(userCmd)
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer then return end

    if not localPlayer:IsAlive()
        or engine.IsGameUIVisible()
        then return end

    local pClass = localPlayer:GetPropInt("m_iClass")
    if pClass == nil or pClass ~= TF2_Heavy then
        return
    end

    if input.IsButtonDown(key) then
        if tauntTimer == nil then
            tauntTimer = globals.RealTime() + 0.5
        end

        local weapon = localPlayer:GetPropEntity("m_hActiveWeapon")
        if weapon and (weapon:IsShootingWeapon() or weapon:IsMeleeWeapon()) then
            return
        end

        userCmd:SetButtons(userCmd:GetButtons() | IN_ATTACK)

        if globals.RealTime() >= tauntTimer then
            client.Command("taunt", true)
            tauntTimer = nil
        end
    else
        tauntTimer = nil
    end
end

callbacks.Unregister("CreateMove", "heavy_is_fat")
callbacks.Register("CreateMove", "heavy_is_fat", OnUserCmd)