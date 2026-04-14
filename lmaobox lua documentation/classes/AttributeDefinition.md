# AttributeDefinition

*Source: https://lmaobox.net/lua/Lua_Classes/AttributeDefinition/*

---



# AttributeDefinition


The AttributeDefinition object contains information about an attribute in TF2.


## Methods


### GetName()


Returns the name of the attribute.


### GetID()


Returns the ID of the attribute.


### IsStoredAsInteger()


Returns true if the attribute is stored as an integer. For numeric attibutes, false means it is stored as a float.


## Examples


Enumerate all attributes
```
itemschema.EnumerateAttributes( function( attrDef )
    print( attrDef:GetName() .. ": " .. tostring( attrDef:GetID() ) )
end )

```


