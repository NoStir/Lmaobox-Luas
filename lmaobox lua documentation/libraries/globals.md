# globals

*Source: https://lmaobox.net/lua/Lua_Libraries/globals/*

---



# globals


This library contains global source engine variables.


## Functions


### TickInterval()


Returns server tick interval


### TickCount()


Returns client tick count


### RealTime()


Returns the time since start of the game


### CurTime()


Returns the current time


### FrameCount()


Returns the frame count


### FrameTime()


Return delta time between frames


### AbsoluteFrameTime()


Return delta time between frames


### MaxClients()


Max player count of the current server


## Examples


FPS Counter - by x6h
```
local consolas = draw.CreateFont("Consolas", 17, 500)
local current_fps = 0

local function watermark()
  draw.SetFont(consolas)
  draw.Color(255, 255, 255, 255)

  -- update fps every 100 frames
  if globals.FrameCount() % 100 == 0 then
    current_fps = math.floor(1 / globals.FrameTime())
  end

  draw.Text(5, 5, "[lmaobox | fps: " .. current_fps .. "]")
end

callbacks.Register("Draw", "draw", watermark)
-- https://github.com/x6h

```


