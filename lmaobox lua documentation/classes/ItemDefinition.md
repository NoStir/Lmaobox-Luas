# ItemDefinition

*Source: https://lmaobox.net/lua/Lua_Classes/ItemDefinition/*

---



# ItemDefinition


The ItemDefinition object contains static information about an item. Static information refers to information that is not changed during the course of the game.


## Methods


### GetName()


Returns the name of the item.


### GetID()


Returns the definition ID of the item.


### GetClass()


Returns the class of the item.


### GetLoadoutSlot()


Returns the loadout slot that the item should be placed in.


### IsHidden()


Returns true if the item is hidden.


### IsTool()


Returns true if the item is a tool, such as a key.


### IsBaseItem()


Returns true if the item is a base item, such as a stock weapon.


### IsWearable()


Returns true if the item is a wearable.


### GetNameTranslated()


Returns the name of the item in the language of the current player.


### GetTypeName()


Returns the type name of the item.


### GetDescription()


Returns the description of the item.


### GetIconName()


Returns the icon name of the item.


### GetBaseItemName()


Returns the base item name of the item.


### GetAttributes()


Returns the static item attributes as a table where keys are [AttributeDefinition](../AttributeDefinition) objects and values are the values of the attributes.


## Examples


Get the name of active weapon
```
local me = entities.GetLocalPlayer()
local activeWeapon = me:GetPropEntity( "m_hActiveWeapon" )

if activeWeapon ~= nil then
    local itemDefinitionIndex = activeWeapon:GetPropInt( "m_iItemDefinitionIndex" )
    local itemDefinition = itemschema.GetItemDefinitionByID( itemDefinitionIndex )
    local weaponName = itemDefinition:GetName()
    print( weaponName )
end

```

Print all static active weapon attributes
```
local me = entities.GetLocalPlayer()
local activeWeapon = me:GetPropEntity( "m_hActiveWeapon" )
local itemDef = itemschema.GetItemDefinitionByID( activeWeapon:GetPropInt( "m_iItemDefinitionIndex" ) )
local attributes = itemDef:GetAttributes()

for attrDef, value in pairs( attributes ) do
    print( attrDef:GetName() .. ": " .. tostring( value ) )
end

```


