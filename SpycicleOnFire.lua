local function IsSpycicleEquipped()
    local player = entities.GetLocalPlayer()
    if not player then return false end

    local meleeWeapon = player:GetEntityForLoadoutSlot(LOADOUT_POSITION_MELEE)
    if not meleeWeapon then return false end

    local itemDefinitionIndex = meleeWeapon:GetPropInt("m_iItemDefinitionIndex")
    local itemDefinition = itemschema.GetItemDefinitionByID(itemDefinitionIndex)
    local spyCicleDef = itemschema.GetItemDefinitionByName("The Spy-cicle")

    return itemDefinition and spyCicleDef and itemDefinition:GetIndex() == spyCicleDef:GetIndex()
end

local function CheckAndSwitchToSpycicle()
    local player = entities.GetLocalPlayer()
    if not player or player:GetPropInt("m_iClass") ~= TF2_Spy then return end

    if IsSpycicleEquipped() and player:InCond(TFCond_OnFire) then
        client.Command("slot3", true)
    end
end

callbacks.Register("FireGameEvent", function(event)
    if event:GetName() == "player_ignited" then
        local victimIndex = event:GetInt("victim_entindex")
        local localPlayerIndex = entities.GetLocalPlayer() and entities.GetLocalPlayer():GetIndex() or -1

        if victimIndex == localPlayerIndex then
            CheckAndSwitchToSpycicle()
        end
    end
end)
