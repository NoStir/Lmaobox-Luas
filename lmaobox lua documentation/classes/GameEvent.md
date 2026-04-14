# GameEvent

*Source: https://lmaobox.net/lua/Lua_Classes/GameEvent/*

---



# GameEvent


Represents a game event that was sent from the server. For a list of game events for Source games and TF2 see the [GameEvent List](https://wiki.alliedmods.net/Team_Fortress_2_Events).


## Methods


### GetName()


Returns the name of the event.


### GetString( fieldName:string )


Returns the string value of the given field.


### GetInt( fieldName:string )


Returns the int value of the given field.


### GetFloat( fieldName:string )


Returns the float value of the given field.


### SetString( fieldName:string, value:string )


Sets the string value of the given field.


### SetInt( fieldName:string, value:int )


Sets the int value of the given field.


### SetFloat( fieldName:string, value:float )


Sets the float value of the given field.


### SetBool( fieldName:string, value:bool )


Sets the bool value of the given field.


## Examples


Damage logger - by @RC
```
local function damageLogger(event)

    if (event:GetName() == 'player_hurt' ) then

        local localPlayer = entities.GetLocalPlayer();
        local victim = entities.GetByUserID(event:GetInt("userid"))
        local health = event:GetInt("health")
        local attacker = entities.GetByUserID(event:GetInt("attacker"))
        local damage = event:GetInt("damageamount")

        if (attacker == nil or localPlayer:GetIndex() ~= attacker:GetIndex()) then
            return
        end

        print("You hit " ..  victim:GetName() .. " or ID " .. victim:GetIndex() .. " for " .. damage .. "HP they now have " .. health .. "HP left")
    end

end

callbacks.Register("FireGameEvent", "exampledamageLogger", damageLogger)
-- Made by @RC: https://github.com/racistcop/lmaobox-luas/blob/main/example-damagelogger.lua

```


