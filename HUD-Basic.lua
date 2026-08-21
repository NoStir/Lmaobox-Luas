-- GENERATED FILE — do not edit. Built by build.lua on 2026-08-19 18:12:37
-- Retained-mode GUI library for the TF2 Lua environment.

local __modules, __loaded = {}, {}
local function __require(name)
    local m = __loaded[name]
    if m == nil then
        local mod = __modules[name]
        if mod == nil then error("bundle: unknown module '" .. tostring(name) .. "'") end
        m = mod(__require)
        if m == nil then m = true end
        __loaded[name] = m
    end
    return m
end

__modules["core.util"] = function(require)
-- core.util — class helper, math/geometry helpers, color conversion.
-- No dependencies. Everything that touches draw coords goes through floor helpers.

local util = {}

--- Plain metatable single-inheritance class.
--- local C = util.class(Base); function C:Init(...) end; local obj = C.new(...)
function util.class(base)
    local c = {}
    c.__index = c
    if base then
        setmetatable(c, { __index = base })
    end
    c.new = function(...)
        local o = setmetatable({}, c)
        if o.Init then
            o:Init(...)
        end
        return o
    end
    return c
end

util.floor = math.floor

function util.round(v)
    return math.floor(v + 0.5)
end

function util.clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

function util.pointIn(px, py, x, y, w, h)
    return px >= x and px < x + w and py >= y and py < y + h
end

--- draw.FilledRect taking x,y,w,h with flooring at the draw boundary.
function util.rect(x, y, w, h)
    x, y = math.floor(x), math.floor(y)
    draw.FilledRect(x, y, math.floor(x + w), math.floor(y + h))
end

--- draw.OutlinedRect taking x,y,w,h with flooring at the draw boundary.
function util.outline(x, y, w, h)
    x, y = math.floor(x), math.floor(y)
    draw.OutlinedRect(x, y, math.floor(x + w), math.floor(y + h))
end

function util.line(x1, y1, x2, y2)
    draw.Line(math.floor(x1), math.floor(y1), math.floor(x2), math.floor(y2))
end

function util.text(x, y, s)
    draw.Text(math.floor(x), math.floor(y), s)
end

