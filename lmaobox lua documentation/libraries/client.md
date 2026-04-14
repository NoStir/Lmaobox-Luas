# client

*Source: https://lmaobox.net/lua/Lua_Libraries/client/*

---



# client


The client library is used to get information about the client.


## Functions


### GetExtraInventorySlots()


Returns the number of extra inventory slots the user has.


### IsFreeTrialAccount()


Returns whether the user is a free trial account.


### HasCompetitiveAccess()


Returns whether the user has competitive access.


### IsInCoachesList()


Returns whether the user is in the coaches list.


### WorldToScreen( worldPos:Vector3, [view:ViewSetup] )


Translate world position into screen position (x,y). view is optional, and of type [ViewSetup](../../Lua_Classes/ViewSetup/)


### Command( command:string, unrestrict:bool )


Run command in game console


### ChatSay( msg:string )


Say text on chat


### ChatTeamSay( msg:string )


Say text on team chat


### AllowListener( eventName:string )


DOES NOTHING. All events are allowed by default. This function is deprecated and it's only there to not cause errors in existing scripts.


### GetPlayerNameByIndex( index:integer )


Return player name by index


### GetPlayerNameByUserID( userID:integer )


Return player name by user id


### GetPlayerInfo( index:integer )


Returns the following table:



| Variable | Value |
| --- | --- |
| Name | playername |
| UserID | number |
| SteamID | STEAM_0:?:? |
| IsBot | true/false |
| IsHLTV | true/false |


### GetPlayerView()


Returns the players view setup. See [ViewSetup](../../Lua_Classes/ViewSetup/) for more information.


### GetLocalPlayerIndex()


Return local player index


### GetConVar( name:string )


Get game convar value. Returns integer, number and string if found. Returns nil if not found.


### SetConVar( name:string, value:any )


Set game convar value. Value can be integer, number, string.


### RemoveConVarProtection( name:string )


Remove convar protection. This is needed for convars that are not allowed to be changed by the server.


### ChatPrintf( msg:string )


Print text on chat, this text can be colored. Color codes are:



- \x01 - White color
- \x02 - Old color
- \x03 - Player name color
- \x04 - Location color
- \x05 - Achievement color
- \x06 - Black color
- \x07 - Custom color, read from next 6 characters as HEX
- \x08 - Custom color with alpha, read from next 8 characters as HEX


### Localize ( key:string )


Returns a localized string. The localizable strings usually start with a `#` character, but there are exceptions. Will return nil on failure.


## Examples


Print colored chat message
```
if client.ChatPrintf( "\x06[\x07FF1122LmaoBox\x06] \x04You died!" ) then
    print( "Chat message sent" )
end

```

Get player name
```
local me = client.GetLocalPlayer()
local name = client.GetPlayerNameByIndex(me:GetIndex())
print( name )

```

Get player steam id
```
local me = client.GetLocalPlayer()
local playerInfo = client.GetPlayerInfo(me:GetIndex())
local steamID = playerInfo.SteamID
print( steamID )

```


