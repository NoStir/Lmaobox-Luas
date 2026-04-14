# PhysicsObject

*Source: https://lmaobox.net/lua/Lua_Classes/PhysicsObject/*

---



# PhysicsObject


PhysicsObject is a class that represents a physics object. It has a position, angle, velocity, angular velocity, and is affected by gravity and air resistance. It can be simulated in time. Other parameters include class [PhysicsObjectParameters](../../Lua_Classes/PhysicsObjectParameters).


## Methods


### Wake()


Wakes up the physics object. It will become active in the physics environment and will be simulated in time if the physics environment is simulating.


### Sleep()


Puts the physics object to sleep. It will become inactive in the physics environment and will not be simulated.


### GetPosition()


Returns the position of the physics object as a [Vector3](../../Lua_Classes/Vector3) and the angle as a [Vector3](../../Lua_Classes/Vector3) second return value.


### SetPosition( position:Vector3, angle:Vector3, isTeleport:bool )


Sets the position and angle of the physics object. If isTeleport is true, the physics object will be teleported to the new position and angle.


### GetVelocity()


Returns the velocity of the physics object as a [Vector3](../../Lua_Classes/Vector3) and the angular velocity as a [Vector3](../../Lua_Classes/Vector3) second return value.


### SetVelocity( velocity:Vector3, angularVelocity:Vector3 )


Sets the velocity and angular velocity of the physics object.


### AddVelocity( velocity:Vector3, angularVelocity:Vector3 )


Adds the velocity and angular velocity to the physics object.


### OutputDebugInfo()


Outputs debug information about the physics object to the console.



