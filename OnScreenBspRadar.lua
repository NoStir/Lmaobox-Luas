--[[
    BSP-Backed On-Screen Tactical Radar

    Reads the current map's .bsp file for static map data:
    - entity lump: health, ammo, control points, flags, other map objectives
    - geometry lumps: vertices, edges, surfedges, faces for wall/brush outlines

    Moving data such as enemy players and engineer buildings still comes from
    live entities because those objects are not stored in the map BSP.
]]

local VERSION = "1.1.0"
local CONFIG_DIR = "bsp_radar_cfg"
local CONFIG_FILE = "bsp_radar.cfg"

local LUMP_ENTITIES = 0
local LUMP_VERTEXES = 3
local LUMP_FACES = 7
local LUMP_EDGES = 12
local LUMP_SURFEDGES = 13
local BSP_LUMP_COUNT = 64
local SOURCE_FACE_SIZE = 56

local DEFAULT_SETTINGS = {
    Enabled = true,
    ToggleKey = KEY_HOME,
    MenuKey = KEY_DELETE,
    Size = 230,
    MarginX = 24,
    MarginY = 150,
    Scale = 1.0,
    Range = 2800.0,
    RuntimeScanInterval = 0.10,
    MapReloadInterval = 1.00,
    GeometryCellSize = 512.0,
    GeometryZBelow = 96.0,
    GeometryZAbove = 140.0,
    MinGeometryLength = 20.0,
    MaxGeometryDraw = 1800,
    MaxRuntimeMarkers = 180,
    ShowBspGeometry = true,
    ShowBspStaticMarkers = true,
    ShowAllies = true,
    ShowBuildings = true,
    ShowEdgeClamps = true,
    ShowAccessibleOnly = true,
    CullLiveMarkers = false,
    AccessibilityCellSize = 224.0,
    AccessibilityTraceHeight = 38.0,
    AccessibilityRefreshInterval = 0.45,
    AccessibilityMaxCells = 720
}

local Settings = {}
for key, value in pairs(DEFAULT_SETTINGS) do
    Settings[key] = value
end

local CONFIG_KEYS = {
    "Enabled",
    "Size",
    "MarginX",
    "MarginY",
    "Scale",
    "Range",
    "RuntimeScanInterval",
    "GeometryZBelow",
    "GeometryZAbove",
    "MinGeometryLength",
    "MaxGeometryDraw",
    "MaxRuntimeMarkers",
    "ShowBspGeometry",
    "ShowBspStaticMarkers",
    "ShowAllies",
    "ShowBuildings",
    "ShowEdgeClamps",
    "ShowAccessibleOnly",
    "CullLiveMarkers",
    "AccessibilityCellSize",
    "AccessibilityTraceHeight",
    "AccessibilityRefreshInterval",
    "AccessibilityMaxCells"
}

