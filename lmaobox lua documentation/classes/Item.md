# Item

*Source: https://lmaobox.net/lua/Lua_Classes/Item/*

---



# Item


Represents an item in player's inventory.


## Methods


### IsValid()


Returns true if the item is valid. There are instances where an item in the inventory is not valid and you should account for them. Otherwise, methods will return nil.


### GetName()


Returns the name of the item. This is the name that is displayed in the inventory and can be custom.


### GetDefIndex()


Returns the item's definition index. Can be used to get the item's definition.


### GetItemDefinition()


Returns the item's definition as the [ItemDefinition](../ItemDefinition) object.


### GetLevel()


Returns the item's level.


### GetItemID()


Returns the item's ID. This is a unique 64bit ID for the item that identifies it across the economy.


### GetInventoryPosition()


Returns the item's position in the inventory.


### IsEquippedForClass( classid:integer )


Returns true if the item is equipped for the given class.


### GetImageTextureID()


Returns the item's backpack image texture ID. Some items may not have it, in which case, result is -1.


### GetAttributes()


Returns the item's attributes as a table where keys are [AttributeDefinition](../AttributeDefinition) objects and values are the values of the attributes.


### SetAttribute( attrDef:AttributeDefinition, value:any )


Sets the value of the given attribute by it's definition. The value must be the correct type for the given attribute definition.


### SetAttribute( attrName:string, value:any )


Sets the value of the given attribute by it's name. The value must be the correct type for the given attribute definition.


### RemoveAttribute( attrDef:AttributeDefinition )


Removes the given attribute by it's definition.


### RemoveAttribute( attrName:string )


Removes the given attribute by it's name.


## Examples


Set unusual effect and name of item
```
local nameAttr = itemschema.GetAttributeDefinitionByName( "custom name attr" )

local firstItem = inventory.GetItemByPosition( 1 )

firstItem:SetAttribute( "attach particle effect", 33 ) -- Set the unusual effect to rotating flames
firstItem:SetAttribute( nameAttr, "Dumb dumb item" ) -- Set the custom name to "Dumb dumb item"

```

Print all attributes of an item
```
local item = inventory.GetItemByPosition( 1 )

for def, v in pairs( item:GetAttributes() ) do
    print( def:GetName() .. " : " .. tostring( v ) )
end

```


