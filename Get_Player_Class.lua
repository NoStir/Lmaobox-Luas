local me = entities.GetLocalPlayer()
local pClass = me:GetPropInt( "m_iClass" )

if pClass ~= nil then
    client.ChatPrintf( pClass )
end