local Colors = {
    background = { 10, 12, 15, 185 },
    panel = { 19, 22, 27, 218 },
    border = { 214, 224, 234, 178 },
    grid = { 128, 148, 168, 58 },
    bspWall = { 206, 214, 224, 125 },
    enemy = { 255, 72, 72, 245 },
    ally = { 86, 160, 255, 225 },
    health = { 70, 245, 120, 245 },
    ammo = { 255, 202, 76, 245 },
    objective = { 208, 130, 255, 245 },
    building = { 95, 225, 235, 235 },
    localPlayer = { 255, 255, 255, 255 },
    text = { 230, 238, 246, 235 },
    subduedText = { 180, 190, 202, 210 },
    warning = { 255, 185, 80, 235 }
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

local screenW, screenH = draw.GetScreenSize()
local radarFont = nil
local radarSmallFont = nil
local menuFonts = {}
local currentFontScaleKey = nil
local pendingFontRefresh = false
local mouseCaptured = false

local UI = {
    isOpen = false,
    x = 96,
    y = 96,
    w = 520,
    h = 528,
    dragging = false,
    dragX = 0,
    dragY = 0,
    activeSlider = nil,
    canInteract = false
}

local Inp = {
    mx = 0,
    my = 0,
    mbDown = false,
    mbPressed = false,
    wasMouseDown = false,
    wasRadarToggleDown = false,
    wasMenuToggleDown = false,
    wUpPressed = false,
    wDownPressed = false
}

local Accessibility = {
    cells = {},
    computed = false,
    originKey = nil,
    nextRefreshTime = 0.0,
    visibleCells = 0,
    limited = false
}

local TRACE_MASK_ACCESSIBILITY = MASK_PLAYERSOLID_BRUSHONLY or MASK_SOLID_BRUSHONLY or MASK_PLAYERSOLID or 0x1400B

local Bsp = {
    loaded = false,
    mapName = nil,
    path = nil,
    error = nil,
    segments = {},
    cells = {},
    cellSize = Settings.GeometryCellSize,
    mapMarkers = {},
    markerCounts = {
        health = 0,
        ammo = 0,
        objective = 0
    }
}

local runtimeMarkers = {}
local runtimeCounts = {
    enemy = 0,
    ally = 0,
    building = 0
}

local lastRuntimeScanTime = -999.0
local lastMapCheckTime = -999.0

local function Clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value
end

local function MouseInBounds(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function InvalidateAccessibility()
    Accessibility.cells = {}
    Accessibility.computed = false
    Accessibility.originKey = nil
    Accessibility.visibleCells = 0
    Accessibility.limited = false
end

local function ClampSettings()
    Settings.Size = math.floor(Clamp(Settings.Size or DEFAULT_SETTINGS.Size, 160, 420) + 0.5)
    Settings.MarginX = math.floor(Clamp(Settings.MarginX or DEFAULT_SETTINGS.MarginX, 0, 2000) + 0.5)
    Settings.MarginY = math.floor(Clamp(Settings.MarginY or DEFAULT_SETTINGS.MarginY, 0, 2000) + 0.5)
    Settings.Scale = math.floor(Clamp(Settings.Scale or DEFAULT_SETTINGS.Scale, 0.75, 2.00) * 20.0 + 0.5) / 20.0
    Settings.Range = Clamp(Settings.Range or DEFAULT_SETTINGS.Range, 600.0, 6500.0)
    Settings.RuntimeScanInterval = Clamp(Settings.RuntimeScanInterval or DEFAULT_SETTINGS.RuntimeScanInterval, 0.03, 0.50)
    Settings.GeometryZBelow = Clamp(Settings.GeometryZBelow or DEFAULT_SETTINGS.GeometryZBelow, 16.0, 420.0)
    Settings.GeometryZAbove = Clamp(Settings.GeometryZAbove or DEFAULT_SETTINGS.GeometryZAbove, 16.0, 520.0)
    Settings.MinGeometryLength = Clamp(Settings.MinGeometryLength or DEFAULT_SETTINGS.MinGeometryLength, 4.0, 160.0)
    Settings.MaxGeometryDraw = math.floor(Clamp(Settings.MaxGeometryDraw or DEFAULT_SETTINGS.MaxGeometryDraw, 150, 6000) + 0.5)
    Settings.MaxRuntimeMarkers = math.floor(Clamp(Settings.MaxRuntimeMarkers or DEFAULT_SETTINGS.MaxRuntimeMarkers, 20, 500) + 0.5)
    Settings.AccessibilityCellSize = Clamp(Settings.AccessibilityCellSize or DEFAULT_SETTINGS.AccessibilityCellSize, 96.0, 420.0)
    Settings.AccessibilityTraceHeight = Clamp(Settings.AccessibilityTraceHeight or DEFAULT_SETTINGS.AccessibilityTraceHeight, 16.0, 84.0)
    Settings.AccessibilityRefreshInterval = Clamp(Settings.AccessibilityRefreshInterval or DEFAULT_SETTINGS.AccessibilityRefreshInterval, 0.10, 1.50)
    Settings.AccessibilityMaxCells = math.floor(Clamp(Settings.AccessibilityMaxCells or DEFAULT_SETTINGS.AccessibilityMaxCells, 120, 3200) + 0.5)
end

local function UpdateFonts(scale)
    scale = Clamp(scale or 1.0, 0.75, 2.00)
    local scaleKey = math.floor(scale * 100.0 + 0.5)

    if currentFontScaleKey == scaleKey then
        return
    end

    radarFont = draw.CreateFont("Verdana", math.max(8, math.floor(11 * scale + 0.5)), 600, FONTFLAG_OUTLINE)
    radarSmallFont = draw.CreateFont("Verdana", math.max(7, math.floor(10 * scale + 0.5)), 500, FONTFLAG_OUTLINE)
    menuFonts.title = draw.CreateFont("Verdana", math.max(12, math.floor(17 * scale + 0.5)), 800)
    menuFonts.text = draw.CreateFont("Verdana", math.max(10, math.floor(13 * scale + 0.5)), 500)
    menuFonts.small = draw.CreateFont("Verdana", math.max(8, math.floor(11 * scale + 0.5)), 500)
    currentFontScaleKey = scaleKey
end

local function QueueFontRefresh()
    pendingFontRefresh = true
end

local function SetCustomMouseEnabled(enabled)
    if mouseCaptured == enabled then
        return
    end

    input.SetMouseInputEnabled(enabled)
    mouseCaptured = enabled
end

local function ClampWindowToScreen(window, w, h)
    window.x = Clamp(window.x, 0, math.max(0, screenW - w))
    window.y = Clamp(window.y, 0, math.max(0, screenH - h))
end

local function CloseMenu()
    UI.isOpen = false
    UI.dragging = false
    UI.activeSlider = nil
    SetCustomMouseEnabled(false)
end

local function OnSettingChanged(key)
    ClampSettings()

    if key == "Scale" then
        QueueFontRefresh()
    end

    if key == "Range" or key == "ShowAccessibleOnly" or key == "AccessibilityCellSize" or
        key == "AccessibilityTraceHeight" or key == "AccessibilityMaxCells"
    then
        InvalidateAccessibility()
    end
end

local function ResetWindowPositions()
    screenW, screenH = draw.GetScreenSize()
    local scale = Settings.Scale or 1.0
    UI.x = Clamp(math.floor(screenW * 0.06), 0, math.max(0, screenW - math.floor(UI.w * scale)))
    UI.y = Clamp(math.floor(screenH * 0.10), 0, math.max(0, screenH - math.floor(UI.h * scale)))
    Settings.MarginX = DEFAULT_SETTINGS.MarginX
    Settings.MarginY = DEFAULT_SETTINGS.MarginY
end

local function ResetSettings()
    for key, value in pairs(DEFAULT_SETTINGS) do
        Settings[key] = value
    end

    ClampSettings()
    QueueFontRefresh()
    InvalidateAccessibility()
end

local function BuildConfigPath()
    if filesystem and filesystem.CreateDirectory then
        local ok, _, fullPath = pcall(function()
            return filesystem.CreateDirectory(CONFIG_DIR)
        end)

        if ok and type(fullPath) == "string" and fullPath ~= "" then
            return fullPath .. [[\]] .. CONFIG_FILE
        end
    end

    local gameDir = engine.GetGameDir()
    if type(gameDir) == "string" and gameDir ~= "" then
        local lastChar = gameDir:sub(-1)
        local separator = (lastChar == [[\]] or lastChar == "/") and "" or [[\]]
        return gameDir .. separator .. CONFIG_DIR .. [[\]] .. CONFIG_FILE
    end

    return CONFIG_DIR .. [[\]] .. CONFIG_FILE
end

local function ParseConfigValue(key, value)
    local defaultValue = DEFAULT_SETTINGS[key]

    if type(defaultValue) == "boolean" then
        return value == "true" or value == "1"
    elseif type(defaultValue) == "number" then
        return tonumber(value) or defaultValue
    end

    return nil
end

local function ApplyConfigPair(key, value)
    if key:sub(1, 8) == "setting." then
        local settingKey = key:sub(9)
        local parsedValue = ParseConfigValue(settingKey, value)

        if parsedValue ~= nil then
            Settings[settingKey] = parsedValue
        end

        return
    end

    local numericValue = tonumber(value)
    if not numericValue then
        return
    end

    if key == "ui.x" then
        UI.x = numericValue
    elseif key == "ui.y" then
        UI.y = numericValue
    end
end

local function LoadConfig(silent)
    if not io or not io.open then
        if not silent then
            client.ChatPrintf("\x07FF6666[BSP Radar]\x01 Lua io library is unavailable; config cannot be loaded.")
        end
        return false
    end

    local file = io.open(BuildConfigPath(), "r")
    if not file then
        return false
    end

    for line in file:lines() do
        local key, value = line:match("^%s*([^=]+)%s*=%s*(.-)%s*$")
        if key and value then
            ApplyConfigPair(key, value)
        end
    end

    file:close()
    ClampSettings()
    UpdateFonts(Settings.Scale)
    InvalidateAccessibility()

    if not silent then
        client.ChatPrintf("\x0777DD77[BSP Radar]\x01 Configuration loaded.")
    end

    return true
end

local function SaveConfig()
    if not io or not io.open then
        client.ChatPrintf("\x07FF6666[BSP Radar]\x01 Lua io library is unavailable; config cannot be saved.")
        return false
    end

    local file = io.open(BuildConfigPath(), "w")
    if not file then
        client.ChatPrintf("\x07FF6666[BSP Radar]\x01 Failed to open config file for writing.")
        return false
    end

    file:write("# BSP Radar configuration\n")
    file:write("version=", VERSION, "\n")

    for _, key in ipairs(CONFIG_KEYS) do
        file:write("setting.", key, "=", tostring(Settings[key]), "\n")
    end

    file:write("ui.x=", tostring(math.floor(UI.x + 0.5)), "\n")
    file:write("ui.y=", tostring(math.floor(UI.y + 0.5)), "\n")
    file:close()

    client.ChatPrintf("\x0777DD77[BSP Radar]\x01 Configuration saved.")
    return true
end

local function Color(color, alphaScale)
    local alpha = color[4]

    if alphaScale ~= nil then
        alpha = math.floor(alpha * alphaScale)
    end

    draw.Color(color[1], color[2], color[3], alpha)
end

local function RadarScale()
    return Settings.Scale or 1.0
end

local function ResetRuntimeCounts()
    runtimeCounts.enemy = 0
    runtimeCounts.ally = 0
    runtimeCounts.building = 0
end

local function ClassContains(className, text)
    return string.find(className, text, 1, true) ~= nil
end

local function ReadUInt16(data, offset)
    local b1, b2 = string.byte(data, offset, offset + 1)

    if not b2 then
        return nil
    end

    return b1 + b2 * 256
end

local function ReadInt16(data, offset)
    local value = ReadUInt16(data, offset)

    if value and value >= 32768 then
        return value - 65536
    end

    return value
end

local function ReadUInt32(data, offset)
    local b1, b2, b3, b4 = string.byte(data, offset, offset + 3)

    if not b4 then
        return nil
    end

    return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

local function ReadInt32(data, offset)
    local value = ReadUInt32(data, offset)

    if value and value >= 2147483648 then
        return value - 4294967296
    end

    return value
end

local function ReadFloat32(data, offset)
    local b1, b2, b3, b4 = string.byte(data, offset, offset + 3)

    if not b4 then
        return nil
    end

    local sign = 1

    if b4 >= 128 then
        sign = -1
        b4 = b4 - 128
    end

    local exponent = b4 * 2 + math.floor(b3 / 128)
    local mantissa = (b3 % 128) * 65536 + b2 * 256 + b1

    if exponent == 0 then
        if mantissa == 0 then
            return 0
        end

        return sign * (mantissa / 8388608) * (2 ^ (-126))
    end

    if exponent == 255 then
        if mantissa == 0 then
            return sign * math.huge
        end

        return 0 / 0
    end

    return sign * (1.0 + mantissa / 8388608) * (2 ^ (exponent - 127))
end

local function ReadFile(path)
    if not io or not io.open then
        return nil, "Lua io.open is unavailable"
    end

    local file = io.open(path, "rb")

    if not file then
        return nil, "could not open " .. path
    end

    local data = file:read("*a")
    file:close()

    if not data or #data < 1036 then
        return nil, "file is too small or empty"
    end

    return data, nil
end

local function BuildBspPath(mapName)
    local normalized = (mapName or ""):gsub("/", "\\")

    if normalized:lower():sub(-4) ~= ".bsp" then
        normalized = normalized .. ".bsp"
    end

    if normalized:lower():sub(1, 5) ~= "maps\\" then
        normalized = "maps\\" .. normalized
    end

    local gameDir = engine.GetGameDir() or ""

    if gameDir == "" then
        return normalized
    end

    local last = gameDir:sub(-1)
    local separator = (last == "\\" or last == "/") and "" or "\\"
    return gameDir .. separator .. normalized
end

local function ReadBspHeader(data)
    if data:sub(1, 4) ~= "VBSP" then
        return nil, "not a Source VBSP file"
    end

    local lumps = {}

    for i = 0, BSP_LUMP_COUNT - 1 do
        local offset = 9 + i * 16
        lumps[i] = {
            fileOfs = ReadInt32(data, offset),
            fileLen = ReadInt32(data, offset + 4),
            version = ReadInt32(data, offset + 8),
            fourCC = ReadInt32(data, offset + 12)
        }
    end

    return lumps, nil
end

local function IsValidLump(data, lump)
    if not lump or not lump.fileOfs or not lump.fileLen then
        return false
    end

    return lump.fileOfs >= 0 and lump.fileLen > 0 and (lump.fileOfs + lump.fileLen) <= #data
end

local function ParseOrigin(originText)
    if type(originText) ~= "string" then
        return nil
    end

    local x, y, z = originText:match("^%s*([%-%.%d]+)%s+([%-%.%d]+)%s+([%-%.%d]+)")

    if not x then
        return nil
    end

    return Vector3(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0)
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

local function ClassifyBspEntity(className)
    if ClassContains(className, "health") or ClassContains(className, "medkit") then
        return "health", "H"
    end

    if ClassContains(className, "ammo") or ClassContains(className, "ammopack") then
        return "ammo", "A"
    end

    if ClassContains(className, "team_control_point") or
        ClassContains(className, "controlpoint") or
        ClassContains(className, "item_teamflag") or
        ClassContains(className, "captureflag") or
        ClassContains(className, "passtime_ball") or
        ClassContains(className, "item_powerup_rune")
    then
        return "objective", GetObjectiveLabel(className)
    end

    return nil, nil
end

local function ParseEntityLump(data, lump)
    local mapMarkers = {}
    local markerCounts = {
        health = 0,
        ammo = 0,
        objective = 0
    }

    if not IsValidLump(data, lump) then
        return mapMarkers, markerCounts
    end

    local text = data:sub(lump.fileOfs + 1, lump.fileOfs + lump.fileLen)

    for block in text:gmatch("{(.-)}") do
        local kv = {}

        for key, value in block:gmatch("\"([^\"]*)\"%s*\"([^\"]*)\"") do
            kv[key] = value
        end

        local className = string.lower(kv.classname or "")
        local kind, label = ClassifyBspEntity(className)
        local origin = ParseOrigin(kv.origin)

        if kind and origin then
            mapMarkers[#mapMarkers + 1] = {
                kind = kind,
                pos = origin,
                label = label,
                source = "bsp"
            }
            markerCounts[kind] = (markerCounts[kind] or 0) + 1
        end
    end

    return mapMarkers, markerCounts
end

local function CellCoord(value)
    return math.floor(value / Bsp.cellSize)
end

local function CellKey(cellX, cellY)
    return tostring(cellX) .. ":" .. tostring(cellY)
end

local function AddSegmentToCells(segmentIndex, segment)
    local minX = math.min(segment.ax, segment.bx)
    local maxX = math.max(segment.ax, segment.bx)
    local minY = math.min(segment.ay, segment.by)
    local maxY = math.max(segment.ay, segment.by)
    local minCellX = CellCoord(minX)
    local maxCellX = CellCoord(maxX)
    local minCellY = CellCoord(minY)
    local maxCellY = CellCoord(maxY)
    local span = (maxCellX - minCellX + 1) * (maxCellY - minCellY + 1)

    if span > 24 then
        minCellX = CellCoord(segment.midX)
        maxCellX = minCellX
        minCellY = CellCoord(segment.midY)
        maxCellY = minCellY
    end

    for cellX = minCellX, maxCellX do
        for cellY = minCellY, maxCellY do
            local key = CellKey(cellX, cellY)
            local bucket = Bsp.cells[key]

            if not bucket then
                bucket = {}
                Bsp.cells[key] = bucket
            end

            bucket[#bucket + 1] = segmentIndex
        end
    end
end

local function AddGeometrySegment(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local length2D = math.sqrt(dx * dx + dy * dy)

    if length2D < Settings.MinGeometryLength then
        return
    end

    local segment = {
        ax = a.x,
        ay = a.y,
        az = a.z,
        bx = b.x,
        by = b.y,
        bz = b.z,
        midX = (a.x + b.x) * 0.5,
        midY = (a.y + b.y) * 0.5,
        minZ = math.min(a.z, b.z),
        maxZ = math.max(a.z, b.z)
    }

    Bsp.segments[#Bsp.segments + 1] = segment
    AddSegmentToCells(#Bsp.segments, segment)
end

local function ParseGeometryLumps(data, lumps)
    local vertexLump = lumps[LUMP_VERTEXES]
    local edgeLump = lumps[LUMP_EDGES]
    local surfEdgeLump = lumps[LUMP_SURFEDGES]
    local faceLump = lumps[LUMP_FACES]

    if not IsValidLump(data, vertexLump) or
        not IsValidLump(data, edgeLump) or
        not IsValidLump(data, surfEdgeLump) or
        not IsValidLump(data, faceLump)
    then
        return false, "required geometry lumps are missing"
    end

    local vertices = {}
    local vertexCount = math.floor(vertexLump.fileLen / 12)

    for i = 0, vertexCount - 1 do
        local base = vertexLump.fileOfs + 1 + i * 12
        vertices[i + 1] = {
            x = ReadFloat32(data, base),
            y = ReadFloat32(data, base + 4),
            z = ReadFloat32(data, base + 8)
        }
    end

    local edges = {}
    local edgeCount = math.floor(edgeLump.fileLen / 4)

    for i = 0, edgeCount - 1 do
        local base = edgeLump.fileOfs + 1 + i * 4
        edges[i + 1] = {
            a = (ReadUInt16(data, base) or 0) + 1,
            b = (ReadUInt16(data, base + 2) or 0) + 1
        }
    end

    local surfEdges = {}
    local surfEdgeCount = math.floor(surfEdgeLump.fileLen / 4)

    for i = 0, surfEdgeCount - 1 do
        surfEdges[i + 1] = ReadInt32(data, surfEdgeLump.fileOfs + 1 + i * 4)
    end

    local usedEdges = {}
    local faceCount = math.floor(faceLump.fileLen / SOURCE_FACE_SIZE)

    for i = 0, faceCount - 1 do
        local base = faceLump.fileOfs + 1 + i * SOURCE_FACE_SIZE
        local firstEdge = ReadInt32(data, base + 4)
        local numEdges = ReadInt16(data, base + 8)

        if firstEdge and numEdges and numEdges > 0 and numEdges <= 256 then
            for j = 0, numEdges - 1 do
                local surfEdge = surfEdges[firstEdge + j + 1]

                if surfEdge then
                    local edgeIndex = math.abs(surfEdge)

                    if not usedEdges[edgeIndex] then
                        local edge = edges[edgeIndex + 1]

                        if edge then
                            local va
                            local vb

                            if surfEdge >= 0 then
                                va = vertices[edge.a]
                                vb = vertices[edge.b]
                            else
                                va = vertices[edge.b]
                                vb = vertices[edge.a]
                            end

                            if va and vb and va.x and vb.x then
                                AddGeometrySegment(va, vb)
                                usedEdges[edgeIndex] = true
                            end
                        end
                    end
                end
            end
        end
    end

    return true, nil
end

local function ResetBspState()
    Bsp.loaded = false
    Bsp.path = nil
    Bsp.error = nil
    Bsp.segments = {}
    Bsp.cells = {}
    Bsp.cellSize = Settings.GeometryCellSize
    Bsp.mapMarkers = {}
    Bsp.markerCounts = {
        health = 0,
        ammo = 0,
        objective = 0
    }
end

local function LoadBspForMap(mapName)
    ResetBspState()
    Bsp.mapName = mapName
    Bsp.path = BuildBspPath(mapName)

    local data, readError = ReadFile(Bsp.path)

    if not data then
        Bsp.error = readError
        client.ChatPrintf("\x07FFAA55[BSP Radar]\x01 " .. readError)
        return false
    end

    local lumps, headerError = ReadBspHeader(data)

    if not lumps then
        Bsp.error = headerError
        client.ChatPrintf("\x07FF5555[BSP Radar]\x01 " .. headerError)
        return false
    end

    Bsp.mapMarkers, Bsp.markerCounts = ParseEntityLump(data, lumps[LUMP_ENTITIES])

    local ok, geometryError = ParseGeometryLumps(data, lumps)

    if not ok then
        Bsp.error = geometryError
        client.ChatPrintf("\x07FFAA55[BSP Radar]\x01 " .. geometryError)
        return false
    end

    Bsp.loaded = true
    Bsp.error = nil
    client.ChatPrintf(
        "\x0777DD77[BSP Radar v" .. VERSION .. "]\x01 Loaded " ..
        mapName .. " (" .. tostring(#Bsp.segments) .. " segments, " ..
        tostring(#Bsp.mapMarkers) .. " static markers)."
    )
    return true
end

local function EnsureBspLoaded()
    local curTime = globals.RealTime()

    if curTime < lastMapCheckTime + Settings.MapReloadInterval then
        return
    end

    lastMapCheckTime = curTime

    local mapName = engine.GetMapName()

    if not mapName or mapName == "" then
        return
    end

    if Bsp.mapName ~= mapName then
        LoadBspForMap(mapName)
    end
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

local function WorldToRadarUnits(x, y, origin, fx, fy, rx, ry)
    local dx = x - origin.x
    local dy = y - origin.y
    return dx * rx + dy * ry, dx * fx + dy * fy
end

local function PointToRadar(pos, origin, cx, cy, radius, fx, fy, rx, ry)
    local side, ahead = WorldToRadarUnits(pos.x, pos.y, origin, fx, fy, rx, ry)
    local dist = math.sqrt(side * side + ahead * ahead)
    local edgeClamped = false

    if dist > Settings.Range and Settings.ShowEdgeClamps then
        local scale = Settings.Range / dist
        side = side * scale
        ahead = ahead * scale
        edgeClamped = true
    elseif dist > Settings.Range then
        return nil
    end

    local radarScale = radius / Settings.Range
    return cx + side * radarScale, cy - ahead * radarScale, edgeClamped
end

local function ClipRadarSegment(sideA, aheadA, sideB, aheadB)
    local dx = sideB - sideA
    local dy = aheadB - aheadA
    local quadA = dx * dx + dy * dy
    local quadB = 2.0 * (sideA * dx + aheadA * dy)
    local quadC = sideA * sideA + aheadA * aheadA - Settings.Range * Settings.Range
    local endC = sideB * sideB + aheadB * aheadB - Settings.Range * Settings.Range

    if quadC <= 0 and endC <= 0 then
        return sideA, aheadA, sideB, aheadB
    end

    if quadA < 0.001 then
        return nil
    end

    local disc = quadB * quadB - 4.0 * quadA * quadC

    if disc < 0 then
        return nil
    end

    local root = math.sqrt(disc)
    local t1 = (-quadB - root) / (2.0 * quadA)
    local t2 = (-quadB + root) / (2.0 * quadA)
    local tMin = math.max(0.0, math.min(t1, t2))
    local tMax = math.min(1.0, math.max(t1, t2))

    if tMin > tMax then
        return nil
    end

    return sideA + dx * tMin, aheadA + dy * tMin, sideA + dx * tMax, aheadA + dy * tMax
end

local function DistancePointSegment2D(px, py, segment)
    local ax = segment.ax
    local ay = segment.ay
    local bx = segment.bx
    local by = segment.by
    local dx = bx - ax
    local dy = by - ay
    local lengthSq = dx * dx + dy * dy

    if lengthSq < 0.001 then
        local ex = px - ax
        local ey = py - ay
        return math.sqrt(ex * ex + ey * ey)
    end

    local t = ((px - ax) * dx + (py - ay) * dy) / lengthSq
    t = Clamp(t, 0.0, 1.0)

    local cx = ax + dx * t
    local cy = ay + dy * t
    local ex = px - cx
    local ey = py - cy
    return math.sqrt(ex * ex + ey * ey)
end

local function SegmentMatchesHeight(segment, playerZ)
    return segment.maxZ >= playerZ - Settings.GeometryZBelow and
        segment.minZ <= playerZ + Settings.GeometryZAbove
end

local function AccessCellCoord(value)
    return math.floor(value / Settings.AccessibilityCellSize)
end

local function AccessCellKey(cellX, cellY)
    return tostring(cellX) .. ":" .. tostring(cellY)
end

local function AccessCellCenter(cellX, cellY, z)
    local half = Settings.AccessibilityCellSize * 0.5
    return cellX * Settings.AccessibilityCellSize + half, cellY * Settings.AccessibilityCellSize + half, z
end

local function IsAccessibilityAvailable()
    return Settings.ShowAccessibleOnly and Bsp.loaded and engine and engine.TraceLine
end

local function TraceAllowsStep(ax, ay, bx, by, z)
    if not engine or not engine.TraceLine then
        return true
    end

    local traceZ = z + Settings.AccessibilityTraceHeight
    local src = Vector3(ax, ay, traceZ)
    local dst = Vector3(bx, by, traceZ)
    local ok, trace = pcall(engine.TraceLine, src, dst, TRACE_MASK_ACCESSIBILITY, function()
        return false
    end)

    if not ok or not trace then
        return true
    end

    return not trace.startsolid and not trace.allsolid and (trace.fraction or 1.0) >= 0.985
end

local function RebuildAccessibility(origin)
    Accessibility.cells = {}
    Accessibility.computed = false
    Accessibility.visibleCells = 0
    Accessibility.limited = false

    if not IsAccessibilityAvailable() then
        return
    end

    -- Heuristic only: flood nearby collision cells from the player and fall back
    -- if traces cannot find enough open cells to be trustworthy.
    local startX = AccessCellCoord(origin.x)
    local startY = AccessCellCoord(origin.y)
    local startKey = AccessCellKey(startX, startY)
    local maxCells = Settings.AccessibilityMaxCells
    local maxDistance = Settings.Range + Settings.AccessibilityCellSize
    local maxDistanceSq = maxDistance * maxDistance
    local maxCellDelta = math.ceil(maxDistance / Settings.AccessibilityCellSize)
    local queueX = { startX }
    local queueY = { startY }
    local head = 1
    local count = 1

    Accessibility.cells[startKey] = true

    local originCenterX, originCenterY = AccessCellCenter(startX, startY, origin.z)
    local neighbors = {
        { 1, 0 },
        { -1, 0 },
        { 0, 1 },
        { 0, -1 }
    }

    while head <= #queueX do
        if count >= maxCells then
            Accessibility.limited = true
            break
        end

        local cellX = queueX[head]
        local cellY = queueY[head]
        head = head + 1

        local ax, ay = AccessCellCenter(cellX, cellY, origin.z)

        for i = 1, #neighbors do
            local nx = cellX + neighbors[i][1]
            local ny = cellY + neighbors[i][2]

            if math.abs(nx - startX) <= maxCellDelta and math.abs(ny - startY) <= maxCellDelta then
                local key = AccessCellKey(nx, ny)

                if not Accessibility.cells[key] then
                    local bx, by = AccessCellCenter(nx, ny, origin.z)
                    local dx = bx - originCenterX
                    local dy = by - originCenterY

                    if dx * dx + dy * dy <= maxDistanceSq and TraceAllowsStep(ax, ay, bx, by, origin.z) then
                        Accessibility.cells[key] = true
                        queueX[#queueX + 1] = nx
                        queueY[#queueY + 1] = ny
                        count = count + 1

                        if count >= maxCells then
                            Accessibility.limited = true
                            break
                        end
                    end
                end
            end
        end
    end

    Accessibility.visibleCells = count
    Accessibility.computed = count >= 8
end

local function EnsureAccessibility(origin)
    if not Settings.ShowAccessibleOnly or not Bsp.loaded then
        InvalidateAccessibility()
        return
    end

    local cellX = AccessCellCoord(origin.x)
    local cellY = AccessCellCoord(origin.y)
    local zBucket = math.floor(origin.z / 64.0)
    local key = tostring(cellX) .. ":" .. tostring(cellY) .. ":" .. tostring(zBucket) ..
        ":" .. tostring(math.floor(Settings.Range + 0.5)) ..
        ":" .. tostring(math.floor(Settings.AccessibilityCellSize + 0.5))
    local curTime = globals.RealTime()

    if Accessibility.originKey ~= key or curTime >= Accessibility.nextRefreshTime then
        Accessibility.originKey = key
        Accessibility.nextRefreshTime = curTime + Settings.AccessibilityRefreshInterval
        RebuildAccessibility(origin)
    end
end

local function IsAccessCellVisibleForPoint(x, y)
    if not Accessibility.computed then
        return true
    end

    return Accessibility.cells[AccessCellKey(AccessCellCoord(x), AccessCellCoord(y))] == true
end

local function IsAccessCellOrNeighborVisible(x, y)
    if not Accessibility.computed then
        return true
    end

    local cellX = AccessCellCoord(x)
    local cellY = AccessCellCoord(y)

    for dx = -1, 1 do
        for dy = -1, 1 do
            if Accessibility.cells[AccessCellKey(cellX + dx, cellY + dy)] then
                return true
            end
        end
    end

    return false
end

local function IsPointAccessible(pos, origin)
    if not Settings.ShowAccessibleOnly or not Accessibility.computed then
        return true
    end

    if pos.z and (pos.z < origin.z - Settings.GeometryZBelow or pos.z > origin.z + Settings.GeometryZAbove) then
        return false
    end

    return IsAccessCellVisibleForPoint(pos.x, pos.y)
end

local function IsSegmentInAccessibleSpace(segment)
    if not Settings.ShowAccessibleOnly or not Accessibility.computed then
        return true
    end

    if IsAccessCellOrNeighborVisible(segment.midX, segment.midY) then
        return true
    end

    if IsAccessCellOrNeighborVisible(segment.ax, segment.ay) or IsAccessCellOrNeighborVisible(segment.bx, segment.by) then
        return true
    end

    return false
end

local function AddRuntimeMarker(kind, pos, label, team, health, maxHealth)
    if #runtimeMarkers >= Settings.MaxRuntimeMarkers or pos == nil then
        return
    end

    runtimeMarkers[#runtimeMarkers + 1] = {
        kind = kind,
        pos = pos,
        label = label,
        team = team,
        health = health,
        maxHealth = maxHealth,
        source = "live"
    }

    runtimeCounts[kind] = (runtimeCounts[kind] or 0) + 1
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

local function ClassifyRuntimeBuilding(className)
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

local function ScanRuntimeEntities(localPlayer)
    local myTeam = localPlayer:GetTeamNumber()
    local myIndex = localPlayer:GetIndex()
    local highestIndex = entities.GetHighestEntityIndex() or 0
    runtimeMarkers = {}
    ResetRuntimeCounts()

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
                        AddRuntimeMarker(isEnemy and "enemy" or "ally", entity:GetAbsOrigin(), label, team, entity:GetHealth(), entity:GetMaxHealth())
                    end
                end
            else
                local loweredClass = string.lower(className or "")
                local kind, label = ClassifyRuntimeBuilding(loweredClass)

                if kind then
                    AddRuntimeMarker(kind, entity:GetAbsOrigin(), label, entity:GetTeamNumber(), entity:GetHealth(), entity:GetMaxHealth())
                end
            end
        end
    end
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
    local scale = RadarScale()
    local size = math.floor((edgeClamped and 10 or 8) * scale + 0.5)

    DrawFilledSquare(x, y, size, color)

    if marker.health and marker.maxHealth and marker.maxHealth > 0 then
        local hp = Clamp(marker.health / marker.maxHealth, 0.0, 1.0)
        local barW = math.floor(14 * scale + 0.5)
        local barH = math.max(2, math.floor(2 * scale + 0.5))
        local bx = math.floor(x - barW * 0.5)
        local by = math.floor(y + size * 0.5 + math.max(2, math.floor(2 * scale + 0.5)))

        draw.Color(0, 0, 0, 165)
        draw.FilledRect(bx, by, bx + barW, by + barH)
        Color(color, 0.9)
        draw.FilledRect(bx, by, bx + math.floor(barW * hp), by + barH)
    end

    DrawTextCentered(x, y - math.floor(11 * scale + 0.5), marker.label, color, radarSmallFont)
end

local function DrawOutlinedCircleInt(x, y, radius, segments)
    draw.OutlinedCircle(
        math.floor(x + 0.5),
        math.floor(y + 0.5),
        math.max(1, math.floor(radius + 0.5)),
        math.floor(segments)
    )
end

local function DrawMarker(marker, x, y, edgeClamped)
    local scale = RadarScale()

    if marker.kind == "enemy" or marker.kind == "ally" then
        DrawPlayerMarker(marker, x, y, edgeClamped)
    elseif marker.kind == "health" then
        DrawPlus(x, y, math.floor((edgeClamped and 12 or 10) * scale + 0.5), Colors.health)
    elseif marker.kind == "ammo" then
        DrawOutlinedSquare(x, y, math.floor((edgeClamped and 10 or 8) * scale + 0.5), Colors.ammo)
        DrawTextCentered(x, y, "A", Colors.ammo, radarSmallFont)
    elseif marker.kind == "objective" then
        Color(Colors.objective)
        DrawOutlinedCircleInt(x, y, (edgeClamped and 7 or 6) * scale, 18)
        DrawTextCentered(x, y, marker.label, Colors.objective, radarSmallFont)
    elseif marker.kind == "building" then
        DrawDiamond(x, y, math.floor((edgeClamped and 12 or 10) * scale + 0.5), Colors.building)
        DrawTextCentered(x, y, marker.label, Colors.building, radarSmallFont)
    end
end

local function DrawRadarFrame(x, y, size, cx, cy, radius)
    local scale = RadarScale()
    local outerPad = math.max(2, math.floor(2 * scale + 0.5))
    local gridPad = math.floor(9 * scale + 0.5)
    local nose = math.floor(8 * scale + 0.5)
    local wing = math.floor(6 * scale + 0.5)

    Color(Colors.background)
    draw.FilledRect(x - outerPad, y - outerPad, x + size + outerPad, y + size + outerPad)
    Color(Colors.panel)
    draw.FilledRect(x, y, x + size, y + size)
    Color(Colors.border)
    draw.OutlinedRect(x, y, x + size, y + size)

    Color(Colors.grid)
    draw.Line(cx, y + gridPad, cx, y + size - gridPad)
    draw.Line(x + gridPad, cy, x + size - gridPad, cy)
    DrawOutlinedCircleInt(cx, cy, radius * 0.33, 48)
    DrawOutlinedCircleInt(cx, cy, radius * 0.66, 64)
    DrawOutlinedCircleInt(cx, cy, radius, 96)

    Color(Colors.localPlayer)
    draw.Line(cx, cy - nose, cx + wing, cy + wing)
    draw.Line(cx, cy - nose, cx - wing, cy + wing)
    draw.Line(cx - wing, cy + wing, cx + wing, cy + wing)

    draw.SetFont(radarFont)
    Color(Colors.text)
    draw.Text(x + math.floor(8 * scale + 0.5), y + math.floor(7 * scale + 0.5), "BSP RADAR")

    draw.SetFont(radarSmallFont)
    Color(Colors.subduedText)
    local rangeText = tostring(math.floor(Settings.Range)) .. " HU"
    local rangeW = draw.GetTextSize(rangeText)
    draw.Text(x + size - rangeW - math.floor(8 * scale + 0.5), y + math.floor(8 * scale + 0.5), rangeText)
end

local function DrawBspGeometry(origin, cx, cy, radius, fx, fy, rx, ry)
    if not Settings.ShowBspGeometry or not Bsp.loaded then
        return 0
    end

    local baseCellX = CellCoord(origin.x)
    local baseCellY = CellCoord(origin.y)
    local cellRadius = math.ceil(Settings.Range / Bsp.cellSize) + 2
    local seen = {}
    local drawn = 0
    local radarScale = radius / Settings.Range

    Color(Colors.bspWall)

    for cellX = baseCellX - cellRadius, baseCellX + cellRadius do
        if drawn >= Settings.MaxGeometryDraw then
            break
        end

        for cellY = baseCellY - cellRadius, baseCellY + cellRadius do
            if drawn >= Settings.MaxGeometryDraw then
                break
            end

            local bucket = Bsp.cells[CellKey(cellX, cellY)]

            if bucket then
                for i = 1, #bucket do
                    if drawn >= Settings.MaxGeometryDraw then
                        break
                    end

                    local segmentIndex = bucket[i]

                    if not seen[segmentIndex] then
                        seen[segmentIndex] = true
                        local segment = Bsp.segments[segmentIndex]

                        if segment and
                            SegmentMatchesHeight(segment, origin.z) and
                            IsSegmentInAccessibleSpace(segment) and
                            DistancePointSegment2D(origin.x, origin.y, segment) <= Settings.Range
                        then
                            local sideA, aheadA = WorldToRadarUnits(segment.ax, segment.ay, origin, fx, fy, rx, ry)
                            local sideB, aheadB = WorldToRadarUnits(segment.bx, segment.by, origin, fx, fy, rx, ry)
                            local clipA, clipB, clipC, clipD = ClipRadarSegment(sideA, aheadA, sideB, aheadB)

                            if clipA then
                                draw.Line(
                                    math.floor(cx + clipA * radarScale),
                                    math.floor(cy - clipB * radarScale),
                                    math.floor(cx + clipC * radarScale),
                                    math.floor(cy - clipD * radarScale)
                                )
                                drawn = drawn + 1
                            end
                        end
                    end
                end
            end
        end
    end

    return drawn
end

local function DrawMarkerList(markerList, origin, cx, cy, radius, fx, fy, rx, ry)
    for i = 1, #markerList do
        local marker = markerList[i]
        local shouldCull = Settings.ShowAccessibleOnly and
            (marker.source ~= "live" or Settings.CullLiveMarkers) and
            not IsPointAccessible(marker.pos, origin)

        if not shouldCull then
            local markerX, markerY, edgeClamped = PointToRadar(marker.pos, origin, cx, cy, radius, fx, fy, rx, ry)

            if markerX and markerY then
                DrawMarker(marker, markerX, markerY, edgeClamped)
            end
        end
    end
end

local function TotalCount(kind)
    local mapCount = Settings.ShowBspStaticMarkers and (Bsp.markerCounts[kind] or 0) or 0
    return (runtimeCounts[kind] or 0) + mapCount
end

local function DrawLegend(x, y, size, drawnGeometry)
    local scale = RadarScale()
    local lineY = y + size + math.floor(7 * scale + 0.5)
    local text = string.format(
        "E:%d  H:%d  A:%d  CP:%d  B:%d  G:%d",
        TotalCount("enemy"),
        TotalCount("health"),
        TotalCount("ammo"),
        TotalCount("objective"),
        TotalCount("building"),
        drawnGeometry or 0
    )

    draw.SetFont(radarSmallFont)
    Color(Colors.text)
    draw.Text(x + math.floor(3 * scale + 0.5), lineY, text)

    Color(Colors.subduedText)
    local hint = UI.isOpen and "DELETE close" or "DELETE menu"
    local hintW = draw.GetTextSize(hint)
    draw.Text(x + size - hintW - math.floor(3 * scale + 0.5), lineY, hint)
end

local function DrawBspStatus(x, y, size)
    if Bsp.loaded then
        return
    end

    local scale = RadarScale()
    draw.SetFont(radarSmallFont)
    Color(Colors.warning)
    draw.Text(x + math.floor(8 * scale + 0.5), y + size - math.floor(22 * scale + 0.5), "BSP unavailable")
end

local function GetWheelDelta()
    if Inp.wUpPressed then
        return 1
    elseif Inp.wDownPressed then
        return -1
    end

    return 0
end

local function DrawPill(x, y, w, h, r, g, b, a)
    local inset = math.max(2, math.floor(h * 0.18))
    draw.Color(r, g, b, a)
    draw.FilledRect(x + inset, y, x + w - inset, y + h)
    draw.FilledRect(x, y + inset, x + w, y + h - inset)
    draw.Color(math.min(255, r + 22), math.min(255, g + 22), math.min(255, b + 22), math.min(255, a))
    draw.Line(x + inset, y, x + w - inset, y)
    draw.Line(x, y + inset, x, y + h - inset)
    draw.Color(math.max(0, r - 22), math.max(0, g - 22), math.max(0, b - 22), math.min(255, a))
    draw.Line(x + inset, y + h, x + w - inset, y + h)
    draw.Line(x + w, y + inset, x + w, y + h - inset)
end

local function DrawButton(x, y, w, h, label, scale)
    local hovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, x, y, w, h)
    DrawPill(x, y, w, h, hovered and 72 or 42, hovered and 78 or 46, hovered and 88 or 54, 255)

    draw.SetFont(menuFonts.small)
    local textW, textH = draw.GetTextSize(label)
    draw.Color(hovered and 255 or 230, hovered and 255 or 236, hovered and 255 or 244, 255)
    draw.Text(math.floor(x + (w - textW) * 0.5), math.floor(y + (h - textH) * 0.5), label)
    return hovered and Inp.mbPressed
end

local function DrawCheckbox(x, y, label, key, width, scale)
    local cbSize = math.max(12, math.floor(15 * scale + 0.5))
    local hovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, x, y, width or math.floor(210 * scale), cbSize)

    draw.Color(42, 48, 56, 255)
    draw.FilledRect(x, y, x + cbSize, y + cbSize)
    draw.Color(105, 120, 138, 220)
    draw.OutlinedRect(x, y, x + cbSize, y + cbSize)

    if Settings[key] then
        local pad = math.max(3, math.floor(3 * scale + 0.5))
        draw.Color(84, 190, 128, 255)
        draw.FilledRect(x + pad, y + pad, x + cbSize - pad, y + cbSize - pad)
    end

    draw.SetFont(menuFonts.small)
    draw.Color(hovered and 255 or 226, hovered and 255 or 234, hovered and 255 or 242, 255)
    draw.Text(x + cbSize + math.floor(8 * scale + 0.5), y + math.floor(1 * scale + 0.5), label)

    if hovered and Inp.mbPressed then
        Settings[key] = not Settings[key]
        OnSettingChanged(key)
    end
end

local function DrawSlider(x, y, w, label, key, minValue, maxValue, isFloat, wheelStep, scale)
    local value = Settings[key]
    local valueText = isFloat and string.format("%.2f", value) or tostring(math.floor(value + 0.5))
    local labelText = label .. ": " .. valueText
    local labelW = math.floor(150 * scale + 0.5)
    local sx = x + labelW
    local sy = y + math.floor(5 * scale + 0.5)
    local sw = w - labelW
    local sh = math.max(8, math.floor(11 * scale + 0.5))
    local hovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, sx - 5, sy - 6, sw + 10, sh + 12)
    local ratio = Clamp((value - minValue) / (maxValue - minValue), 0.0, 1.0)
    local fillW = math.floor(sw * ratio)
    local knobX = sx + fillW
    local knobW = math.max(4, math.floor(5 * scale + 0.5))

    draw.SetFont(menuFonts.small)
    draw.Color(232, 238, 246, 255)
    draw.Text(x, y, labelText)

    DrawPill(sx, sy, sw, sh, 42, 48, 56, 255)
    if fillW > 0 then
        DrawPill(sx, sy, math.max(sh, fillW), sh, 80, 162, 212, 255)
    end

    draw.Color(238, 246, 255, 255)
    draw.FilledRect(knobX - knobW, sy - math.floor(3 * scale + 0.5), knobX + knobW, sy + sh + math.floor(3 * scale + 0.5))

    local wheelDelta = hovered and GetWheelDelta() or 0
    if wheelDelta ~= 0 then
        local step = wheelStep or ((maxValue - minValue) / 40.0)
        Settings[key] = Clamp(Settings[key] + wheelDelta * step, minValue, maxValue)
        OnSettingChanged(key)
    end

    if hovered and Inp.mbPressed then
        UI.activeSlider = key
    end

    if UI.activeSlider == key then
        local newRatio = Clamp((Inp.mx - sx) / sw, 0.0, 1.0)
        Settings[key] = minValue + (newRatio * (maxValue - minValue))
        OnSettingChanged(key)
    end
end

local function DrawPowerToggle(x, y, w, h, scale)
    local hovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, x, y, w, h)
    local enabled = Settings.Enabled
    local br = enabled and 36 or 80
    local bg = enabled and 132 or 52
    local bb = enabled and 82 or 58
    local knobW = math.floor(36 * scale + 0.5)
    local knobH = h - math.floor(8 * scale + 0.5)
    local knobX = enabled and (x + w - knobW - math.floor(7 * scale + 0.5)) or (x + math.floor(7 * scale + 0.5))
    local knobY = y + math.floor(4 * scale + 0.5)

    DrawPill(x, y, w, h, hovered and br + 18 or br, hovered and bg + 18 or bg, hovered and bb + 18 or bb, 245)
    DrawPill(knobX, knobY, knobW, knobH, enabled and 224 or 160, enabled and 255 or 164, enabled and 218 or 168, 255)

    draw.SetFont(menuFonts.text)
    draw.Color(255, 255, 255, 255)
    draw.Text(x + math.floor(70 * scale + 0.5), y + math.floor(8 * scale + 0.5), enabled and "RADAR ACTIVE" or "RADAR PAUSED")

    if hovered and Inp.mbPressed then
        Settings.Enabled = not Settings.Enabled
        OnSettingChanged("Enabled")
    end
end

local function ReloadCurrentBsp()
    local mapName = engine.GetMapName()

    if mapName and mapName ~= "" then
        LoadBspForMap(mapName)
        InvalidateAccessibility()
    end
end

local function DrawStatusPanel(x, y, w, scale)
    local panelH = math.floor(52 * scale + 0.5)
    local mapText = Bsp.mapName or engine.GetMapName() or "no map"
    local stateText = Bsp.loaded and "loaded" or "unavailable"
    local markerText = string.format("Segments: %d | Static: %d", #Bsp.segments, #Bsp.mapMarkers)
    local accessText
    if not Settings.ShowAccessibleOnly then
        accessText = "Accessible cull: off"
    elseif Accessibility.computed then
        accessText = string.format("Accessible cells: %d%s", Accessibility.visibleCells or 0, Accessibility.limited and "+" or "")
    else
        accessText = "Accessible cull: fallback"
    end

    draw.Color(12, 16, 21, 235)
    draw.FilledRect(x, y, x + w, y + panelH)
    draw.Color(76, 92, 110, 210)
    draw.OutlinedRect(x, y, x + w, y + panelH)

    draw.SetFont(menuFonts.small)
    draw.Color(Bsp.loaded and 220 or 255, Bsp.loaded and 238 or 190, Bsp.loaded and 226 or 90, 255)
    draw.Text(x + math.floor(8 * scale + 0.5), y + math.floor(7 * scale + 0.5), "Map: " .. mapText .. " | " .. stateText)
    draw.Color(218, 228, 238, 235)
    draw.Text(x + math.floor(8 * scale + 0.5), y + math.floor(24 * scale + 0.5), markerText .. " | " .. accessText)
end

local function DrawMenu(scale)
    if not UI.isOpen then
        return
    end

    local scaledW = math.floor(UI.w * scale + 0.5)
    local scaledH = math.floor(UI.h * scale + 0.5)
    local titleBarH = math.floor(30 * scale + 0.5)

    ClampWindowToScreen(UI, scaledW, scaledH)

    if UI.canInteract and Inp.mbPressed and MouseInBounds(Inp.mx, Inp.my, UI.x, UI.y, scaledW - titleBarH, titleBarH) then
        UI.dragging = true
        UI.dragX = Inp.mx - UI.x
        UI.dragY = Inp.my - UI.y
    end

    if not Inp.mbDown then
        UI.dragging = false
        UI.activeSlider = nil
    end

    if UI.dragging then
        UI.x = Inp.mx - UI.dragX
        UI.y = Inp.my - UI.dragY
        ClampWindowToScreen(UI, scaledW, scaledH)
    end

    local bx = math.floor(UI.x)
    local by = math.floor(UI.y)

    draw.Color(8, 10, 13, 238)
    draw.FilledRect(bx, by, bx + scaledW, by + scaledH)
    draw.Color(42, 92, 125, 255)
    draw.FilledRect(bx, by, bx + scaledW, by + titleBarH)
    draw.Color(118, 176, 214, 210)
    draw.OutlinedRect(bx, by, bx + scaledW, by + scaledH)

    draw.SetFont(menuFonts.title)
    draw.Color(255, 255, 255, 255)
    draw.Text(bx + math.floor(10 * scale + 0.5), by + math.floor(6 * scale + 0.5), "BSP Radar Settings | v" .. VERSION)

    local closeHovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, bx + scaledW - titleBarH, by, titleBarH, titleBarH)
    draw.Color(closeHovered and 190 or 34, closeHovered and 68 or 72, closeHovered and 68 or 98, 255)
    draw.FilledRect(bx + scaledW - titleBarH, by, bx + scaledW, by + titleBarH)
    draw.SetFont(menuFonts.title)
    draw.Color(255, 255, 255, 255)
    draw.Text(bx + scaledW - math.floor(20 * scale + 0.5), by + math.floor(5 * scale + 0.5), "X")

    if closeHovered and Inp.mbPressed then
        CloseMenu()
        return
    end

    local contentX = bx + math.floor(12 * scale + 0.5)
    local contentW = scaledW - math.floor(24 * scale + 0.5)
    local currentY = by + math.floor(40 * scale + 0.5)

    DrawStatusPanel(contentX, currentY, contentW, scale)
    currentY = currentY + math.floor(62 * scale + 0.5)

    DrawPowerToggle(contentX, currentY, math.floor(220 * scale + 0.5), math.floor(34 * scale + 0.5), scale)
    currentY = currentY + math.floor(46 * scale + 0.5)

    DrawSlider(contentX, currentY, contentW, "Overall Scale", "Scale", 0.75, 2.00, true, 0.05, scale)
    currentY = currentY + math.floor(26 * scale + 0.5)
    DrawSlider(contentX, currentY, contentW, "Radar Size", "Size", 160, 420, false, 10, scale)
    currentY = currentY + math.floor(26 * scale + 0.5)
    DrawSlider(contentX, currentY, contentW, "Range", "Range", 800, 6500, false, 100, scale)
    currentY = currentY + math.floor(26 * scale + 0.5)
    DrawSlider(contentX, currentY, contentW, "Right Margin", "MarginX", 0, 600, false, 10, scale)
    currentY = currentY + math.floor(26 * scale + 0.5)
    DrawSlider(contentX, currentY, contentW, "Top Position", "MarginY", 0, 900, false, 10, scale)
    currentY = currentY + math.floor(28 * scale + 0.5)

    local col1 = contentX
    local col2 = contentX + math.floor(250 * scale + 0.5)
    local rowH = math.floor(23 * scale + 0.5)

    DrawCheckbox(col1, currentY, "BSP geometry", "ShowBspGeometry", math.floor(180 * scale + 0.5), scale)
    DrawCheckbox(col2, currentY, "Static pickups/objectives", "ShowBspStaticMarkers", math.floor(220 * scale + 0.5), scale)
    currentY = currentY + rowH
    DrawCheckbox(col1, currentY, "Allied players", "ShowAllies", math.floor(180 * scale + 0.5), scale)
    DrawCheckbox(col2, currentY, "Engineer buildings", "ShowBuildings", math.floor(200 * scale + 0.5), scale)
    currentY = currentY + rowH
    DrawCheckbox(col1, currentY, "Edge clamped markers", "ShowEdgeClamps", math.floor(210 * scale + 0.5), scale)
    DrawCheckbox(col2, currentY, "Cull hidden map space", "ShowAccessibleOnly", math.floor(220 * scale + 0.5), scale)
    currentY = currentY + rowH
    DrawCheckbox(col1, currentY, "Cull live markers too", "CullLiveMarkers", math.floor(210 * scale + 0.5), scale)
    currentY = currentY + math.floor(30 * scale + 0.5)

    DrawSlider(contentX, currentY, contentW, "Z Below", "GeometryZBelow", 16, 420, false, 8, scale)
    currentY = currentY + math.floor(25 * scale + 0.5)
    DrawSlider(contentX, currentY, contentW, "Z Above", "GeometryZAbove", 16, 520, false, 8, scale)
    currentY = currentY + math.floor(25 * scale + 0.5)
    DrawSlider(contentX, currentY, contentW, "Access Cell", "AccessibilityCellSize", 96, 420, false, 16, scale)
    currentY = currentY + math.floor(25 * scale + 0.5)
    DrawSlider(contentX, currentY, contentW, "Runtime Scan", "RuntimeScanInterval", 0.03, 0.50, true, 0.01, scale)
    currentY = currentY + math.floor(34 * scale + 0.5)

    local buttonW = math.floor(88 * scale + 0.5)
    local buttonH = math.floor(24 * scale + 0.5)
    local gap = math.floor(8 * scale + 0.5)

    if DrawButton(contentX, currentY, buttonW, buttonH, "Reload BSP", scale) then
        ReloadCurrentBsp()
    end

    if DrawButton(contentX + (buttonW + gap), currentY, buttonW, buttonH, "Save", scale) then
        SaveConfig()
    end

    if DrawButton(contentX + (buttonW + gap) * 2, currentY, buttonW, buttonH, "Load", scale) then
        LoadConfig(false)
    end

    if DrawButton(contentX + (buttonW + gap) * 3, currentY, buttonW, buttonH, "Reset UI", scale) then
        ResetWindowPositions()
    end

    if DrawButton(contentX + (buttonW + gap) * 4, currentY, buttonW, buttonH, "Defaults", scale) then
        ResetSettings()
    end
end

local function UpdateInput()
    local isLboxMenuOpen = gui.IsMenuOpen()
    local isChatOpen = engine.IsChatOpen()
    local mousePos = input.GetMousePos()

    Inp.mx = mousePos[1]
    Inp.my = mousePos[2]

    local menuToggleDown = input.IsButtonDown(Settings.MenuKey)
    if menuToggleDown and not Inp.wasMenuToggleDown and not isLboxMenuOpen and not isChatOpen then
        UI.isOpen = not UI.isOpen
        if not UI.isOpen then
            CloseMenu()
        end
    end
    Inp.wasMenuToggleDown = menuToggleDown

    local toggleDown = input.IsButtonDown(Settings.ToggleKey)
    if toggleDown and not Inp.wasRadarToggleDown and not isLboxMenuOpen and not isChatOpen then
        Settings.Enabled = not Settings.Enabled
        OnSettingChanged("Enabled")
    end
    Inp.wasRadarToggleDown = toggleDown

    UI.canInteract = UI.isOpen and not isLboxMenuOpen
    SetCustomMouseEnabled(UI.canInteract)

    local mbDown = input.IsButtonDown(MOUSE_LEFT)
    Inp.mbPressed = mbDown and not Inp.wasMouseDown
    Inp.wasMouseDown = mbDown
    Inp.mbDown = mbDown
    Inp.wUpPressed = input.IsButtonPressed(MOUSE_WHEEL_UP)
    Inp.wDownPressed = input.IsButtonPressed(MOUSE_WHEEL_DOWN)
end

local function OnDraw()
    screenW, screenH = draw.GetScreenSize()
    UpdateInput()

    if pendingFontRefresh and not Inp.mbDown then
        UpdateFonts(Settings.Scale)
        pendingFontRefresh = false
    end

    if engine.Con_IsVisible() or engine.IsGameUIVisible() or engine.IsTakingScreenshot() then
        SetCustomMouseEnabled(false)
        return
    end

    EnsureBspLoaded()

    if not Settings.Enabled then
        DrawMenu(Settings.Scale)
        return
    end

    local localPlayer = entities.GetLocalPlayer()

    if not localPlayer or not localPlayer:IsValid() or not localPlayer:IsAlive() then
        DrawMenu(Settings.Scale)
        return
    end

    local curTime = globals.RealTime()

    if curTime >= lastRuntimeScanTime + Settings.RuntimeScanInterval then
        ScanRuntimeEntities(localPlayer)
        lastRuntimeScanTime = curTime
    end

    local scale = RadarScale()
    local size = math.floor(Settings.Size * scale + 0.5)
    local x = math.floor(screenW - size - Settings.MarginX)
    local y = math.floor(Settings.MarginY)

    if y + size + math.floor(26 * scale + 0.5) > screenH then
        y = math.max(math.floor(12 * scale + 0.5), screenH - size - math.floor(32 * scale + 0.5))
    end

    x = math.max(math.floor(4 * scale + 0.5), x)

    local cx = math.floor(x + size * 0.5)
    local cy = math.floor(y + size * 0.5)
    local radius = math.floor(size * 0.5 - math.floor(17 * scale + 0.5))
    local origin = localPlayer:GetAbsOrigin()
    local fx, fy, rx, ry = GetRadarBasis()

    EnsureAccessibility(origin)
    DrawRadarFrame(x, y, size, cx, cy, radius)
    local drawnGeometry = DrawBspGeometry(origin, cx, cy, radius, fx, fy, rx, ry)

    if Settings.ShowBspStaticMarkers and Bsp.loaded then
        DrawMarkerList(Bsp.mapMarkers, origin, cx, cy, radius, fx, fy, rx, ry)
    end

    DrawMarkerList(runtimeMarkers, origin, cx, cy, radius, fx, fy, rx, ry)
    DrawBspStatus(x, y, size)
    DrawLegend(x, y, size, drawnGeometry)
    DrawMenu(Settings.Scale)
end

local function OnUnload()
    SetCustomMouseEnabled(false)
end

ClampSettings()
LoadConfig(true)
UpdateFonts(Settings.Scale)

callbacks.Unregister("Draw", "OnScreenBspRadar_Draw")
callbacks.Unregister("Unload", "OnScreenBspRadar_Unload")
callbacks.Register("Draw", "OnScreenBspRadar_Draw", OnDraw)
callbacks.Register("Unload", "OnScreenBspRadar_Unload", OnUnload)

client.ChatPrintf("\x0777DD77[BSP Radar v" .. VERSION .. "]\x01 Loaded. HOME toggles radar, DELETE opens settings.")
