# input

*Source: https://lmaobox.net/lua/Lua_Libraries/input/*

---



# input


The input library provides an interface to the user's keyboard and mouse.


## Functions


### GetMousePos()


Returns the current mouse position as a table where index 1 is x and index 2 is y.


### IsButtonDown( button:integer )


Returns true if the specified mouse button is down. Otherwise, it returns false.


### IsButtonPressed( button:integer )


Returns true if the specified mouse button was pressed. Otherwise, it returns false.
Second return value is the tick when button was pressed.


### IsButtonReleased( button:integer )


Returns true if the specified mouse button was released. Otherwise, it returns false.
Second return value is the tick when button was released.


### IsMouseInputEnabled()


Returns whether the mouse input is currently enabled.


### SetMouseInputEnabled( enabled:bool )


Sets whether the mouse is visible on screen and has priority on the topmost panel.


### GetPollTick()


Returns the tick when buttons have last been polled.


## Examples


Attack when user presses E
```
local function onCreateMove( cmd )
    if input.IsButtonDown( KEY_E ) then
        cmd.buttons = cmd.buttons | IN_ATTACK
    end
end

callbacks.Register( "CreateMove", onCreateMove )

```


