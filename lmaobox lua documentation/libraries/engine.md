# engine

*Source: https://lmaobox.net/lua/Lua_Libraries/engine/*

---



# engine


The engine library provides access to the game's core functionality.


## Functions


### Con_IsVisible()


Whether the game console is visible.


### IsGameUIVisible()


Whether the game UI is visible.


### IsChatOpen()


Whether the game chat is open.


### IsTakingScreenshot()


Whether the game is taking a screenshot.


### TraceLine( src:Vector3, dst:Vector3, mask:integer, [shouldHitEntity(ent:Entity, contentsMask:integer):Function] )


Traces line from src to dst, returns Trace class.
The shouldHitEntity function is optional, and can be used to filter out entities that should not be hit. It should return true if the entity should be hit, and false otherwise.


### TraceHull( src:Vector3, dst:Vector3, mins:Vector3, maxs:Vector3, mask:integer, [shouldHitEntity(ent:Entity, contentsMask:integer):Function] )


Traces hull from src to dst, returns Trace class.
The shouldHitEntity function is optional, and can be used to filter out entities that should not be hit. It should return true if the entity should be hit, and false otherwise.


### GetPointContents( pos:Vector3 )


Returns 2 values: mask as integer and entity as Entity class.
The mask is the contents of the point in 3D space, and the entity is the entity present at the point, can be nil.


### GetMapName()


Returns map name


### GetServerIP()


Returns server ip


### GetViewAngles()


Returns player view angles


### SetViewAngles( angles:EulerAngles )


Sets player view angles


### PlaySound( soundPath:string )


Plays a sound at the given path, relative to the game's root folder


### GetGameDir()


Returns game install directory


### SendKeyValues( keyValues:string )


Sends key values to server, returns true if successful, this can be used to send very specific commands to the server. For example, buy MvM upgrades, trigger noise makers...


### Notification( title:string, [longText:string] )


Creates a notification in the TF2 client. If longText is not specified, the notification will be a simple popup with title text. If longText is specified, the notification will be a popup with title text, which will open a large window with longText as text.


### RandomSeed( seed:integer )


Sets the seed for the game's uniform random number generator.


### RandomFloat( min:number, [max:number = 1] )


Returns a random number between min and max (inclusive), using the game's uniform random number generator.


### RandomInt( min:integer, [max:integer = 0x7FFF] )


Returns a random integer between min and max (inclusive), using the game's uniform random number generator.


### RandomFloatExp( min:number, max:number, [exponent:number = 1] )


Returns a random number between min and max using the exponent, using the game's uniform random number generator.


## Examples


Trigger noise maker without using a charge
```
local kv = [[
    "use_action_slot_item_server"
    {
    }
]]

engine.SendKeyValues( kv )

```

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

TraceLine with custom trace filter
```
local trace = engine.TraceLine( source, destination, MASK_SHOT_HULL, function ( entity, contentsMask )
        if ( entity:GetClass() == "CTFPlayer" ) then
            return true;
        end

        print("Entity: " .. entity:GetClass() .. " is not a player")
        return false;
    end );

```


