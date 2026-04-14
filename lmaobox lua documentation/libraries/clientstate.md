# clientstate

*Source: https://lmaobox.net/lua/Lua_Libraries/clientstate/*

---



# clientstate


The clientstate library is used to get information about the internal client state.


## Functions


### ForceFullUpdate()


Requests a full update from the server. This can lag the game a bit and should be used sparingly. It can even cause the game to crash if used incorrectly.


### GetClientSignonState()


Returns the current client signon state. This is useful for determining if the client is fully connected to the server.


### GetDeltaTick()


Returns the tick number of the last received tick.


### GetLastOutgoingCommand()


Returns the last outgoing command number.


### GetChokedCommands()


Returns the number of commands the client is currently choking.


### GetLastCommandAck()


Returns the last command acknowledged by the server.


### GetNetChannel()


Returns the [NetChannel](../../Lua_Classes/NetChannel/) object. This can be nil if the client is not connected to a server. NetChannel first spawns when a "client_connected" event is fired.


## Examples


Print the server's IP address
```
local netChannel = clientstate.GetNetChannel()

if netChannel then
    print(netChannel:GetAddress())
end

```


