# LobbyPlayer

*Source: https://lmaobox.net/lua/Lua_Classes/LobbyPlayer/*

---



# LobbyPlayer


The LobbyPlayer class is used to provide information about a player in a Game Server lobby.


## Methods


### GetSteamID()


Returns the SteamID of the player as a string.


### GetTeam()


Returns the GC assigned team of the player.


### GetPlayerType()


Returns the GC assigned player type of this player.


### GetName()


Returns the steam name of the player.


### GetLastConnectTime()


Returns the last time the player connected to the server as a unix timestamp.


### GetNormalizedRating()


Returns the normalized rating of the player - a measure of the player's skill?


### GetNormalizedUncertainty()


Returns the normalized uncertainty of the player - a measure of how confident the GC is in the player's rating.


### GetRank()


Returns the rank of the player. Integer representing the player's rank.


### IsChatSuspended()


Returns true if the player is chat suspended.


## Examples


Print the steam IDs and teams of all players in a found lobby
```
callbacks.Register( "OnLobbyUpdated", "mylobby", function( lobby )
    for _, player in pairs( lobby:GetMembers() ) do
        print( player:GetSteamID(), player:GetTeam() )
    end
end )

```


