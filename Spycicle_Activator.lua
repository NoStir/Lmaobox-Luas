local function IsSpycicleEquipped()
    local player = entities.GetLocalPlayer()
    if not player then return false end

    local meleeWeapon = player:GetEntityForLoadoutSlot(LOADOUT_POSITION_MELEE)
    if not meleeWeapon then return false end

    local itemDefinitionIndex = meleeWeapon:GetPropInt("m_iItemDefinitionIndex")
    local itemDefinition = itemschema.GetItemDefinitionByID(itemDefinitionIndex)
    local spyCicleDef = itemschema.GetItemDefinitionByName("The Spy-cicle")

    return itemDefinition and spyCicleDef and itemDefinition:GetName() == spyCicleDef:GetName()
end

local wasOnFire = false

local function HandleWeaponSwitch()
    local player = entities.GetLocalPlayer()
    if not player then return end

    local onFire = player:InCond(TFCond_OnFire)

    if IsSpycicleEquipped() then
        if onFire and not wasOnFire then
            client.Command("slot3", true)
            wasOnFire = true
        elseif not onFire and wasOnFire then
            client.Command("slot1", true)
            wasOnFire = false
        end
    end
end

callbacks.Register("FireGameEvent", function(event)
    if event:GetName() == "player_ignited" then
        local victimIndex = event:GetInt("victim_entindex")
        local localPlayerIndex = entities.GetLocalPlayer() and entities.GetLocalPlayer():GetIndex() or -1

        if victimIndex == localPlayerIndex then
            HandleWeaponSwitch()
        end
    end
end)

callbacks.Register("CreateMove", function()
    HandleWeaponSwitch()
end)
