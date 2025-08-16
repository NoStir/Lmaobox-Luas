--== Beginning of test.lua ==--

------------------------------------------------------------
-- TF2 | LMAOBOX | Premium Corner Brackets (Hit/Death, Overall BBox)
-- - Green (hurt) follows the player in real time
-- - Multi-color (kill) is snapshot at death, with looping color flash
-- - Per-type thickness + optional kill shadow
-- - Anti-spam (per-victim replace), spawn pop-in, kill pulse
-- - Min on-screen size & entry cap, smooth fade-out
------------------------------------------------------------

package.loaded["menu"] = nil -- Forces Lua to reload the module

local loaded, menu = pcall(require, "menu")
if not loaded then
    print("Failed to load menu.lua:", menu)
    return
end

-- =======================
-- Settings Table
-- =======================
local settings = {
    -- Behavior
    only_enemies        = true,
    fade_over_time      = true,
    follow_hurt         = true,
    
    -- Hurt (Follow) Visuals
    duration_sec        = 2.0,
    bracket_len         = 16,
    pad_x               = 18,
    pad_y               = 24,
    scale_x             = 1.20,
    scale_y             = 1.10,
    color_hurt          = {0, 255, 50},
    thickness_hurt      = 3,

    -- Death (Snapshot) Visuals
    duration_kill       = 2.5,
    bracket_len_kill    = 18,
    pad_x_kill          = 22,
    pad_y_kill          = 28,
    scale_x_kill        = 1.25,
    scale_y_kill        = 1.12,
    color_kill          = {255, 60, 60},
    thickness_kill      = 7,

    -- Kill Flash Animation
    kill_flash_period   = 0.4,
    kill_flash_colors   = {
        { time = 0.0,  color = {255,  60,  60} }, -- red
        { time = 0.33, color = {255, 140,   0} }, -- orange
        { time = 0.66, color = {255, 255,   0} }, -- yellow
        { time = 1.0,  color = {255,  60,  60} }, -- back to red
    },

    -- Kill Shadow
    kill_shadow             = true,
    shadow_color            = {0, 0, 0},
    shadow_offset           = 1,
    shadow_extra_thickness  = 4,

    -- Animation & QoL
    pop_in_time         = 0.12,
    pop_in_scale        = 1.12,
    kill_pulse_time     = 0.22,
    kill_pulse_scale    = 1.10,
    min_screen_w        = 70,
    min_screen_h        = 80,
    max_entries         = 12,
    min_alpha           = 10
}


-- =======================
-- State
-- =======================
local hits = {}

-- =======================
-- Helpers
-- =======================
local function vx(v) return v.x or v[1] end
local function vy(v) return v.y or v[2] end
local function vz(v) return v.z or v[3] end
local function clamp(v, lo, hi) if v < lo then return lo elseif v > hi then return hi else return v end end
local function easeOutQuad(t) return 1 - (1 - t) * (1 - t) end
local function setRGB(tbl, r,g,b) tbl[1]=r; tbl[2]=g; tbl[3]=b; end

local function computeOverallBBox(hbList)
    if not hbList or #hbList == 0 then return nil end
    local minx, miny, minz
    local maxx, maxy, maxz
    for i = 1, #hbList do
        local hb = hbList[i]
        local mn, mx = hb and hb[1], hb and hb[2]
        if mn and mx then
            local x0, y0, z0 = vx(mn), vy(mn), vz(mn)
            local x1, y1, z1 = vx(mx), vy(mx), vz(mx)
            if not minx then
                minx, miny, minz = x0, y0, z0
                maxx, maxy, maxz = x1, y1, z1
            else
                if x0 < minx then minx = x0 end
                if y0 < miny then miny = y0 end
                if z0 < minz then minz = z0 end
                if x1 > maxx then maxx = x1 end
                if y1 > maxy then maxy = y1 end
                if z1 > maxz then maxz = z1 end
            end
        end
    end
    if not minx then return nil end
    return Vector3(minx, miny, minz), Vector3(maxx, maxy, maxz)
