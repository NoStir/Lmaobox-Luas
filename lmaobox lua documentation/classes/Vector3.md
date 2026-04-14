# Vector3

*Source: https://lmaobox.net/lua/Lua_Classes/Vector3/*

---



# Vector3


Represents a point in 3D space. X and Y are the horizontal coordinates, Z is the vertical coordinate.


## Constructor


## Vector3( x, y, z )


## Fields


Fields are modifiable directly.


### x


number


The X coordinate.


### y


number


The Y coordinate.


### z


number


The Z coordinate.


## Methods


### Unpack()


Returns the X, Y, and Z coordinates as a separate variables.


### Length()


The length of the vector.


### LengthSqr()


The squared length of the vector.


### Length2D()


The length of the vector in 2D.


### Length2DSqr()


The squared length of the vector in 2D.


### Dot( Vector3 )


The dot product of the vector and the given vector.


### Cross( Vector3 )


The cross product of the vector and the given vector.


### Clear()


Clears the vector to 0,0,0


### Normalize()


Normalizes the vector.


### Right()


Returns the right vector of the vector.


### Up()


Returns the up vector of the vector.


### Angles()


Returns the angles of the vector.


### Vectors()


Returns the forward, right, and up vectors as 3 return values.


## Examples


Unpack example
```
local myVector = Vector3( 1, 2, 3 )
local x, y, z = myVector:Unpack()

```

Length example
```
local myVector = Vector3( 1, 2, 3 )
local length = myVector:Length()

```


