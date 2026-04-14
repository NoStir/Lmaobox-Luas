# UserMessage

*Source: https://lmaobox.net/lua/Lua_Classes/UserMessage/*

---



# UserMessage


Received as the only argument in DispatchUserMessage callback.


## Reading


Reading starts at the beginning of the message (curBit = 0). Each call to Read*() advances the read cursor by the number of bits read. Reading past the end of the message will cause an error.


### GetID()


Returns the ID of the message. You can get the list here: [TF2 User Messages](https://wiki.alliedmods.net/User_messages).


### GetBitBuffer()


Returns the [BitBuffer](../BitBuffer/) object that contains the message data.


## Example


Print chat messages from players
```
local function myCoolMessageHook(msg)

    if msg:GetID() == SayText2 then 
        local bf = msg:GetBitBuffer()

        bf:SetCurBit(8)-- skip 1 byte of not useful data

        local chatType = bf:ReadString(256)
        local playerName = bf:ReadString(256)
        local message = bf:ReadString(256)

        print("Player " .. playerName .. " said " .. message)
    end

end

callbacks.Register("DispatchUserMessage", myCoolMessageHook)

```


