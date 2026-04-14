# StudioModelHeader

*Source: https://lmaobox.net/lua/Lua_Classes/StudioModelHeader/*

---



# StudioModelHeader


The StudioModelHeader object contains information about a studio models hitbox sets and bones.


## Methods


### GetName()


Returns the name of the model.


### GetHitboxSet( index:integer )


Returns a [StudioHitboxSet](../StudioHitboxSet/) object by the entities hitbox set index. This can be retrieved from m_nHitBoxSet netvar.


### GetAllHitboxSets()


Returns a table of all [StudioHitboxSet](../StudioHitboxSet/) objects for the model.


## Examples


Enumerate all hitboxes
```


```


