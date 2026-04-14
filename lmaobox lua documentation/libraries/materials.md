# materials

*Source: https://lmaobox.net/lua/Lua_Libraries/materials/*

---



# materials


The materials library provides a way to create and alter materials for rendering.


## Functions


### Find( name:string )


Find a material by name


### Enumerate( callback( mat ) )


Enumerate all loaded materials and call the callback function for each one. The only argument in the callback is the Material object.


### Create( name:string, vmt:string )


Create custom material following the [Valve Material Type](https://developer.valvesoftware.com/wiki/Material) syntax.
VMT should be a string containing the full material definition. Name should be an unique name of the material.


### CreateTextureRenderTarget( name:string, width:number, height:number )


Create a texture render target. Name should be an unique name of the material. Width and height are the dimensions of the texture. Returns a [Texture](../../Lua_Classes/Texture/) object.


### FindTexture( name:string, groupName:string, complain:boolean )


Fetches a texture by name. If the texture is not found, it will be created. If complain is true, it will print an error message if the texture is not found. Returns a [Texture](../../Lua_Classes/Texture/) object.


## Examples


Create white material
```
kv = [["UnlitGeneric"
{
    "$basetexture"  "vgui/white_additive"
    "$ignorez" "1"
    "$model" "1"
}
]]

myMaterial = materials.Create( "myMaterial", kv )

```

Find materials that have 'wood' in name
```
local function forEveryMaterial( material )
    if string.find( material:GetName(), "wood" ) then
        print( "Found material: " .. material:GetName() )
    end
end

materials.Enumerate( forEveryMaterial )

```


