--[[
    On-Screen Tactical Radar

    Compact rotating radar for TF2/Lmaobox Lua. The local player is fixed in
    the center, view-forward points upward, and nearby world entities are drawn
    around the player. Walls are approximated with brush-only trace samples.
]]

local VERSION = "1.0.0"

local Settings = {
    Enabled = true,
    ToggleKey = KEY_INSERT,
    Size = 220,
    MarginX = 24,
    MarginY = 150,
    Range = 2600.0,
    ScanInterval = 0.10,
    WallScanInterval = 0.18,
    WallSamples = 72,
    MaxMarkers = 220,
    ShowWalls = true,
    ShowAllies = true,
    ShowBuildings = true,
    ShowPickups = true,
    ShowObjectives = true,
    ShowEdgeClamps = true
}

local Colors = {
    background = { 10, 12, 15, 185 },
    panel = { 20, 23, 28, 215 },
    border = { 210, 220, 230, 175 },
    grid = { 125, 145, 165, 58 },
    wall = { 190, 200, 210, 130 },
    enemy = { 255, 72, 72, 245 },
    ally = { 86, 160, 255, 225 },
    health = { 70, 245, 120, 245 },
    ammo = { 255, 202, 76, 245 },
    objective = { 208, 130, 255, 245 },
    building = { 95, 225, 235, 235 },
    localPlayer = { 255, 255, 255, 255 },
    text = { 230, 238, 246, 235 },
    subduedText = { 180, 190, 202, 210 }
}

local PlayerClassShort = {
    [1] = "Sc",
    [2] = "Sn",
    [3] = "So",
    [4] = "De",
    [5] = "Me",
    [6] = "He",
    [7] = "Py",
    [8] = "Sp",
    [9] = "En"
}

local radarFont = draw.CreateFont("Verdana", 11, 600, FONTFLAG_OUTLINE)
local radarSmallFont = draw.CreateFont("Verdana", 10, 500, FONTFLAG_OUTLINE)
local markers = {}
local wallHits = {}
local lastScanTime = -999.0
local lastWallScanTime = -999.0
local wasToggleDown = false
local counts = {
    enemy = 0,
    ally = 0,
    health = 0,
    ammo = 0,
    objective = 0,
    building = 0,
    wall = 0
}

local function Clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value
end

local function Color(color, alphaScale)
    local alpha = color[4]

    if alphaScale ~= nil then
        alpha = math.floor(alpha * alphaScale)
    end

    draw.Color(color[1], color[2], color[3], alpha)
end

local function ResetEntityCounts()
    counts.enemy = 0
    counts.ally = 0
    counts.health = 0
    counts.ammo = 0
    counts.objective = 0
    counts.building = 0
end

local function Normalize2D(x, y, fallbackX, fallbackY)
    local len = math.sqrt(x * x + y * y)

    if len < 0.001 then
        return fallbackX, fallbackY
    end

    return x / len, y / len
end

local function GetRadarBasis()
    local viewAngles = engine.GetViewAngles()
    local forward = viewAngles:Forward()
    local right = viewAngles:Right()
    local fx, fy = Normalize2D(forward.x, forward.y, 1.0, 0.0)
    local rx, ry = Normalize2D(right.x, right.y, 0.0, -1.0)
    return fx, fy, rx, ry
end

local function PointToRadar(pos, origin, cx, cy, radius, fx, fy, rx, ry)
    local dx = pos.x - origin.x
    local dy = pos.y - origin.y
    local ahead = dx * fx + dy * fy
    local side = dx * rx + dy * ry
    local dist = math.sqrt(ahead * ahead + side * side)
    local edgeClamped = false

    if dist > Settings.Range and Settings.ShowEdgeClamps then
        local scale = Settings.Range / dist
        ahead = ahead * scale
        side = side * scale
        dist = Settings.Range
        edgeClamped = true
    elseif dist > Settings.Range then
        return nil
    end

    local radarScale = radius / Settings.Range
    return cx + side * radarScale, cy - ahead * radarScale, edgeClamped
end

local function AddMarker(kind, pos, label, team, health, maxHealth)
    if #markers >= Settings.MaxMarkers or pos == nil then
        return
    end

    markers[#markers + 1] = {
        kind = kind,
        pos = pos,
        label = label,
        team = team,
        health = health,
        maxHealth = maxHealth
    }

    counts[kind] = (counts[kind] or 0) + 1
