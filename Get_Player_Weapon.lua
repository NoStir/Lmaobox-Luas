local me = entities.GetLocalPlayer()
local activeWeapon = me:GetPropEntity( "m_hActiveWeapon" )
local wClass = activeWeapon:GetClass()

if activeWeapon ~= nil then
    local itemDefinitionIndex = activeWeapon:GetPropInt( "m_iItemDefinitionIndex" )
    local itemDefinition = itemschema.GetItemDefinitionByID( itemDefinitionIndex )
    local weaponName = itemDefinition:GetName()
    print( weaponName )
    print( wClass )
end