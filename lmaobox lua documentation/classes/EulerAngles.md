# EulerAngles

*Source: https://lmaobox.net/lua/Lua_Classes/EulerAngles/*

---



# EulerAngles


A class that represents a set of Euler angles.


## Constructor


### EulerAngles( pitch, yaw, roll)


Creates a new instace of EulerAngles.


## Fields


Fields are modifiable directly.


### x / pitch


number


### y / yaw


number


### z / roll


number


## Methods


### Unpack()


Returns the X, Y, and Z coordinates as a separate variables.


### Clear()


Clears the angles to 0, 0, 0


### Normalize()


Clamps the angles to standard ranges.


### Forward()


Returns the forward vector of the angles.


### Right()


Returns the right vector of the angles.


### Up()


Returns the up vector of the angles.


### Vectors()


Returns the forward, right, and up vectors as 3 return values.


## Examples


Getting view angles
```
local me = entities.GetLocalPlayer()
local viewAngles = me:GetPropVector("tfnonlocaldata", "m_angEyeAngles[0]")

```

Unpack example
```
local myAngles = EulerAngles( 30, 60, 0 )
local pitch, yaw, roll = myAngles:Unpack()

```


