# render

*Source: https://lmaobox.net/lua/Lua_Libraries/render/*

---



# render


The render library provides a way to interact with the rendering system.


## Functions


### Push3DView( view:ViewSetup, clearFlags:integer, texture:Texture )


Push a 3D view of type [ViewSetup](../../Lua_Classes/ViewSetup/) to the render stack. Flags is a bitfield of Clear flags. Texture is a [Texture](../../Lua_Classes/Texture/) object to render to. If texture is nil, the current render target is used.


### PopView()


Pop the current view from the render stack.


### ViewDrawScene( draw3Dskybox:boolean, drawSkybox:boolean, view:ViewSetup )


Draw the scene onto the texture that is currently on top of the stack - by default your whole screen. draw3Dskybox and drawSkybox are booleans that determine if the 3D skybox or 2D skybox should be drawn. View is a [ViewSetup](../../Lua_Classes/ViewSetup/) object.


### DrawScreenSpaceRectangle( material:Material, destX:integer, destY:integer, width:integer, height:integer, srcTextureX0:number, srcTextureY0:number, srcTextureX1:number, srcTextureY1:number, srcTextureWidth:integer, srcTextureHeight:integer )


Draw a screen space rectangle with a given Material. Material is a [Material](../../Lua_Classes/Material/) object. destX and destY are the coordinates of the top left corner of the rectangle. width and height are the dimensions of the rectangle. srcTextureX0, srcTextureY0, srcTextureX1, srcTextureY1 are the coordinates of the top left and bottom right corners of the rectangle on the texture. srcTextureWidth and srcTextureHeight are the dimensions of the texture.


### DrawScreenSpaceQuad( material:Material )


Draws a screen space quad by material


### GetViewport()


Returns x, y, w, h of current viewport


### Viewport( x:integer, y:integer, w:integer, h:integer)


Sets current viewport 


### DepthRange( zNear:number, zFar:number)


Sets the depth range of rendering


### GetDepthRange()


Returns the depth range of rendering as zNear, zFar


### SetRenderTarget( texture:Texture )


Sets the current render target to texture.


### GetRenderTarget()


Returns the current render target as a [Texture](../../Lua_Classes/Texture/) object.


### ClearBuffers( clearColor:boolean, clearDepth:boolean, clearStencil:boolean)


Clears the current render target's buffers. clearColor, clearDepth and clearStencil are booleans that determine which buffers should be cleared.


### ClearColor3ub( r:integer, g:integer, b:integer)


Clears the current render target's color buffer with the given RGB values. r, g and b are integers between 0 and 255.


### ClearColor4ub( r:integer, g:integer, b:integer, a:integer)


Clears the current render target's color buffer with the given RGBA values. r, g, b and a are integers between 0 and 255.


### OverrideDepthEnable( enable:boolean, depthEnable:boolean )


Sets the depth override state. enable is a boolean that determines if the depth override is enabled. depthEnable is a boolean that determines if depth testing is enabled when the depth override is enabled.


### OverrideAlphaWriteEnable( enable:boolean, alphaWriteEnable:boolean )


Sets the alpha write override state. enable is a boolean that determines if the alpha write override is enabled. alphaWriteEnable is a boolean that determines if alpha writing is enabled when the alpha write override is enabled.


### PushRenderTargetAndViewport()


Push the current render target and viewport to the stack.


### PopRenderTargetAndViewport()


Pop the current render target and viewport from the stack.


### SetStencilEnable( enable:boolean )


Sets the stencil staet. enable is a boolean that determines if the stencil test is enabled.


### SetStencilFailOperation( failOp:integer )


Seets the stencil fail operation. failOp is an integer that determines the operation to perform when the stencil test fails. The possible values are of enum E_StencilOperation.


### SetStencilZFailOperation( zFailOp:integer )


Sets the stencil Z fail operation. zFailOp is an integer that determines the operation to perform when the stencil test passes but the depth test fails. The possible values are of enum E_StencilOperation.


### SetStencilPassOperation( passOp:integer )


Sets the stencil pass operation. passOp is an integer that determines the operation to perform when the stencil test passes. The possible values are of enum E_StencilOperation.


### SetStencilCompareFunction( compareFunc:integer )


Set the stencil compare function. compareFunc is an integer that determines the comparison function to use. The possible values are of enum E_StencilComparisonFunction.


### SetStencilReferenceValue( comparationValue:integer )


Ssets the stencil reference value. comparationValue is an integer that determines the reference value to use for the stencil test. The value is clamped between 0 and 255.


### SetStencilTestMask( mask:integer )


Sets the stencil test mask. mask is an integer that determines the mask to use for the stencil test. The value is clamped between 0 and 0xFFFFFFFF.


### SetStencilWriteMask( mask:integer )


Sets the stencil write mask. mask is an integer that determines the mask to use for writing to the stencil buffer. The value is clamped between 0 and 0xFFFFFFFF.


### ClearStencilBufferRectangle( xmin:integer, ymin:integer, xmax:integer, ymax:integer, value:integer)


Clears the stencil buffer rectangle. xmin, ymin, xmax and ymax are integers that determine the rectangle to clear. value is an integer that determines the value to clear the rectangle to.


### ForcedMaterialOverride( material:Material )


Sets the forced material override. material is a [Material](../../Lua_Classes/Material/) object that determines the material to use for all subsequent draw calls. Pass nil to disable the forced material override.


### SetBlend( blend:float )


Set the blend factor. blend is a float that determines the blend factor to use for all subsequent draw calls. The value is clamped between 0 and 1. This is used for alpha blending.


### GetBlend()


Reutrns the current blend factor as a float.


### SetColorModulation( r:number, g:number, b:number )


Set the color modulation. r, g and b are floats that determine the color modulation to use for all subsequent draw calls. The values are clamped between 0 and 1. This is used for color tinting.


### GetColorModulation()


Returns r,g,b - 3 floats that represent the current color modulation.


## Examples


Draw a custom camera view - spy camera
```
local camW = 400
local camH = 300
local cameraTexture = materials.CreateTextureRenderTarget( "cameraTexture123", camW, camH )
local cameraMaterial = materials.Create( "cameraMaterial123", [[
    UnlitGeneric
    {
        $basetexture    "cameraTexture123"
    }
]] )

callbacks.Register("PostRenderView", function(view)
    customView = view
    customView.angles = EulerAngles(customView.angles.x, customView.angles.y + 180, customView.angles.z)

    render.Push3DView( customView, E_ClearFlags.VIEW_CLEAR_COLOR | E_ClearFlags.VIEW_CLEAR_DEPTH, cameraTexture )
    render.ViewDrawScene( true, true, customView )
    render.PopView()
    render.DrawScreenSpaceRectangle( cameraMaterial, 300, 300, camW, camH, 0, 0, camW, camH, camW, camH )
end)

```


