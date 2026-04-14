# Trace

*Source: https://lmaobox.net/lua/Lua_Classes/Trace/*

---



# Trace


Return value of engine.TraceLine and engine.TraceHull funcs


## Fields


Fields are non-modifiable.


### fraction


number


Fraction of the trace that was completed.


### entity


Entity


The entity that was hit.


### plane


Vector3


Plane normal of the surface hit.


### contents


integer


Contents of the surface hit.


### hitbox


integer


Hitbox that was hit.


### hitgroup


integer


Hitgroup that was hit.


### allsolid


boolean


Whether the trace completed in all solid.


### startsolid


boolean


Whether the trace started in a solid.


### startpos


Vector3


The start position of the trace.


### endpos


Vector3


The end position of the trace.


## Extra


More information can be found at  [Valve Wiki](https://developer.valvesoftware.com/wiki/UTIL_TraceLine#trace_t_.26tr)


## Examples


What am I looking at?
```
local me = entities.GetLocalPlayer();
local source = me:GetAbsOrigin() + me:GetPropVector( "localdata", "m_vecViewOffset[0]" );
local destination = source + engine.GetViewAngles():Forward() * 1000;

local trace = engine.TraceLine( source, destination, MASK_SHOT_HULL );

if (trace.entity ~= nil) then
    print( "I am looking at " .. trace.entity:GetClass() );
    print( "Distance to entity: " .. trace.fraction * 1000 );
end

```


