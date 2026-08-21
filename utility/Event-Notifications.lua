-- Event Feed: vertical stack with fade + smooth reflow, per-item random colors

-- ======= config =======
local FONT        = draw.CreateFont("Verdana", 20, 800)
local BASE_X      = 52
local BASE_Y      = 140
local LINE_H      = 24
local MAX_ITEMS   = 24
local LIFETIME    = 6.0
local FADE_TIME   = 2.0
local LERP_SPEED  = 14.0
-- ======================

-- Seed RNG once
if os and os.time then math.randomseed(os.time()) end

---@class FeedItem
-- text: string, t: number, y: number, r/g/b: number
local feed = {}

local function rand_color()
    -- bright-ish palette to avoid unreadable dark colors
    return math.random(110,255), math.random(110,255), math.random(110,255)
end

-- Push a new item at the top of the stack
local function push_item(label)
    local r,g,b = rand_color()
    table.insert(feed, 1, { text = label, t = LIFETIME, y = BASE_Y - LINE_H, r = r, g = g, b = b })
    if #feed > MAX_ITEMS then
        table.remove(feed)
    end
end

-- Capture every game event name
local function on_event(ev)
    local name = ev and ev:GetName()
    if name ~= nil then
        if name ~= "gameui_hide" and
           name ~= "gameui_hidden" and
           name ~= "gameui_activate" and
           name ~= "gameui_activated" then
            push_item(name)
            engine.PlaySound("ui/trade_up_envelope_slide_in.wav")
        end
    else
        push_item("<nil event>")
        engine.PlaySound("ui/record_fail.wav")
    end
end

local function lerp(a, b, t) return a + (b - a) * t end

-- Draw/update the feed
local function on_draw()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then return end

    local dt = globals.FrameTime()
    draw.SetFont(FONT)

    local i = 1
    while i <= #feed do
        local item = feed[i]
        item.t = item.t - dt
        if item.t <= 0 then
            table.remove(feed, i)
        else
            local targetY = BASE_Y + (i - 1) * LINE_H
            item.y = lerp(item.y, targetY, math.min(1.0, LERP_SPEED * dt))

            local alpha = 255
            if item.t < FADE_TIME then
                alpha = math.max(0, math.floor(255 * (item.t / FADE_TIME)))
            end

            draw.Color(item.r, item.g, item.b, alpha)
            draw.Text(BASE_X, math.floor(item.y + 0.5), item.text)

            i = i + 1
        end
    end
end

callbacks.Register("FireGameEvent", "event_feed_on_event", on_event)
callbacks.Register("Draw",          "event_feed_on_draw",  on_draw)