end

local function lerpColor(t, c1, c2)
    local r = c1[1] + (c2[1] - c1[1]) * t
    local g = c1[2] + (c2[2] - c1[2]) * t
    local b = c1[3] + (c2[3] - c1[3]) * t
    return math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5)
end

local function thickLine(x0, y0, x1, y1, thickness, ox, oy)
    ox = ox or 0; oy = oy or 0
    x0, y0, x1, y1 = x0 + ox, y0 + oy, x1 + ox, y1 + oy
    if x0 == x1 then
        for t = 0, thickness - 1 do draw.Line(x0 + t, y0, x1 + t, y1) end
    elseif y0 == y1 then
        for t = 0, thickness - 1 do draw.Line(x0, y0 + t, x1, y1 + t) end
    else
        draw.Line(x0, y0, x1, y1)
    end
end

local function drawBrackets2D(min2, max2, params, alpha)
    local x0, y0 = min2[1], min2[2]
    local x1, y1 = max2[1], max2[2]
    if x0 > x1 then x0, x1 = x1, x0 end
    if y0 > y1 then y0, y1 = y1, y0 end

    local w, h = x1 - x0, y1 - y0
    if w < settings.min_screen_w then local add=(settings.min_screen_w-w)*0.5; x0=x0-add; x1=x1+add; w=x1-x0 end
    if h < settings.min_screen_h then local add=(settings.min_screen_h-h)*0.5; y0=y0-add; y1=y1+add; h=y1-y0 end

    local cx, cy = (x0 + x1) * 0.5, (y0 + y1) * 0.5
    local hw, hh = w * 0.5, h * 0.5
    hw = hw * (params.scaleX or 1.0) + (params.padX or 0)
    hh = hh * (params.scaleY or 1.0) + (params.padY or 0)

    x0, x1 = math.floor(cx - hw + 0.5), math.floor(cx + hw + 0.5)
    y0, y1 = math.floor(cy - hh + 0.5), math.floor(cy + hh + 0.5)

    w, h = x1 - x0, y1 - y0
    if w <= 1 or h <= 1 then return end

    local bl = params.len
    if bl > w * 0.5 then bl = math.floor(w * 0.5) end
    if bl > h * 0.5 then bl = math.floor(h * 0.5) end
    if bl < 1 then return end

    if params.shadow then
        draw.Color(settings.shadow_color[1], settings.shadow_color[2], settings.shadow_color[3], alpha)
        local th = (params.thickness or 1) + settings.shadow_extra_thickness
        local off = settings.shadow_offset
        thickLine(x0, y0, x0 + bl, y0, th, off, off)
        thickLine(x0, y0, x0, y0 + bl, th, off, off)
        thickLine(x1, y0, x1 - bl, y0, th, off, off)
        thickLine(x1, y0, x1, y0 + bl, th, off, off)
        thickLine(x1, y1, x1 - bl, y1, th, off, off)
        thickLine(x1, y1, x1, y1 - bl, th, off, off)
        thickLine(x0, y1, x0 + bl, y1, th, off, off)
        thickLine(x0, y1, x0, y1 - bl, th, off, off)
    end

    draw.Color(params.r, params.g, params.b, alpha)
    local th = params.thickness or 1
    thickLine(x0, y0, x0 + bl, y0, th)
    thickLine(x0, y0, x0, y0 + bl, th)
    thickLine(x1, y0, x1 - bl, y0, th)
    thickLine(x1, y0, x1, y0 + bl, th)
    thickLine(x1, y1, x1 - bl, y1, th)
    thickLine(x1, y1, x1, y1 - bl, th)
    thickLine(x0, y1, x0 + bl, y1, th)
    thickLine(x0, y1, x0, y1 - bl, th)
end

