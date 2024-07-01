local wasOnFire = false

callbacks.Register("CreateMove", "handleWeaponSwitch", function()
    local player = entities.GetLocalPlayer()
    if not player then return end

    local onFire = player:InCond(TFCond_OnFire)
    local meleeWeapon = player:GetEntityForLoadoutSlot(LOADOUT_POSITION_MELEE)

    if meleeWeapon and itemschema.GetItemDefinitionByID(meleeWeapon:GetPropInt("m_iItemDefinitionIndex")):GetName() == "The Spy-cicle" then
        if onFire and not wasOnFire then
            client.Command("slot3", true)
            wasOnFire = true
        elseif not onFire and wasOnFire then
            client.Command("slot1", true)
            wasOnFire = false
        end
    end
end)
