# itemschema

*Source: https://lmaobox.net/lua/Lua_Libraries/itemschema/*

---



# itemschema


The `itemschema` library contains functions for retrieving information about items.
Items referred to in this library are of the `ItemDefinition` type.


## Functions


### GetItemDefinitionByID( id:integer )


Returns the item definition for the item with the given ID.


### GetItemDefinitionByName( name:string )


Returns the item definition for the item with the given name.


### Enumerate( callback:function(itemDefinition) )


Enumerates all item definitions, calling the callback for each one.


### GetAttributeDefinitionByName( name:string )


Returns the attribute definition for the item with the given name.


### EnumerateAttributes( callback:function(attributeDefinition) )


Enumerates all attribute definitions, calling the callback for each one.


## Examples


Get player's weapon name
```
local activeWeapon = entities.GetLocalPlayer():GetPropEntity("m_hActiveWeapon")
local wpnId = activeWeapon:GetPropInt("m_iItemDefinitionIndex")
if wpnId ~= nil then
    local wpnName = itemschema.GetItemDefinitionByID(wpnId):GetName()
    draw.TextShadow(screenPos[1], screenPos[2], wpnName)
end

```

Find all hats and cosmetics
```
local function forEveryItem( itemDefinition )
    if itemDefinition:IsWearable() then
        print( "Found: " .. itemDefinition:GetName() )
    end
end

itemschema.Enumerate( forEveryItem )

```