end

local function ClassContains(className, text)
    return string.find(className, text, 1, true) ~= nil
end

local function GetBuildingLabel(className)
    if ClassContains(className, "sentry") then
        return "SG"
    end

    if ClassContains(className, "dispenser") then
        return "DS"
    end

    if ClassContains(className, "teleporter") then
        return "TP"
    end

    return "B"
end

local function GetObjectiveLabel(className)
    if ClassContains(className, "flag") or ClassContains(className, "intelligence") then
        return "F"
    end

    if ClassContains(className, "passtime") or ClassContains(className, "ball") then
        return "PB"
    end

    return "CP"
end

local function ClassifyWorldEntity(className)
    if Settings.ShowPickups and (ClassContains(className, "health") or ClassContains(className, "medkit")) then
        return "health", "H"
    end

    if Settings.ShowPickups and (ClassContains(className, "ammo") or ClassContains(className, "ammopack") or ClassContains(className, "dropped_weapon")) then
        return "ammo", "A"
    end

    if Settings.ShowObjectives and (
        ClassContains(className, "controlpoint") or
        ClassContains(className, "captureflag") or
        ClassContains(className, "team_control_point") or
        ClassContains(className, "passtime_ball")
    ) then
        return "objective", GetObjectiveLabel(className)
    end

    if Settings.ShowBuildings and (
        ClassContains(className, "objectsentry") or
        ClassContains(className, "objectdispenser") or
        ClassContains(className, "objectteleporter") or
        ClassContains(className, "sentrygun") or
        ClassContains(className, "dispenser") or
        ClassContains(className, "teleporter")
    ) then
        return "building", GetBuildingLabel(className)
    end

    return nil, nil
end

local function ScanEntities(localPlayer)
    local myTeam = localPlayer:GetTeamNumber()
    local myIndex = localPlayer:GetIndex()
    local highestIndex = entities.GetHighestEntityIndex() or 0
    markers = {}
    ResetEntityCounts()

    for i = 1, highestIndex do
        local entity = entities.GetByIndex(i)

        if entity and entity:IsValid() and not entity:IsDormant() then
            local className = entity:GetClass()

            if className == "CTFPlayer" then
                if entity:GetIndex() ~= myIndex and entity:IsAlive() then
                    local team = entity:GetTeamNumber()
                    local isEnemy = team ~= myTeam

                    if isEnemy or Settings.ShowAllies then
                        local classId = entity:GetPropInt("m_iClass") or 0
                        local label = PlayerClassShort[classId] or "P"
                        AddMarker(isEnemy and "enemy" or "ally", entity:GetAbsOrigin(), label, team, entity:GetHealth(), entity:GetMaxHealth())
                    end
                end
            else
                local loweredClass = string.lower(className or "")
                local kind, label = ClassifyWorldEntity(loweredClass)

                if kind then
                    AddMarker(kind, entity:GetAbsOrigin(), label, entity:GetTeamNumber(), entity:GetHealth(), entity:GetMaxHealth())
                end
            end
        end
    end
end

local function ScanWalls(localPlayer)
    if not Settings.ShowWalls then
        wallHits = {}
        counts.wall = 0
        return
    end

    local origin = localPlayer:GetAbsOrigin()
    local traceOrigin = origin + Vector3(0, 0, 44)
    local mask = MASK_SOLID_BRUSHONLY or MASK_SOLID or MASK_SHOT_BRUSHONLY
    local hits = {}

    for i = 0, Settings.WallSamples - 1 do
        local angle = (i / Settings.WallSamples) * math.pi * 2.0
        local dir = Vector3(math.cos(angle), math.sin(angle), 0)
        local traceEnd = traceOrigin + dir * Settings.Range
        local trace = engine.TraceLine(traceOrigin, traceEnd, mask)

        if trace and trace.fraction and trace.fraction < 0.995 then
            local hitPos = trace.endpos or (origin + dir * (trace.fraction * Settings.Range))
            hits[#hits + 1] = {
                pos = Vector3(hitPos.x, hitPos.y, origin.z),
                fraction = trace.fraction
            }
        end
    end

    wallHits = hits
    counts.wall = #wallHits
end

local function DrawFilledSquare(x, y, size, color)
    local half = math.floor(size * 0.5)
    Color(color)
    draw.FilledRect(math.floor(x - half), math.floor(y - half), math.floor(x + half), math.floor(y + half))
