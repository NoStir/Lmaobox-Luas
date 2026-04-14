# Material

*Source: https://lmaobox.net/lua/Lua_Classes/Material/*

---



# Material


Represents a material in source engine. For more information about materials see the [Material](https://developer.valvesoftware.com/wiki/Material) page.


## Methods


### GetName()


Returns the material name


### GetTextureGroupName


Returns group the material is part of


### AlphaModulate( alpha:number )


Modulate transparency of material by given alpha value


### ColorModulate( red:number, green:number, blue:number )


Modulate color of material by given RGB values


### SetMaterialVarFlag( flag:integer, set:bool )


Change a material variable flag, see [MaterialVarFlags](https://developer.valvesoftware.com/wiki/Category:List_of_Shader_Parameters) for a list of flags.
The flag is the integer value of the flag enum, not the string name.


### SetShaderParam( param:string, value:any )


Set a shader parameter, see [ShaderParameters](https://developer.valvesoftware.com/wiki/Category:List_of_Shader_Parameters) for a list of parameters.
Supported values are integer, number, Vector3, string.


## Examples


Create a material, and change ignorez to false
```
kv = [["VertexLitGeneric"
{
    "$basetexture"  "vgui/white_additive"
    "$ignorez" "1"
}
]]

myMaterial = materials.Create( "myMaterial", kv )
myMaterial:SetMaterialVarFlag( MATERIAL_VAR_IGNOREZ, false )

```


