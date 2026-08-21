local function GetAmmoCount()
    if not me or not me:IsValid() then return 0 end
    local ammoTable = me:GetPropDataTableInt("localdata", "m_iAmmo")
    return ammoTable and ammoTable[0] or 0
end

local function reloadAmmo()
    if not me or not me:IsValid() or not me:IsAlive() then
        me = entities.GetLocalPlayer()
        return
    end

    if GetAmmoCount() < 2 then
        client.Command("impulse 101", true)
    end
end
callbacks.Register("Draw", reloadAmmo)