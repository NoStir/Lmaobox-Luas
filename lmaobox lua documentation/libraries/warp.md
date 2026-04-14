# warp

*Source: https://lmaobox.net/lua/Lua_Libraries/warp/*

---



# warp


This library can be used for interacting with the warp exploit feature of TF2.
How it works:


You can charge up ticks to later on send to server in a batch, which will execute them all at once, it behaves like a small speedhack, a `warp`.


Warping results in a small dash in the direction you are running in.


Warping while shooting results in weapons speeding up their reload times -> some weapons can shoot twice - a double tap.


## Functions


### GetChargedTicks()


Returns the amount of charged warp ticks.


### IsWarping()


Returns true if the user is currently warping.
Since the period of warping is super short, this is only really useful in CreateMove callbacks where you can use it to do your logic.


### CanWarp()


Whether we can warp or not. Does not guarantee a full charge or a double tap.


### CanDoubleTap( weapon:Entity )


Extension of `CanWarp` with additional checks. When this is true, you can guarentee a weapon will double tap.


### TriggerWarp()


Triggers a warp.


### TriggerDoubleTap()


Triggers a warp with double tap.


### TriggerCharge()


Triggers a charge of warp ticks.


## Examples


Play a sound when weapon can double tap
```
local function onCreateMove( cmd )
    local me = entities.GetLocalPlayer()
    if e ~= nil then
        local wpn = me:GetPropEntity( "m_hActiveWeapon" )
        if wpn  ~= nil then

            local canDt = warp.CanDoubleTap(wpn)

            if oldCanDt ~= canDt and canDt == true then
                engine.PlaySound( "player/recharged.wav" )
            end

            oldCanDt = canDt
        end
    end
end

callbacks.Register("CreateMove", onCreateMove)

```


