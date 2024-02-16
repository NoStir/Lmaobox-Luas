callbacks.Register("FireGameEvent", function(event)
    if event:GetName() == "player_ignited" then
        local player = entities.GetLocalPlayer()
        if event:GetInt("victim_entindex") == client.GetLocalPlayerIndex() then
            local meleeWeapon = player:GetEntityForLoadoutSlot(LOADOUT_POSITION_MELEE)
            if meleeWeapon and itemschema.GetItemDefinitionByID(meleeWeapon:GetPropInt("m_iItemDefinitionIndex")):GetName() == "The Spy-cicle" and player:InCond(TFCond_OnFire) then
                client.Command("slot3", true)
            end end end end)
