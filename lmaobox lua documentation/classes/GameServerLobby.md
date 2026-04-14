# GameServerLobby

*Source: https://lmaobox.net/lua/Lua_Classes/GameServerLobby/*

---



# GameServerLobby


The GameServerLobby library provides information about the current match made game.


## Methods


### GetGroupID()


Returns the group ID of the current lobby.


### GetMembers()


Returns a table of [LobbyPlayer](../../Lua_Classes/LobbyPlayer) objects representing the players in the lobby.


## Examples


Print the steam IDs of all players in the lobby
```
local lobby = gamecoordinator.GetGameServerLobby()

if lobby then
    for _, player in pairs( lobby:GetMembers() ) do
        print( player:GetSteamID() )
    end
end

```


