# vector

*Source: https://lmaobox.net/lua/Lua_Libraries/vector/*

---



# vector


The vector library provides a simple way to manipulate 3D vectors. You can use both Lua tables and Vector3 instances as arguments. The functions below showcase only the table-based option.


See definitions of [Vector3](../Lua_Classes/vector3.md) and [EulerAngles](../../Lua_Classes/EulerAngles/)


## Functions


### Add( a: Vector3, b: Vector3 ): Vector3


Add two vectors


### Subtract( a: Vector3, b: Vector3 ): Vector3


Subtract two vectors


### Multiply( vec: Vector3, scalar: number ): Vector3


Multiply vector by scalar


### Divide( vec: Vector3, scalar: number ): Vector3


Divide vector by scalar


### Length( vec: Vector3 ): number


Get vector length


### LengthSqr( vec: Vector3 ): number


Get vector squared length


### Distance( a: Vector3, b: Vector3 ): number


Get distance between two vectors


### Normalize( vec: Vector3 ): Vector3


Normalize vector


### Angles( angles: EulerAngles ): EulerAngles


Get vector angles


### AngleForward( angles: EulerAngles ): EulerAngles


Get forward vector angle


### AngleRight( angles: EulerAngles ): EulerAngles


Get right vector angle


### AngleUp( angles: EulerAngles ): EulerAngles


Get up vector angle


### AngleVectors( angles: EulerAngles ): forward: Vector3, right: Vector3, up: Vector3


Get forward, right, and up vector angles as 3 return values


### AngleNormalize( angles: EulerAngles ): EulerAngles


Normalize vector angles


## Examples


Arithmetic example
```
local vec = vector.Add( Vector3( 1, 2, 3 ), {4, 5, 6} )
local vec = vector.Subtract( {10, 20, 30}}, {4, 5, 6} )

```

Angle normalise
```
print(vector.AngleNormalize({30, 182, 2}))
--- prints [30.0, -178.0, 0.0]

```


