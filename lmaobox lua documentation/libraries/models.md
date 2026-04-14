# models

*Source: https://lmaobox.net/lua/Lua_Libraries/models/*

---



# models


The models library provides a way to get information about models. When inputting the model:Model parameter, it must be of type [Model](../../Lua_Classes/Model/).


## Functions


### GetModel( modelIndex:integer )


Returns a [Model](../../Lua_Classes/Model/) object by model index.


### GetModelIndex( modelName:string )


Returns a model index as an integer by a given model name.


### GetStudioModel( model:Model )


Returns a [StudioModelHeader](../../Lua_Classes/StudioModelHeader/) object by model.


### GetModelName( model:Model )


Returns a model name by string.


### GetModelMaterials( model:Model )


Returns a table of [Material](../../Lua_Classes/Material/) objects by model.


### GetModelRenderBounds( model:Model )


Returns two [Vector3](../Lua_Classes/vector3.md) objects, mins and maxs, by model string, representing render bounds.


### GetModelBounds( model:Model )


Returns two [Vector3](../Lua_Classes/vector3.md) objects, mins and maxs, by model string representing model space bounds.


## Examples


Draw all bone numbers in world space
```
callbacks.Register( "Draw", function ()

  local me = entities.GetLocalPlayer()

  local model = me:GetModel()
  local studioHdr = models.GetStudioModel(model)

  local myHitBoxSet = me:GetPropInt("m_nHitboxSet")
  local hitboxSet = studioHdr:GetHitboxSet(myHitBoxSet)
  local hitboxes = hitboxSet:GetHitboxes()

 --boneMatrices is an array of 3x4 float matrices
  local boneMatrices = me:SetupBones()

  for i = 1, #hitboxes do
    local hitbox = hitboxes[i]
    local bone = hitbox:GetBone()

    local boneMatrix = boneMatrices[bone]

    if boneMatrix == nil then
      goto continue
    end

    local bonePos = Vector3( boneMatrix[1][4], boneMatrix[2][4], boneMatrix[3][4] )

    local screenPos = client.WorldToScreen(bonePos)

    if screenPos == nil then
      goto continue
    end

    draw.Text( screenPos[1], screenPos[2], i )

    ::continue::
  end

end)

```


