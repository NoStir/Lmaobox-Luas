# physics

*Source: https://lmaobox.net/lua/Lua_Libraries/physics/*

---



# physics


This is a library for physics calculations in TF2. You can use this to calculate the trajectory of projectiles, or perform any sort of physics calculations on physics objects in time, in your own environment, or in TF2's environment.


## Functions


### CreateEnvironment()


Creates a new physics environment of class [PhysicsEnvironment](../../Lua_Classes/PhysicsEnvironment). By default it has no gravity, and no air resistance and no collisions.


### DestroyEnvironment( environment:PhysicsEnvironment )


Destroys a physics environment.


### DefaultEnvironment()


Returns the default physics environment. This is the environment that TF2 client uses for clientside physics calculations. Wouldnt recommend using, can cause odd side effects, but im not your mom.


### BBoxToCollisionModel( mins:Vector, maxs:Vector )


Creates a collision model from a bounding box. Returns a [PhysicsCollisionModel](../../Lua_Classes/PhysicsCollisionModel) object.


### ParseModelByName( modelName:string )


Creates a PhysicsSolid and a PhysicsCollisionModel from a model name. Returns a [PhysicsSolid](../../Lua_Classes/PhysicsSolid) object and a [PhysicsCollisionModel](../../Lua_Classes/PhysicsCollisionModel) object.


### DefaultObjectParameters()


Creates a [PhysicsObjectParameters](../../Lua_Classes/PhysicsObjectParameters) object with default values.


## Examples


### Projectile trajectory in time with custom values



```
-- Run only once
local grenadeModel = [[models/weapons/w_models/w_grenade_grenadelauncher.mdl]]
local env = physics.CreateEnvironment( )
env:SetGravity( Vector3( 0, 0, -800 ) )
env:SetAirDensity( 2.0 )
env:SetSimulationTimestep( globals.TickInterval() )
local solid, collisionModel = physics.ParseModelByName( grenadeModel )
local simulatedProjectile = nil

callbacks.Register( "Draw", function ()

  local me = entities.GetLocalPlayer()

  if simulatedProjectile == nil then 
    simulatedProjectile = env:CreatePolyObject(collisionModel, solid:GetSurfacePropName(), solid:GetObjectParameters())
    simulatedProjectile:Wake()
  end

  local startPos = me:GetAbsOrigin() + me:GetPropVector( "m_vecViewOffset[0]" )
  local startAngles = me:GetPropVector(  "m_angEyeAngles" )
  simulatedProjectile:SetPosition(startPos, startAngles, true)

  local velocity = Vector3(1000,600,200)
  local angularVelocity = Vector3(600,0,0) --Spin!

  simulatedProjectile:SetVelocity(velocity, angularVelocity)

  local tickInteval = globals.TickInterval()
  local simulationEnd = env:GetSimulationTime() + 2.0

  while env:GetSimulationTime() < simulationEnd do

    -- Where is it now?
    local currentPos, currentAngle = simulatedProjectile:GetPosition()

    -- draw line from startPos to currentPos
    local screenCurrentPos = client.WorldToScreen(currentPos)
    local screenStartPos = client.WorldToScreen(startPos)

    if screenCurrentPos ~= nil and screenStartPos ~= nil then
      draw.Color(255, 0, 255, 255)
      draw.Line(screenStartPos[1], screenStartPos[2], screenCurrentPos[1], screenCurrentPos[2])
    end

    startPos = currentPos

    -- Run the simulation
    env:Simulate(tickInteval)
  end

  env:ResetSimulationClock()

end)

callbacks.Register("Unload", function()
  -- Clean up afterwards
  if simulatedProjectile ~= nil then
    env:DestroyObject(simulatedProjectile)
  end

  physics.DestroyEnvironment( env )
end)

```


