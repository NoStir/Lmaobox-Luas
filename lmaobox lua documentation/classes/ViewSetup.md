# ViewSetup

*Source: https://lmaobox.net/lua/Lua_Classes/ViewSetup/*

---



# ViewSetup


The ViewSetup object is used to get information about the the origin, angles, fov, zNear, zFar, and aspect ratio of the player's view.


## Fields


Fields are modifiable directly.


### x


integer


Left side of view window


### unscaledX


integer


Left side of view window without HUD scaling


### y


integer


Top side of view window


### unscaledY


integer


Top side of view window without HUD scaling


### width


integer


Width of view window


### unscaledWidth


integer


Width of view window without HUD scaling


### height


integer


Height of view window


### unscaledHeight


integer


Height of view window without HUD scaling


### ortho


bool


Whether the view is orthographic


### orthoLeft


number


Left side of orthographic view


### orthoTop


number


Top side of orthographic view


### orthoRight


number


Right side of orthographic view


### orthoBottom


number


Bottom side of orthographic view


### fov


number


Field of view


### fovViewmodel


number


Field of view of the viewmodel


### origin


[Vector3](../Lua_Classes/vector3.md)


Origin of the view


### angles


[EulerAngles](../EulerAngles/)


Angles of the view


### zNear


number


Near clipping plane


### zFar


number


Far clipping plane


### aspectRatio


number


Aspect ratio of the view


## Examples


Print the player's view origin
```
local view = client.GetViewSetup()
print( "View origin: " .. view.origin )

```


