# TempEntity

*Source: https://lmaobox.net/lua/Lua_Classes/TempEntity/*

---



# TempEntity


Represents a temporary entity. Temporary entities are not like regular Entities, they only exist for a split moment to transfer some information, create an effect, or perform some action. Their effects can often outlive the temporary entity itself.
They can hold useful data from the server and can be modified.


## Methods


### GetNetworkName()


Returns the network name of the TempEntity


### Release()


Releases the temporary entity - Do not call this for entities you did not create. Only call this if you created this TempEntity to avoid crashes.


### PostDataUpdate( dataUpdateType:integer)


Triggers the temporary entity. For effects in spawns an effect, like an explosion, for others it will do whatever the TempEntity is programmed to perform.


## Netvars/props


You can either input just the netvar name, or the table path to it


### GetPropFloat( propName, ... )


Returns the float value of the given netvar


### GetPropInt( propName, ... )


Returns the int value of the given netvar


### GetPropBool( propName, ... )


Returns the bool value of the given netvar


### GetPropString( propName, ... )


Returns the string value of the given netvar


### GetPropVector( propName, ... )


Returns the vector value of the given netvar


### GetPropEntity( propName, ... )


For entity handle props (m_hXXXXX)


### SetPropFloat( value:number, propName, ... )


Sets the float value of the given netvar.


### SetPropInt( value:integer, propName, ... )


Sets the int value of the given netvar.


### SetPropBool( value:bool, propName, ... )


Sets the bool value of the given netvar.


### SetPropEntity( value:Entity, propName, ... )


Set the entity value of the given netvar.


### SetPropVector( value:Vector3, propName, ... )


Set the vector value of the given netvar.


## Prop Data Tables


They return a Lua Table containing the entries, you can index them with integers


### GetPropDataTableFloat( propName, ... )


Returns a table of floats, index them with integers based on context of the netvar


### GetPropDataTableBool( propName, ... )


Returns a table of bools, index them with integers based on context of the netvar


### GetPropDataTableInt( propName, ... )


Returns a table of ints, index them with integers based on context of the netvar


### GetPropDataTableEntity( propName, ... )


Returns a table of entities, index them with integers based on context of the netvar


### SetPropDataTableFloat( value:number, index:integer, propName, ... )


Sets the number value of the given netvar at the given index.


### SetPropDataTableBool( value:integer, index:integer, propName, ... )


Sets the bool value of the given netvar at the given index.


### SetPropDataTableInt( value:integer, index:integer, propName, ... )


Sets the integer value of the given netvar at the given index.


### SetPropDataTableEntity( value:Entity, index:integer, propName, ... )


Sets the Entity value of the given netvar at the given index.


## Examples


Modify a temp entity netvar
```
callbacks.Register("ProcessTempEntities", function (entEvtTable)

    for ent, eventInfo in pairs(entEvtTable) do
        if ent:GetNetworkName() == "CTETFParticleEffect" then
            local m_iParticleSystemIndex = ent:GetPropInt("m_iParticleSystemIndex")
            m_iParticleSystemIndex = m_iParticleSystemIndex - 1
            ent:SetPropInt(m_iParticleSystemIndex, "m_iParticleSystemIndex")
        end
    end
end)

```


