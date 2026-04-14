# UserCmd

*Source: https://lmaobox.net/lua/Lua_Classes/UserCmd/*

---



# UserCmd


Represents a user (movement) command about to be sent to the server. For more in depth insight see the [UserCmd](https://developer.valvesoftware.com/wiki/Usercmd) page.


## Fields


Fields are modifiable directly.


### command_number


integer


The number of the command.


### tick_count


integer


The current tick count.


### viewangles


EulerAngles


The view angles of the player.


### forwardmove


number


The forward movement of the player.


### sidemove


number


The sideways movement of the player.


### upmove


number


The upward movement of the player.


### buttons


integer (bits)


The buttons that are pressed. Masked with bits from `IN_*` enum


### impulse


integer


The impulse command that was issued.


### weaponselect


integer


The weapon id that is selected.


### weaponsubtype


integer


The subtype of the weapon.


### random_seed


integer


The random seed of the command.


### mousedx


integer


The mouse delta in the x direction.


### mousedy


integer


The mouse delta in the y direction.


### hasbeenpredicted


boolean


Whether the command has been predicted.


### sendpacket


boolean


Whether the command should be sent to the server or choked.


## Methods


### SetViewAngles( pitch, yaw, roll )


Sets the view angles of the player.


### GetViewAngles()


returns: pitch, yaw, roll


### SetSendPacket( sendpacket )


Sets whether the command should be sent to the server or choked.


### GetSendPacket()


returns: sendpacket


### SetButtons( buttons )


Sets the buttons that are pressed.


### GetButtons()


returns: buttons


### SetForwardMove( float factor )


Sets the forward movement of the player.


### GetForwardMove()


returns: forwardmove


### SetSideMove( float factor )


Sets the sideways movement of the player.


### GetSideMove()


returns: sidemove


### SetUpMove( float factor )


Sets the upward movement of the player.


### GetUpMove()


returns: upmove


## Examples


Simple Bunny hop
```
local function doBunnyHop( cmd )
    local player = entities.GetLocalPlayer( );

    if (player ~= nil or not player:IsAlive()) then
    end

    if input.IsButtonDown( KEY_SPACE ) then

        local flags = player:GetPropInt( "m_fFlags" );

        if flags & FL_ONGROUND == 1 then
            cmd:SetButtons(cmd.buttons | IN_JUMP)
        else 
            cmd:SetButtons(cmd.buttons & (~IN_JUMP))
        end
    end
end

callbacks.Register("CreateMove", "myBhop", doBunnyHop)

```