--- Fit text into maxW pixels using the CURRENT font: unchanged when it
--- already fits, otherwise the longest prefix that fits with "..." appended.
--- There is no clip rect in this environment, so every text draw that sits
--- inside a resizable rect must go through this.
function util.truncate(text, maxW)
    if maxW <= 0 then return "" end
    if draw.GetTextSize(text) <= maxW then return text end
    while #text > 1 do
        text = text:sub(1, #text - 1)
        if draw.GetTextSize(text .. "...") <= maxW then
            return text .. "..."
        end
    end
    return text
end

--- Deep-merge src into dst (tables merged recursively, scalars overwrite).
function util.deepMerge(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then
            util.deepMerge(dst[k], v)
        else
            dst[k] = v
        end
    end
    return dst
end

--- h, s, v in [0,1] -> r, g, b in [0,255]
function util.hsvToRgb(h, s, v)
    local i = math.floor(h * 6) % 6
    local f = h * 6 - math.floor(h * 6)
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    local r, g, b
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q end
    return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
end

--- r, g, b in [0,255] -> h, s, v in [0,1]
function util.rgbToHsv(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local maxc, minc = math.max(r, g, b), math.min(r, g, b)
    local d = maxc - minc
    local h
    if d == 0 then
        h = 0
    elseif maxc == r then
        h = ((g - b) / d) % 6
    elseif maxc == g then
        h = (b - r) / d + 2
    else
        h = (r - g) / d + 4
    end
    h = h / 6
    local s = maxc == 0 and 0 or d / maxc
    return h, s, maxc
end

return util
end

__modules["theme"] = function(require)
-- theme — centralized colors, metrics, and a lazy font cache.
--
-- Every pixel metric and font height derives from a base table (designed at
-- 1080p) multiplied by theme.scale. HighRes mode (on by default) computes the
-- scale from the screen resolution — screenHeight / 1080 — so the UI keeps
-- its intended physical size on 1440p/4K screens instead of shrinking; a user
-- multiplier stacks on top for taste. Fonts are recreated whenever the scale
-- or resolution changes (the classic Source font-invalidation trigger).

local util = require("core.util")

local theme = {}

theme.colors = {
    windowBg       = { 24, 24, 28, 250 },
    titleBar       = { 34, 34, 40, 255 },
    titleBarFocus  = { 44, 44, 52, 255 },
    widgetBg       = { 44, 44, 50, 255 },
    widgetHover    = { 56, 56, 64, 255 },
    widgetActive   = { 70, 70, 80, 255 },
    accent         = { 255, 150, 0, 255 },
    accentDim      = { 180, 105, 0, 255 },
    border         = { 62, 62, 70, 255 },
    text           = { 235, 235, 235, 255 },
    textDim        = { 155, 155, 160, 255 },
    popupBg        = { 30, 30, 34, 255 },
    scrollTrack    = { 34, 34, 40, 255 },
    scrollThumb    = { 70, 70, 80, 255 },
}

-- 1080p-reference values; theme.metrics is this table scaled by theme.scale.
theme.baseMetrics = {
    padding      = 8,
    spacing      = 6,
    rowHeight    = 20,
    titleHeight  = 20,
    checkSize    = 14,
    sliderTrackH = 8,
    scrollbarW   = 8,
    popupRowH    = 18,
    labelGap     = 16, -- label strip above textbox/combo/multiselect controls
    hotspotW     = 16, -- VirtualList trailing click zone
    indentW      = 12, -- VirtualList indent step
    scrollStep   = 3,  -- rows per wheel tick (a count, never scaled)
}

theme.baseFontDefs = {
    default = { face = "Verdana", height = 14, weight = 500 },
    title   = { face = "Verdana", height = 14, weight = 700 },
    small   = { face = "Verdana", height = 11, weight = 400 },
}

theme.highres = true  -- auto-scale to the screen resolution
theme.userScale = 1.0 -- extra multiplier on top of the auto scale
theme.scale = 1.0     -- effective scale, derived; read via ui.GetScale()

theme.metrics = {}
theme.fontDefs = {}

local UNSCALED = { scrollStep = true }

local fontCache = {}
local cachedW, cachedH = 0, 0

--- Scale a 1080p-reference pixel value by the effective UI scale.
function theme.S(px)
    if px == 0 then return 0 end
    local v = math.floor(px * theme.scale + 0.5)
    if px > 0 and v < 1 then v = 1 end
    return v
end

local function applyScale()
    for k, v in pairs(theme.baseMetrics) do
        theme.metrics[k] = UNSCALED[k] and v or theme.S(v)
    end
    for name, def in pairs(theme.baseFontDefs) do
        theme.fontDefs[name] = {
            face = def.face,
            height = math.max(6, theme.S(def.height)),
            weight = def.weight,
        }
    end
    fontCache = {}
end

--- Recompute the effective scale from the screen size and the highres/user
--- settings; reapplies metrics and fonts when it changed. Called once at
--- load and at the start of every frame (cheap when nothing changed).
function theme.Refresh()
    local auto = 1.0
    if theme.highres then
        local _, sh = draw.GetScreenSize()
        if sh and sh > 0 then
            auto = util.clamp(sh / 1080, 1.0, 3.0)
        end
    end
    local s = util.clamp(auto * theme.userScale, 0.5, 4.0)
    if s ~= theme.scale then
        theme.scale = s
        applyScale()
    end
end

function theme.SetHighRes(b)
    theme.highres = b and true or false
    theme.Refresh()
end

function theme.SetUserScale(mult)
    theme.userScale = util.clamp(tonumber(mult) or 1.0, 0.5, 4.0)
    theme.Refresh()
end

--- Returns the font id for a named font def, (re)creating it lazily.
function theme.GetFont(name)
    local w, h = draw.GetScreenSize()
    if w ~= cachedW or h ~= cachedH then
        fontCache = {}
        cachedW, cachedH = w, h
    end
    local id = fontCache[name]
    if id == nil then
        local def = theme.fontDefs[name] or theme.fontDefs.default
        local flags = (FONTFLAG_CUSTOM or 0x400) | (FONTFLAG_ANTIALIAS or 0x010)
        id = draw.CreateFont(def.face, def.height, def.weight, flags)
        fontCache[name] = id
    end
    return id
end

--- draw.SetFont for a named font def. Call before any GetTextSize/Text.
function theme.SetFont(name)
    draw.SetFont(theme.GetFont(name))
end

--- draw.Color from a {r,g,b,a} theme color.
function theme.Color(c)
    draw.Color(c[1], c[2], c[3], c[4])
end

--- Deep-merge user overrides into the theme. Metric and font overrides are
--- 1080p-reference values (they participate in HighRes scaling).
function theme.Merge(overrides)
    if type(overrides) ~= "table" then return end
    if overrides.colors then util.deepMerge(theme.colors, overrides.colors) end
    if overrides.metrics then util.deepMerge(theme.baseMetrics, overrides.metrics) end
    if overrides.fontDefs then util.deepMerge(theme.baseFontDefs, overrides.fontDefs) end
    applyScale()
end

applyScale()    -- populate metrics/fontDefs at scale 1
theme.Refresh() -- pick up the real screen scale

return theme
end

__modules["core.keymap"] = function(require)
-- core.keymap — E_ButtonCode -> character tables (with shift variants) and
-- human-readable key names for the keybind widget.
-- Code values are fixed by the environment (see Lua_Constants.md):
-- KEY_0..KEY_9 = 1..10, KEY_A..KEY_Z = 11..36, numpad = 37..52,
-- punctuation = 53..63, MOUSE_LEFT..MOUSE_WHEEL_DOWN = 107..113.

local keymap = {}

-- chars[code] = { normal, shifted }
local chars = {}

-- Digit row: KEY_0 = 1 .. KEY_9 = 10
local digitShift = { ["0"] = ")", ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$",
                     ["5"] = "%", ["6"] = "^", ["7"] = "&", ["8"] = "*", ["9"] = "(" }
for d = 0, 9 do
    local ch = tostring(d)
    chars[1 + d] = { ch, digitShift[ch] }
end

-- Letters: KEY_A = 11 .. KEY_Z = 36
for i = 0, 25 do
    local lower = string.char(string.byte("a") + i)
    chars[11 + i] = { lower, lower:upper() }
end

-- Numpad digits: KEY_PAD_0 = 37 .. KEY_PAD_9 = 46 (no shift variants)
for d = 0, 9 do
    local ch = tostring(d)
    chars[37 + d] = { ch, ch }
end
chars[47] = { "/", "/" }  -- KEY_PAD_DIVIDE
chars[48] = { "*", "*" }  -- KEY_PAD_MULTIPLY
chars[49] = { "-", "-" }  -- KEY_PAD_MINUS
chars[50] = { "+", "+" }  -- KEY_PAD_PLUS
-- KEY_PAD_ENTER (51) is handled as Enter, not a character
chars[52] = { ".", "." }  -- KEY_PAD_DECIMAL

-- Punctuation row: KEY_LBRACKET = 53 .. KEY_EQUAL = 63
local punct        = { "[", "]", ";", "'", "`", ",", ".", "/", "\\", "-", "=" }
local punctShifted = { "{", "}", ":", "\"", "~", "<", ">", "?", "|", "_", "+" }
for i = 1, #punct do
    chars[52 + i] = { punct[i], punctShifted[i] }
end

chars[65] = { " ", " " } -- KEY_SPACE

keymap.chars = chars

--- Returns the character for a button code given shift state, or nil.
function keymap.CharFor(code, shifted)
    local c = chars[code]
    if not c then return nil end
    return shifted and c[2] or c[1]
end

-- names[code] = display name for keybind widget
local names = {}
for d = 0, 9 do names[1 + d] = tostring(d) end
for i = 0, 25 do names[11 + i] = string.char(string.byte("A") + i) end
for d = 0, 9 do names[37 + d] = "NUM " .. d end
names[47], names[48], names[49] = "NUM /", "NUM *", "NUM -"
names[50], names[51], names[52] = "NUM +", "NUM ENTER", "NUM ."
for i = 1, #punct do names[52 + i] = punct[i] end
names[64], names[65], names[66], names[67] = "ENTER", "SPACE", "BACKSPACE", "TAB"
names[68], names[69], names[70], names[71] = "CAPSLOCK", "NUMLOCK", "ESC", "SCROLLLOCK"
names[72], names[73], names[74], names[75] = "INSERT", "DELETE", "HOME", "END"
names[76], names[77], names[78] = "PGUP", "PGDN", "BREAK"
names[79], names[80], names[81], names[82] = "LSHIFT", "RSHIFT", "LALT", "RALT"
names[83], names[84], names[85], names[86] = "LCTRL", "RCTRL", "LWIN", "RWIN"
names[87] = "APP"
names[88], names[89], names[90], names[91] = "UP", "LEFT", "DOWN", "RIGHT"
for i = 1, 12 do names[91 + i] = "F" .. i end
names[104], names[105], names[106] = "CAPSTOGGLE", "NUMTOGGLE", "SCROLLTOGGLE"
names[107], names[108], names[109] = "MOUSE1", "MOUSE2", "MOUSE3"
names[110], names[111] = "MOUSE4", "MOUSE5"
names[112], names[113] = "MWHEELUP", "MWHEELDOWN"

keymap.names = names

--- Display name for a button code ("NONE" for 0/nil, "KEY <n>" for unknown).
function keymap.NameFor(code)
    if not code or code == 0 then return "NONE" end
    return names[code] or ("KEY " .. tostring(code))
end

return keymap
end

__modules["core.input"] = function(require)
-- core.input — one InputState snapshot per frame.
-- input.IsButtonPressed/IsButtonReleased are edge-triggered; each edge is
-- read exactly once per frame here, and every widget reads the snapshot.

local util = require("core.util")

local Input = {}

local MAX_CODE = 113 -- MOUSE_WHEEL_DOWN, the last E_ButtonCode

local M_LEFT       = MOUSE_LEFT or 107
local M_WHEEL_UP   = MOUSE_WHEEL_UP or 112
local M_WHEEL_DOWN = MOUSE_WHEEL_DOWN or 113

local InputState = util.class()

-- The environment polls buttons at input-tick rate (66/s) but Draw runs per
-- frame, so at high FPS IsButtonPressed reports the SAME press across several
-- consecutive frames. IsButtonPressed/IsButtonReleased return the tick of the
-- event as a second value — an edge only counts if that tick is new for the
-- code, collapsing the repeats into exactly one edge per physical press.
local lastPressTick, lastReleaseTick = {}, {}

function InputState:Init()
    local mp = input.GetMousePos()
    self.mx = math.floor(mp[1])
    self.my = math.floor(mp[2])

    -- Read every press edge once; derive named flags from the set.
    local pressedSet, pressedList = {}, {}
    for code = 1, MAX_CODE do
        local pressed, tick = input.IsButtonPressed(code)
        if pressed and lastPressTick[code] ~= tick then
            lastPressTick[code] = tick
            pressedSet[code] = true
            pressedList[#pressedList + 1] = code
        end
    end
    self.pressedSet = pressedSet
    self.pressedList = pressedList

    self.leftDown = input.IsButtonDown(M_LEFT)
    self.leftPressed = pressedSet[M_LEFT] or false

    local released, rtick = input.IsButtonReleased(M_LEFT)
    if released and lastReleaseTick[M_LEFT] ~= rtick then
        lastReleaseTick[M_LEFT] = rtick
        self.leftReleased = true
    else
        self.leftReleased = false
    end

    self.wheelUp = pressedSet[M_WHEEL_UP] or false
    self.wheelDown = pressedSet[M_WHEEL_DOWN] or false

    self.mouseConsumed = false
end

--- Level state (safe to poll repeatedly, unlike press edges).
function InputState:IsDown(code)
    return input.IsButtonDown(code)
end

function InputState:WasPressed(code)
    return self.pressedSet[code] or false
end

--- Claim the mouse for this frame; later widgets see no hover/click.
function InputState:ConsumeMouse()
    self.mouseConsumed = true
end

function InputState:IsHovered(x, y, w, h)
    return not self.mouseConsumed and util.pointIn(self.mx, self.my, x, y, w, h)
end

function InputState:PressedIn(x, y, w, h)
    return not self.mouseConsumed and self.leftPressed
        and util.pointIn(self.mx, self.my, x, y, w, h)
end

function Input.Snapshot()
    return InputState.new()
end

return Input
end

__modules["core.context"] = function(require)
-- core.context — the singleton frame pipeline: window z-order, input routing,
-- mouse capture, keyboard focus, cursor ownership, texture registry, and the
-- single Draw/Unload callback registration.
--
-- To stay cycle-free this module requires nothing from window/popup/config;
-- those modules register themselves into slots here.

local Input = require("core.input")
local theme = require("theme")

local context = {
    windows = {},          -- draw order: [1] = bottom .. [#] = top
    captured = nil,        -- widget (or window) holding mouse capture
    focus = nil,           -- widget holding keyboard focus
    popupMgr = nil,        -- set by core.popup
    configHandler = nil,   -- set by config
    textures = {},         -- textureId -> true, freed on Unload
    input = nil,           -- InputState snapshot, valid during a frame
    visibleFn = nil,       -- overrides all visibility logic when set
    toggleKey = 0,         -- E_ButtonCode that shows/hides the UI (0 = none)
    toggleState = false,   -- current toggle-key visibility
    mouseOverUI = false,   -- mouse over any open window/popup this frame
    weEnabledCursor = false,
    dirty = false,
    lastChange = 0,
    isSetup = false,
}

local AUTOSAVE_DELAY = 2.0

local function scriptTag()
    local name = "script"
    if type(GetScriptName) == "function" then
        local ok, n = pcall(GetScriptName)
        if ok and type(n) == "string" then name = n end
    end
    return "ui_" .. name
end

-- Window list ---------------------------------------------------------------

function context.AddWindow(win)
    context.windows[#context.windows + 1] = win
end

function context.RemoveWindow(win)
    for i, w in ipairs(context.windows) do
        if w == win then
            table.remove(context.windows, i)
            return
        end
    end
end

function context.BringToFront(win)
    for i, w in ipairs(context.windows) do
        if w == win then
            if i < #context.windows then
                table.remove(context.windows, i)
                context.windows[#context.windows + 1] = win
            end
            return
        end
    end
end

-- Capture / focus -----------------------------------------------------------

function context.SetCapture(widget)
    context.captured = widget
end

function context.ReleaseCapture()
    context.captured = nil
end

function context.SetFocus(widget)
    local old = context.focus
    if old == widget then return end
    context.focus = widget
    if old and old.OnFocusLost then
        old:OnFocusLost()
    end
end

-- Registries ----------------------------------------------------------------

function context.SetPopupManager(mgr)
    context.popupMgr = mgr
end

function context.SetConfigHandler(handler)
    context.configHandler = handler
end

function context.NotifyWidgetAdded(widget)
    if context.configHandler then
        context.configHandler.Restore(widget)
    end
end

function context.RegisterTexture(id)
    context.textures[id] = true
end

--- Delete a registered texture immediately (e.g. when regenerating it).
function context.UnregisterTexture(id)
    if context.textures[id] then
        context.textures[id] = nil
        draw.DeleteTexture(id)
    end
end

function context.FreeTextures()
    for id in pairs(context.textures) do
        draw.DeleteTexture(id)
    end
    context.textures = {}
end

function context.MarkDirty()
    context.dirty = true
    context.lastChange = globals.RealTime()
end

-- Cursor ownership ----------------------------------------------------------
-- SetMouseInputEnabled is ENGINE state: it survives the UI hiding and even
-- the script unloading, so a leaked claim permanently steals the player's
-- mouse. Rules: only release a cursor we enabled; while the environment's
-- own menu (which also needs the cursor) is open, defer the release but KEEP
-- the claim recorded so a later frame performs it; on Unload release
-- unconditionally — nothing of ours survives to do it later.

local function releaseCursor(force)
    if not context.weEnabledCursor then return end
    if force or not gui.IsMenuOpen() then
        input.SetMouseInputEnabled(false)
        context.weEnabledCursor = false
    end
end

--- The UI just went inactive (hidden, guarded, or unloaded): give back the
--- cursor and drop keyboard focus + mouse capture. Stale focus would eat
--- keystrokes on the next show — and silently disable the toggle key, which
--- is suppressed while a widget holds focus.
local function deactivate(forceCursor)
    releaseCursor(forceCursor)
    context.SetFocus(nil)
    context.captured = nil
end

-- Frame pipeline ------------------------------------------------------------

local function anyWindowOpen()
    for _, w in ipairs(context.windows) do
        if w.open then return true end
    end
    return false
end

function context.IsVisible()
    if context.visibleFn then
        return context.visibleFn() and true or false
    end
    -- Toggle key OR the environment menu: the key gives access in gameplay,
    -- the menu keeps the old behavior as a fallback.
    if context.toggleState then return true end
    return gui.IsMenuOpen()
end

-- Toggle key: a manual IsButtonDown edge, because it must fire while the UI
-- is hidden (the press-edge snapshot only runs for visible frames) and a
-- level check can't be eaten by other pollers. Skipped while a widget holds
-- keyboard focus so typing/binding the key doesn't also flip the UI.
local prevToggleDown = false

local function pollToggleKey()
    if context.toggleKey == 0 or context.focus then
        prevToggleDown = false
        return
    end
    local down = input.IsButtonDown(context.toggleKey)
    if down and not prevToggleDown then
        context.toggleState = not context.toggleState
    end
    prevToggleDown = down
end

function context.OnDraw()
    context.mouseOverUI = false

    -- 0. Effective UI scale (HighRes): tracks resolution changes.
    theme.Refresh()

    -- 1. Hard guards: other UI owns the screen. Fully let go of the input —
    -- keeping the cursor claimed under an open console/scoreboard is exactly
    -- the "mouse randomly stops aiming" residue. We re-claim when it closes.
    if engine.Con_IsVisible() or engine.IsGameUIVisible() or engine.IsChatOpen() then
        deactivate()
        return
    end

    -- 2. Visibility gate (the toggle key is polled first — it is what
    -- un-hides the UI, so it must run on hidden frames too).
    pollToggleKey()
    if not context.IsVisible() then
        deactivate()
        return
    end

    -- 3. Cursor: claim it while any window is open.
    local anyOpen = anyWindowOpen()
    if anyOpen then
        if not input.IsMouseInputEnabled() then
            input.SetMouseInputEnabled(true)
            context.weEnabledCursor = true
        end
    else
        deactivate()
    end

    -- 4. Input snapshot.
    local snap = Input.Snapshot()
    context.input = snap

    -- Is the mouse over any of our surfaces? (For scripts drawing their own
    -- overlays that must not react to clicks meant for the UI.)
    do
        local pm = context.popupMgr
        if pm and pm.active then
            local p = pm.active
            if snap.mx >= p.x and snap.mx < p.x + p.w
                and snap.my >= p.y and snap.my < p.y + p.h then
                context.mouseOverUI = true
            end
        end
        if not context.mouseOverUI then
            for _, w in ipairs(context.windows) do
                if w.open and snap.mx >= w.x and snap.mx < w.x + w.w
                    and snap.my >= w.y and snap.my < w.y + w:GetDrawnHeight() then
                    context.mouseOverUI = true
                    break
                end
            end
        end
    end

    -- 5. Layout.
    for _, win in ipairs(context.windows) do
        if win.open then win:Layout() end
    end

    -- 6. Input routing.
    if context.captured then
        -- Safety: never let capture outlive the button.
        if not snap.leftDown and not snap.leftPressed and not snap.leftReleased then
            context.captured = nil
        end
    end
    if context.captured then
        context.captured:OnInput(context)
        snap:ConsumeMouse()
    end

    -- Click outside the focused widget blurs it (unless it opted out).
    if snap.leftPressed and context.focus and context.focus.blurOnOutsideClick ~= false then
        local f = context.focus
        if not (f.ContainsPoint and f:ContainsPoint(snap.mx, snap.my)) then
            context.SetFocus(nil)
        end
    end

    -- Keyboard first: an arming keybind may claim (and consume) a mouse
    -- press as its new bind before any widget under the cursor reacts.
    if context.focus and context.focus.OnKeyboard then
        context.focus:OnKeyboard(context)
    end

    if context.popupMgr then
        context.popupMgr.OnInput(context)
    end

    do -- windows top-down; iterate a copy since BringToFront reorders
        local order = {}
        for i, w in ipairs(context.windows) do order[i] = w end
        for i = #order, 1, -1 do
            local win = order[i]
            -- A captured window (title-bar drag) already got input above.
            if win.open and win ~= context.captured then
                win:OnInput(context)
            end
        end
    end

    -- 7/8. Render: windows bottom-up, then the popup overlay on top.
    for _, win in ipairs(context.windows) do
        if win.open then win:Render(context) end
    end
    if context.popupMgr then
        context.popupMgr.Render(context)
    end

    -- 9. Debounced config autosave.
    if context.dirty and context.configHandler
        and globals.RealTime() > context.lastChange + AUTOSAVE_DELAY then
        context.configHandler.Save()
        context.dirty = false
    end

    context.input = nil
end

function context.OnUnload()
    if context.configHandler then
        context.configHandler.Save()
        context.dirty = false
    end
    context.FreeTextures()
    -- Force the cursor release: scripts are usually unloaded FROM the open
    -- environment menu, and the deferred release would never get a frame.
    deactivate(true)
    callbacks.Unregister("Draw", scriptTag())
end

function context.Setup()
    if context.isSetup then return end
    context.isSetup = true
    callbacks.Register("Draw", scriptTag(), context.OnDraw)
    callbacks.Register("Unload", scriptTag(), context.OnUnload)
end

function context.Shutdown()
    context.OnUnload()
    callbacks.Unregister("Unload", scriptTag())
    context.windows = {}
    context.captured = nil
    context.focus = nil
    context.isSetup = false
end

return context
end

__modules["core.widget"] = function(require)
-- core.widget — base class every widget derives from.
-- Positions (x,y,w,h) are absolute screen coords assigned by the parent
-- container's layout pass each frame; widgets never position themselves.

local util = require("core.util")
local theme = require("theme")
local context = require("core.context")

local Widget = util.class()

function Widget:Init(parent, label, opts)
    opts = opts or {}
    self.parent = parent
    self.label = label or ""
    self.id = opts.id or self.label
    self.visible = true
    self.enabled = opts.enabled ~= false
    self.x, self.y, self.w, self.h = 0, 0, 0, 0
    self.hovered = false
    self.inView = true -- false when culled by a scrolling container
end

--- Desired row height; containers call this during layout.
function Widget:GetHeight()
    return theme.metrics.rowHeight
end

--- Handle input for this frame. ctx.input is the InputState snapshot.
function Widget:OnInput(ctx) end

--- Draw the widget. x,y,w,h are already set by layout.
function Widget:Render(ctx) end

--- Config integration; value widgets override both.
function Widget:GetValue() return nil end
function Widget:SetValue(v) end

--- Called when this widget loses keyboard focus.
function Widget:OnFocusLost() end

function Widget:ContainsPoint(px, py)
    return util.pointIn(px, py, self.x, self.y, self.w, self.h)
end

function Widget:SetVisible(b)
    self.visible = b and true or false
end

function Widget:SetEnabled(b)
    self.enabled = b and true or false
end

--- Invoke the user callback safely; a script error in a callback must not
--- kill the whole UI frame.
function Widget:FireCallback(...)
    if not self.callback then return end
    local ok, err = pcall(self.callback, ...)
    if not ok then
        print("[ui] callback error in '" .. tostring(self.label) .. "': " .. tostring(err))
    end
end

--- Value changed: notify config autosave.
function Widget:MarkDirty()
    context.MarkDirty()
end

return Widget
end

__modules["core.window"] = function(require)
-- core.window — Container (vertical auto-stack layout shared by Window and
-- tab pages) and Window (title bar, drag, collapse/close, optional scroll).
--
-- There is no scissor/clip rect in this environment, so vertical overflow is
-- handled by whole-row culling: a child whose row is not fully inside the
-- body is skipped for both input and render (clean edges, no partial rows).
-- Horizontal overflow is handled by util.truncate at every text draw, plus
-- a minimum window size (library floor MIN_W; opts.minW/minH per window).

local util = require("core.util")
local theme = require("theme")
local context = require("core.context")

-- Container ------------------------------------------------------------------

local Container = util.class()

function Container:InitContainer()
    self.children = {}
end

function Container:AddChild(widget)
    self.children[#self.children + 1] = widget
    context.NotifyWidgetAdded(widget)
    return widget
end

--- Config key prefix; Window and TabPage override.
function Container:GetConfigPath()
    return ""
end

--- Vertical stack layout. Children get absolute rects starting at (x, y)
--- with width w. If viewTop/viewBottom are given, rows not fully inside
--- that band are culled (inView = false). Returns total content height.
function Container:LayoutChildren(x, y, w, viewTop, viewBottom)
    local m = theme.metrics
    local cy = y
    local first = true
    for _, c in ipairs(self.children) do
        if c.visible then
            if not first then cy = cy + m.spacing end
            first = false
            c.x, c.y, c.w = math.floor(x), math.floor(cy), math.floor(w)
            c.h = c.layoutH or c:GetHeight() -- layoutH: flexed by the window
            if viewTop then
                c.inView = c.y >= viewTop and (c.y + c.h) <= viewBottom
            else
                c.inView = true
            end
            if c.Layout then c:Layout() end -- containers-in-containers (tabs)
            cy = cy + c.h
        else
            c.inView = false
        end
    end
    return cy - y
end

function Container:InputChildren(ctx)
    for _, c in ipairs(self.children) do
        -- The captured widget already got input first from the context.
        if c.visible and c.inView and c.enabled and c ~= context.captured then
            c:OnInput(ctx)
        end
    end
end

function Container:RenderChildren(ctx)
    for _, c in ipairs(self.children) do
        if c.visible and c.inView then
            c:Render(ctx)
        end
    end
end

-- Window ---------------------------------------------------------------------

-- Resize grip band around each border: mostly outward-reaching (like OS
-- window borders) so it doesn't steal clicks from the chrome buttons and
-- widgets that sit near the edges. Corners are more forgiving: anywhere
-- within CORNER px (Chebyshev) of a corner point grips both edges — corners
-- are small diagonal targets otherwise. Chrome buttons are hit-tested before
-- grips, so the close button keeps its top-right region.
-- All 1080p-reference values, scaled through theme.S at use time so the
-- grab targets stay physically comfortable in HighRes mode.
local GRIP_IN = 2
local GRIP_OUT = 6
local CORNER = 8
local MIN_W = 140 -- floor for every window: room for the title + chrome buttons

local Window = util.class(Container)

function Window:Init(title, x, y, w, h, opts)
    opts = opts or {}
    self:InitContainer()
    self.title = title or "Window"
    self.x = x or 100
    self.y = y or 100
    self.w = w or 300
    self.scroll = opts.scroll and true or false
    -- Per-window minimum size (1080p-reference px, scaled like every other
    -- metric); the library floor MIN_W / MinHeight() always applies on top.
    self.minW = tonumber(opts.minW) or 0
    self.minH = tonumber(opts.minH) or 0
    self.autoHeight = not self.scroll and (h == nil or h == 0 or opts.autoHeight == true)
    self.h = (h and h > 0) and h or theme.metrics.titleHeight
    self.open = true
    self.collapsed = false
    self.dragging = false
    self.dragOX, self.dragOY = 0, 0
    self.resizing = nil    -- active resize state
    self.resizeHover = nil -- edges under the mouse (border highlight)
    self.scrollDrag = nil  -- active scrollbar-thumb drag state
    self.scrollY = 0
    self.contentHeight = 0
    self.closeHovered = false
    self.collapseHovered = false
    context.AddWindow(self)
end

function Window:GetConfigPath()
    return self.title
end

function Window:GetWindow()
    return self
end

--- Height of the window as currently drawn (title bar only when collapsed).
function Window:GetDrawnHeight()
    if self.collapsed then return theme.metrics.titleHeight end
    return self.h
end

--- Body band (below the title bar) used for culling and scrolling.
function Window:GetBodyRect()
    local m = theme.metrics
    return self.x, self.y + m.titleHeight, self.w, self.h - m.titleHeight
end

--- Scrollbar geometry shared by input and render, or nil when the content
--- fits. Returns trackX, trackY, trackH, thumbH, thumbY, maxScroll.
function Window:GetScrollbarGeometry()
    if not self.scroll or self.collapsed then return nil end
    local m = theme.metrics
    local bx, by, bw, bh = self:GetBodyRect()
    local total = self.contentHeight + 2 * m.padding
    if total <= bh then return nil end
    local trackX = self.x + self.w - m.scrollbarW - 2
    local trackY, trackH = by + 2, bh - 4
    local thumbH = math.max(16, (bh / total) * trackH)
    local maxScroll = total - bh
    local thumbY = trackY + (self.scrollY / maxScroll) * (trackH - thumbH)
    return trackX, trackY, trackH, thumbH, thumbY, maxScroll
end

function Window:Layout()
    local m = theme.metrics
    theme.SetFont("default")
    -- Enforce the minimum every frame, not just during interactive resizes:
    -- this catches programmatic sizes and UI-scale changes too.
    self.w = math.max(self.w, self:MinWidth())
    if not self.autoHeight then
        self.h = math.max(self.h, self:MinHeight())
    end
    if self.collapsed then
        for _, c in ipairs(self.children) do c.inView = false end
        return
    end
    local innerX = self.x + m.padding
    local innerW = self.w - 2 * m.padding - (self.scroll and (m.scrollbarW + 4) or 0)
    local contentTop = self.y + m.titleHeight + m.padding

    if self.autoHeight then
        self.contentHeight = self:LayoutChildren(innerX, contentTop, innerW)
        self.h = m.titleHeight + 2 * m.padding + self.contentHeight
    else
        -- Flexible children (VirtualLists by default) absorb the difference
        -- between the natural content height and the body: a taller window
        -- shows more list rows, a shorter one shrinks the lists (down to
        -- their minimum) instead of culling them wholesale.
        local avail = self.h - m.titleHeight - 2 * m.padding
        local natural, weights = 0, 0
        local firstChild = true
        for _, c in ipairs(self.children) do
            c.layoutH = nil
            if c.visible then
                if not firstChild then natural = natural + m.spacing end
                firstChild = false
                natural = natural + c:GetHeight()
                weights = weights + (c.flex or 0)
            end
        end
        if weights > 0 then
            local extra = avail - natural
            for _, c in ipairs(self.children) do
                if c.visible and (c.flex or 0) > 0 then
                    local share = math.floor(extra * c.flex / weights)
                    local minH = c.MinFlexHeight and c:MinFlexHeight() or 1
                    c.layoutH = math.max(minH, c:GetHeight() + share)
                end
            end
        end

        -- Clamp scroll using last frame's content height (stable in practice).
        local bodyH = self.h - m.titleHeight
        local maxScroll = math.max(0, self.contentHeight + 2 * m.padding - bodyH)
        self.scrollY = util.clamp(self.scrollY, 0, maxScroll)
        local bx, by, bw, bh = self:GetBodyRect()
        self.contentHeight = self:LayoutChildren(
            innerX, contentTop - self.scrollY, innerW,
            by + 1, by + bh - 1)
    end
end

function Window:MinWidth()
    return math.max(theme.S(MIN_W), theme.S(self.minW))
end

function Window:MinHeight()
    local m = theme.metrics
    return math.max(m.titleHeight + 2 * m.padding + m.rowHeight, theme.S(self.minH))
end

--- Per-window minimum size in 1080p-reference px (scaled like all metrics).
--- The library floor (MIN_W wide, one row tall) still applies on top.
function Window:SetMinSize(w, h)
    self.minW = tonumber(w) or self.minW
    self.minH = tonumber(h) or self.minH
end

--- Which resize edges (if any) the point is gripping. The grip band
--- straddles each border by GRIP px; corners combine two edges.
function Window:GetResizeEdges(mx, my)
    if self.collapsed then return nil end
    local h = self:GetDrawnHeight()
    local gripIn, gripOut, corner = theme.S(GRIP_IN), theme.S(GRIP_OUT), theme.S(CORNER)
    local pad = math.max(gripOut, corner)
    if mx < self.x - pad or mx > self.x + self.w + pad
        or my < self.y - pad or my > self.y + h + pad then
        return nil
    end
    local e = {
        left = mx >= self.x - gripOut and mx <= self.x + gripIn,
        right = mx >= self.x + self.w - gripIn and mx <= self.x + self.w + gripOut,
        top = my >= self.y - gripOut and my <= self.y + gripIn,
        bottom = my >= self.y + h - gripIn and my <= self.y + h + gripOut,
    }
    -- Forgiving corners: near a corner point counts as gripping both edges.
    local nearL = math.abs(mx - self.x) <= corner
    local nearR = math.abs(mx - (self.x + self.w)) <= corner
    local nearT = math.abs(my - self.y) <= corner
    local nearB = math.abs(my - (self.y + h)) <= corner
    if nearL and nearT then e.left, e.top = true, true end
    if nearR and nearT then e.right, e.top = true, true end
    if nearL and nearB then e.left, e.bottom = true, true end
    if nearR and nearB then e.right, e.bottom = true, true end
    if e.left or e.right or e.top or e.bottom then return e end
    return nil
end

function Window:OnInput(ctx)
    local s = ctx.input
    local m = theme.metrics

    -- Resize continuation (we hold mouse capture while resizing).
    if self.resizing then
        local r = self.resizing
        if s.leftDown then
            local minH = self:MinHeight()
            local minW = self:MinWidth()
            if r.edges.left then
                local newLeft = math.min(s.mx - r.offL, r.right - minW)
                self.x = math.floor(newLeft)
                self.w = math.floor(r.right - newLeft)
            elseif r.edges.right then
                self.w = math.floor(math.max(minW, s.mx + r.offR - self.x))
            end
            if r.edges.top then
                local newTop = math.min(s.my - r.offT, r.bottom - minH)
                self.y = math.floor(newTop)
                self.h = math.floor(r.bottom - newTop)
            elseif r.edges.bottom then
                self.h = math.floor(math.max(minH, s.my + r.offB - self.y))
            end
        end
        if s.leftReleased or not s.leftDown then
            self.resizing = nil
            context.ReleaseCapture()
        end
        return
    end

    -- Drag continuation (we hold mouse capture while dragging).
    if self.dragging then
        if s.leftDown then
            local sw, sh = draw.GetScreenSize()
            self.x = util.clamp(s.mx - self.dragOX, -(self.w - 40), sw - 40)
            self.y = util.clamp(s.my - self.dragOY, 0, sh - m.titleHeight)
        end
        if s.leftReleased or not s.leftDown then
            self.dragging = false
            context.ReleaseCapture()
        end
        return
    end

    -- Scrollbar-thumb drag continuation.
    if self.scrollDrag then
        local d = self.scrollDrag
        if s.leftDown then
            local denom = d.trackH - d.thumbH
            local newTop = util.clamp(s.my - d.grab, d.trackY, d.trackY + denom)
            self.scrollY = denom > 0 and ((newTop - d.trackY) / denom) * d.maxScroll or 0
        end
        if s.leftReleased or not s.leftDown then
            self.scrollDrag = nil
            context.ReleaseCapture()
        end
        return
    end

    local h = self:GetDrawnHeight()
    local inWin = s:IsHovered(self.x, self.y, self.w, h)

    if s.leftPressed and inWin then
        context.BringToFront(self)
    end

    -- Chrome buttons win over resize grips (keep close/collapse reliable
    -- now that corner grip zones are generous).
    local bs0 = m.titleHeight
    local closeX0 = self.x + self.w - bs0
    local collX0 = closeX0 - bs0
    self.closeHovered = s:IsHovered(closeX0, self.y, bs0, bs0)
    self.collapseHovered = s:IsHovered(collX0, self.y, bs0, bs0)
    if s.leftPressed and self.closeHovered then
        self.open = false
        s:ConsumeMouse()
        return
    end
    if s.leftPressed and self.collapseHovered then
        self.collapsed = not self.collapsed
        s:ConsumeMouse()
        return
    end

    -- Resize grips win over title/children at the very border.
    self.resizeHover = (not s.mouseConsumed) and self:GetResizeEdges(s.mx, s.my) or nil
    if s.leftPressed and self.resizeHover then
        local edges = self.resizeHover
        -- Vertical resize of an auto-height window pins its height: it
        -- becomes a fixed-height scrolling window from here on.
        if (edges.top or edges.bottom) and self.autoHeight then
            self.autoHeight = false
            self.scroll = true
        end
        context.BringToFront(self)
        self.resizing = {
            edges = edges,
            right = self.x + self.w,
            bottom = self.y + h,
            offL = s.mx - self.x,
            offR = (self.x + self.w) - s.mx,
            offT = s.my - self.y,
            offB = (self.y + h) - s.my,
        }
        context.SetCapture(self)
        s:ConsumeMouse()
        return
    end

    -- Title bar drag start (everything left of the chrome buttons).
    if s:PressedIn(self.x, self.y, self.w - 2 * m.titleHeight, m.titleHeight) then
        self.dragging = true
        self.dragOX = s.mx - self.x
        self.dragOY = s.my - self.y
        context.SetCapture(self)
        s:ConsumeMouse()
        return
    end

    if not self.collapsed then
        -- Scrollbar-thumb grab / track jump (wheel also works, but in-game
        -- the wheel doubles as weapon switch, so the bar is the reliable way).
        if self.scroll then
            local tx, ty, tth, thumbH, thumbY, maxScroll = self:GetScrollbarGeometry()
            if tx and s:PressedIn(tx, ty, m.scrollbarW, tth) then
                if s.my >= thumbY and s.my < thumbY + thumbH then
                    self.scrollDrag = { grab = s.my - thumbY, trackY = ty,
                        trackH = tth, thumbH = thumbH, maxScroll = maxScroll }
                else
                    -- Jump so the thumb centers on the click, then keep dragging.
                    local denom = tth - thumbH
                    local newTop = util.clamp(s.my - thumbH / 2, ty, ty + denom)
                    self.scrollY = denom > 0 and ((newTop - ty) / denom) * maxScroll or 0
                    self.scrollDrag = { grab = thumbH / 2, trackY = ty,
                        trackH = tth, thumbH = thumbH, maxScroll = maxScroll }
                end
                context.SetCapture(self)
                s:ConsumeMouse()
                return
            end
        end

        -- Wheel scrolling over the body.
        if self.scroll and (s.wheelUp or s.wheelDown) then
            local bx, by, bw, bh = self:GetBodyRect()
            if s:IsHovered(bx, by, bw, bh) then
                local step = m.scrollStep * (m.rowHeight + m.spacing)
                self.scrollY = self.scrollY + (s.wheelDown and step or -step)
            end
        end
        self:InputChildren(ctx)
    end

    -- The window blocks hover and clicks from reaching anything beneath it.
    if inWin then
        s:ConsumeMouse()
    end
end

function Window:Render(ctx)
    local m = theme.metrics
    local c = theme.colors
    local h = self:GetDrawnHeight()

    if not self.collapsed then
        theme.Color(c.windowBg)
        util.rect(self.x, self.y, self.w, h)
    end

    -- Title bar.
    local focused = context.windows[#context.windows] == self
    theme.Color(focused and c.titleBarFocus or c.titleBar)
    util.rect(self.x, self.y, self.w, m.titleHeight)

    theme.SetFont("title")
    theme.Color(c.text)
    -- Truncate to the space left of the chrome buttons.
    local title = util.truncate(self.title,
        self.w - 2 * m.titleHeight - m.padding - 4)
    local _, th = draw.GetTextSize(title)
    util.text(self.x + m.padding, self.y + (m.titleHeight - th) / 2, title)

    -- Chrome buttons.
    local bs = m.titleHeight
    local closeX = self.x + self.w - bs
    local collX = closeX - bs
    theme.SetFont("default")
    local function chromeButton(bx, glyph, hov)
        if hov then
            theme.Color(c.widgetHover)
            util.rect(bx, self.y, bs, bs)
        end
        theme.Color(c.textDim)
        local gw, gh = draw.GetTextSize(glyph)
        util.text(bx + (bs - gw) / 2, self.y + (bs - gh) / 2, glyph)
    end
    chromeButton(collX, self.collapsed and "+" or "-", self.collapseHovered)
    chromeButton(closeX, "x", self.closeHovered)

    if not self.collapsed then
        self:RenderChildren(ctx)

        -- Scrollbar (same geometry the input path grabs).
        local trackX, trackY, trackH, thumbH, thumbY = self:GetScrollbarGeometry()
        if trackX then
            theme.Color(c.scrollTrack)
            util.rect(trackX, trackY, m.scrollbarW, trackH)
            theme.Color(self.scrollDrag and c.accent or c.scrollThumb)
            util.rect(trackX, thumbY, m.scrollbarW, thumbH)
        end
    end

    -- Border; accent while a resize grip is hovered or active (there is no
    -- way to change the OS cursor shape, so this is the resize affordance).
    theme.Color((self.resizing or self.resizeHover) and c.accent or c.border)
    util.outline(self.x, self.y, self.w, h)
end

-- Public window controls ------------------------------------------------------

function Window:SetOpen(b)
    self.open = b and true or false
end

function Window:IsOpen()
    return self.open
end

function Window:SetPos(x, y)
    self.x, self.y = math.floor(x), math.floor(y)
end

--- Programmatic resize. Setting a height on an auto-height window converts
--- it to a fixed-height scrolling window (same as an interactive vertical
--- resize); pass nil for h to keep the current height/mode.
function Window:SetSize(w, h)
    self.w = math.floor(math.max(self:MinWidth(), w or self.w))
    if h then
        if self.autoHeight then
            self.autoHeight = false
            self.scroll = true
        end
        self.h = math.floor(math.max(self:MinHeight(), h))
    end
end

function Window:Remove()
    context.RemoveWindow(self)
end

return { Window = Window, Container = Container }
end

__modules["core.popup"] = function(require)
-- core.popup — the single active popup overlay (open combo list, multiselect
-- list, color picker panel). Popups get input BEFORE all windows and render
-- AFTER all windows (draw order = z order). A left-press outside the popup
-- closes it and consumes the click so nothing beneath is hit.
--
-- A popup descriptor:
--   { owner = widget, w = n, h = n,
--     anchorX, anchorY, anchorH,        -- control rect the popup hangs off
--     onInput = function(p, ctx) end,
--     onRender = function(p, ctx) end,
--     onClose = function(p) end }       -- optional
-- popup.Open computes p.x/p.y from the anchor, flipping upward and clamping
-- to the screen since nothing can be clipped.

local util = require("core.util")
local context = require("core.context")

local popup = {}

popup.active = nil

function popup.Open(p)
    if popup.active then popup.Close() end
    local sw, sh = draw.GetScreenSize()
    p.x = p.anchorX or 0
    p.y = (p.anchorY or 0) + (p.anchorH or 0)
    if p.y + p.h > sh then
        p.y = (p.anchorY or 0) - p.h -- flip above the control
    end
    p.x = util.clamp(p.x, 0, math.max(0, sw - p.w))
    p.y = util.clamp(p.y, 0, math.max(0, sh - p.h))
    popup.active = p
end

function popup.Close()
    local p = popup.active
    popup.active = nil
    if p and p.onClose then p.onClose(p) end
end

function popup.IsOpenFor(owner)
    return popup.active ~= nil and popup.active.owner == owner
end

function popup.OnInput(ctx)
    local p = popup.active
    if not p then return end
    local s = ctx.input

    p.onInput(p, ctx)
    if popup.active ~= p then return end -- closed itself

    if s.leftPressed and not s.mouseConsumed
        and not util.pointIn(s.mx, s.my, p.x, p.y, p.w, p.h) then
        popup.Close()
        s:ConsumeMouse()
        return
    end

    -- Hover inside the popup blocks everything beneath it.
    if s:IsHovered(p.x, p.y, p.w, p.h) then
        s:ConsumeMouse()
    end
end

function popup.Render(ctx)
    local p = popup.active
    if p then p.onRender(p, ctx) end
end

context.SetPopupManager(popup)

return popup
end

__modules["widgets.label"] = function(require)
-- widgets.label — stateless text row.

local util = require("core.util")
local theme = require("theme")
local Widget = require("core.widget")
local Container = require("core.window").Container

local Label = util.class(Widget)

function Label:Init(parent, text, opts)
    Widget.Init(self, parent, text, opts)
    self.dim = opts and opts.dim or false
end

function Label:GetHeight()
    theme.SetFont("default")
    local _, th = draw.GetTextSize(self.label == "" and " " or self.label)
    return th + 2
end

function Label:Render()
    theme.SetFont("default")
    theme.Color(self.dim and theme.colors.textDim or theme.colors.text)
    util.text(self.x, self.y + 1, util.truncate(self.label, self.w))
end

function Label:SetText(text)
    self.label = tostring(text)
end

function Container:AddLabel(text, opts)
    return self:AddChild(Label.new(self, text, opts))
end

return Label
end

__modules["widgets.button"] = function(require)
-- widgets.button — fires its callback on release-while-inside (standard
-- push button semantics, using mouse capture so a press can be dragged off
-- and back without losing the interaction).

local util = require("core.util")
local theme = require("theme")
local Widget = require("core.widget")
local context = require("core.context")
local Container = require("core.window").Container

local Button = util.class(Widget)

function Button:Init(parent, label, opts)
    Widget.Init(self, parent, label, opts)
    self.held = false
end

function Button:OnInput(ctx)
    local s = ctx.input
    if self.held then
        -- We hold capture; finish the interaction on release.
        self.hovered = util.pointIn(s.mx, s.my, self.x, self.y, self.w, self.h)
        if s.leftReleased or not s.leftDown then
            local fire = self.hovered and s.leftReleased
            self.held = false
            context.ReleaseCapture()
            if fire then self:FireCallback() end
        end
        return
    end

    self.hovered = s:IsHovered(self.x, self.y, self.w, self.h)
    if self.hovered and s.leftPressed then
        self.held = true
        context.SetCapture(self)
        s:ConsumeMouse()
    end
end

function Button:Render()
    local c = theme.colors
    local bg = c.widgetBg
    if self.held and self.hovered then
        bg = c.widgetActive
    elseif self.hovered or self.held then
        bg = c.widgetHover
    end
    theme.Color(bg)
    util.rect(self.x, self.y, self.w, self.h)
    theme.Color(c.border)
    util.outline(self.x, self.y, self.w, self.h)

    theme.SetFont("default")
    theme.Color(self.enabled and c.text or c.textDim)
    local label = util.truncate(self.label, self.w - 8)
    local tw, th = draw.GetTextSize(label)
    util.text(self.x + (self.w - tw) / 2, self.y + (self.h - th) / 2, label)
end

function Container:AddButton(label, fn, opts)
    local b = Button.new(self, label, opts)
    b.callback = fn
    return self:AddChild(b)
end

return Button
end

__modules["widgets.checkbox"] = function(require)
-- widgets.checkbox — click anywhere on the row to toggle.

local util = require("core.util")
local theme = require("theme")
local Widget = require("core.widget")
local Container = require("core.window").Container

local Checkbox = util.class(Widget)

function Checkbox:Init(parent, label, default, opts)
    Widget.Init(self, parent, label, opts)
    self.checked = default and true or false
end

function Checkbox:GetValue()
    return self.checked
end

function Checkbox:SetValue(v)
    v = v and true or false
    if v == self.checked then return end
    self.checked = v
    self:MarkDirty()
    self:FireCallback(self.checked)
end

function Checkbox:OnInput(ctx)
    local s = ctx.input
    self.hovered = s:IsHovered(self.x, self.y, self.w, self.h)
    if self.hovered and s.leftPressed then
        self:SetValue(not self.checked)
        s:ConsumeMouse()
    end
end

function Checkbox:Render()
    local c = theme.colors
    local size = theme.metrics.checkSize
    local by = self.y + (self.h - size) / 2

    theme.Color(self.hovered and c.widgetHover or c.widgetBg)
    util.rect(self.x, by, size, size)
    theme.Color(c.border)
    util.outline(self.x, by, size, size)
    if self.checked then
        theme.Color(self.enabled and c.accent or c.accentDim)
        util.rect(self.x + 3, by + 3, size - 6, size - 6)
    end

    theme.SetFont("default")
    theme.Color(self.enabled and c.text or c.textDim)
    local label = util.truncate(self.label, self.w - size - 6)
    local _, th = draw.GetTextSize(label)
    util.text(self.x + size + 6, self.y + (self.h - th) / 2, label)
end

function Container:AddCheckbox(label, default, fn, opts)
    local w = Checkbox.new(self, label, default, opts)
    w.callback = fn
    return self:AddChild(w)
end

return Checkbox
end

__modules["widgets.slider"] = function(require)
-- widgets.slider — label + value readout on one line, track below.
-- Press anywhere on the track row to grab; capture keeps the drag tracking
-- even when the cursor leaves the rect. Int and float variants share the
-- implementation; only step/format differ.

local util = require("core.util")
local theme = require("theme")
local Widget = require("core.widget")
local context = require("core.context")
local Container = require("core.window").Container

local Slider = util.class(Widget)

function Slider:Init(parent, label, min, max, default, opts)
    Widget.Init(self, parent, label, opts)
    opts = opts or {}
    self.min = min or 0
    self.max = max or 100
    if self.max <= self.min then self.max = self.min + 1 end
    self.isFloat = opts.float and true or false
    self.step = opts.step or (self.isFloat and 0.01 or 1)
    local precision = opts.precision or 2
    self.fmt = self.isFloat and ("%." .. precision .. "f") or "%d"
    self.value = self:Snap(default or self.min)
    self.dragging = false
end

function Slider:Snap(v)
    v = self.min + util.round((v - self.min) / self.step) * self.step
    if not self.isFloat then v = util.round(v) end
    return util.clamp(v, self.min, self.max)
end

function Slider:GetValue()
    return self.value
end

function Slider:SetValue(v)
    if type(v) ~= "number" then return end
    v = self:Snap(v)
    if v == self.value then return end
    self.value = v
    self:MarkDirty()
    self:FireCallback(self.value)
end

function Slider:GetHeight()
    return theme.metrics.rowHeight + theme.metrics.sliderTrackH
end

--- Track rect (bottom band of the widget).
function Slider:GetTrackRect()
    local trackH = theme.metrics.sliderTrackH
    return self.x, self.y + self.h - trackH, self.w, trackH
end

function Slider:ApplyMouse(mx)
    local tx, _, tw = self:GetTrackRect()
    local frac = util.clamp((mx - tx) / tw, 0, 1)
    self:SetValue(self.min + frac * (self.max - self.min))
end

function Slider:OnInput(ctx)
    local s = ctx.input
    if self.dragging then
        if s.leftDown then
            self:ApplyMouse(s.mx)
        end
        if s.leftReleased or not s.leftDown then
            self.dragging = false
            context.ReleaseCapture()
        end
        return
    end

    -- Generous grab area: the track plus the space just above it.
    local tx, ty, tw, trackH = self:GetTrackRect()
    self.hovered = s:IsHovered(tx, ty - 4, tw, trackH + 8)
    if self.hovered and s.leftPressed then
        self.dragging = true
        context.SetCapture(self)
        self:ApplyMouse(s.mx)
        s:ConsumeMouse()
    end
end

function Slider:Render()
    local c = theme.colors

    theme.SetFont("default")
    local valueText = string.format(self.fmt, self.value)
    local vw = draw.GetTextSize(valueText)
    theme.Color(self.enabled and c.text or c.textDim)
    util.text(self.x, self.y + 1, util.truncate(self.label, self.w - vw - 6))
    theme.Color(c.textDim)
    util.text(self.x + self.w - vw, self.y + 1, valueText)

    local tx, ty, tw, trackH = self:GetTrackRect()
    theme.Color((self.hovered or self.dragging) and c.widgetHover or c.widgetBg)
    util.rect(tx, ty, tw, trackH)
    local frac = (self.value - self.min) / (self.max - self.min)
    theme.Color(self.enabled and c.accent or c.accentDim)
    util.rect(tx, ty, tw * frac, trackH)
    theme.Color(c.border)
    util.outline(tx, ty, tw, trackH)
end

function Container:AddSlider(label, min, max, default, fn, opts)
    local w = Slider.new(self, label, min, max, default, opts)
    w.callback = fn
    return self:AddChild(w)
end

function Container:AddSliderFloat(label, min, max, default, fn, opts)
    opts = opts or {}
    opts.float = true
    local w = Slider.new(self, label, min, max, default, opts)
    w.callback = fn
    return self:AddChild(w)
end

return Slider
end

__modules["widgets.combo"] = function(require)
-- widgets.combo — single-select dropdown. The open list is a popup overlay
-- (input priority over windows, rendered topmost, closes on outside click).

local util = require("core.util")
local theme = require("theme")
local Widget = require("core.widget")
local popup = require("core.popup")
local Container = require("core.window").Container

local Combo = util.class(Widget)

function Combo:Init(parent, label, options, defaultIndex, opts)
    Widget.Init(self, parent, label, opts)
    self.options = options or {}
    self.index = util.clamp(defaultIndex or 1, 1, math.max(1, #self.options))
end

function Combo:GetHeight()
    return theme.metrics.rowHeight + theme.metrics.labelGap
end

function Combo:GetControlRect()
    local lg = theme.metrics.labelGap
    return self.x, self.y + lg, self.w, self.h - lg
end

function Combo:SetIndex(i)
    i = util.clamp(i, 1, math.max(1, #self.options))
    if i == self.index then return end
    self.index = i
    self:MarkDirty()
    self:FireCallback(self.index, self.options[self.index])
end

--- Config value is the option string so saved configs survive reordering.
function Combo:GetValue()
    return self.options[self.index]
end

function Combo:SetValue(v)
    if type(v) == "number" then
        self:SetIndex(v)
    elseif type(v) == "string" then
        for i, opt in ipairs(self.options) do
            if opt == v then
                self:SetIndex(i)
                return
            end
        end
    end
end

function Combo:OpenPopup()
    local cx, cy, cw, ch = self:GetControlRect()
    local rh = theme.metrics.popupRowH
    popup.Open({
        owner = self,
        w = cw,
        h = #self.options * rh + 2,
        anchorX = cx, anchorY = cy, anchorH = ch,

        onInput = function(p, ctx)
            local s = ctx.input
            for i = 1, #self.options do
                local ry = p.y + 1 + (i - 1) * rh
                if s:PressedIn(p.x + 1, ry, p.w - 2, rh) then
                    self:SetIndex(i)
                    popup.Close()
                    s:ConsumeMouse()
                    return
                end
            end
        end,

        onRender = function(p, ctx)
            local c = theme.colors
            theme.Color(c.popupBg)
            util.rect(p.x, p.y, p.w, p.h)
            theme.SetFont("default")
            local s = ctx.input
            for i, opt in ipairs(self.options) do
                local ry = p.y + 1 + (i - 1) * rh
                -- Popup is topmost: raw hover is correct here even though
                -- the snapshot was consumed during routing.
                if s and util.pointIn(s.mx, s.my, p.x + 1, ry, p.w - 2, rh) then
                    theme.Color(c.widgetHover)
                    util.rect(p.x + 1, ry, p.w - 2, rh)
                end
                theme.Color(i == self.index and c.accent or c.text)
                local optText = util.truncate(opt, p.w - 12)
                local _, th = draw.GetTextSize(optText)
                util.text(p.x + 6, ry + (rh - th) / 2, optText)
            end
            theme.Color(c.border)
            util.outline(p.x, p.y, p.w, p.h)
        end,
    })
end

function Combo:OnInput(ctx)
    local s = ctx.input
    local cx, cy, cw, ch = self:GetControlRect()
    self.hovered = s:IsHovered(cx, cy, cw, ch)
    if self.hovered and s.leftPressed then
        if popup.IsOpenFor(self) then
            popup.Close()
        else
            self:OpenPopup()
        end
        s:ConsumeMouse()
    end
end

function Combo:Render()
    local c = theme.colors
    theme.SetFont("default")
    theme.Color(self.enabled and c.text or c.textDim)
    util.text(self.x, self.y + 1, util.truncate(self.label, self.w))

    local cx, cy, cw, ch = self:GetControlRect()
    theme.Color((self.hovered or popup.IsOpenFor(self)) and c.widgetHover or c.widgetBg)
    util.rect(cx, cy, cw, ch)
    theme.Color(c.border)
    util.outline(cx, cy, cw, ch)

    -- Keep the value clear of the chevron zone on the right.
    local current = util.truncate(self.options[self.index] or "",
        cw - 6 - theme.S(18))
    theme.Color(c.text)
    local _, th = draw.GetTextSize(current)
    util.text(cx + 6, cy + (ch - th) / 2, current)

    -- Down chevron out of two lines (no reliable unicode glyphs).
    local g = theme.S(4)
    local gx = cx + cw - theme.S(14)
    local gy = cy + ch / 2 - g / 2
    theme.Color(c.textDim)
    util.line(gx, gy, gx + g, gy + g)
    util.line(gx + g, gy + g, gx + 2 * g, gy)
end

function Container:AddCombo(label, options, defaultIndex, fn, opts)
    local w = Combo.new(self, label, options, defaultIndex, opts)
    w.callback = fn
    return self:AddChild(w)
end

return Combo
end

__modules["widgets.multiselect"] = function(require)
-- widgets.multiselect — dropdown whose rows are toggles. The popup stays
-- open while items are clicked; only an outside click closes it.

local util = require("core.util")
local theme = require("theme")
local Widget = require("core.widget")
local popup = require("core.popup")
local Container = require("core.window").Container

local Multiselect = util.class(Widget)

function Multiselect:Init(parent, label, options, defaultSet, opts)
    Widget.Init(self, parent, label, opts)
    self.options = options or {}
    self.selected = {}
    if type(defaultSet) == "table" then
        for k, v in pairs(defaultSet) do
            if type(k) == "number" then -- array form { "Scout", "Pyro" }
                self.selected[v] = true
            elseif v then               -- set form { Scout = true }
                self.selected[k] = true
            end
        end
    end
end

function Multiselect:GetHeight()
    return theme.metrics.rowHeight + theme.metrics.labelGap
end

function Multiselect:GetControlRect()
    local lg = theme.metrics.labelGap
    return self.x, self.y + lg, self.w, self.h - lg
end

function Multiselect:CountSelected()
    local n = 0
    for _, opt in ipairs(self.options) do
        if self.selected[opt] then n = n + 1 end
    end
    return n
end

--- Config value is a { [option] = true } set.
function Multiselect:GetValue()
    local copy = {}
    for _, opt in ipairs(self.options) do
        if self.selected[opt] then copy[opt] = true end
    end
    return copy
end

function Multiselect:SetValue(t)
    if type(t) ~= "table" then return end
    self.selected = {}
    for k, v in pairs(t) do
        if type(k) == "number" then
            self.selected[v] = true
        elseif v then
            self.selected[k] = true
        end
    end
    self:MarkDirty()
    self:FireCallback(self:GetValue())
end

function Multiselect:Toggle(opt)
    self.selected[opt] = not self.selected[opt] or nil
    self:MarkDirty()
    self:FireCallback(self:GetValue())
end

function Multiselect:OpenPopup()
    local cx, cy, cw, ch = self:GetControlRect()
    local rh = theme.metrics.popupRowH
    popup.Open({
        owner = self,
        w = cw,
        h = #self.options * rh + 2,
        anchorX = cx, anchorY = cy, anchorH = ch,

        onInput = function(p, ctx)
            local s = ctx.input
            for i, opt in ipairs(self.options) do
                local ry = p.y + 1 + (i - 1) * rh
                if s:PressedIn(p.x + 1, ry, p.w - 2, rh) then
                    self:Toggle(opt)
                    s:ConsumeMouse()
                    return
                end
            end
        end,

        onRender = function(p, ctx)
            local c = theme.colors
            theme.Color(c.popupBg)
            util.rect(p.x, p.y, p.w, p.h)
            theme.SetFont("default")
            local s = ctx.input
            local box = rh - 8
            for i, opt in ipairs(self.options) do
                local ry = p.y + 1 + (i - 1) * rh
                if s and util.pointIn(s.mx, s.my, p.x + 1, ry, p.w - 2, rh) then
                    theme.Color(c.widgetHover)
                    util.rect(p.x + 1, ry, p.w - 2, rh)
                end
                theme.Color(c.widgetBg)
                util.rect(p.x + 5, ry + 4, box, box)
                theme.Color(c.border)
                util.outline(p.x + 5, ry + 4, box, box)
                if self.selected[opt] then
                    theme.Color(c.accent)
                    util.rect(p.x + 7, ry + 6, box - 4, box - 4)
                end
                theme.Color(self.selected[opt] and c.text or c.textDim)
                local optText = util.truncate(opt, p.w - (5 + box + 5) - 6)
                local _, th = draw.GetTextSize(optText)
                util.text(p.x + 5 + box + 5, ry + (rh - th) / 2, optText)
            end
            theme.Color(c.border)
            util.outline(p.x, p.y, p.w, p.h)
        end,
    })
end

function Multiselect:OnInput(ctx)
    local s = ctx.input
    local cx, cy, cw, ch = self:GetControlRect()
    self.hovered = s:IsHovered(cx, cy, cw, ch)
    if self.hovered and s.leftPressed then
        if popup.IsOpenFor(self) then
            popup.Close()
        else
            self:OpenPopup()
        end
        s:ConsumeMouse()
    end
end

function Multiselect:Render()
    local c = theme.colors
    theme.SetFont("default")
    theme.Color(self.enabled and c.text or c.textDim)
    util.text(self.x, self.y + 1, util.truncate(self.label, self.w))

    local cx, cy, cw, ch = self:GetControlRect()
    theme.Color((self.hovered or popup.IsOpenFor(self)) and c.widgetHover or c.widgetBg)
    util.rect(cx, cy, cw, ch)
    theme.Color(c.border)
    util.outline(cx, cy, cw, ch)

    local n = self:CountSelected()
    local summary = n == 0 and "none" or (n .. " selected")
    summary = util.truncate(summary, cw - 6 - theme.S(18))
    theme.Color(n == 0 and c.textDim or c.text)
    local _, th = draw.GetTextSize(summary)
    util.text(cx + 6, cy + (ch - th) / 2, summary)

    local g = theme.S(4)
    local gx = cx + cw - theme.S(14)
    local gy = cy + ch / 2 - g / 2
    theme.Color(c.textDim)
    util.line(gx, gy, gx + g, gy + g)
    util.line(gx + g, gy + g, gx + 2 * g, gy)
end

function Container:AddMultiselect(label, options, defaultSet, fn, opts)
    local w = Multiselect.new(self, label, options, defaultSet, opts)
    w.callback = fn
    return self:AddChild(w)
end

return Multiselect
end

__modules["widgets.tabs"] = function(require)
-- widgets.tabs — a tab bar row plus one visible TabPage. Pages expose the
-- same Add* surface as windows (both inherit Container). Only the active
-- page is laid out, routed, and rendered.

local util = require("core.util")
local theme = require("theme")
local Widget = require("core.widget")
local Container = require("core.window").Container

-- TabPage ----------------------------------------------------------------------

local TabPage = util.class(Container)

function TabPage:Init(tabControl, name)
    self:InitContainer()
    self.tabControl = tabControl
    self.name = name
end

function TabPage:GetConfigPath()
    return self.tabControl.parent:GetConfigPath() .. "/" .. self.name
end

function TabPage:GetWindow()
    local p = self.tabControl.parent
    return p.GetWindow and p:GetWindow() or p
end

-- TabControl -------------------------------------------------------------------

local TabControl = util.class(Widget)

function TabControl:Init(parent, names, opts)
    opts = opts or {}
    opts.id = opts.id or "tabs"
    Widget.Init(self, parent, "tabs", opts)
    self.names = names or {}
    self.pages = {}
    self.pageList = {}
    for _, n in ipairs(self.names) do
        local pg = TabPage.new(self, n)
        self.pages[n] = pg
        self.pageList[#self.pageList + 1] = pg
    end
    self.activeIndex = 1
    self.hoverIndex = nil
end

function TabControl:GetPage(name)
    return self.pages[name]
end

function TabControl:GetActivePage()
    return self.pageList[self.activeIndex]
end

function TabControl:SetActive(i)
    i = util.clamp(math.floor(i), 1, math.max(1, #self.pageList))
    if i == self.activeIndex then return end
    self.activeIndex = i
    self:MarkDirty()
end

function TabControl:GetValue()
    return self.activeIndex
end

function TabControl:SetValue(v)
    if type(v) == "number" then self:SetActive(v) end
end

local function measurePage(pg)
    local m = theme.metrics
    local h = 0
    local first = true
    for _, c in ipairs(pg.children) do
        if c.visible then
            if not first then h = h + m.spacing end
            first = false
            h = h + c:GetHeight()
        end
    end
    return h
end

function TabControl:GetHeight()
    local m = theme.metrics
    local pg = self:GetActivePage()
    return m.rowHeight + m.spacing + (pg and measurePage(pg) or 0)
end

function TabControl:Layout()
    local m = theme.metrics
    for i, pg in ipairs(self.pageList) do
        if i ~= self.activeIndex then
            for _, c in ipairs(pg.children) do c.inView = false end
        end
    end
    local pg = self:GetActivePage()
    if not pg then return end
    if not self.inView then
        for _, c in ipairs(pg.children) do c.inView = false end
        return
    end
    pg:LayoutChildren(self.x, self.y + m.rowHeight + m.spacing, self.w)
end

function TabControl:OnInput(ctx)
    local s = ctx.input
    local m = theme.metrics
    local n = #self.names
    if n > 0 then
        local segW = self.w / n
        self.hoverIndex = nil
        for i = 1, n do
            local sx = self.x + (i - 1) * segW
            if s:IsHovered(sx, self.y, segW, m.rowHeight) then
                self.hoverIndex = i
                if s.leftPressed then
                    self:SetActive(i)
                    s:ConsumeMouse()
                end
                break
            end
        end
    end
    local pg = self:GetActivePage()
    if pg then pg:InputChildren(ctx) end
end

function TabControl:Render(ctx)
    local m = theme.metrics
    local c = theme.colors
    local n = #self.names
    if n > 0 then
        local segW = self.w / n
        theme.SetFont("default")
        for i, name in ipairs(self.names) do
            local sx = self.x + (i - 1) * segW
            local active = i == self.activeIndex
            local bg = active and c.widgetActive
                or (i == self.hoverIndex and c.widgetHover or c.widgetBg)
            theme.Color(bg)
            util.rect(sx, self.y, segW, m.rowHeight)
            if active then
                theme.Color(c.accent)
                util.rect(sx, self.y + m.rowHeight - 2, segW, 2)
            end
            theme.Color(active and c.text or c.textDim)
            local tabText = util.truncate(name, segW - 6)
            local tw, th = draw.GetTextSize(tabText)
            util.text(sx + (segW - tw) / 2, self.y + (m.rowHeight - th) / 2, tabText)
        end
        theme.Color(c.border)
        util.outline(self.x, self.y, self.w, m.rowHeight)
    end
    local pg = self:GetActivePage()
    if pg then pg:RenderChildren(ctx) end
end

function Container:AddTabs(names, opts)
    return self:AddChild(TabControl.new(self, names, opts))
end

return TabControl
end

__modules["widgets.textbox"] = function(require)
-- widgets.textbox — single-line text input. The environment has no char
-- events, so keys are polled: fresh presses come from the frame snapshot,
-- key repeat is timed manually via globals.RealTime() (0.4 s delay, then
-- 20/s). No clipboard API exists, so there is no copy/paste.
--
-- No clip rect either: when the text is wider than the box only the tail
-- substring that fits is drawn, keeping the caret visible at the end.

local util = require("core.util")
local theme = require("theme")
local keymap = require("core.keymap")
local Widget = require("core.widget")
local context = require("core.context")
local Container = require("core.window").Container

local K_ENTER     = KEY_ENTER or 64
local K_PAD_ENTER = KEY_PAD_ENTER or 51
local K_BACKSPACE = KEY_BACKSPACE or 66
local K_DELETE    = KEY_DELETE or 73
local K_ESCAPE    = KEY_ESCAPE or 70
local K_HOME      = KEY_HOME or 74
local K_END       = KEY_END or 75
local K_LEFT      = KEY_LEFT or 89
local K_RIGHT     = KEY_RIGHT or 91
local K_LSHIFT    = KEY_LSHIFT or 79
local K_RSHIFT    = KEY_RSHIFT or 80

local REPEAT_DELAY = 0.4
local REPEAT_RATE = 0.05

local Textbox = util.class(Widget)

function Textbox:Init(parent, label, defaultText, opts)
    Widget.Init(self, parent, label, opts)
    self.text = tostring(defaultText or "")
    self.caret = #self.text
    self.focused = false
    self.repeatAt = {} -- code -> next repeat time
    self.lastNotified = self.text
end

function Textbox:GetHeight()
    return theme.metrics.rowHeight + theme.metrics.labelGap
end

function Textbox:GetControlRect()
    local lg = theme.metrics.labelGap
    return self.x, self.y + lg, self.w, self.h - lg
end

function Textbox:GetValue()
    return self.text
end

function Textbox:SetValue(v)
    if type(v) ~= "string" then v = tostring(v) end
    if v == self.text then return end
    self.text = v
    self.caret = #self.text
    self:MarkDirty()
    self.lastNotified = self.text
    self:FireCallback(self.text)
end

function Textbox:Notify()
    if self.text ~= self.lastNotified then
        self.lastNotified = self.text
        self:FireCallback(self.text)
    end
end

function Textbox:OnFocusLost()
    self.focused = false
    self.repeatAt = {}
    self:Notify()
end

function Textbox:OnInput(ctx)
    local s = ctx.input
    local cx, cy, cw, ch = self:GetControlRect()
    self.hovered = s:IsHovered(cx, cy, cw, ch)
    if self.hovered and s.leftPressed then
        self.focused = true
        self.caret = #self.text
        context.SetFocus(self)
        s:ConsumeMouse()
    end
end

function Textbox:InsertChar(ch)
    self.text = self.text:sub(1, self.caret) .. ch .. self.text:sub(self.caret + 1)
    self.caret = self.caret + 1
    self:MarkDirty()
end

--- Returns true when the key blurred the textbox (stop processing).
function Textbox:HandleKey(code, shifted)
    if code == K_ENTER or code == K_PAD_ENTER then
        self:Notify()
        context.SetFocus(nil)
        return true
    elseif code == K_ESCAPE then
        context.SetFocus(nil)
        return true
    elseif code == K_BACKSPACE then
        if self.caret > 0 then
            self.text = self.text:sub(1, self.caret - 1) .. self.text:sub(self.caret + 1)
            self.caret = self.caret - 1
            self:MarkDirty()
        end
    elseif code == K_DELETE then
        if self.caret < #self.text then
            self.text = self.text:sub(1, self.caret) .. self.text:sub(self.caret + 2)
            self:MarkDirty()
        end
    elseif code == K_LEFT then
        self.caret = math.max(0, self.caret - 1)
    elseif code == K_RIGHT then
        self.caret = math.min(#self.text, self.caret + 1)
    elseif code == K_HOME then
        self.caret = 0
    elseif code == K_END then
        self.caret = #self.text
    else
        local ch = keymap.CharFor(code, shifted)
        if ch then self:InsertChar(ch) end
    end
    return false
end

function Textbox:OnKeyboard(ctx)
    local s = ctx.input
    local now = globals.RealTime()
    local shifted = s:IsDown(K_LSHIFT) or s:IsDown(K_RSHIFT)

    -- Fresh presses arm the repeat timer.
    for _, code in ipairs(s.pressedList) do
        if self:HandleKey(code, shifted) then return end
        self.repeatAt[code] = now + REPEAT_DELAY
    end

    -- Held keys repeat.
    for code, t in pairs(self.repeatAt) do
        if not s:IsDown(code) then
            self.repeatAt[code] = nil
        elseif now >= t then
            if self:HandleKey(code, shifted) then return end
            self.repeatAt[code] = now + REPEAT_RATE
        end
    end
end

function Textbox:Render()
    local c = theme.colors
    theme.SetFont("default")
    theme.Color(self.enabled and c.text or c.textDim)
    util.text(self.x, self.y + 1, util.truncate(self.label, self.w))

    local cx, cy, cw, ch = self:GetControlRect()
    theme.Color(self.hovered and c.widgetHover or c.widgetBg)
    util.rect(cx, cy, cw, ch)
    theme.Color(self.focused and c.accent or c.border)
    util.outline(cx, cy, cw, ch)

    -- Tail substring that fits (no clipping available).
    local avail = cw - 10
    local visText = self.text
    while #visText > 0 and draw.GetTextSize(visText) > avail do
        visText = visText:sub(2)
    end
    local cut = #self.text - #visText
    local _, th = draw.GetTextSize(visText == "" and " " or visText)
    local textY = cy + (ch - th) / 2
    theme.Color(c.text)
    util.text(cx + 5, textY, visText)

    -- Blinking caret.
    if self.focused and globals.RealTime() % 1.0 < 0.5 then
        local caretInVis = self.caret - cut
        if caretInVis >= 0 then
            local prefixW = caretInVis == 0 and 0 or draw.GetTextSize(visText:sub(1, caretInVis))
            local lx = cx + 5 + prefixW + 1
            theme.Color(c.accent)
            util.line(lx, cy + 3, lx, cy + ch - 4)
        end
    end
end

function Container:AddTextbox(label, defaultText, fn, opts)
    local w = Textbox.new(self, label, defaultText, opts)
    w.callback = fn
    return self:AddChild(w)
end

return Textbox
end

__modules["widgets.keybind"] = function(require)
-- widgets.keybind — click the box to arm it, the next key or mouse button
-- pressed becomes the bind, ESC clears it. The click that armed the widget
-- is ignored for MOUSE_LEFT until the button has been released once, so
-- arming doesn't instantly bind MOUSE1 — but a deliberate second click does.

local util = require("core.util")
local theme = require("theme")
local keymap = require("core.keymap")
local Widget = require("core.widget")
local context = require("core.context")
local Container = require("core.window").Container

local K_ESCAPE      = KEY_ESCAPE or 70
local M_LEFT        = MOUSE_LEFT or 107
local M_WHEEL_UP    = MOUSE_WHEEL_UP or 112
local M_WHEEL_DOWN  = MOUSE_WHEEL_DOWN or 113

local Keybind = util.class(Widget)

function Keybind:Init(parent, label, defaultCode, opts)
    Widget.Init(self, parent, label, opts)
    self.keyCode = tonumber(defaultCode) or 0
    self.arming = false
    self.leftReleasedSeen = false
    self.blurOnOutsideClick = false -- a click while arming should bind MOUSE1
end

function Keybind:GetValue()
    return self.keyCode
end

function Keybind:SetValue(v)
    v = tonumber(v)
    if not v or v == self.keyCode then return end
    self.keyCode = math.floor(v)
    self:MarkDirty()
    self:FireCallback(self.keyCode)
end

function Keybind:GetBoxRect()
    local bw = math.min(theme.S(90), math.floor(self.w * 0.4))
    return self.x + self.w - bw, self.y, bw, self.h
end

function Keybind:OnFocusLost()
    self.arming = false
end

function Keybind:OnInput(ctx)
    local s = ctx.input
    local bx, by, bw, bh = self:GetBoxRect()
    self.hovered = s:IsHovered(bx, by, bw, bh)
    if self.hovered and s.leftPressed and not self.arming then
        self.arming = true
        self.leftReleasedSeen = false
        context.SetFocus(self)
        s:ConsumeMouse()
    end
end

function Keybind:OnKeyboard(ctx)
    if not self.arming then return end
    local s = ctx.input

    if not self.leftReleasedSeen and s.leftReleased then
        self.leftReleasedSeen = true
    end

    for _, code in ipairs(s.pressedList) do
        if code == M_WHEEL_UP or code == M_WHEEL_DOWN then
            -- wheel makes a terrible bind; ignore
        elseif code == M_LEFT and not self.leftReleasedSeen then
            -- still the click that armed us
        elseif code == K_ESCAPE then
            self.keyCode = 0
            self:MarkDirty()
            context.SetFocus(nil)
            self:FireCallback(0)
            return
        else
            self.keyCode = code
            self:MarkDirty()
            context.SetFocus(nil)
            if code == M_LEFT then
                -- Eat the click so it doesn't also activate a widget.
                s:ConsumeMouse()
            end
            self:FireCallback(code)
            return
        end
    end
end

function Keybind:Render()
    local c = theme.colors
    theme.SetFont("default")
    theme.Color(self.enabled and c.text or c.textDim)
    local bx, by, bw, bh = self:GetBoxRect()
    local label = util.truncate(self.label, bx - self.x - 6)
    local _, lh = draw.GetTextSize(label)
    util.text(self.x, self.y + (self.h - lh) / 2, label)
    theme.Color(self.hovered and c.widgetHover or c.widgetBg)
    util.rect(bx, by, bw, bh)
    theme.Color(self.arming and c.accent or c.border)
    util.outline(bx, by, bw, bh)

    local caption = self.arming and "..." or keymap.NameFor(self.keyCode)
    caption = util.truncate(caption, bw - 4)
    theme.Color(self.arming and c.accent or c.text)
    local tw, th = draw.GetTextSize(caption)
    util.text(bx + (bw - tw) / 2, by + (bh - th) / 2, caption)
end

function Container:AddKeybind(label, defaultCode, fn, opts)
    local w = Keybind.new(self, label, defaultCode, opts)
    w.callback = fn
    return self:AddChild(w)
end

return Keybind
end

__modules["widgets.colorpicker"] = function(require)
-- widgets.colorpicker — HSV+alpha picker. Closed: label + color swatch.
-- Open (popup): 128x128 saturation/value square, 16x128 hue bar, alpha bar,
-- hex readout. The SV square and hue bar are CreateTextureRGBA textures
-- (power-of-2 sizes per the docs); the hue bar is generated once and shared
-- by all pickers, the SV square is regenerated only when the hue changes.
-- All textures go through the context registry and are freed on Unload.

local util = require("core.util")
local theme = require("theme")
local Widget = require("core.widget")
local context = require("core.context")
local popup = require("core.popup")
local Container = require("core.window").Container

local SV_SIZE = 128
local HUE_W, HUE_H = 16, 128
local ALPHA_H = 12
local PAD = 6

-- Shared hue bar texture (lazy).
local hueTex = nil

local function getHueTexture()
    if hueTex then return hueTex end
    local rows = {}
    for y = 0, HUE_H - 1 do
        local r, g, b = util.hsvToRgb(y / (HUE_H - 1), 1, 1)
        rows[#rows + 1] = string.rep(string.char(r, g, b, 255), HUE_W)
    end
    hueTex = draw.CreateTextureRGBA(table.concat(rows), HUE_W, HUE_H)
    context.RegisterTexture(hueTex)
    return hueTex
end

local ColorPicker = util.class(Widget)

function ColorPicker:Init(parent, label, defaultRGBA, opts)
    Widget.Init(self, parent, label, opts)
    local c = defaultRGBA or { 255, 255, 255, 255 }
    self.hue, self.sat, self.val = util.rgbToHsv(c[1] or 255, c[2] or 255, c[3] or 255)
    self.alpha = c[4] or 255
    self.svTex = nil
    self.svTexHue = nil -- hue value the current svTex was built for
    self.dragTarget = nil -- "sv" | "hue" | "alpha" while capturing
    self.activePopup = nil
end

function ColorPicker:GetRGB()
    return util.hsvToRgb(self.hue, self.sat, self.val)
end

function ColorPicker:GetValue()
    local r, g, b = self:GetRGB()
    return { r, g, b, math.floor(self.alpha) }
end

function ColorPicker:SetValue(v)
    if type(v) ~= "table" then return end
    self.hue, self.sat, self.val = util.rgbToHsv(v[1] or 255, v[2] or 255, v[3] or 255)
    self.alpha = util.clamp(v[4] or 255, 0, 255)
    self:MarkDirty()
    self:FireCallback(self:GetValue())
end

function ColorPicker:Changed()
    self:MarkDirty()
    self:FireCallback(self:GetValue())
end

--- Regenerate the SV square texture; only called when the hue changed.
function ColorPicker:EnsureSvTexture()
    local hueKey = math.floor(self.hue * 255)
    if self.svTex and self.svTexHue == hueKey then return self.svTex end
    if self.svTex then
        context.UnregisterTexture(self.svTex)
        self.svTex = nil
    end
    local rows = {}
    local px = {}
    for y = 0, SV_SIZE - 1 do
        local v = 1 - y / (SV_SIZE - 1)
        for x = 0, SV_SIZE - 1 do
            local r, g, b = util.hsvToRgb(self.hue, x / (SV_SIZE - 1), v)
            px[x + 1] = string.char(r, g, b, 255)
        end
        rows[y + 1] = table.concat(px)
    end
    self.svTex = draw.CreateTextureRGBA(table.concat(rows), SV_SIZE, SV_SIZE)
    self.svTexHue = hueKey
    context.RegisterTexture(self.svTex)
    return self.svTex
end

-- Sub-rects inside the popup. Layout is scaled by theme.S; the SV/hue
-- textures stay at their power-of-2 pixel sizes and stretch via TexturedRect.

local function svRect(p)
    local S = theme.S
    return p.x + S(PAD), p.y + S(PAD), S(SV_SIZE), S(SV_SIZE)
end

local function hueRect(p)
    local S = theme.S
    return p.x + S(PAD) + S(SV_SIZE) + S(4), p.y + S(PAD), S(HUE_W), S(HUE_H)
end

local function alphaRect(p)
    local S = theme.S
    return p.x + S(PAD), p.y + S(PAD) + S(SV_SIZE) + S(4),
        S(SV_SIZE) + S(4) + S(HUE_W), S(ALPHA_H)
end

function ColorPicker:ApplyDrag(mx, my)
    local p = self.activePopup
    if not p then return end
    if self.dragTarget == "sv" then
        local x, y, w, h = svRect(p)
        self.sat = util.clamp((mx - x) / (w - 1), 0, 1)
        self.val = 1 - util.clamp((my - y) / (h - 1), 0, 1)
        self:Changed()
    elseif self.dragTarget == "hue" then
        local x, y, w, h = hueRect(p)
        self.hue = util.clamp((my - y) / (h - 1), 0, 1)
        self:Changed()
    elseif self.dragTarget == "alpha" then
        local x, y, w, h = alphaRect(p)
        self.alpha = util.clamp((mx - x) / (w - 1), 0, 1) * 255
        self:Changed()
    end
end

function ColorPicker:OpenPopup()
    local bx, by, bw, bh = self:GetBoxRect()
    local S = theme.S
    local w = S(PAD) + S(SV_SIZE) + S(4) + S(HUE_W) + S(PAD)
    local h = S(PAD) + S(SV_SIZE) + S(4) + S(ALPHA_H) + S(4) + S(14) + S(PAD)
    local widget = self
    popup.Open({
        owner = self,
        w = w,
        h = h,
        anchorX = bx, anchorY = by, anchorH = bh,

        onInput = function(p, ctx)
            local s = ctx.input
            widget.activePopup = p
            local grabs = {
                { "sv", svRect(p) },
                { "hue", hueRect(p) },
                { "alpha", alphaRect(p) },
            }
            for _, g in ipairs(grabs) do
                local name, x, y, rw, rh = g[1], g[2], g[3], g[4], g[5]
                if s:PressedIn(x, y, rw, rh) then
                    widget.dragTarget = name
                    context.SetCapture(widget)
                    widget:ApplyDrag(s.mx, s.my)
                    s:ConsumeMouse()
                    return
                end
            end
        end,

        onRender = function(p, ctx)
            local c = theme.colors
            theme.Color(c.popupBg)
            util.rect(p.x, p.y, p.w, p.h)

            -- SV square + selection marker
            local sx, sy, sw, sh = svRect(p)
            draw.TexturedRect(widget:EnsureSvTexture(), sx, sy, sx + sw, sy + sh)
            local mx = sx + widget.sat * (sw - 1)
            local my = sy + (1 - widget.val) * (sh - 1)
            draw.Color(255, 255, 255, 255)
            draw.OutlinedCircle(math.floor(mx), math.floor(my), 3, 12)

            -- Hue bar + marker
            local hx, hy, hw, hh = hueRect(p)
            draw.TexturedRect(getHueTexture(), hx, hy, hx + hw, hy + hh)
            local hueY = hy + widget.hue * (hh - 1)
            draw.Color(255, 255, 255, 255)
            util.line(hx - 1, hueY, hx + hw + 1, hueY)

            -- Alpha bar: color fading out left->right over a dark base
            local ax, ay, aw, ah = alphaRect(p)
            theme.Color(c.widgetBg)
            util.rect(ax, ay, aw, ah)
            local r, g, b = widget:GetRGB()
            draw.Color(r, g, b, 255)
            draw.FilledRectFade(math.floor(ax), math.floor(ay),
                math.floor(ax + aw), math.floor(ay + ah), 255, 0, true)
            local alphaX = ax + (widget.alpha / 255) * (aw - 1)
            draw.Color(255, 255, 255, 255)
            util.line(alphaX, ay - 1, alphaX, ay + ah + 1)

            -- Hex readout
            theme.SetFont("small")
            theme.Color(c.textDim)
            local hex = string.format("#%02X%02X%02X%02X", r, g, b, math.floor(widget.alpha))
            util.text(ax, ay + ah + 4, hex)

            theme.Color(c.border)
            util.outline(p.x, p.y, p.w, p.h)
        end,

        onClose = function()
            widget.activePopup = nil
        end,
    })
end

-- Widget surface -------------------------------------------------------------------

function ColorPicker:GetBoxRect()
    local bw = math.min(theme.S(60), math.floor(self.w * 0.3))
    return self.x + self.w - bw, self.y + 2, bw, self.h - 4
end

function ColorPicker:OnInput(ctx)
    local s = ctx.input

    -- Drag continuation while capturing an SV/hue/alpha handle.
    if self.dragTarget then
        if s.leftDown then
            self:ApplyDrag(s.mx, s.my)
        end
        if s.leftReleased or not s.leftDown then
            self.dragTarget = nil
            context.ReleaseCapture()
        end
        return
    end

    local bx, by, bw, bh = self:GetBoxRect()
    self.hovered = s:IsHovered(bx, by, bw, bh)
    if self.hovered and s.leftPressed then
        if popup.IsOpenFor(self) then
            popup.Close()
        else
            self:OpenPopup()
        end
        s:ConsumeMouse()
    end
end

function ColorPicker:Render()
    local c = theme.colors
    theme.SetFont("default")
    theme.Color(self.enabled and c.text or c.textDim)
    local bx, by, bw, bh = self:GetBoxRect()
    local label = util.truncate(self.label, bx - self.x - 6)
    local _, lh = draw.GetTextSize(label)
    util.text(self.x, self.y + (self.h - lh) / 2, label)
    local r, g, b = self:GetRGB()
    draw.Color(r, g, b, 255)
    util.rect(bx, by, bw, bh)
    theme.Color(popup.IsOpenFor(self) and c.accent or c.border)
    util.outline(bx, by, bw, bh)
end

function Container:AddColorPicker(label, defaultRGBA, fn, opts)
    local w = ColorPicker.new(self, label, defaultRGBA, opts)
    w.callback = fn
    return self:AddChild(w)
end

return ColorPicker
end

__modules["widgets.virtuallist"] = function(require)
-- widgets.virtuallist — a provider-driven list that renders only the rows
-- currently on screen, so it scales to thousands of entries with no widget
-- churn. Used by data-heavy tools (entity trees, prop lists, watch panels).
--
-- provider = {
--   Count = function() -> integer,
--   Row = function(i) -> {
--     text = string,            -- main text (left, truncated to fit)
--     color = {r,g,b,a}?,       -- main text color (default theme text)
--     indent = integer?,        -- indent level (metrics.indentW px each)
--     suffix = string?,         -- right-aligned secondary text
--     suffixColor = {r,g,b,a}?,
--     hotspot = string?,        -- glyph in the trailing metrics.hotspotW zone
--     selected = boolean?,      -- accent-tinted row background
--     flash = boolean?,         -- accent text flash (value just changed)
--   },
--   OnClick = function(i, zone)?  -- zone: "row" | "hotspot"
-- }
-- opts.rows sets the natural row count (default 12) — the height the list
-- asks for in auto-height windows. In a fixed-height window the list is
-- FLEXIBLE by default: the window layout stretches or shrinks it to absorb
-- leftover body space, so resizing the window shows more (or fewer) rows.
-- opts.flex = false makes it rigid; a number sets its share weight when
-- several flexible children split the space.

local util = require("core.util")
local theme = require("theme")
local Widget = require("core.widget")
local context = require("core.context")
local Container = require("core.window").Container

local VirtualList = util.class(Widget)

function VirtualList:Init(parent, provider, opts)
    opts = opts or {}
    opts.id = opts.id or "list"
    Widget.Init(self, parent, "list", opts)
    self.provider = provider
    self.rows = opts.rows or 12
    if opts.flex == false then
        self.flex = 0
    elseif type(opts.flex) == "number" then
        self.flex = opts.flex
    else
        self.flex = 1
    end
    self.offset = 0 -- first visible row is offset + 1
    self.hoverIndex = nil
    self.scrollDrag = nil
end

function VirtualList:GetHeight()
    return self.rows * theme.metrics.popupRowH + 2
end

function VirtualList:RowHeight()
    return theme.metrics.popupRowH
end

--- Rows that fit the CURRENT layout height (a flexed list may be taller or
--- shorter than opts.rows; in auto-height windows this equals opts.rows).
function VirtualList:VisibleRows()
    return math.max(1, math.floor((self.h - 2) / self:RowHeight()))
end

--- Smallest height the window layout may squeeze a flexible list to.
function VirtualList:MinFlexHeight()
    return 3 * self:RowHeight() + 2
end

--- First and last visible row indices (1-based, inclusive); 1, 0 when empty.
function VirtualList:VisibleRange()
    local count = self.provider.Count()
    local first = self.offset + 1
    local last = math.min(count, self.offset + self:VisibleRows())
    return first, last
end

function VirtualList:MaxOffset()
    return math.max(0, self.provider.Count() - self:VisibleRows())
end

--- Width reserved on the right for the scrollbar (0 when everything fits).
function VirtualList:ScrollbarReserve()
    return self.provider.Count() > self:VisibleRows() and (theme.metrics.scrollbarW + 2) or 0
end

--- Scrollbar geometry shared by input and render, or nil when content fits.
function VirtualList:GetScrollbarGeometry()
    local count = self.provider.Count()
    local visible = self:VisibleRows()
    if count <= visible then return nil end
    local m = theme.metrics
    local trackX = self.x + self.w - m.scrollbarW - 1
    local trackY, trackH = self.y + 1, self.h - 2
    local thumbH = math.max(theme.S(14), trackH * (visible / count))
    local maxOff = self:MaxOffset()
    local thumbY = trackY + (maxOff > 0 and (self.offset / maxOff) or 0) * (trackH - thumbH)
    return trackX, trackY, trackH, thumbH, thumbY, maxOff
end

function VirtualList:ScrollTo(i)
    self.offset = util.clamp(i - 1, 0, self:MaxOffset())
end

--- Row index at a screen point, or nil.
function VirtualList:RowAt(mx, my)
    if not util.pointIn(mx, my, self.x, self.y, self.w, self.h) then return nil end
    local i = self.offset + math.floor((my - self.y - 1) / self:RowHeight()) + 1
    if i < 1 or i > self.provider.Count() then return nil end
    -- A flexed height is not always a whole number of rows: the partial
    -- strip below the last full row must not click the row after it.
    if i > self.offset + self:VisibleRows() then return nil end
    return i
end

function VirtualList:OnInput(ctx)
    local s = ctx.input
    self.offset = util.clamp(self.offset, 0, self:MaxOffset())

    -- Thumb drag continuation (mouse captured).
    if self.scrollDrag then
        local d = self.scrollDrag
        if s.leftDown then
            local denom = d.trackH - d.thumbH
            local newTop = util.clamp(s.my - d.grab, d.trackY, d.trackY + denom)
            self.offset = denom > 0
                and util.round(((newTop - d.trackY) / denom) * d.maxOff) or 0
        end
        if s.leftReleased or not s.leftDown then
            self.scrollDrag = nil
            context.ReleaseCapture()
        end
        return
    end

    self.hovered = s:IsHovered(self.x, self.y, self.w, self.h)
    self.hoverIndex = self.hovered and self:RowAt(s.mx, s.my) or nil

    if self.hovered and (s.wheelUp or s.wheelDown) then
        self.offset = util.clamp(self.offset + (s.wheelDown and 3 or -3), 0, self:MaxOffset())
    end

    if self.hovered and s.leftPressed then
        -- Scrollbar first: grab the thumb, or jump-and-drag from the track.
        local tx, ty, th, thumbH, thumbY, maxOff = self:GetScrollbarGeometry()
        if tx and s.mx >= tx then
            if s.my >= thumbY and s.my < thumbY + thumbH then
                self.scrollDrag = { grab = s.my - thumbY, trackY = ty,
                    trackH = th, thumbH = thumbH, maxOff = maxOff }
            else
                local denom = th - thumbH
                local newTop = util.clamp(s.my - thumbH / 2, ty, ty + denom)
                self.offset = denom > 0
                    and util.round(((newTop - ty) / denom) * maxOff) or 0
                self.scrollDrag = { grab = thumbH / 2, trackY = ty,
                    trackH = th, thumbH = thumbH, maxOff = maxOff }
            end
            context.SetCapture(self)
            s:ConsumeMouse()
            return
        end

        local i = self:RowAt(s.mx, s.my)
        if i and self.provider.OnClick then
            local row = self.provider.Row(i)
            local zone = "row"
            local hotX = self.x + self.w - self:ScrollbarReserve() - theme.metrics.hotspotW
            if row and row.hotspot and s.mx >= hotX then
                zone = "hotspot"
            end
            self.provider.OnClick(i, zone)
        end
        s:ConsumeMouse()
    end
end

function VirtualList:Render()
    local c = theme.colors
    local m = theme.metrics
    local rh = self:RowHeight()

    theme.Color(c.popupBg)
    util.rect(self.x, self.y, self.w, self.h)

    theme.SetFont("default")
    local count = self.provider.Count()
    local first, last = self:VisibleRange()
    local reserve = self:ScrollbarReserve()

    for i = first, last do
        local row = self.provider.Row(i)
        if row then
            local ry = self.y + 1 + (i - first) * rh
            if row.selected then
                theme.Color({ c.accent[1], c.accent[2], c.accent[3], 45 })
                util.rect(self.x + 1, ry, self.w - 2, rh)
            end
            if i == self.hoverIndex then
                theme.Color(c.widgetHover)
                util.rect(self.x + 1, ry, self.w - 2, rh)
            end

            local indent = (row.indent or 0) * m.indentW
            local tx = self.x + 4 + indent
            local rightEdge = self.x + self.w - 4 - reserve
            if row.hotspot then rightEdge = rightEdge - m.hotspotW end

            -- Right-aligned suffix first so the main text can truncate to it.
            local textLimit = rightEdge - tx
            if row.suffix then
                local sfx = util.truncate(row.suffix, math.floor((self.w - indent) * 0.55))
                local sw = draw.GetTextSize(sfx)
                theme.Color(row.flash and c.accent or (row.suffixColor or c.textDim))
                local _, th = draw.GetTextSize(sfx)
                util.text(rightEdge - sw, ry + (rh - th) / 2, sfx)
                textLimit = textLimit - sw - 8
            end

            local text = util.truncate(row.text or "", math.max(10, textLimit))
            theme.Color(row.flash and c.accent or (row.color or c.text))
            local _, th = draw.GetTextSize(text)
            util.text(tx, ry + (rh - th) / 2, text)

            if row.hotspot then
                local hx = self.x + self.w - reserve - m.hotspotW
                if i == self.hoverIndex then
                    theme.Color(c.widgetActive)
                    util.rect(hx, ry, m.hotspotW - 1, rh)
                end
                theme.Color(c.textDim)
                local gw, gh = draw.GetTextSize(row.hotspot)
                util.text(hx + (m.hotspotW - gw) / 2, ry + (rh - gh) / 2, row.hotspot)
            end
        end
    end

    -- Scrollbar (same geometry the input path grabs; wide enough to hit).
    local trackX, trackY, trackH, thumbH, thumbY = self:GetScrollbarGeometry()
    if trackX then
        theme.Color(c.scrollTrack)
        util.rect(trackX, trackY, theme.metrics.scrollbarW, trackH)
        theme.Color(self.scrollDrag and c.accent or c.scrollThumb)
        util.rect(trackX, thumbY, theme.metrics.scrollbarW, thumbH)
    end

    theme.Color(c.border)
    util.outline(self.x, self.y, self.w, self.h)
end

function Container:AddVirtualList(provider, opts)
    return self:AddChild(VirtualList.new(self, provider, opts))
end

return VirtualList
end

__modules["config"] = function(require)
-- config — persists widget values per script. Values are serialized as a
-- plain Lua table (`return { ["key"] = value }`) with sorted keys, loaded
-- back with a sandboxed load(); a corrupt file is discarded, never fatal.
--
-- Keys are "<window>/<tab>/<widgetId>" where widgetId defaults to the label
-- (override with opts.id on any Add*). Duplicate keys get a "#2" suffix in
-- creation order, which is deterministic for a given script.

local context = require("core.context")

local config = {}

config.data = {}     -- key -> stored value
config.widgets = {}  -- registered value widgets
config.usedKeys = {}
config.path = nil

-- Serializer -------------------------------------------------------------------

local function serializeScalar(v)
    local t = type(v)
    if t == "string" then return string.format("%q", v) end
    if t == "boolean" then return tostring(v) end
    if t == "number" then
        if math.type and math.type(v) == "integer" then return tostring(v) end
        return string.format("%.17g", v)
    end
    return nil
end

local function sortedKeys(tbl)
    local ks = {}
    for k in pairs(tbl) do
        if type(k) == "string" or type(k) == "number" then
            ks[#ks + 1] = k
        end
    end
    table.sort(ks, function(a, b)
        if type(a) == type(b) then return a < b end
        return type(a) == "number" -- numbers before strings
    end)
    return ks
end

local function serializeKey(k)
    return "[" .. serializeScalar(k) .. "]"
end

--- Serialize one stored value: a scalar, or a flat table of scalars.
local function serializeValue(v)
    local sv = serializeScalar(v)
    if sv then return sv end
    if type(v) ~= "table" then return nil end
    local parts = {}
    for _, k in ipairs(sortedKeys(v)) do
        local inner = serializeScalar(v[k])
        if inner then
            parts[#parts + 1] = serializeKey(k) .. " = " .. inner
        end
    end
    return "{ " .. table.concat(parts, ", ") .. " }"
end

local function serialize(data)
    local lines = { "return {" }
    for _, k in ipairs(sortedKeys(data)) do
        local sv = serializeValue(data[k])
        if sv then
            lines[#lines + 1] = "    " .. serializeKey(k) .. " = " .. sv .. ","
        end
    end
    lines[#lines + 1] = "}"
    return table.concat(lines, "\n") .. "\n"
end

-- File location ------------------------------------------------------------------

local function scriptBaseName()
    local name = "script"
    if type(GetScriptName) == "function" then
        local ok, n = pcall(GetScriptName)
        if ok and type(n) == "string" and n ~= "" then name = n end
    end
    return name:gsub("%.lua$", ""):gsub("[^%w_%-]", "_")
end

function config.GetPath()
    if config.path then return config.path end
    local ok, fullPath = filesystem.CreateDirectory("ui_configs")
    local dir = (type(fullPath) == "string" and fullPath ~= "") and fullPath or "ui_configs"
    config.path = dir .. "/" .. scriptBaseName() .. ".cfg"
    return config.path
end

-- Load / save / restore --------------------------------------------------------------

function config.Load()
    local f = io.open(config.GetPath(), "r")
    if not f then return end
    local src = f:read("*a")
    f:close()
    -- Sandboxed: the chunk gets an empty environment and must only build a table.
    local chunk = load(src, "uiconfig", "t", {})
    if not chunk then return end
    local ok, data = pcall(chunk)
    if ok and type(data) == "table" then
        config.data = data
    end
end

function config.Save()
    for _, w in ipairs(config.widgets) do
        config.data[w._cfgKey] = w:GetValue()
    end
    local f, err = io.open(config.GetPath(), "w")
    if not f then
        print("[ui] cannot save config to " .. config.GetPath() .. ": " .. tostring(err))
        return
    end
    f:write(serialize(config.data))
    f:close()
end

--- Re-apply loaded values to every registered widget.
function config.Apply()
    for _, w in ipairs(config.widgets) do
        local stored = config.data[w._cfgKey]
        if stored ~= nil then
            w:SetValue(stored)
        end
    end
end

--- Called by the context whenever a widget is added to a container.
--- Registers value widgets and applies any stored value (this fires the
--- widget's callback so script state stays in sync — documented behavior).
function config.Restore(widget)
    if widget:GetValue() == nil then return end -- not a value widget

    local parentPath = ""
    if widget.parent and widget.parent.GetConfigPath then
        parentPath = widget.parent:GetConfigPath()
    end
    local base = parentPath .. "/" .. tostring(widget.id)
    local key = base
    local n = 2
    while config.usedKeys[key] do
        key = base .. "#" .. n
        n = n + 1
    end
    if key ~= base then
        print("[ui] duplicate config key '" .. base .. "', using '" .. key
            .. "' (set opts.id for a stable key)")
    end
    config.usedKeys[key] = true
    widget._cfgKey = key
    config.widgets[#config.widgets + 1] = widget

    local stored = config.data[key]
    if stored ~= nil then
        widget:SetValue(stored)
    end
end

config.Load()
context.SetConfigHandler(config)

return config
end

__modules["init"] = function(require)
-- init — public "ui" entry point. Requiring this module wires everything up
-- (widget modules attach their Add* methods to Container as a side effect)
-- and registers the Draw/Unload callbacks.

local theme = require("theme")
local context = require("core.context")
local keymap = require("core.keymap")
local config = require("config")
local Window = require("core.window").Window

-- Widget modules register Container:Add* on load.
require("widgets.label")
require("widgets.button")
require("widgets.checkbox")
require("widgets.slider")
require("widgets.combo")
require("widgets.multiselect")
require("widgets.tabs")
require("widgets.textbox")
require("widgets.keybind")
require("widgets.colorpicker")
require("widgets.virtuallist")

local ui = {}

ui.VERSION = "0.1.0"

--- Create a window. h == 0 (or nil) means auto-height; pass opts.scroll
--- with a fixed h for a scrolling window. opts.minW/opts.minH set a
--- per-window minimum size (1080p-reference px) that resizing and SetSize
--- can't go below; a library-wide floor applies regardless.
function ui.Window(title, x, y, w, h, opts)
    return Window.new(title, x, y, w, h, opts)
end

--- Deep-merge theme overrides ({ colors = {...}, metrics = {...}, fontDefs = {...} }).
--- Metric and font values are 1080p-reference sizes; HighRes scaling applies
--- on top of them.
function ui.SetTheme(overrides)
    theme.Merge(overrides)
end

--- HighRes mode (default ON): scales the whole UI — text, buttons, rows,
--- scrollbars, resize grips — by screenHeight / 1080, so it keeps its
--- intended size on 1440p/4K screens instead of shrinking. Pass false for
--- the original compact 1:1 pixel metrics.
function ui.SetHighRes(b)
    theme.SetHighRes(b)
end

--- Extra user multiplier stacked on the HighRes auto-scale (default 1.0).
function ui.SetScale(mult)
    theme.SetUserScale(mult)
end

--- The effective UI scale this frame (auto x user). Scripts drawing their
--- own overlays can multiply their pixel sizes by this.
function ui.GetScale()
    return theme.scale
end

--- Round a 1080p-reference pixel value to the current scale.
function ui.Scale(px)
    return theme.S(px)
end

--- Override when the UI is shown (replaces both the toggle key and the
--- menu-open default).
function ui.SetVisibleCallback(fn)
    context.visibleFn = fn
end

--- Bind a key (E_ButtonCode) that shows/hides the UI during gameplay; the
--- UI also shows while the environment menu is open. Pass 0 to clear.
--- Ignored while a custom visibility callback is set.
function ui.SetToggleKey(code)
    context.toggleKey = math.floor(tonumber(code) or 0)
end

--- True while the UI is shown (toggle key, environment menu, or a custom
--- visibility callback). Scripts can key their own "edit mode" off this.
function ui.IsVisible()
    return context.IsVisible()
end

--- Display name for an E_ButtonCode value (for keybind widgets).
function ui.GetKeyName(code)
    return keymap.NameFor(code)
end

--- Persist all widget values now (also happens on Unload and debounced
--- 2 s after any change).
function ui.SaveConfig()
    config.Save()
    context.dirty = false
end

--- Re-read the config file and apply stored values to existing widgets.
function ui.LoadConfig()
    config.Load()
    config.Apply()
end

--- Persist a custom (non-widget) value through the same config file.
--- Keys are namespaced under "custom/". Saved with the normal triggers
--- (Unload, debounced autosave, ui.SaveConfig).
function ui.Store(key, value)
    config.data["custom/" .. tostring(key)] = value
    context.MarkDirty()
end

--- Read back a value saved with ui.Store (or `default` if absent).
function ui.Fetch(key, default)
    local v = config.data["custom/" .. tostring(key)]
    if v == nil then return default end
    return v
end

--- True while the mouse is over any open UI window or popup this frame.
--- Scripts drawing their own overlays should skip their click handling
--- when this is true.
function ui.IsMouseOverUI()
    return context.mouseOverUI
end

--- Tear the UI down manually (config save + texture cleanup included).
function ui.Shutdown()
    context.Shutdown()
end

context.Setup()

return ui
end

__modules["__main"] = function(require)
-- examples/hud.lua — a configurable in-game HUD built on the GUI library.
--
-- Elements (each toggleable; drag to move, drag any edge/corner to resize):
--   * Health   — bar + number, color scales red->yellow->green, overheal blue
--   * Ammo     — active weapon clip / reserve
--   * Uber     — medigun charge (shown only when you carry a medigun)
--   * Perf     — smoothed FPS + ping
--   * Feed     — recent damage YOU dealt (from player_hurt game events)
--
-- Settings live in a "HUD Settings" window (visible with the menu). Element
-- positions and scales persist along with every setting. Resizing scales the
-- whole element uniformly — fonts are recreated at the scaled size, so text
-- stays crisp instead of stretching.
--
-- Bundle for in-game use:  lua build.lua hud   ->  dist/hud_bundled.lua

-- The HUD render callback is registered BEFORE the library loads so the
-- menu windows draw on top of the HUD (callbacks run in registration order).
local renderHUD -- forward declaration, assigned at the end of setup
callbacks.Register("Draw", "hud_render", function()
    if renderHUD then renderHUD() end
end)

local ui = require("init")

-- The GUI (settings window + HUD edit mode) toggles with DELETE by default
-- (rebindable below); it also shows while the environment menu is open.
ui.SetToggleKey(KEY_DELETE)

-- Config state (widget callbacks keep this in sync; stored values are
-- re-applied through those same callbacks on load) ---------------------------------

local cfg = {
    master = true,
    toggleKey = 0,
    health = true,
    ammo = true,
    uber = true,
    perf = true,
    feed = true,
    showBg = true,
    feedDuration = 6,
    feedMax = 6,
    bgColor = { 0, 0, 0, 150 },
    accent = { 255, 150, 0, 255 },
}

-- Scaled font cache: fonts are recreated per integer pixel height so scaled
-- elements render crisp text (there is no way to stretch-draw a font).

local FONT_DEFS = {
    big = { height = 24, weight = 800 },
    med = { height = 13, weight = 500 },
    small = { height = 11, weight = 400 },
}
local fontCache = {}

local function getFont(kind, scale)
    local def = FONT_DEFS[kind]
    local h = math.max(8, math.floor(def.height * scale + 0.5))
    local key = kind .. h
    local id = fontCache[key]
    if not id then
        id = draw.CreateFont("Verdana", h, def.weight)
        fontCache[key] = id
    end
    return id
end

local FLOW_OUT = FLOW_OUTGOING or 0

-- Helpers ---------------------------------------------------------------------------

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

--- Health -> display color. Pure function (unit-tested in the smoke test).
--- Returns r, g, b for hp against maxHp; overheal gets a blue tint.
local function healthColor(hp, maxHp)
    if maxHp <= 0 then return 235, 80, 70 end
    if hp > maxHp then return 100, 200, 255 end
    local frac = clamp(hp / maxHp, 0, 1)
    if frac < 0.5 then
        local t = frac / 0.5 -- red -> yellow
        return math.floor(lerp(235, 240, t)), math.floor(lerp(80, 200, t)), math.floor(lerp(70, 80, t))
    end
    local t = (frac - 0.5) / 0.5 -- yellow -> green
    return math.floor(lerp(240, 120, t)), math.floor(lerp(200, 220, t)), math.floor(lerp(80, 100, t))
end

local function panelBg(x, y, w, h)
    if not cfg.showBg then return end
    local c = cfg.bgColor
    draw.Color(c[1], c[2], c[3], c[4])
    draw.FilledRect(math.floor(x), math.floor(y), math.floor(x + w), math.floor(y + h))
end

local function shadowText(font, x, y, r, g, b, a, text)
    draw.SetFont(font)
    draw.Color(r, g, b, a)
    draw.TextShadow(math.floor(x), math.floor(y), text)
end

-- Per-frame game data (placeholders fill in during edit mode so elements can
-- be positioned from the main menu) -------------------------------------------------

local function gatherData(editMode)
    local d = {}
    local ply = entities.GetLocalPlayer()
    if ply and ply:IsAlive() then
        d.hp = ply:GetHealth()
        d.maxHp = ply:GetMaxHealth()

        local wpn = ply:GetPropEntity("m_hActiveWeapon")
        if wpn then
            local clip = wpn:GetPropInt("LocalWeaponData", "m_iClip1")
            local ammoType = wpn:GetPropInt("LocalWeaponData", "m_iPrimaryAmmoType")
            local ammoTable = ply:GetPropDataTableInt("localdata", "m_iAmmo")
            d.clip = clip
            if ammoTable and ammoType and ammoType >= 0 then
                d.reserve = ammoTable[ammoType + 1]
            end
            if wpn.IsMedigun and wpn:IsMedigun() then
                d.uber = wpn:GetPropFloat("LocalTFWeaponMedigunData", "m_flChargeLevel")
            end
        end
        if d.uber == nil and ply.GetEntityForLoadoutSlot then
            local sec = ply:GetEntityForLoadoutSlot(LOADOUT_POSITION_SECONDARY or 1)
            if sec and sec.IsMedigun and sec:IsMedigun() then
                d.uber = sec:GetPropFloat("LocalTFWeaponMedigunData", "m_flChargeLevel")
            end
        end
    end

    if editMode then -- placeholders for anything missing
        if d.hp == nil then d.hp, d.maxHp = 87, 125 end
        if d.clip == nil then d.clip, d.reserve = 17, 140 end
        if d.uber == nil then d.uber = 0.45 end
    end
    return d
end

-- Elements --------------------------------------------------------------------------
-- Every element has a persisted position (x, y) and uniform scale. Its draw
-- function must set el.w/el.h (already scaled) so hit-testing matches what
-- is on screen, and return whether it drew live content.
--
-- The persisted el.scale is the user's tweak relative to the library's
-- HighRes UI scale (ui.GetScale()); the effective draw scale multiplies the
-- two, so elements stay resolution-appropriate AND user adjustments survive
-- toggling HighRes or changing resolutions.

local MIN_SCALE, MAX_SCALE = 0.5, 3.0

local function drawScale(el)
    return el.scale * ui.GetScale()
end

local elements = {} -- id -> element table
local elementOrder = { "health", "ammo", "uber", "perf", "feed" }

local function addElement(id, defX, defY, drawFn)
    elements[id] = {
        id = id,
        x = math.floor(ui.Fetch("hud_" .. id .. "_x", defX)),
        y = math.floor(ui.Fetch("hud_" .. id .. "_y", defY)),
        scale = clamp(ui.Fetch("hud_" .. id .. "_s", 1), MIN_SCALE, MAX_SCALE),
        defX = defX,
        defY = defY,
        w = 100,
        h = 20,
        draw = drawFn,
    }
end

local function storeElement(el)
    ui.Store("hud_" .. el.id .. "_x", el.x)
    ui.Store("hud_" .. el.id .. "_y", el.y)
    ui.Store("hud_" .. el.id .. "_s", el.scale)
end

local sw, sh = draw.GetScreenSize()

-- Health: number + colored bar
addElement("health", math.floor(sw * 0.30), sh - ui.Scale(150), function(el, d)
    local s = drawScale(el)
    el.w, el.h = math.floor(150 * s), math.floor(46 * s)
    if d.hp == nil then return false end
    panelBg(el.x, el.y, el.w, el.h)
    local r, g, b = healthColor(d.hp, d.maxHp or 100)
    shadowText(getFont("small", s), el.x + 8 * s, el.y + 4 * s, 200, 200, 200, 255, "HP")
    shadowText(getFont("big", s), el.x + 8 * s, el.y + 14 * s, r, g, b, 255, tostring(d.hp))
    -- bar
    local bx, by = el.x + 62 * s, el.y + el.h - 18 * s
    local bw, bh = el.w - 70 * s, 8 * s
    draw.Color(40, 40, 40, 220)
    draw.FilledRect(math.floor(bx), math.floor(by), math.floor(bx + bw), math.floor(by + bh))
    local frac = clamp(d.hp / math.max(1, d.maxHp or 100), 0, 1)
    draw.Color(r, g, b, 255)
    draw.FilledRect(math.floor(bx), math.floor(by), math.floor(bx + bw * frac), math.floor(by + bh))
    return true
end)

-- Ammo: clip / reserve
addElement("ammo", math.floor(sw * 0.62), sh - ui.Scale(150), function(el, d)
    local s = drawScale(el)
    el.w, el.h = math.floor(130 * s), math.floor(46 * s)
    if d.clip == nil and d.reserve == nil then return false end
    panelBg(el.x, el.y, el.w, el.h)
    local clipText = (d.clip and d.clip >= 0) and tostring(d.clip) or "-"
    local reserveText = d.reserve and tostring(d.reserve) or "-"
    shadowText(getFont("small", s), el.x + 8 * s, el.y + 4 * s, 200, 200, 200, 255, "AMMO")
    shadowText(getFont("big", s), el.x + 8 * s, el.y + 14 * s, 235, 235, 235, 255, clipText)
    draw.SetFont(getFont("big", s))
    local cw = draw.GetTextSize(clipText)
    shadowText(getFont("med", s), el.x + 8 * s + cw + 6 * s, el.y + 24 * s,
        170, 170, 170, 255, "/ " .. reserveText)
    return true
end)

-- Uber: only when a medigun is carried
addElement("uber", math.floor(sw * 0.44), sh - ui.Scale(90), function(el, d)
    local s = drawScale(el)
    el.w, el.h = math.floor(170 * s), math.floor(30 * s)
    if d.uber == nil then return false end
    panelBg(el.x, el.y, el.w, el.h)
    local pct = math.floor(d.uber * 100 + 0.5)
    local full = pct >= 100
    local a = cfg.accent
    local r, g, b = a[1], a[2], a[3]
    if full then r, g, b = 120, 220, 100 end
    shadowText(getFont("med", s), el.x + 8 * s, el.y + 4 * s, r, g, b, 255,
        full and "UBER READY" or ("UBER " .. pct .. "%"))
    local bx, by = el.x + 8 * s, el.y + el.h - 9 * s
    local bw, bh = el.w - 16 * s, 5 * s
    draw.Color(40, 40, 40, 220)
    draw.FilledRect(math.floor(bx), math.floor(by), math.floor(bx + bw), math.floor(by + bh))
    draw.Color(r, g, b, 255)
    draw.FilledRect(math.floor(bx), math.floor(by),
        math.floor(bx + bw * clamp(d.uber, 0, 1)), math.floor(by + bh))
    return true
end)

-- Perf: smoothed FPS + ping
local fpsSmoothed = 0
local perfText = ""
addElement("perf", sw - ui.Scale(170), ui.Scale(10), function(el)
    local s = drawScale(el)
    el.w, el.h = math.floor(150 * s), math.floor(20 * s)
    local ft = globals.FrameTime()
    if ft > 0 then
        fpsSmoothed = fpsSmoothed == 0 and (1 / ft) or (fpsSmoothed * 0.95 + (1 / ft) * 0.05)
    end
    if perfText == "" or globals.FrameCount() % 15 == 0 then
        local ping = ""
        local nc = clientstate.GetNetChannel()
        if nc then
            local lat = nc:GetLatency(FLOW_OUT)
            if lat then ping = ("  %d ms"):format(math.floor(lat * 1000 + 0.5)) end
        end
        perfText = ("%d fps%s"):format(math.floor(fpsSmoothed + 0.5), ping)
    end
    panelBg(el.x, el.y, el.w, el.h)
    shadowText(getFont("med", s), el.x + 8 * s, el.y + 3 * s, 235, 235, 235, 255, perfText)
    return true
end)

-- Damage feed: recent damage dealt by the local player
local feed = {} -- newest first: { dmg, name, crit, t }

addElement("feed", math.floor(sw * 0.78), math.floor(sh * 0.35), function(el, d, editMode)
    local s = drawScale(el)
    local now = globals.RealTime()
    -- prune expired
    for i = #feed, 1, -1 do
        if now - feed[i].t > cfg.feedDuration then table.remove(feed, i) end
    end
    local shown = feed
    if editMode and #feed == 0 then
        shown = { -- sample lines so the element can be positioned
            { dmg = 45, name = "Placeholder", crit = false, t = now },
            { dmg = 120, name = "Sample", crit = true, t = now },
        }
    end
    local lineH = 15 * s
    el.w = math.floor(170 * s)
    el.h = math.floor(math.max(1, #shown) * lineH + 6 * s)
    if #shown > 0 then
        panelBg(el.x, el.y, el.w, el.h)
        for i, e in ipairs(shown) do
            local age = now - e.t
            local alpha = math.floor(255 * clamp(1 - age / cfg.feedDuration, 0.15, 1))
            local text = ("-%d  %s%s"):format(e.dmg, e.name, e.crit and " (crit)" or "")
            if e.crit then
                shadowText(getFont("med", s), el.x + 6 * s, el.y + 3 * s + (i - 1) * lineH,
                    cfg.accent[1], cfg.accent[2], cfg.accent[3], alpha, text)
            else
                shadowText(getFont("med", s), el.x + 6 * s, el.y + 3 * s + (i - 1) * lineH,
                    235, 235, 235, alpha, text)
            end
        end
    end
    return #shown > 0
end)

callbacks.Register("FireGameEvent", "hud_feed", function(event)
    if event:GetName() ~= "player_hurt" then return end
    local me = entities.GetLocalPlayer()
    if not me then return end
    local attacker = entities.GetByUserID(event:GetInt("attacker"))
    local victim = entities.GetByUserID(event:GetInt("userid"))
    if not attacker or not victim then return end
    if attacker:GetIndex() ~= me:GetIndex() then return end
    if victim:GetIndex() == me:GetIndex() then return end -- ignore self-damage
    local crit = event:GetInt("crit") == 1 or event:GetInt("minicrit") == 1
    table.insert(feed, 1, {
        dmg = event:GetInt("damageamount"),
        name = victim:GetName() or "?",
        crit = crit,
        t = globals.RealTime(),
    })
    while #feed > cfg.feedMax do table.remove(feed) end
end)

-- Settings window ---------------------------------------------------------------------

local win = ui.Window("HUD Settings", ui.Scale(60), ui.Scale(60), ui.Scale(300), 0)
local tabs = win:AddTabs({ "Elements", "Style" })

local pe = tabs:GetPage("Elements")
local masterCb = pe:AddCheckbox("HUD enabled", cfg.master, function(v) cfg.master = v end)
pe:AddKeybind("Toggle key", cfg.toggleKey, function(code) cfg.toggleKey = code end)
pe:AddKeybind("Menu key (show/hide GUI)", KEY_DELETE, function(code) ui.SetToggleKey(code) end)
pe:AddCheckbox("Health", cfg.health, function(v) cfg.health = v end)
pe:AddCheckbox("Ammo", cfg.ammo, function(v) cfg.ammo = v end)
pe:AddCheckbox("Ubercharge", cfg.uber, function(v) cfg.uber = v end)
pe:AddCheckbox("FPS / ping", cfg.perf, function(v) cfg.perf = v end)
pe:AddCheckbox("Damage feed", cfg.feed, function(v) cfg.feed = v end)
pe:AddSlider("Feed duration (s)", 2, 15, cfg.feedDuration, function(v) cfg.feedDuration = v end)
pe:AddSlider("Feed max lines", 3, 12, cfg.feedMax, function(v) cfg.feedMax = v end)

local ps = tabs:GetPage("Style")
-- HighRes scaling: sizes the whole UI (menu + HUD elements) for the screen
-- resolution. Both values persist like every other widget.
ps:AddCheckbox("HighRes UI (scale to screen)", true, function(v) ui.SetHighRes(v) end)
ps:AddSliderFloat("UI scale multiplier", 0.75, 2.0, 1.0,
    function(v) ui.SetScale(v) end, { step = 0.05 })
ps:AddCheckbox("Panel backgrounds", cfg.showBg, function(v) cfg.showBg = v end)
ps:AddColorPicker("Background", cfg.bgColor, function(c) cfg.bgColor = c end)
ps:AddColorPicker("Accent", cfg.accent, function(c) cfg.accent = c end)
ps:AddLabel("While this menu is open:", { dim = true })
ps:AddLabel("drag elements to move them,", { dim = true })
ps:AddLabel("drag their edges/corners to resize.", { dim = true })
ps:AddButton("Reset layout", function()
    for _, id in ipairs(elementOrder) do
        local el = elements[id]
        el.x, el.y, el.scale = el.defX, el.defY, 1
        storeElement(el)
    end
end)

-- Render + edit-mode moving/resizing ------------------------------------------------------

-- Same grip geometry as library windows: 2 px inside, 6 px outside, plus a
-- forgiving 8 px corner zone (Chebyshev distance to the corner point).
-- 1080p-reference values, scaled with the UI like the library's own grips.
local GRIP_IN, GRIP_OUT, CORNER = 2, 6, 8

local function gripEdges(el, mx, my)
    local gIn, gOut = ui.Scale(GRIP_IN), ui.Scale(GRIP_OUT)
    local corner = ui.Scale(CORNER)
    local pad = math.max(gOut, corner)
    if mx < el.x - pad or mx > el.x + el.w + pad
        or my < el.y - pad or my > el.y + el.h + pad then
        return nil
    end
    local e = {
        left = mx >= el.x - gOut and mx <= el.x + gIn,
        right = mx >= el.x + el.w - gIn and mx <= el.x + el.w + gOut,
        top = my >= el.y - gOut and my <= el.y + gIn,
        bottom = my >= el.y + el.h - gIn and my <= el.y + el.h + gOut,
    }
    local nearL = math.abs(mx - el.x) <= corner
    local nearR = math.abs(mx - (el.x + el.w)) <= corner
    local nearT = math.abs(my - el.y) <= corner
    local nearB = math.abs(my - (el.y + el.h)) <= corner
    if nearL and nearT then e.left, e.top = true, true end
    if nearR and nearT then e.right, e.top = true, true end
    if nearL and nearB then e.left, e.bottom = true, true end
    if nearR and nearB then e.right, e.bottom = true, true end
    if e.left or e.right or e.top or e.bottom then return e end
    return nil
end

local prevLeftDown = false
local prevToggleDown = false
local dragging = nil -- { el, ox, oy }
local resizing = nil -- { el, edges, startW, startH, startScale, right, bottom, offL, offR, offT, offB }

renderHUD = function()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then return end

    -- Edit mode follows the library's visibility: the menu toggle key
    -- (DELETE by default) or the environment menu.
    local editMode = ui.IsVisible()

    -- Toggle key: manual edge from IsButtonDown (level-safe: press edges may
    -- be consumed by the GUI library's own polling when the menu is open,
    -- and we don't want the key to toggle while typing in the menu anyway).
    if not editMode and cfg.toggleKey ~= 0 then
        local downNow = input.IsButtonDown(cfg.toggleKey)
        if downNow and not prevToggleDown then
            masterCb:SetValue(not masterCb:GetValue())
        end
        prevToggleDown = downNow
    else
        prevToggleDown = false
    end

    if not cfg.master and not editMode then
        prevLeftDown = false
        return
    end
    if not editMode and entities.GetLocalPlayer() == nil then
        prevLeftDown = false
        return
    end

    local d = gatherData(editMode)
    local screenW, screenH = draw.GetScreenSize()

    local editMx, editMy, overUI
    if editMode then
        local mp = input.GetMousePos()
        editMx, editMy = mp[1], mp[2]
        overUI = ui.IsMouseOverUI()
    end

    for _, id in ipairs(elementOrder) do
        local el = elements[id]
        if cfg[id] then
            local drawn = el.draw(el, d, editMode)
            if editMode then
                -- Position ghost: outline + name even if the element has no
                -- live data, so it can still be placed.
                if not drawn then
                    panelBg(el.x, el.y, el.w, el.h)
                end
                -- Same affordance as the menu windows: the border switches
                -- from neutral gray to the accent color while a resize grip
                -- is hovered or being dragged.
                local gripped = (resizing and resizing.el == el)
                    or (not resizing and not dragging and not overUI
                        and gripEdges(el, editMx, editMy) ~= nil)
                if gripped then
                    local a = cfg.accent
                    draw.Color(a[1], a[2], a[3], 255)
                else
                    draw.Color(140, 140, 150, 180)
                end
                draw.OutlinedRect(el.x, el.y, el.x + el.w, el.y + el.h)
                if gripped then -- second ring for visibility at any scale
                    draw.OutlinedRect(el.x - 1, el.y - 1, el.x + el.w + 1, el.y + el.h + 1)
                end
                local tag = el.scale ~= 1 and ("%s (x%.2f)"):format(id, el.scale) or id
                local us = ui.GetScale()
                shadowText(getFont("small", us), el.x + 2, el.y - 13 * us, 255, 255, 255, 200, tag)
            end
        end
    end

    -- Edit-mode moving and resizing (manual mouse edges; never fight the GUI).
    if editMode then
        local mp = input.GetMousePos()
        local mx, my = mp[1], mp[2]
        local leftDown = input.IsButtonDown(MOUSE_LEFT)
        local pressEdge = leftDown and not prevLeftDown

        if pressEdge and not dragging and not resizing and not ui.IsMouseOverUI() then
            for _, id in ipairs(elementOrder) do
                local el = elements[id]
                if cfg[id] then
                    local edges = gripEdges(el, mx, my)
                    if edges then
                        resizing = {
                            el = el,
                            edges = edges,
                            startW = el.w,
                            startH = el.h,
                            startScale = el.scale,
                            right = el.x + el.w,
                            bottom = el.y + el.h,
                            offL = mx - el.x,
                            offR = (el.x + el.w) - mx,
                            offT = my - el.y,
                            offB = (el.y + el.h) - my,
                        }
                        break
                    elseif mx >= el.x and mx < el.x + el.w
                        and my >= el.y and my < el.y + el.h then
                        dragging = { el = el, ox = mx - el.x, oy = my - el.y }
                        break
                    end
                end
            end
        elseif resizing and leftDown then
            -- Uniform scale from whichever axis is being pulled; the
            -- opposite edge/corner stays pinned.
            local r = resizing
            local el = r.el
            local ratioX, ratioY
            if r.edges.right then
                ratioX = (mx + r.offR - el.x) / r.startW
            elseif r.edges.left then
                ratioX = (r.right - (mx - r.offL)) / r.startW
            end
            if r.edges.bottom then
                ratioY = (my + r.offB - el.y) / r.startH
            elseif r.edges.top then
                ratioY = (r.bottom - (my - r.offT)) / r.startH
            end
            local ratio = math.max(ratioX or 0, ratioY or 0)
            if ratio > 0 then
                local newScale = clamp(r.startScale * ratio, MIN_SCALE, MAX_SCALE)
                local growth = newScale / r.startScale
                el.scale = newScale
                if r.edges.left then
                    el.x = math.floor(r.right - r.startW * growth)
                end
                if r.edges.top then
                    el.y = math.floor(r.bottom - r.startH * growth)
                end
            end
        elseif resizing and not leftDown then
            storeElement(resizing.el)
            resizing = nil
        elseif dragging and leftDown then
            local el = dragging.el
            el.x = clamp(mx - dragging.ox, 0, screenW - el.w)
            el.y = clamp(my - dragging.oy, 0, screenH - el.h)
        elseif dragging and not leftDown then
            storeElement(dragging.el)
            dragging = nil
        end
        prevLeftDown = leftDown
    else
        dragging = nil
        resizing = nil
        prevLeftDown = false
    end
end

-- Returned for the off-game smoke test; ignored in-game.
return {
    cfg = cfg,
    elements = elements,
    feed = feed,
    widgets = { master = masterCb },
    helpers = { healthColor = healthColor },
    ui = ui,
}
end

return __require("__main")
