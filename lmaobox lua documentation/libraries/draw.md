# draw

*Source: https://lmaobox.net/lua/Lua_Libraries/draw/*

---



# draw


This library allows you to draw shapes and text on the screen. It also allows you to create textures from images and draw them.


## Functions


### Color( r, g, b, a )


Set color for drawing shapes and texts


### Line( x1, y1, x2, y2 )


Draw line from x1, y1 to x2, y2


### FilledRect( x1, y1, x2, y2 )


Draw filled rectangle with top left point at x1, y1 and bottom right point at x2, y2


### OutlinedRect( x1, y1, x2, y2 )


Draw outlined rectangle with top left point at x1, y1 and bottom right point at x2, y2


### FilledRectFade(x1:integer, y1:integer, x2:integer, y2:integer, alpha1:integer, alpha2:integer, horizontal:bool)


Draw a rectangle with a fade. The fade is horizontal by default, but can be vertical by setting horizontal to false. The alpha values are between 0 and 255.


### FilledRectFastFade(x1:integer, y1:integer, x2:integer, y2:integer, fadeStartPt:integer, fadeEndPt:integer, alpha1:integer, alpha2:integer, horizontal:bool)


Draws a fade between the fadeStartPt and fadeEndPT points. The fade is horizontal by default, but can be vertical by setting horizontal to false. The alpha values are between 0 and 255.


### ColoredCircle( centerx:integer, centery:integer, radius:number, r:integer, g:integer, b:integer, a:integer )


Draw a colored circle with center at centerx, centery and radius radius. The color is specified by r, g, b, a.


### OutlinedCircle( x:integer, y:integer, radius:number, segments:integer )


Draw an outlined circle with center at centerx, centery and radius radius. The circle is made up of segments number of lines.


### GetTextSize( string )


returns: width, height
Get text size with current font


### Text( x:integer, y:integer, text:string )


Draw text at x, y


### TextShadow( x:integer, y:integer, text:string )


Draw text with shadow at x, y


### GetScreenSize()


returns: width, height
Get game resolution settings


### CreateFont( name:string, height:integer, weight:integer, [fontFlags:integer] )


Create font by name. Font flags are optional and can be combined with bitwise OR. Default font flags are `FONTFLAG_CUSTOM | FONTFLAG_ANTIALIAS`


### AddFontResource( pathTTF:string )


Add font resource by path to ttf file, relative to Team Fortress 2 folder


### SetFont( font:integer )


Set current font for drawing. To be used with DrawText


## Textures


When creating textures, you should make sure each size is a valid power of 2. Otherwise, the texture will be scaled to the nearest larger power of 2 and look weird.


### CreateTexture( imagePath:string )


Create texture from image on the given path. Path is relative to `%localappdata%`.. But you can also specify an absolute path if you wish. Returns texture id for the newly created texture. Supported image extensions: PNG, JPG, BMP, TGA, VTF


### CreateTextureRGBA( rgbaBinaryData:string, width:integer, height:integer )


Create texture from raw rgba data in the format RGBA8888 (one byte per color). In this format you must specify the valid width and height of the texture. Returns texture id for the newly created texture.


### GetTextureSize( textureId:integer )


Returns: width, height of the texture as integers


### TexturedRect( textureId:integer, x1:integer, y1:integer, x2:integer, y2:integer)


Draw the texture by textureId as a rectangle with top left point at x1, y1 and bottom right point at x2, y2.


### TexturedPolygon( textureId:integer, vertices:table, clipVertices:bool )


Draw the texture by textureId as a polygon. The vertices table should be a list of tables, each containing 4 values: x,y of the vertex, and u,v of the tex coordinate. Example vertex = { 0,0,0.1,0.5 }. clipVertices decides whether the resulting polygon should be clipped to the screen or not. If unsure how to add vertices, refer to an example below


### DeleteTexture( textureId:integer )


Delete texture by textureId from memory. You should do this when unloading your script.


## Examples


Draw an image
```
local lmaoboxTexture = draw.CreateTexture( "lmaobox.png" ) -- in %localappdata% folder

callbacks.Register("Draw", function()
    local w, h = draw.GetScreenSize()
    local tw, th = draw.GetTextureSize( lmaoboxTexture )

    draw.TexturedRect( lmaoboxTexture, w/2 - tw/2, h/2 - th/2, w/2 + tw/2, h/2 + th/2 )
end)

```

Draw an image but really skewed using polygon
```
local lmaoboxTexture = draw.CreateTexture( "lmaobox.png" ) -- in %localappdata% folder

callbacks.Register("Draw", function()
    local w, h = draw.GetScreenSize()
    local tw, th = draw.GetTextureSize( lmaoboxTexture )

    draw. TexturedPolygon( lmaoboxTexture, {
        { w/2 - tw/2, h/2 - th/2, 0.0, 0.0 },
        { w/2 + tw/2, h/2 - th/2, 1.0, 0.1 },
        { w/2 + tw/2, h/2 + th/2, 1.0, 1.0 },
        { w/2 - tw/2, h/2 + th/2, 0.0, 1.0 },
    }, true )
end)

```

Add font resource
```
draw.AddFontResource("Choktoff.ttf") -- In Team Fortress 2 folder
local myfont = draw.CreateFont("Choktoff", 15, 800, FONTFLAG_CUSTOM | FONTFLAG_ANTIALIAS)

```

Drawing a white square with lines
```
local function doDraw()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return
    end

    draw.Color(255, 255, 255, 255)
    draw.Line(100, 100, 100, 200)
    draw.Line(100, 200, 200, 200)
    draw.Line(200, 200, 200, 100)
    draw.Line(200, 100, 100, 100)
end

callbacks.Register("Draw", "mydraw", doDraw)

```


