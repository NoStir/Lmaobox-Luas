local materialList = {}
--[[materials.Enumerate( function( mat )
    local group, name = mat:GetTextureGroupName(), mat:GetName()
    if not materialList[group] then
        materialList[group] = {}
    end
    table.insert( materialList[group], name )

    --[[if string.find( group, 'Model' ) then
        if string.find( name, 'door_slide' ) then
            mat:SetMaterialVarFlag( MATERIAL_VAR_WIREFRAME, false )
        end
        -- mat:AlphaModulate( 1 );
        -- mat:ColorModulate( 158, 193, 207 )
        -- mat:SetMaterialVarFlag( MATERIAL_VAR_IGNOREZ, false )
    end--]]


    --[[if string.find( group, 'SkyBox' ) then
        mat:ColorModulate( 0, 0, 0 )
        -- netprop m_skybox3d : You can do it easier by setting m_skybox3d.area which is a netvar to 255
    end
end )--]]

local doors = {
    'door_slide',
    'main_entrance_door',
    'door',
}
materials.Enumerate( function(mat) 
    for i, name in ipairs(doors) do
        if string.find( mat:GetName(), name ) then
            mat:SetMaterialVarFlag( MATERIAL_VAR_SELFILLUM, true )
        end
    end
end)

callbacks.Register( 'SendStringCmd', function( cmd )
    local i, j = cmd:Get():find( 'mat' )
    if i == 1 and j == #cmd:Get() then
        cmd:Set( '' )
    end
end )