# gamerules

*Source: https://lmaobox.net/lua/Lua_Libraries/gamerules/*

---



# gamerules


The `gamerules` library contains functions for detecting the game rules of a TF2 match.


## Functions


### IsMatchTypeCasual()


Returns true if the match is a casual match.


### IsMatchTypeCompetitive()


Returns true if the match is a competitive match.


### IsManagedMatchEnded()


Returns true if the matchmaking match has ended.


### GetTimeLeftInMatch()


Returns the time left in the match.


### IsTruceActive()


When truce is active, players cannot attack each other.


### IsMvM()


Returns true if the current match is a MvM game.


### GetCurrentMatchGroup()


Returns the current match group.


### IsUsingGrapplingHook()


Returns true if current gamemode allows players to use the grappling hook.


### IsUsingSpells()


Returns true if current gamemode allows players to use spells.


### GetCurrentNextMapVotingState()


Returns the current next map voting state.


### GetPlayerVoteState ( playerIndex:integer )


Returns the vote state of the player with the given index.


### GetRoundState()


Returns the current state of the round as integer.



| State | Meaning |
| --- | --- |
| 0 | ROUND_INIT |
| 1 | ROUND_PREGAME |
| 2 | ROUND_STARTGAME |
| 3 | ROUND_PREROUND |
| 4 | ROUND_RUNNING |
| 5 | ROUND_TEAMWIN |
| 6 | ROUND_RESTART |
| 7 | ROUND_STALEMATE |
| 8 | ROUND_GAMEOVER |
| 9 | ROUND_BONUS |
| 10 | ROUND_BETWEEN_ROUNDS |


## Examples


Prevent player from attacking during Truce
```
local function onCreateMove( cmd )
    if gamerules.IsTruceActive() then
        cmd.buttons = cmd.buttons & ~IN_ATTACK
    end
end

callbacks.Register("CreateMove", onCreateMove)

```


