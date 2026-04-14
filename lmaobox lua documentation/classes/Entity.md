# Entity

*Source: https://lmaobox.net/lua/Lua_Classes/Entity/*

---



# Entity


Represents an entity in the game world. Make sure to not store entities long term, they can become invalid over time - their methods will return nil in that case.


## Methods


### IsValid()


Returns whether the entity is valid. This is done automatically and all other functions will return nil if the entity is invalid.


### GetName()


Returns the name string of the entity if its a player


### GetClass()


Returns the class string of the entity i.e. CTFPlayer


### GetIndex()


Returns entity index


### GetTeamNumber()


Returns the team number of the entity


### GetAbsOrigin()


Returns the absolute position of the entity


### SetAbsOrigin(origin:Vector)


Sets the absolute position of the entity


### GetAbsAngles()


Returns the absolute angles of the entity


### SetAbsAngles(angles:Vector)


Sets the absolute angles of the entity


### GetMins()


Returns mins of the entity, must be combined with origin


### GetMaxs()


Returns maxs of the entity, must be combined with origin


### GetHealth()


Returns the health of the entity


### GetMaxHealth()


Returns the max health of the entity


### GetMoveChild()


Returns the Entity, which is a move child of this entity. This is a start of a peer list of attachments usually.


### GetMovePeer()


Return the Entity, which is a move peer of this entity. This is a next entity in a peer list of attachments usually.


### IsPlayer()


Returns true if the entity is a player


### IsWeapon()


Returns true if the entity is a weapon


### IsAlive()


Returns true if the entity is alive


### EstimateAbsVelocity()


Returns the estimated absolute velocity of the entity as [Vector3](../Vector3/)


### GetMoveType()


Returns the move type of the entity (the netvar propr does not work)


### HitboxSurroundingBox()


Returns the hitbox surrounding box of the entity as table of [Vector3](../Vector3/) mins and maxs


### EntitySpaceHitboxSurroundingBox()


Returns the hitbox surrounding box of the entity in entity space as table of [Vector3](../Vector3/) mins and maxs


### SetupBones( [boneMask:integer], [currentTime:number] )


Sets up the bones of the entity, boneMask is optional, by default 0x7FF00, and can be changed if you want to only setup certain bones. The currentTime argument is optional, by default 0, and can be changed if you want the transform to be based on a different time. Returns a table of at most 128 entries of a 3x4 matrix (table) of float numbers, representing the bone transforms.


### GetHitboxes( [currentTime:number] )


Returns world-transformed hitboxes of the entity as table of tables, each containing 2 entries of [Vector3](../Vector3/): mins and maxs positions of each hitbox.
The currentTime argument is optional, by default 0, and can be changed if you want the transform to be based on a different time.
Example returned table:



| Hitbox Index | Mins&Maxs table |
| --- | --- |
| 1 | 1: Vector3(1,2,3) 2: Vector3(4,5,6) |
| 2 | 1: Vector3(7,8,9) 2: Vector3(0,1,2) |


### SetModel( modelPath:string )


Sets the model of the entity, returns true if successful


### GetModel()


Returns the model of the entity


### ShouldDraw()


Retruns true if this entity should be drawn right now


### GetInvisibility()


Returns the float value of the entity invisibility value


### SetInvisibility( value:float )


Sets the entity invisibility value


### DrawModel( drawFlags:integer )


Draws the model of the entity


### Release()


