# NetMessage

*Source: https://lmaobox.net/lua/Lua_Classes/NetMessage/*

---



# NetMessage


The NetMessage class represents a network message. It is used to read and write data to the network stream.


## Methods


### GetGroup()


Returns the message group.


### GetNetChannel()


Returns the [NetChannel](../NetChannel/) object that the message belongs to.


### IsReliable()


Returns true if the message is reliable.


### SetReliable( reliable:boolean )


Sets the message to be reliable or unreliable.


### GetType()


Returns the message type.


### GetName()


Returns the message name.


### ToString()


Returns the message as a human readable string with the contents of the message.


### WriteToBitBuffer( bitBuffer:BitBuffer )


Writes the message content to a [BitBuffer](../BitBuffer/), useful for reading its variables via the bit buffer. Make sure that current bit position is correct and that you do not overflow the buffer.


### ReadFromBitBuffer( bitBuffer:BitBuffer )


Reads the message content from a [BitBuffer](../BitBuffer/) and applies it to the message. If done in SendNetMsg callback, the sent message will be changed. Make sure that current bit position is correct.


## Examples


Read & Write a net_tick message
```
-- Create a new bitbuffer
local bf = BitBuffer()

callbacks.Register( "SendNetMsg", function( msg, reliable, voice )

  if msg:GetType() == 3 then -- net_tick
    bf:Reset()
    msg:WriteToBitBuffer(bf)

    bf:SetCurBit(0)
    local type = bf:ReadInt(6) -- 6 bits of NETMSG_TYPE_BITS
    local tick = bf:ReadInt(32)

    print("tick: " .. tick .. " type: " .. type)

    -- Write a new tick if we want (but dotn do it, you will get kicked)
    bf:SetCurBit(0)
    bf:WriteInt( tick, 32 ) 
    bf:SetCurBit(0)

    -- Write the new tick to the message
    msg:ReadFromBitBuffer(bf)

    print("msg: " .. msg:ToString()) -- See the result
  end

  return true
end )

callbacks.Register("Unload", function()
  bf:Delete() -- delete the bitbuffer
end)

```


