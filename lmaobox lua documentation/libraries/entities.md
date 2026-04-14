# entities

*Source: https://lmaobox.net/lua/Lua_Libraries/entities/*

---



# entities


The entities library provides a way to find entities by their name, or by their class.


## Functions


### FindByClass( className:string )


Find and put into table all entities with given class name


### GetLocalPlayer()


Return local player entity


### GetByIndex( index:integer )


Return entity by index


### GetHighestEntityIndex()


Return highest entity index


### GetByUserID( userID:integer )


Return entity by user id


### GetPlayerResources()


Return player resources entity


### CreateEntityByName( className:string )


Creates a non-networkable entity by class name, returns entity. Keep in mind that YOU are responsible for its entire lifecycle and for releasing the entity later by calling [entity.Release](../../Lua_Classes/Entity/#Release). 


### CreateTempEntityByName( className:string )


Creates a non-networkable temporary entity of type [TempEntity](../../Lua_Classes/TempEntity/). You are responsible for calling [tempentity.Release](../../Lua_Classes/TempEntity/#Release) when you are done with the entity. To trigger the entity, call PostDataUpdate.


## Examples


What is my name?
```
local me = entities.GetLocalPlayer()
local name = me:GetName()
print( name )

```

Find all players
```
local players = entities.FindByClass("CTFPlayer")

for i, player in ipairs(players) do
    print( player:GetName() )
end

```

Find all entities in the game
```
for i = 1, entities.GetHighestEntityIndex() do -- index 1 is world entity
    local entity = entities.GetByIndex( i )
    if entity then
        print( i, entity:GetClass() )
    end
end

```