local function drawBrackets3D(min3, max3, params, alpha)
    local min2 = client.WorldToScreen(min3); if not min2 then return end
    local max2 = client.WorldToScreen(max3); if not max2 then return end
    drawBrackets2D(min2, max2, params, alpha)
end

local function pushEntry(victimIdx, ent, min3, max3, dur, color, len, padX, padY, sX, sY, thickness, shadow, isKill, dynamic)
    local now = globals.RealTime()
    local entry = {
        victimIdx = victimIdx, ent = ent, min3 = min3, max3 = max3,
        dieAt = now + dur, duration = dur, createdAt = now,
        r = color[1], g = color[2], b = color[3],
        len = len, padX = padX, padY = padY, scaleX = sX, scaleY = sY,
        thickness = thickness or 1, shadow = shadow and true or false,
        isKill = isKill and true or false, dynamic = dynamic and true or false
    }

    for i = #hits, 1, -1 do
        if hits[i].victimIdx == victimIdx then
            hits[i] = entry
            return
        end
    end

    if settings.max_entries > 0 and #hits >= settings.max_entries then
        table.remove(hits, 1)
    end
    hits[#hits + 1] = entry
end

-- =======================
-- Events
-- =======================
local function onGameEvent(event)
    local name = event:GetName()
    if name ~= "player_hurt" and name ~= "player_death" then return end

    local me = entities.GetLocalPlayer(); if not me then return end
    local victim   = entities.GetByUserID(event:GetInt("userid"))
    local attacker = entities.GetByUserID(event:GetInt("attacker"))

    if not victim or not attacker or me:GetIndex() ~= attacker:GetIndex() or victim:GetIndex() == me:GetIndex() then return end

    if settings.only_enemies and victim.GetTeamNumber and me.GetTeamNumber then
        if victim:GetTeamNumber() == me:GetTeamNumber() then return end
    end

    if name == "player_hurt" and (event:GetInt("health") or 1) <= 0 then return end

    local hb = victim.GetHitboxes and victim:GetHitboxes()
    if not hb or #hb == 0 then return end

    local min3, max3 = computeOverallBBox(hb)
    if not min3 or not max3 then return end

    local vIdx = victim:GetIndex()

    if name == "player_death" then
        for i = #hits, 1, -1 do
            if hits[i].victimIdx == vIdx then table.remove(hits, i) end
        end
        pushEntry(vIdx, nil, min3, max3, settings.duration_kill, settings.color_kill,
                  settings.bracket_len_kill, settings.pad_x_kill, settings.pad_y_kill, settings.scale_x_kill, settings.scale_y_kill,
                  settings.thickness_kill, settings.kill_shadow, true, false)
    elseif name == "player_hurt" then
        pushEntry(vIdx, victim, min3, max3, settings.duration_sec, settings.color_hurt,
                  settings.bracket_len, settings.pad_x, settings.pad_y, settings.scale_x, settings.scale_y,
                  settings.thickness_hurt, false, false, settings.follow_hurt)
    end
end

callbacks.Register("FireGameEvent", "premium_brackets_events", onGameEvent)

-- =======================
-- Draw
-- =======================
local function onDraw()
    if #hits == 0 then return end
    local now = globals.RealTime()

    for i = #hits, 1, -1 do
        local h = hits[i]
        if now >= h.dieAt then
            table.remove(hits, i)
        else
            if h.dynamic and h.ent then
                local hb = h.ent.GetHitboxes and h.ent:GetHitboxes()
                if hb and #hb > 0 then
                    local mn, mx = computeOverallBBox(hb)
                    if mn and mx then h.min3, h.max3 = mn, mx end
                end
            end

            local alpha = 255
            if settings.fade_over_time then
                alpha = clamp(math.floor(255 * ((h.dieAt - now) / h.duration)), settings.min_alpha, 255)
            end

            local sx, sy = h.scaleX, h.scaleY
            local tSinceCreate = now - h.createdAt
            if tSinceCreate < settings.pop_in_time then
                local t = easeOutQuad(clamp(tSinceCreate / settings.pop_in_time, 0, 1))
                local start = settings.pop_in_scale
                sx = sx * (start - (start - 1.0) * t)
                sy = sy * (start - (start - 1.0) * t)
            end

            if h.isKill and tSinceCreate < settings.kill_pulse_time then
                local p = 1.0 + (settings.kill_pulse_scale - 1.0) * (1.0 - (tSinceCreate / settings.kill_pulse_time))
                sx = sx * p
                sy = sy * p
            end

            local cr, cg, cb = h.r, h.g, h.b
            if h.isKill and settings.kill_flash_period > 0 then
                local ft = (tSinceCreate % settings.kill_flash_period) / settings.kill_flash_period
                for idx = 1, #settings.kill_flash_colors - 1 do
                    local t1, c1 = settings.kill_flash_colors[idx].time, settings.kill_flash_colors[idx].color
                    local t2, c2 = settings.kill_flash_colors[idx+1].time, settings.kill_flash_colors[idx+1].color
                    if ft >= t1 and ft <= t2 then
                        cr, cg, cb = lerpColor((ft - t1) / (t2 - t1), c1, c2)
                        break
                    end
                end
            end

            drawBrackets3D(h.min3, h.max3, {
                r=cr, g=cg, b=cb, len=h.len, padX=h.padX, padY=h.padY,
                scaleX=sx, scaleY=sy, thickness=h.thickness, shadow=h.shadow
            }, alpha)
        end
    end
end

callbacks.Register("Draw", "premium_brackets_draw", onDraw)

----------------------------------------------------------------
-- GUI for TF2 Brackets (uses menu.lua)
----------------------------------------------------------------

-- ==================================
-- Window + Tabs (menu.lua components)
-- ==================================
local wnd = menu.createWindow("Brackets Config", {
    x=120, y=120, width=380, desiredItems=12, titleBarHeight=30, itemHeight=24
})
wnd:focus()

local tabs = wnd:renderTabPanel()

------------------------------------------------------------
-- Tab: General
------------------------------------------------------------
tabs:addTab("General", function()
    wnd:clearWidgets()

    wnd:createCheckbox("Only show on enemies", settings.only_enemies, function(on) settings.only_enemies = on end)
    wnd:createCheckbox("Fade over lifetime", settings.fade_over_time, function(on) settings.fade_over_time = on end)
    wnd:createSlider("Min alpha", settings.min_alpha, 0, 255, function(v) settings.min_alpha = math.floor(v + 0.5) end)
    wnd:createSlider("Min width (px)", settings.min_screen_w, 0, 300, function(v) settings.min_screen_w = math.floor(v + 0.5) end)
    wnd:createSlider("Min height (px)", settings.min_screen_h, 0, 300, function(v) settings.min_screen_h = math.floor(v + 0.5) end)
    wnd:createSlider("Max entries on screen", settings.max_entries, 0, 30, function(v) settings.max_entries = math.floor(v + 0.5) end)

    wnd:createButton("Reset All to Defaults", function()
        settings.only_enemies, settings.fade_over_time, settings.min_alpha = true, true, 10
        settings.min_screen_w, settings.min_screen_h, settings.max_entries = 70, 80, 12
        settings.duration_sec, settings.bracket_len, settings.pad_x, settings.pad_y, settings.scale_x, settings.scale_y, settings.thickness_hurt = 2.0, 16, 18, 24, 1.20, 1.10, 3
        setRGB(settings.color_hurt, 0, 255, 50)
        settings.duration_kill, settings.bracket_len_kill, settings.pad_x_kill, settings.pad_y_kill, settings.scale_x_kill, settings.scale_y_kill, settings.thickness_kill = 2.5, 18, 22, 28, 1.25, 1.12, 7
        setRGB(settings.color_kill, 255, 60, 60)
        settings.kill_flash_period = 0.40
        settings.kill_flash_colors = {
            { time=0.0,  color={255, 60, 60} }, { time=0.33, color={255,140,  0} },
            { time=0.66, color={255,255,  0} }, { time=1.0,  color={255, 60, 60} },
        }
        settings.kill_shadow, settings.shadow_offset, settings.shadow_extra_thickness = true, 1, 4
        setRGB(settings.shadow_color, 0, 0, 0)
        settings.pop_in_time, settings.pop_in_scale, settings.kill_pulse_time, settings.kill_pulse_scale = 0.12, 1.12, 0.22, 1.10
        settings.follow_hurt = true
    end)
end)

------------------------------------------------------------
-- Tab: Hurt (follow)
------------------------------------------------------------
tabs:addTab("Hurt", function()
    wnd:clearWidgets()
    wnd:createCheckbox("Follow target (dynamic)", settings.follow_hurt, function(on) settings.follow_hurt = on end)
    wnd:createSlider("Duration (sec)", settings.duration_sec, 0.2, 5.0, function(v) settings.duration_sec = math.floor(v*100+0.5)/100 end)
    wnd:createSlider("Bracket length (px)", settings.bracket_len, 2, 60, function(v) settings.bracket_len = math.floor(v + 0.5) end)
    wnd:createSlider("Pad X (px)", settings.pad_x, -50, 80, function(v) settings.pad_x = math.floor(v + 0.5) end)
    wnd:createSlider("Pad Y (px)", settings.pad_y, -50, 80, function(v) settings.pad_y = math.floor(v + 0.5) end)
    wnd:createSlider("Scale X", settings.scale_x, 0.7, 2.0, function(v) settings.scale_x = math.floor(v*100+0.5)/100 end)
    wnd:createSlider("Scale Y", settings.scale_y, 0.7, 2.0, function(v) settings.scale_y = math.floor(v*100+0.5)/100 end)
    wnd:createSlider("Thickness", settings.thickness_hurt, 1, 12, function(v) settings.thickness_hurt = math.floor(v + 0.5) end)
    wnd:createComboBox("Color preset", {"Default", "White","Cyan","Lime","Magenta","Custom"}, 1, function(i,_)
        if     i==1 then setRGB(settings.color_hurt, 0, 255, 50)
        elseif i==2 then setRGB(settings.color_hurt, 255,255,255)
        elseif i==3 then setRGB(settings.color_hurt,  80,220,255)
        elseif i==4 then setRGB(settings.color_hurt, 100,255,100)
        elseif i==5 then setRGB(settings.color_hurt, 255,100,255)
        end
    end)
end)

------------------------------------------------------------
-- Tab: Kill (snapshot + flash)
------------------------------------------------------------
tabs:addTab("Kill", function()
    wnd:clearWidgets()
    wnd:createSlider("Duration (sec)", settings.duration_kill, 0.2, 6.0, function(v) settings.duration_kill = math.floor(v*100+0.5)/100 end)
    wnd:createSlider("Bracket length (px)", settings.bracket_len_kill, 2, 80, function(v) settings.bracket_len_kill = math.floor(v + 0.5) end)
    wnd:createSlider("Pad X (px)", settings.pad_x_kill, -50, 100, function(v) settings.pad_x_kill = math.floor(v + 0.5) end)
    wnd:createSlider("Pad Y (px)", settings.pad_y_kill, -50, 100, function(v) settings.pad_y_kill = math.floor(v + 0.5) end)
    wnd:createSlider("Scale X", settings.scale_x_kill, 0.7, 2.0, function(v) settings.scale_x_kill = math.floor(v*100+0.5)/100 end)
    wnd:createSlider("Scale Y", settings.scale_y_kill, 0.7, 2.0, function(v) settings.scale_y_kill = math.floor(v*100+0.5)/100 end)
    wnd:createSlider("Thickness", settings.thickness_kill, 1, 16, function(v) settings.thickness_kill = math.floor(v + 0.5) end)
    wnd:createCheckbox("Shadow", settings.kill_shadow, function(on) settings.kill_shadow = on end)
    wnd:createSlider("Shadow offset (px)", settings.shadow_offset, 0, 6, function(v) settings.shadow_offset = math.floor(v + 0.5) end)
    wnd:createSlider("Shadow extra thickness", settings.shadow_extra_thickness, 0, 12, function(v) settings.shadow_extra_thickness = math.floor(v + 0.5) end)
    wnd:createSlider("Flash cycle (sec)", settings.kill_flash_period, 0.1, 1.2, function(v) settings.kill_flash_period = math.floor(v*100+0.5)/100 end)
    wnd:createComboBox("Flash palette", {"Red-Orange-Yellow", "Red-White-Red", "Hot Pink-Red-Orange", "Keep current"}, 1, function(i,_)
        if i==1 then
            settings.kill_flash_colors = {
                { time=0.0,  color={255, 60, 60} }, { time=0.33, color={255,140,  0} },
                { time=0.66, color={255,255,  0} }, { time=1.0,  color={255, 60, 60} },
            }
        elseif i==2 then
            settings.kill_flash_colors = {
                { time=0.0,  color={255, 60, 60} }, { time=0.5,  color={255,255,255} },
                { time=1.0,  color={255, 60, 60} },
            }
        elseif i==3 then
            settings.kill_flash_colors = {
                { time=0.0,  color={255, 60,180} }, { time=0.5,  color={255, 60, 60} },
                { time=1.0,  color={255,140,  0} },
            }
        end
    end)
end)

------------------------------------------------------------
-- Tab: Animation
------------------------------------------------------------
tabs:addTab("Animation", function()
    wnd:clearWidgets()
    wnd:createSlider("Pop-in time (s)",  settings.pop_in_time, 0.00, 0.40, function(v) settings.pop_in_time = math.floor(v*100+0.5)/100 end)
    wnd:createSlider("Pop-in scale",     settings.pop_in_scale, 1.00, 1.50, function(v) settings.pop_in_scale = math.floor(v*100+0.5)/100 end)
    wnd:createSlider("Kill pulse time (s)",  settings.kill_pulse_time, 0.00, 0.60, function(v) settings.kill_pulse_time = math.floor(v*100+0.5)/100 end)
    wnd:createSlider("Kill pulse scale",     settings.kill_pulse_scale, 1.00, 1.60, function(v) settings.kill_pulse_scale = math.floor(v*100+0.5)/100 end)
end)

------------------------------------------------------------
-- Tab: Debug
------------------------------------------------------------
tabs:addTab("Debug", function()
    wnd:clearWidgets()
    wnd:createButton("Clear all active entries", function()
        if hits then
            for i = #hits, 1, -1 do table.remove(hits, i) end
        end
    end)
    wnd:createButton("Test white (local player)", function()
        local me = entities.GetLocalPlayer()
        if not me then return end
        local hb = me.GetHitboxes and me:GetHitboxes()
        if not hb or #hb==0 then return end
        local mn,mx = computeOverallBBox(hb)
        if not mn or not mx then return end
        local vIdx = me:GetIndex()
        pushEntry(vIdx, me, mn, mx, settings.duration_sec, settings.color_hurt,
                  settings.bracket_len, settings.pad_x, settings.pad_y, settings.scale_x, settings.scale_y,
                  settings.thickness_hurt, false, false, settings.follow_hurt)
    end)
end)

-- ========================
-- Toggle GUI
-- ========================
local function onGuiHotkey()
    if gui.IsMenuOpen() then
        if not wnd.isOpen then
            wnd:focus()
        end
    else 
        if wnd.isOpen then
            wnd:close()
        end
    end
end

callbacks.Register("Draw", "brackets_gui_hotkey", onGuiHotkey)

--== End of test.lua ==--