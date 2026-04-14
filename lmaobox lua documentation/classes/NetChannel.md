# NetChannel

*Source: https://lmaobox.net/lua/Lua_Classes/NetChannel/*

---



# NetChannel


The NetChannel object is used to get information about the network channel.


## Methods


### GetName()


Returns the name of the channel.


### GetAddress()


Returns the IP address of the server.


### GetConnectTime()


Returns the time the client connected to the server.


### GetTimeSinceLastReceived()


Returns the time since the last tick was received.


### GetLatency( flow:integer )


Returns the latency of the specified flow. Use E_Flows contants.


### GetAvgLatency( flow:integer )


Returns the average latency of the specified flow. Use E_Flows contants.


### GetAvgChoke( flow:integer )


Returns the average choke of the specified flow. Use E_Flows contants.


### GetAvgLoss( flow:integer )


Returns the average loss of the specified flow. Use E_Flows contants.


### GetAvgData( flow:integer )


Returns the average data of the specified flow. Use E_Flows contants.


### GetTime()


Returns the current net time.


### GetTimeConnected()


Returns the time when channel connected to the server.


### GetBufferSize()


Returns the size of the buffer.


### GetDataRate()


Returns the current data rate.


### IsLoopback()


Returns true if the channel is loopback.


### IsTimingOut()


Returns true if the channel is timing out.


### IsPlayback()


Returns true if the channel is a demo playback.


### SetDataRate( rate:number )


Sets the data rate.


### SetTimeout( seconds:number )


Sets the channel timeout time.


### SetChallengeNr( challenge:number )


Sets the challenge number.


### SendNetMsg( msg:NetMessage, forceReliable:boolean, voice:boolean )


Sends a network message, msg is of type [NetMessage](../NetMessage/).


### SendData( data:BitBuffer, reliable:boolean )


Sends data, data is of type [BitBuffer](../BitBuffer/).


### GetSequenceData()


Gets the sequence data. Returns 3 values: outSequenceNr, inSequenceNr, outSequenceNrAck.


### SetSequenceData( outSequenceNr:integer, inSequenceNr:integer, outSequenceNrAck:integer )


Sets the sequence data.


### SetInterpolationAmount( interp:number )


Sets the interpolation amount.


### GetChallengeNr()


Returns the challenge number.


## Examples


Set sequence data to +1
```
local netChannel = clientstate.GetNetChannel()

if netChannel then
    local outSequenceNr, inSequenceNr, outSequenceNrAck = netChannel:GetSequenceData()
    netChannel:SetSequenceData(outSequenceNr + 1, inSequenceNr, outSequenceNrAck)
end

```


