# PhysicsEnvironment

*Source: https://lmaobox.net/lua/Lua_Classes/PhysicsEnvironment/*

---



# PhysicsEnvironment


PhysicsEnvironment is a class that represents a physics environment. It has its own gravity, air resistance, and collision rules. It contains physics objects that can be simulated in time.


## Methods


### SetGravity( gravity:Vector3 )


Sets the gravity of the physics environment.


### GetGravity()


Returns the gravity of the physics environment as a [Vector3](../../Lua_Classes/Vector3).


### SetAirDensity( airDensity:float )


Sets the air density of the physics environment.


### GetAirDensity()


Returns the air density of the physics environment.


### Simulate( deltaTime:float )


Simulates the physics environment in time by the given delta time.


### IsInSimulation()


Returns whether the physics environment is currently simulating.


### GetSimulationTime()


Returns the current simulation time of the physics environment.


### GetSimulationTimestep()


Returns the current simulation timestep of the physics environment.


### SetSimulationTimestep( timestep:float )


Sets the simulation timestep of the physics environment.


### GetActiveObjects()


Returns a table of all active physics objects in the physics environment, as [PhysicsObject](../../Lua_Classes/PhysicsObject) objects.


### ResetSimulationClock()


Resets the simulation clock of the physics environment.


### CreatePolyObject( collisionModel:PhysicsCollisionModel, surfacePropertyName:string, objectParams:PhysicsObjectParameters )


Creates a physics object from a collision model, surface property name, and physics object parameters. Returns a [PhysicsObject](../../Lua_Classes/PhysicsObject) object. Objects is created asleep, and must be woken up before simulation by calling [PhysicsObject:Wake()](../../Lua_Classes/PhysicsObject#Wake).


### DestroyObject( object:PhysicsObject )


Destroys a physics object.