end

local function DrawOutlinedSquare(x, y, size, color)
    local half = math.floor(size * 0.5)
    Color(color)
    draw.OutlinedRect(math.floor(x - half), math.floor(y - half), math.floor(x + half), math.floor(y + half))
end

local function DrawPlus(x, y, size, color)
    local half = math.floor(size * 0.5)
    Color(color)
    draw.Line(math.floor(x - half), math.floor(y), math.floor(x + half), math.floor(y))
    draw.Line(math.floor(x), math.floor(y - half), math.floor(x), math.floor(y + half))
end

local function DrawDiamond(x, y, size, color)
    local half = math.floor(size * 0.5)
    x = math.floor(x)
    y = math.floor(y)
    Color(color)
    draw.Line(x, y - half, x + half, y)
    draw.Line(x + half, y, x, y + half)
    draw.Line(x, y + half, x - half, y)
    draw.Line(x - half, y, x, y - half)
end

local function DrawTextCentered(x, y, text, color, font)
    draw.SetFont(font or radarSmallFont)
    local textW, textH = draw.GetTextSize(text)
    Color(color)
    draw.Text(math.floor(x - textW * 0.5), math.floor(y - textH * 0.5), text)
end

local function DrawPlayerMarker(marker, x, y, edgeClamped)
    local color = marker.kind == "enemy" and Colors.enemy or Colors.ally
    local size = edgeClamped and 10 or 8

    DrawFilledSquare(x, y, size, color)

    if marker.health and marker.maxHealth and marker.maxHealth > 0 then
        local hp = Clamp(marker.health / marker.maxHealth, 0.0, 1.0)
        local barW = 14
        local bx = math.floor(x - barW * 0.5)
        local by = math.floor(y + size * 0.5 + 2)

        draw.Color(0, 0, 0, 165)
        draw.FilledRect(bx, by, bx + barW, by + 2)
        Color(color, 0.9)
        draw.FilledRect(bx, by, bx + math.floor(barW * hp), by + 2)
    end

    DrawTextCentered(x, y - 11, marker.label, color, radarSmallFont)
end

local function DrawMarker(marker, x, y, edgeClamped)
    if marker.kind == "enemy" or marker.kind == "ally" then
        DrawPlayerMarker(marker, x, y, edgeClamped)
    elseif marker.kind == "health" then
        DrawPlus(x, y, edgeClamped and 12 or 10, Colors.health)
    elseif marker.kind == "ammo" then
        DrawOutlinedSquare(x, y, edgeClamped and 10 or 8, Colors.ammo)
        DrawTextCentered(x, y, "A", Colors.ammo, radarSmallFont)
    elseif marker.kind == "objective" then
        Color(Colors.objective)
        draw.OutlinedCircle(math.floor(x), math.floor(y), edgeClamped and 7 or 6, 18)
        DrawTextCentered(x, y, marker.label, Colors.objective, radarSmallFont)
    elseif marker.kind == "building" then
        DrawDiamond(x, y, edgeClamped and 12 or 10, Colors.building)
        DrawTextCentered(x, y, marker.label, Colors.building, radarSmallFont)
    end
end

local function DrawRadarFrame(x, y, size, cx, cy, radius)
    Color(Colors.background)
    draw.FilledRect(x - 2, y - 2, x + size + 2, y + size + 2)
    Color(Colors.panel)
    draw.FilledRect(x, y, x + size, y + size)
    Color(Colors.border)
    draw.OutlinedRect(x, y, x + size, y + size)

    Color(Colors.grid)
    draw.Line(cx, y + 9, cx, y + size - 9)
    draw.Line(x + 9, cy, x + size - 9, cy)
    draw.OutlinedCircle(cx, cy, radius * 0.33, 48)
    draw.OutlinedCircle(cx, cy, radius * 0.66, 64)
    draw.OutlinedCircle(cx, cy, radius, 96)

    Color(Colors.localPlayer)
    draw.Line(cx, cy - 8, cx + 6, cy + 6)
    draw.Line(cx, cy - 8, cx - 6, cy + 6)
    draw.Line(cx - 6, cy + 6, cx + 6, cy + 6)

    draw.SetFont(radarFont)
    Color(Colors.text)
    draw.Text(x + 8, y + 7, "RADAR")
    draw.SetFont(radarSmallFont)
    Color(Colors.subduedText)
    draw.Text(x + size - 65, y + 8, tostring(math.floor(Settings.Range)) .. " HU")
