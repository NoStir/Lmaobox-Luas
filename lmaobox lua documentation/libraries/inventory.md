# inventory

*Source: https://lmaobox.net/lua/Lua_Libraries/inventory/*

---



# inventory


The inventory library is used to access the player's inventory and the items in it. Every item is of type [Item](../../Lua_Classes/Item).


## Functions


### Enumerate( callback:function( item ) )


Callback is called for each item in the inventory. The item is passed as the first argument and is of type [Item](../../Lua_Classes/Item).


### GetItemByPosition( position:integer )


Returns the item at the given position in the inventory.


### GetMaxItemCount()


Returns the maximum number of items that can be in the inventory.


### GetItemByItemID( itemID:integer )


Returns the item with the given 64bit item ID.


### GetItemInLoadout( classid:integer, slot:integer )


Returns the item that is in the given slot in the given class' loadout slot.


### EquipItemInLoadout( item:Item, classid:integer, slot:integer )


Equips the item that is in the given slot in the given class' loadout slot. The item is of type [Item](../../Lua_Classes/Item)


### CreateFakeItem( itemdef:ItemDefinition, pickupOrPosition:integer, itemID64:integer, quality:integer, origin:integer, level:integer, isNewItem:bool )


Creates a fake item with the given parameters. The item definition is of type [ItemDefinition](../../Lua_Classes/ItemDefinition). The pickupOrPosition parameter is the pickup method, if `isNewItem` parameter is true, and the inventory position of the item if `isNewItem` parameter is false. The itemID64 is the unique 64bit item ID of the item, you can use -1 to generate a random ID. For quality and origin you can use constants. The level is the item's level.


## Examples


Create pink Cow Mangler using paint can attribute
```
local definition = itemschema.GetItemDefinitionByID(441) -- id from items_game.txt
local createdItem = inventory.CreateFakeItem(definition, 0, -1, 14, 0, 100, true)
local name = itemschema.GetAttributeDefinitionByName( "custom name attr" )
createdItem:SetAttribute(name, "Pink 5000")

local color = itemschema.GetAttributeDefinitionByName( "set item tint RGB" )
createdItem:SetAttribute(color, 0xFF69B4) -- use hex value from Paint Can wiki page

print(string.format("Added %s with item ID %i to inventory slot %i.", createdItem:GetName(), createdItem:GetItemID(), createdItem:GetInventoryPosition()))

-- prints: echo Added ''Pink 5000'' with item ID 4723849120212 to inventory slot 12.

```


