# party

*Source: https://lmaobox.net/lua/Lua_Libraries/party/*

---



# party


The party library provides functions for managing the player's matchmaking party.
All functions return *nil* if the player is not in a party or the party client is not initialized.


## Functions


### GetLeader()


Returns the player's party leader's SteamID as string.


### GetMembers()


Returns a table containing the player's party members' SteamIDs as strings.



| Key Index | Value |
| --- | --- |
| 1 | STEAM_0:?:? |


### GetPendingMembers()


Returns a table containing the player's pending party members' SteamIDs as strings. These members are invited to party, but have not joined yet.


### GetGroupID()


Returns the player's party's group ID.


### GetQueuedMatchGroups()


Returns a table where values are the player's queued match groups as [MatchGroup](../../Lua_Classes/MatchGroup) objects.



| Key | Value |
| --- | --- |
| Casual | MatchGroup object |


### GetAllMatchGroups()


Returns a table where values are all possible match groups as [MatchGroup](../../Lua_Classes/MatchGroup) objects.



| Key | Value |
| --- | --- |
| Casual | MatchGroup object |


### Leave()


Leaves the current party.


### CanQueueForMatchGroup( matchGroup:MatchGroup )


Returns true if the player can queue for the given match group.
If the player can not queue for the match groups, returns a table of reasons why the player can not queue.



| Key | Value |
| --- | --- |
| 1 | Select at least one Mission in order to queue. |


### QueueUp( matchGroup:MatchGroup )


Requests to queue up for a match group.


### CancelQueue( matchGroup:MatchGroup )


Cancles the request to queue up for a match group.


### IsInStandbyQueue()


Whether the player is in the standby queue. That refers to queueing up for an ongoing match in your party.


### CanQueueForStandby()


Returns whether the player can queue up for a standby match. That refers to an ongoing match in your party.


### QueueUpStandby()


Requests to queue up for a standby match in your party. That refers to an ongoing match in your party.


### CancelQueueStandby()


Cancles the request to queue up for a standby match in your party. That refers to an ongoing match in your party.


### GetMemberActivity( index:integer )


Returns a [PartyMemberActivity](../../Lua_Classes/PartyMemberActivity) object for the party member at the given index. See GetMembers() for the index.


### PromoteMemberToLeader( steamid:string )


Promotes the given player to the party leader. Works only if you are the party leader.


### KickMember( steamid:string )


Kicks the given player from the party. Works only if you are the party leader.


### IsCasualMapSelected( map:MatchMapDefinition )


Returns true if the given map is selected for casual play.


### SetCasualMapSelected( map:MatchMapDefinition, selected:bool )


Sets the given map as selected for casual play.


## Examples


Queue up for casual
```
local casual = party.GetAllMatchGroups()["Casual"]

local reasons = party.CanQueueForMatchGroup( casual )

if reasons == true then
    party.QueueUp( casual )
else
    for k,v in pairs( reasons ) do
        print( v )
    end
end

```

Print all party members, but not the leader
```
local members = party.GetMembers()

for k, v in pairs( members ) do
    if v ~= party.GetLeader() then
        print( v )
    end
end

```

Am I in queue?
```
if #party.GetQueuedMatchGroups() > 0 then
    print( "I'm in queue!" )
end

```