end

local function DrawWalls(origin, cx, cy, radius, fx, fy, rx, ry)
    if not Settings.ShowWalls or #wallHits == 0 then
        return
    end

    Color(Colors.wall)

    local prevX, prevY = nil, nil

    for i = 1, #wallHits do
        local hit = wallHits[i]
        local x, y = PointToRadar(hit.pos, origin, cx, cy, radius, fx, fy, rx, ry)

        if x and y then
            x = math.floor(x)
            y = math.floor(y)

            if prevX and prevY then
                local dx = x - prevX
                local dy = y - prevY

                if dx * dx + dy * dy < 900 then
                    draw.Line(prevX, prevY, x, y)
                end
            end

            draw.FilledRect(x - 1, y - 1, x + 2, y + 2)
            prevX = x
            prevY = y
        else
            prevX = nil
            prevY = nil
        end
    end
end

local function DrawLegend(x, y, size)
    local lineY = y + size + 7
    local text = string.format(
        "E:%d  H:%d  A:%d  CP:%d  B:%d  W:%d",
        counts.enemy,
        counts.health,
        counts.ammo,
        counts.objective,
        counts.building,
        counts.wall
    )

    draw.SetFont(radarSmallFont)
    Color(Colors.text)
    draw.Text(x + 3, lineY, text)

    Color(Colors.subduedText)
    draw.Text(x + size - 68, lineY, "INS toggle")
end

local function UpdateInput()
    if engine.IsChatOpen() or gui.IsMenuOpen() then
        wasToggleDown = input.IsButtonDown(Settings.ToggleKey)
        return
    end

    local toggleDown = input.IsButtonDown(Settings.ToggleKey)

    if toggleDown and not wasToggleDown then
        Settings.Enabled = not Settings.Enabled
    end

    wasToggleDown = toggleDown
end

local function OnDraw()
    UpdateInput()

    if not Settings.Enabled then
        return
    end

    if engine.Con_IsVisible() or engine.IsGameUIVisible() or engine.IsTakingScreenshot() then
        return
    end

    local localPlayer = entities.GetLocalPlayer()

    if not localPlayer or not localPlayer:IsValid() or not localPlayer:IsAlive() then
        return
    end

    local curTime = globals.RealTime()

    if curTime >= lastScanTime + Settings.ScanInterval then
        ScanEntities(localPlayer)
        lastScanTime = curTime
    end

    if curTime >= lastWallScanTime + Settings.WallScanInterval then
        ScanWalls(localPlayer)
        lastWallScanTime = curTime
    end

    local screenW, screenH = draw.GetScreenSize()
    local size = Settings.Size
    local x = math.floor(screenW - size - Settings.MarginX)
    local y = math.floor(Settings.MarginY)

    if y + size + 26 > screenH then
        y = math.max(12, screenH - size - 32)
    end

    local cx = math.floor(x + size * 0.5)
    local cy = math.floor(y + size * 0.5)
    local radius = math.floor(size * 0.5 - 17)
    local origin = localPlayer:GetAbsOrigin()
    local fx, fy, rx, ry = GetRadarBasis()

    DrawRadarFrame(x, y, size, cx, cy, radius)
    DrawWalls(origin, cx, cy, radius, fx, fy, rx, ry)

    for i = 1, #markers do
        local marker = markers[i]
        local markerX, markerY, edgeClamped = PointToRadar(marker.pos, origin, cx, cy, radius, fx, fy, rx, ry)

        if markerX and markerY then
            DrawMarker(marker, markerX, markerY, edgeClamped)
        end
    end

    DrawLegend(x, y, size)
end

callbacks.Unregister("Draw", "OnScreenRadar_Draw")
callbacks.Unregister("Unload", "OnScreenRadar_Unload")
callbacks.Register("Draw", "OnScreenRadar_Draw", OnDraw)
callbacks.Register("Unload", "OnScreenRadar_Unload", function()
    callbacks.Unregister("Draw", "OnScreenRadar_Draw")
    callbacks.Unregister("Unload", "OnScreenRadar_Unload")
end)

client.ChatPrintf("\x0777DD77[On-Screen Radar v" .. VERSION .. "]\x01 Loaded. Press INSERT to toggle.")