Releases the entity, making it invalid. Calling this for networkable entities will kick you from the server. This is only useful for non-networkable entities created with [entities.CreateEntityByName](../../Lua_Libraries/entities/#CreateEntityByName)


### IsDormant()


Returns true if the entity is dormant (not being updated). Dormant entities are not drawn and shouldn't be interacted with.


### ToInventoryItem()


If the entity is an item that can be in player's inventory, such as a wearable or a weapon, returns the inventory item as [Item](../Item/)


## Attributes


In order to get the attributes of an entity, you can use the following methods. The attribute hooking methods will multiply the default value by the attribute value, returning the result. For list of attributes see the [Wiki](https://wiki.teamfortress.com/wiki/List_of_item_attributes)


### AttributeHookFloat( name:string, [defaultValue:number] )


Returns the number value of the attribute present on the entity, defaultValue is by default 1.0


### AttributeHookInt( name:string, [defaultValue:integer] )


Returns the integer value of the attribute present on the entity,defaultValue is by default 1


## Entity netvars/props


You can either input just the netvar name, or the table path to it


### GetPropFloat( propName, ... )


Returns the float value of the given netvar


### GetPropInt( propName, ... )


Returns the int value of the given netvar


### GetPropBool( propName, ... )


Returns the bool value of the given netvar


### GetPropString( propName, ... )


Returns the string value of the given netvar


### GetPropVector( propName, ... )


Returns the vector value of the given netvar


### GetPropEntity( propName, ... )


For entity handle props (m_hXXXXX)


### SetPropFloat( value:number, propName, ... )


Sets the float value of the given netvar.


### SetPropInt( value:integer, propName, ... )


Sets the int value of the given netvar.


### SetPropBool( value:bool, propName, ... )


Sets the bool value of the given netvar.


### SetPropEntity( value:Entity, propName, ... )


Set the entity value of the given netvar.


### SetPropVector( value:Vector3, propName, ... )


Set the vector value of the given netvar.


## Prop Data Tables


They return a Lua Table containing the entries, you can index them with integers


### GetPropDataTableFloat( propName, ... )


Returns a table of floats, index them with integers based on context of the netvar


### GetPropDataTableBool( propName, ... )


Returns a table of bools, index them with integers based on context of the netvar


### GetPropDataTableInt( propName, ... )


Returns a table of ints, index them with integers based on context of the netvar


### GetPropDataTableEntity( propName, ... )


Returns a table of entities, index them with integers based on context of the netvar


### SetPropDataTableFloat( value:number, index:integer, propName, ... )


Sets the number value of the given netvar at the given index.


### SetPropDataTableBool( value:integer, index:integer, propName, ... )


Sets the bool value of the given netvar at the given index.


### SetPropDataTableInt( value:integer, index:integer, propName, ... )


Sets the integer value of the given netvar at the given index.


### SetPropDataTableEntity( value:Entity, index:integer, propName, ... )


Sets the Entity value of the given netvar at the given index.


## Player entity methods


These methods are only available if the entity is a player


### InCond( condition:integer )


Returns whether the player is in the specified condition. List of conditions in TF2 can be found


### AddCond( condition:integer, [duration:number] )


Adds the specified condition to the player, duration is optional (defaults to -1, which means infinite)


### RemoveCond( condition:integer )


Removes the specified condition from the player


### IsCritBoosted()


Whether the player is currently crit boosted by an external source


### GetCritMult()


Returns the current crit multiplier of the player. See [TF2 Crit Wiki](https://wiki.teamfortress.com/wiki/Critical_hits) for more info


### GetCarryingRuneType()


For game mode where players can carry runes, returns the type of rune the player is carrying


### GetMaxBuffedHealth()


Returns the max health of the player, including any buffs from items or medics


### GetEntityForLoadoutSlot( slot:integer )


Returns the entity for the specified loadout slot. This can be used to get the hat entity for the slot, or the weapon entity for the slot


### IsInFreezecam()


Whether the player is currently in a freezecam after death


## GetVAngles()


Returns the third person view angles of the player, as a Vector3


## SetVAngles( vecAngles:Vector3 )


Sets the third person view angles of the player, only really effective on the localplayer


## Weapon entity methods


These methods are only available if the entity is a weapon, some methods have closer specifications on weapon type, and will return `nil` if the entity is not required weapon type.


### IsShootingWeapon()


Returns whether the weapon is a weapon that can shoot projectiles or hitscan.


### IsMeleeWeapon()


Returns whether the weapon is a melee weapon.


### IsMedigun()


Returns whether the weapon is a medigun, supports all types of mediguns.


### CanRandomCrit()


Returns whether the weapon can randomly crit in general, not in it's current state.


### GetLoadoutSlot()


Returns the loadout slot ID of the weapon.


### GetWeaponID()


Returns the weapon ID of the weapon.


### IsViewModelFlipped()


Returns whether the weapon's view model is flipped.


## Weapon shooting gun methods


Weapon "gun" methods are only available if the weapon is a shooting weapon, i.e. with projectiles.


### GetProjectileFireSetup( player:entity, vecOffset:Vector3, bHitTeammates:bool, flEndDist:number )


Returns vecSrc as Vector3 and angForward as Vector3. vecSrc is the starting position of the projectile, angForward is the direction of the projectile. vecOffset is the offset of the projectile from the player's eye position. bHitTeammates is whether the projectile can hit teammates. flEndDist is the distance the projectile can travel before it disappears.


### GetWeaponProjectileType()


Returns the projectile type of the weapon, returns nil if the weapon is not a projectile weapon.


### GetWeaponSpread()


Returns the spread of the weapon, returns nil if the weapon is not a gun weapon.


### GetProjectileSpeed()


Returns the projectile speed of the weapon, returns nil if the weapon is not a projectile weapon. Can return 0 if the weapon has the speed hardcoded somewhere else. In that case its up to you to figure out the speed.


### GetProjectileGravity()


Returns the projectile gravity of the weapon, returns nil if the weapon is not a projectile weapon. Can return 0 if the weapon has the gravity hardcoded somewhere else. In that case its up to you to figure out the gravity.


### GetProjectileSpread()


Returns the projectile spread of the weapon, returns nil if the weapon is not a projectile weapon.


## ChargeUpWeapon methods


These methods are only available if the weapon is a charge up weapon, i.e. a weapon that can be charged up before firing.


### CanCharge()


Returns whether the weapon can be charged up.


### GetChargeBeginTime()


Returns the time the weapon started charging up, returns nil if the weapon is not a charge up weapon.


### GetChargeMaxTime()


Returns the max charge time of the weapon, returns nil if the weapon is not a charge up weapon.


### GetCurrentCharge()


Returns the current charge of the weapon, returns nil if the weapon is not a charge up weapon.


## Melee Weapon Methods


### GetSwingRange()


Returns the swing range of the weapon, returns nil if the weapon is not a melee weapon.


### DoSwingTrace()


Returns the [Trace object](../Trace/) result of the weapon's swing. In simple terms, it simulates what would weapon hit if it was swung.


### Medigun methods


### GetMedigunHealRate()


Returns the heal rate of the medigun, returns nil if the weapon is not a medigun.


### GetMedigunHealingStickRange()


Returns the healing stick range of the medigun, returns nil if the weapon is not a medigun.


### GetMedigunHealingRange()


Returns the healing range of the medigun, returns nil if the weapon is not a medigun.


### IsMedigunAllowedToHealTarget( target:Entity )


Returns whether the medigun is allowed to heal the target, returns nil if the weapon is not a medigun.


## Weapon Crit Methods


The following methods have close ties to random crits in TF2. You most likely do not need to use these methods. Feel free to use them though, I'm not here to stop you.


### GetCritTokenBucket()


Returns the current crit token bucket value.


### GetCritCheckCount()


Returns the current crit check count.


### GetCritSeedRequestCount()


Returns the current crit seed request count.


### GetCurrentCritSeed()


Returns the current crit seed.


### GetRapidFireCritTime()


Returns the time until the current rapid fire crit is over.


### GetLastRapidFireCritCheckTime()


Returns the time of the last rapid fire crit check.


### GetWeaponBaseDamage()


Returns the base damage of the weapon.


### GetCritChance()


Returns the weapon's current crit chance as a number from 0 to 1. This crit chance changes during gameplay based on player's recently dealt damage.


### GetCritCost( tokenBucket:number, critSeedRequestCount:number, critCheckCount:number )


Calculates the cost of a crit based on the given crit parameters. You can either use the GetCritTokenBucket(), GetCritCheckCount(), and GetCritSeedRequestCount() methods to get the current crit parameters, or you can pass your own if you are simulating crits.


### CalcObservedCritChance()


This function estimates the observed crit chance. The observed crit chance is calculated on the server from the damage you deal across a game round. It is only rarely sent to the client, but is important for crit calculations.


### IsAttackCritical( commandNumber:integer )


Returns whether the given command number would result in a crit.


### GetWeaponDamageStats()


Returns the current damage stats as a following table:



| Type | Damage |
| --- | --- |
| total | 1234 |
| critical | 250 |
| melee | 90 |


## Examples


Calculate needed crit hack damage
```
local myfont = draw.CreateFont( "Verdana", 16, 800 )

callbacks.Register( "Draw", function ()
    draw.Color(255, 255, 255, 255)
    draw.SetFont( myfont )

    local player = entities.GetLocalPlayer()
    local wpn = player:GetPropEntity("m_hActiveWeapon")

    if wpn ~= nil then
        local critChance = wpn:GetCritChance()
        local dmgStats = wpn:GetWeaponDamageStats()
        local totalDmg = dmgStats["total"]
        local criticalDmg = dmgStats["critical"]

        -- (the + 0.1 is always added to the comparsion)
        local cmpCritChance = critChance + 0.1

        -- If we are allowed to crit
        if cmpCritChance > wpn:CalcObservedCritChance() then
            draw.Text( 200, 510, "We can crit just fine!")
        else --Figure out how much damage we need
            local requiredTotalDamage = (criticalDmg * (2.0 * cmpCritChance + 1.0)) / cmpCritChance / 3.0
            local requiredDamage = requiredTotalDamage - totalDmg

            draw.Text( 200, 510, "Damage needed to crit: " .. math.floor(requiredDamage))
        end
    end
end )

```

Basic player ESP
```
local myfont = draw.CreateFont( "Verdana", 16, 800 )

local function doDraw()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return
    end

    local players = entities.FindByClass("CTFPlayer")

    for i, p in ipairs( players ) do
        if p:IsAlive() and not p:IsDormant() then

            local screenPos = client.WorldToScreen( p:GetAbsOrigin() )
            if screenPos ~= nil then
                draw.SetFont( myfont )
                draw.Color( 255, 255, 255, 255 )
                draw.Text( screenPos[1], screenPos[2], p:GetName() )
            end
        end
    end
end

callbacks.Register("Draw", "mydraw", doDraw) 

```

Draw local player hitboxes
```
callbacks.Register( "Draw", function ()
    local player = entities.GetLocalPlayer()
    local hitboxes = player:GetHitboxes()

    for i = 1, #hitboxes do
        local hitbox = hitboxes[i]
        local min = hitbox[1]
        local max = hitbox[2]

        -- to screen space
        min = client.WorldToScreen( min )
        max = client.WorldToScreen( max )

        if (min ~= nil and max ~= nil) then
            -- draw hitbox
            draw.Color(255, 255, 255, 255)
            draw.Line( min[1], min[2], max[1], min[2] )
            draw.Line( max[1], min[2], max[1], max[2] )
            draw.Line( max[1], max[2], min[1], max[2] )
            draw.Line( min[1], max[2], min[1], min[2] )
        end
    end
end )

```

Clip size attribute on player
```
local me = entities.GetLocalPlayer()

local myClipSizeMultiplier = me:AttributeHookFloat( "mult_clipsize" )

```

Clip size attribute on weapon
```
local me = entities.GetLocalPlayer()

local primaryWeapon = me:GetEntityForLoadoutSlot( LOADOUT_POSITION_PRIMARY )
local weaponClipSizeMultiplier = primaryWeapon:AttributeHookFloat( "mult_clipsize" )

```

Is player taunting
```
local me = entities.GetLocalPlayer()

local isTaunting = me:InCond( TFCond_Taunting )

```

Get rage meter value
```
local me = entities.GetLocalPlayer()

local rageMeter = me:GetPropFloat( "m_flRageMeter" )

```

Create custom entity sentry
```
local myEnt = nil

callbacks.Unregister( "CreateMove", "mycreate" )
callbacks.Register( "CreateMove", "mycreate", function( cmd )
    local pLocal = entities.GetLocalPlayer()

    if pLocal == nil then
        return
    end

    if myEnt ~= nil then
        if globals.TickCount() % 2 == 0 then
            if engine.RandomInt( 1, 100 ) > 32 then
                myEnt:SetModel( "models/buildables/sentry1.mdl" )
            elseif engine.RandomInt( 1, 100 ) > 64 then
                myEnt:SetModel( "models/buildables/sentry2.mdl" )
            else
                myEnt:SetModel( "models/buildables/sentry3.mdl" )
            end
        end

        if input.IsButtonDown( KEY_R ) then
            local source = pLocal:GetAbsOrigin() + pLocal:GetPropVector( "localdata", "m_vecViewOffset[0]" );
            local destination = source + engine.GetViewAngles():Forward() * 1000;
            local trace = engine.TraceLine( source, destination, MASK_SHOT_HULL );
            local pos = trace.endpos + Vector3( 0, 0, 10 )
            myEnt:SetAbsOrigin( pos )
            return
        end

        if input.IsButtonDown( KEY_T ) then
            myEnt:Release()
            myEnt = nil
            return
        end
    else
        myEnt = entities.CreateEntityByName( "grenade" )
        myEnt:SetModel( "models/buildables/sentry1.mdl" )
        client.ChatPrintf( "Created entity at " .. tostring( pos ) )

    end
end )

```


