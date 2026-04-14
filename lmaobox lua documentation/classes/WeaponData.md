# WeaponData

*Source: https://lmaobox.net/lua/Lua_Classes/WeaponData/*

---



# WeaponData


Contains variables related to specifications of a weapon, such as firing speed, number of projectiles, etc.
Some of them may not be used, or may be wrong.


## Fields


Fields are read only


### damage


integer


### bulletsPerShot


integer


### range


number


### spread


number


### punchAngle


number


### timeFireDelay


number


### timeIdle


number


### timeIdleEmpty


number


### timeReloadStart


number


### timeReload


number


### drawCrosshair


number


### projectile


integer


Represents projectile id


### ammoPerShot


integer


### projectileSpeed


number


### smackDelay


number


### useRapidFireCrits


boolean


## Examples


Example usage
```
local function onCreateMove( cmd )
    local me = entities.GetLocalPlayer()
    if (me ~= nil) then
        local wpn = me:GetPropEntity( "m_hActiveWeapon" )
        if (wpn  ~= nil) then
            local wdt = wpn:GetWeaponData()
            print( "timeReload: " .. tostring(wdt.timeReload) )
        end
    end
end

callbacks.Register("CreateMove", onCreateMove)

```


