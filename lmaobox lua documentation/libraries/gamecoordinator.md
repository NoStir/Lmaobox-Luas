# gamecoordinator

*Source: https://lmaobox.net/lua/Lua_Libraries/gamecoordinator/*

---



# gamecoordinator


The gamecoordinator library provides information about the state of the matchmaking system and current match made game.


## Functions


### ConnectedToGC()


Returns true if the player is connected to the game coordinator.


### InEndOfMatch()


Returns true if the player is in the end of match phase.


### HasLiveMatch()


Returns true if the player is assigned to a live match.


### IsConnectedToMatchServer()


Returns true if the player is connected to the assigned match server.


### AbandonMatch()


Abandons the current match and forcefully disconnects the player from the match server.


### GetMatchAbandonStatus()


Returns the status of the match relative to the player connection.


### GetDataCenterPingData()


Returns the ping data for all available data centers in a table.
Table example:



| DataCenter | Ping |
| --- | --- |
| syd | 35 |


### GetNumMatchInvites()


Returns the number of match invites the player has.


### AcceptMatchInvites()


Accepts all match invites the player has. Usually it's just one, and they are automatically accepted after some time anyway so you can selectively accept them. Accepting an invite does not immediately join you into the match.


### JoinMatchmakingMatch()


Joins the match the player is currently assigned to from the previously acccepted match invite. This is usually called after accepting a match invite if the player wants to join the match. If not, call AbandonMatch() to leave the match.


### EnumerateQueueMapsHealth( function( MatchMapDefinition, number ) ) )


Enumerates the maps in the queue and calls the callback function for each map. The callback function receives the [MatchMapDefinition](../../Lua_Classes/MatchMapDefinition) and the health of the map represented as a number from 0 to 1. You must receive the GameCoordinator's map health update at least once to use this function (i.e. by queueing up).


### GetGameServerLobby()


Returns the [GameServerLobby](../../Lua_Classes/GameServerLobby) object for the current match or nil if the player is not in a match.


### GCSendMessage( typeID:integer, data:bytes)


Sends a message to the game coordinator. You can use this to send custom messages to the game coordinator. The typeID is the message type, and data is the message data. The data must be a string of protobuf encoded bytes.


## Examples


Select cp_dustbowl map and print all selected maps
```
gamecoordinator.EnumerateQueueMapsHealth( function( map, health )

    if map:GetName() == "cp_dustbowl" then
        party.SetCasualMapSelected( map, true )
    end

    if party.IsCasualMapSelected( map ) then
        print( "Selected: " .. map:GetName() .. ": " .. tostring(health) )
    end

end )

```


