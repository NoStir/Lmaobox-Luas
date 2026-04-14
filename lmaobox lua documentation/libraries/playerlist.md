# playerlist

*Source: https://lmaobox.net/lua/Lua_Libraries/playerlist/*

---



# playerlist


The playerlist library provides a way to retrieve values from, and customize the playerlist.


## Functions


### GetPriority( player:Entity )


Returns the priority of the player.


### GetPriority( userID:number )


Returns the priority of the player by user ID.


### GetPriority( steamID:string )


Returns the priority of the player by Steam ID.


### SetPriority( player:Entity, priority:number )'


Sets the priority of the player.


### SetPriority( userID:number, priority:number )


Sets the priority of the player by user ID.


### SetPriority( steamID:string, priority:number )


Sets the priority of the player by Steam ID.


### GetColor( player:Entity )


Returns the color of the player.


### GetColor( userID:number )


Returns the color of the player by user ID.


### GetColor( steamID:string )


Returns the color of the player by Steam ID.


### SetColor( player:Entity, color:number )


Sets the color of the player.


### SetColor( userID:number, color:number )


Sets the color of the player by user ID.


### SetColor( steamID:string, color:number )


Sets the color of the player by Steam ID.


## Examples


Get playerlist color by SteamID
```
local color = playerlist.GetColor("STEAM_0:0:123456789");

```

Set playerlist priority by SteamID
```
local priority = 1;

playerlist.SetPriority("STEAM_0:0:123456789", priority);

```


