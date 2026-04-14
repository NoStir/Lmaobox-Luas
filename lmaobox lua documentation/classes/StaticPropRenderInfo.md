# StaticPropRenderInfo

*Source: https://lmaobox.net/lua/Lua_Classes/StaticPropRenderInfo/*

---



# StaticPropRenderInfo


Represents the context of a static prop being drawn.


## Methods


### ForcedMaterialOverride( mat:Material )


Replace material used to draw the models. Material can be found or created via materials. API


### DrawExtraPass()


Redraws the models. Can be used to achieve various effects with different materials.


### StudioSetColorModulation( color:Color )


Sets the color modulation of the models via StudioRender.


### StudioSetAlphaModulation( alpha:number )


Sets the alpha modulation of the models via StudioRender.


## Examples


Draw all player models using AmmoBox material
```
local ammoboxMaterial = materials.Find( "models/items/ammo_box2" )

local function onStaticProps( info )

    info:StudioSetColorModulation( 0.5, 0, 0 )
    info:StudioSetAlphaModulation( 0.7 )
    info:ForcedMaterialOverride( ammoboxMaterial )

end

callbacks.Register("DrawStaticProps", "hook123", onStaticProps) 

```


