# BitBuffer

*Source: https://lmaobox.net/lua/Lua_Classes/BitBuffer/*

---



# BitBuffer


The BitBuffer object is used to read and write data that is usually sent over the network, compressed into a bitstream.


## Constructor


## BitBuffer( )


Creates a new BitBuffer object with an empty buffer. You can write to it using methods below or have some other functions write to it for you, such as [NetMessage::WriteToBitBuffer](../NetMessage/) .


## Methods


### GetDataBitsLength()


Returns the length of the buffer in bits


### GetDataBytesLength()


Returns the length of the buffer in bytes


### Reset()


Resets the read position to the beginning of the buffer. This is useful if you want to read the buffer multiple times, but it is not necessary. 


### ReadByte()


Reads one byte from the buffer. Returns the byte read as first return value, and current bit position as second return value.


### ReadBit()


Reads a single bit from the buffer. Returns the bit read as first return value, and current bit position as second return value.


### ReadFloat( [bitLength:integer] )


Reads 4 bytes from the buffer and returns it as a float. Default bitLength is 32 (4 bytes). For short, use 16, for long, use 64. Returns the float read as first return value, and current bit position as second return value.


### ReadInt( [bitLength:integer] )


Reads 4 bytes from the buffer and returns it as an integer. Default bitLength is 32 (4 bytes). For short, use 16, for long, use 64. Returns the integer read as first return value, and current bit position as second return value.


### ReadString( maxlen:integer )


Reads a string from the buffer. You must specify valid maxlen. The string will be truncated if it is longer than maxlen. Returns the string read as first return value, and current bit position as second return value.


### GetCurBit()


Returns the current bit position in the buffer.


## Writing


When writing, make sure that your curBit is correct and that you do not overflow the buffer.


### SetCurBit( bit:integer )


Sets the current bit position in the buffer.


### WriteBit( bit:integer )


Writes a single bit to the buffer.


### WriteByte( byte:integer )


Writes a single byte to the buffer.


### WriteString( str:string )


Writes given string to the buffer.


### WriteInt( int:integer, [bitLength:integer] )


Writes an integer to the buffer. Default bitLength is 32 (4 bytes). For short, use 16, for long, use 64.


### WriteFloat( value:number, [bitLength:integer] )


Writes a float to the buffer. Default bitLength is 32 (4 bytes). For short, use 16, for long, use 64.


## Examples


Write and print with a BitBuffer
```
local bitBuffer = BitBuffer()

bitBuffer:WriteString("Hello world!")
bitBuffer:WriteInt(1234567890)
bitBuffer:WriteByte(254)
bitBuffer:WriteBit(1)

bitBuffer:SetCurBit(0)
local str = bitBuffer:ReadString(256)
local int = bitBuffer:ReadInt(32)
local byte = bitBuffer:ReadByte()
local bit = bitBuffer:ReadBit()
print(str, int, byte, bit)

bitBuffer:Delete()

```

```lua title="Write and print with a NetMessage"



