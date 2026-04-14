# gui

*Source: https://lmaobox.net/lua/Lua_Libraries/gui/*

---



# gui


## Functions


### GetValue( msg:string )


Get current value of a setting


### SetValue( msg:string, index:integer )


Set current Integer value of a setting


### SetValue( msg:string, msg:string )


Set current Text value of a setting


### IsMenuOpen()


Returns true if lmaobox menu is open.


## Examples


Set aimbot settings
```
gui.SetValue("aim bot", 1);
gui.SetValue("aim method", "silent");

local aim_method = gui.GetValue("aim method");
print( aim_method ) -- prints 'silent'

```

Get current aimbot fov
```
local aim_fov = gui.GetValue("aim fov");
print( aim_fov )

```

Change ESP color for blue team
```
gui.SetValue("blue team color", 0xcaffffff)

```


