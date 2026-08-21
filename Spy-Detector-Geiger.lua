--===============================================================
--
-- # Discord
-- @ purrspire
--
-- # GitHub
-- @ NoStir
--
-- # Lbox forums
-- @ TimLeary
--
--
--===============================================================

-- ==========================================================================
-- 1. SOUND DATABASE
-- ==========================================================================
local SOUND_LIST = {
    "player/geiger1.wav",
    "player/geiger2.wav",
    "player/geiger3.wav",
    "player/cyoa_pda_beep2.wav",
    "player/cyoa_pda_beep3.wav",
    "player/cyoa_pda_beep4.wav",
    "player/cyoa_pda_beep5.wav",
    "player/cyoa_pda_beep6.wav",
    "player/cyoa_pda_beep7.wav",
    "player/cyoa_pda_beep8.wav",
    "ui/hint.wav",
    "ui/hitsound.wav",
    "ui/hitsound_beepo.wav",
    "ui/hitsound_electro1.wav",
    "ui/hitsound_retro1.wav",
    "ui/hitsound_space.wav",
    "ui/system_message_alert.wav",
    "ui/message_update.wav",
    "ui/buttonclick.wav",
    "ui/item_acquired.wav",
    "misc/hud_warning.wav",
    "player/recharged.wav",
    "ui/training_point_big.wav",
    "items/pegleg_01.wav",
    "items/pegleg_02.wav"
}

-- ==========================================================================
-- 2. CORE CONFIGURATION & STATE
-- ==========================================================================
local VERSION = "2.5.0"
local CONFIG_DIR = "spiger_cfg"
local CONFIG_FILE = "spiger.cfg"
local SOUND_SCROLL_STEP = 0.25

local screenW, screenH = draw.GetScreenSize()
local isHighRes = (screenH >= 1080)

local DEFAULT_SETTINGS = {
    Enabled = true,
    Mode = "Geiger",
    SoundPath = "player/geiger1.wav",
    MaxDist = 1200.0,
    MinDist = 250.0,
    MinFreq = 1.2,
    MaxFreq = 20.0,
    Stride = 25.0,
    ScanInterval = 0.08,
    ShowMeter = true,
    MeterStyle = 1,
    ShowDetails = true,
    ShowDirection = false,
    ShowTargetMarker = false,
    ShowGroundCircle = false,
    AlertOnRangeEnter = true,
    MuteWhileMenuOpen = false,
    HighResUI = isHighRes,
    UIScale = 1.5
}

local Settings = {}
for key, value in pairs(DEFAULT_SETTINGS) do
    Settings[key] = value
end

local CONFIG_KEYS = {
    "Enabled",
    "Mode",
    "SoundPath",
    "MaxDist",
    "MinDist",
    "MinFreq",
    "MaxFreq",
    "Stride",
    "ScanInterval",
    "ShowMeter",
    "MeterStyle",
    "ShowDetails",
    "ShowDirection",
    "ShowTargetMarker",
    "ShowGroundCircle",
    "AlertOnRangeEnter",
    "MuteWhileMenuOpen",
    "HighResUI",
    "UIScale"
}

local Presets = {
    { name = "Geiger", mode = "Geiger", dist = 1200, mindist = 250, min = 1.2, max = 20.0, sound = "player/geiger1.wav" },
    { name = "Sonar", mode = "Sonar", dist = 1500, mindist = 300, min = 0.6, max = 4.0, sound = "ui/hint.wav" },
    { name = "Octo", mode = "Octosteps", dist = 1200, mindist = 200, stride = 23.0 },
    { name = "Heart", mode = "Heartbeat", dist = 800, mindist = 150, min = 1.5, max = 5.0, sound = "player/cyoa_pda_beep5.wav" },
    { name = "Stabby", mode = "Stabby", dist = 1200, mindist = 250, min = 0.5, max = 0.5 },
    { name = "Peg Leg", mode = "PegLeg", dist = 1100, mindist = 180, stride = 26.0, sound = "items/pegleg_01.wav" },
    { name = "Decloak", mode = "Decloak", dist = 1000, mindist = 200 }
}

local UI = {
    isOpen = false,
    toggleKey = KEY_DELETE,
    x = 100,
    y = 100,
    w = 540,
    h = 720,
    dragging = false,
    dragX = 0,
    dragY = 0,
    scrollOffset = 0,
    maxVisibleItems = 6,
    itemHeight = 20,
    draggingScroll = false,
    dragScrollOffsetY = 0,
    activeSlider = nil,
    canInteract = false
}

local MeterUI = {
    x = 20,
    y = 300,
    w = 44,
    h = 190,
    dragging = false,
    dragX = 0,
    dragY = 0
}

local Shared = {
    targetIntensity = 0.0,
    visualIntensity = 0.0
}

local Radar = {
    closestDist = nil,
    closestPos = nil,
    closestAimPos = nil,
    closestName = nil,
    spies = {},
    spyCount = 0,
    inRangeCount = 0,
    lastScanTime = 0,
    nextPlayerScanTime = 0,
    nextHistoryCleanupTime = 0,
    nextStateSoundTime = 0,
    nextRangeAlertTime = 0
}

local Inp = {
    mx = 0,
    my = 0,
    mbDown = false,
    mbPressed = false,
    wUpPressed = false,
    wDownPressed = false,
    wasMouseDown = false,
    wasToggleDown = false
}

local nextSoundTime = 0.0
local spyHistory = {}
local activePlayers = {}
local fonts = {}
local mouseCaptured = false
local currentFontScaleKey = nil
local pendingFontRefresh = false

-- ==========================================================================
-- 3. UTILITY FUNCTIONS
-- ==========================================================================
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

local function DistanceSquared(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return dx * dx + dy * dy + dz * dz
end

local function Distance2DFromHistory(pos, history)
    local dx = pos.x - history.x
    local dy = pos.y - history.y
    return math.sqrt(dx * dx + dy * dy)
end

local function SaveHistoryPosition(history, pos)
    history.x = pos.x
    history.y = pos.y
    history.z = pos.z
end

local function ResetRadarState()
    nextSoundTime = 0.0
    spyHistory = {}
    Radar.closestDist = nil
    Radar.closestPos = nil
    Radar.closestAimPos = nil
    Radar.closestName = nil
    Radar.spies = {}
    Radar.spyCount = 0
    Radar.inRangeCount = 0
    Shared.targetIntensity = 0.0
end

local function ClampSettings()
    Settings.ScanInterval = Clamp(Settings.ScanInterval, 0.02, 0.50)
    Settings.MinFreq = Clamp(Settings.MinFreq, 0.1, 66.0)
    Settings.MaxFreq = Clamp(Settings.MaxFreq, 0.1, 66.0)
    Settings.MinDist = Clamp(Settings.MinDist, 25.0, 3000.0)
    Settings.MaxDist = Clamp(Settings.MaxDist, 50.0, 4000.0)
    Settings.Stride = Clamp(Settings.Stride, 5.0, 100.0)
    Settings.UIScale = math.floor(Clamp(Settings.UIScale or 1.5, 1.10, 2.00) * 20.0 + 0.5) / 20.0
    Settings.MeterStyle = math.floor(Clamp(Settings.MeterStyle or 1, 1, 2))

    if Settings.Mode == "Hunter" then
        Settings.Mode = "Decloak"
    end

    if Settings.MinFreq > Settings.MaxFreq then
        Settings.MinFreq = Settings.MaxFreq
    end

    if Settings.MinDist >= Settings.MaxDist then
        Settings.MinDist = Settings.MaxDist - 10.0
    end
end

local function SetCustomMouseEnabled(enabled)
    if mouseCaptured == enabled then
        return
    end

    input.SetMouseInputEnabled(enabled)
    mouseCaptured = enabled
end

local function CloseMenu()
    UI.isOpen = false
    UI.dragging = false
    UI.draggingScroll = false
    UI.activeSlider = nil
    MeterUI.dragging = false
    SetCustomMouseEnabled(false)
end

local function ClampWindowToScreen(window, w, h)
    window.x = Clamp(window.x, 0, math.max(0, screenW - w))
    window.y = Clamp(window.y, 0, math.max(0, screenH - h))
end

local function ResetWindowPositions()
    screenW, screenH = draw.GetScreenSize()
    local scale = Settings.HighResUI and (Settings.UIScale or 1.5) or 1.0
    local scaledW = math.floor(UI.w * scale)
    local scaledH = math.floor(UI.h * scale)
    UI.x = Clamp(math.floor(screenW * 0.05), 0, math.max(0, screenW - scaledW))
    UI.y = Clamp(math.floor(screenH * 0.10), 0, math.max(0, screenH - scaledH))
    MeterUI.x = 20
    MeterUI.y = math.floor(screenH * 0.40)
end

local function ResetSettings()
    for key, value in pairs(DEFAULT_SETTINGS) do
        Settings[key] = value
    end
    ClampSettings()
    ResetRadarState()
end

local function ApplyPreset(preset)
    Settings.Mode = preset.mode
    Settings.MaxDist = preset.dist or Settings.MaxDist
    Settings.MinDist = preset.mindist or Settings.MinDist
    Settings.MinFreq = preset.min or Settings.MinFreq
    Settings.MaxFreq = preset.max or Settings.MaxFreq
    Settings.Stride = preset.stride or Settings.Stride
    Settings.SoundPath = preset.sound or Settings.SoundPath
    ClampSettings()
    ResetRadarState()
end

local function GetChromaColor(speed)
    local h = (globals.RealTime() * (speed or 0.2)) % 1.0
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local q = 1 - f
    i = i % 6

    local r, g, b
    if i == 0 then
        r, g, b = 1, f, 0
    elseif i == 1 then
        r, g, b = q, 1, 0
    elseif i == 2 then
        r, g, b = 0, 1, f
    elseif i == 3 then
        r, g, b = 0, q, 1
    elseif i == 4 then
        r, g, b = f, 0, 1
    else
        r, g, b = 1, 0, q
    end

    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local function DrawGlow(x, y, w, h, r, g, b)
    for i = 1, 6 do
        draw.Color(r, g, b, math.floor(100 / i))
        draw.OutlinedRect(x - i, y - i, x + w + i, y + h + i)
    end
end

local function UpdateFonts(scale)
    local scaleKey = math.floor((scale or 1.0) * 100.0 + 0.5)
    if currentFontScaleKey == scaleKey then
        return
    end

    fonts.title = draw.CreateFont("Verdana", math.floor(18 * scale), 800)
    fonts.text = draw.CreateFont("Verdana", math.floor(15 * scale), 400)
    fonts.small = draw.CreateFont("Verdana", math.floor(13 * scale), 400)
    fonts.tiny = draw.CreateFont("Verdana", math.floor(11 * scale), 400)
    currentFontScaleKey = scaleKey
end

local function FormatDistance(distance)
    if not distance then
        return "none"
    end
    return tostring(math.floor(distance + 0.5)) .. " HU"
end

local function FormatModeName(mode)
    if mode == "PegLeg" then
        return "Peg Leg"
    elseif mode == "Octosteps" then
        return "Octo-steps"
    end

    return mode
end

local function CurrentScale()
    return Settings.HighResUI and (Settings.UIScale or 1.5) or 1.0
end

local function ApplyScaleChange(updateFontsNow)
    local scale = CurrentScale()
    local meterW = Settings.MeterStyle == 2 and 150 or MeterUI.w
    local meterH = Settings.MeterStyle == 2 and 34 or MeterUI.h

    if updateFontsNow then
        UpdateFonts(scale)
        pendingFontRefresh = false
    else
        pendingFontRefresh = true
    end

    ClampWindowToScreen(UI, math.floor(UI.w * scale), math.floor(UI.h * scale))
    ClampWindowToScreen(MeterUI, math.floor(meterW * scale), math.floor(meterH * scale))
end

local function OnSettingChanged(key)
    ClampSettings()

    if key == "HighResUI" then
        ApplyScaleChange(true)
    elseif key == "UIScale" then
        ApplyScaleChange(false)
    elseif key == "MeterStyle" then
        local scale = CurrentScale()
        local meterW = Settings.MeterStyle == 2 and 150 or MeterUI.w
        local meterH = Settings.MeterStyle == 2 and 34 or MeterUI.h
        ClampWindowToScreen(MeterUI, math.floor(meterW * scale), math.floor(meterH * scale))
    elseif key == "Enabled" and not Settings.Enabled then
        ResetRadarState()
    end
end

local function BuildConfigPath()
    local ok, _, fullPath = pcall(function()
        return filesystem.CreateDirectory(CONFIG_DIR)
    end)

    if ok and type(fullPath) == "string" and fullPath ~= "" then
        return fullPath .. [[\]] .. CONFIG_FILE
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
    elseif defaultValue ~= nil then
        return value
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
    elseif key == "meter.x" then
        MeterUI.x = numericValue
    elseif key == "meter.y" then
        MeterUI.y = numericValue
    end
end

local function LoadConfig(silent)
    if not io or not io.open then
        if not silent then
            client.ChatPrintf("\x07FF6666[Spy Radar]\x01 Lua io library is unavailable; config cannot be loaded.")
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
    ApplyScaleChange(true)

    if not silent then
        client.ChatPrintf("\x0777DD77[Spy Radar]\x01 Configuration loaded.")
    end

    return true
end

local function SaveConfig()
    if not io or not io.open then
        client.ChatPrintf("\x07FF6666[Spy Radar]\x01 Lua io library is unavailable; config cannot be saved.")
        return false
    end

    local file = io.open(BuildConfigPath(), "w")
    if not file then
        client.ChatPrintf("\x07FF6666[Spy Radar]\x01 Failed to open config file for writing.")
        return false
    end

    file:write("# Advanced Spy Radar configuration\n")
    file:write("version=", VERSION, "\n")

    for _, key in ipairs(CONFIG_KEYS) do
        file:write("setting.", key, "=", tostring(Settings[key]), "\n")
    end

    file:write("ui.x=", tostring(math.floor(UI.x + 0.5)), "\n")
    file:write("ui.y=", tostring(math.floor(UI.y + 0.5)), "\n")
    file:write("meter.x=", tostring(math.floor(MeterUI.x + 0.5)), "\n")
    file:write("meter.y=", tostring(math.floor(MeterUI.y + 0.5)), "\n")
    file:close()

    client.ChatPrintf("\x0777DD77[Spy Radar]\x01 Configuration saved.")
    return true
end

local function FrequencyDelay(intensity, useSqrtCurve)
    local curve = useSqrtCurve and math.sqrt(Clamp(intensity, 0.0, 1.0)) or Clamp(intensity, 0.0, 1.0)
    local ratio = Settings.MaxFreq / Settings.MinFreq
    return 1.0 / (Settings.MinFreq * (ratio ^ curve))
end

local function PreviewCurrentSound()
    if Settings.Mode == "Geiger" then
        engine.PlaySound("player/geiger2.wav")
    elseif Settings.Mode == "Heartbeat" then
        engine.PlaySound("player/cyoa_pda_beep5.wav")
    elseif Settings.Mode == "Stabby" then
        engine.PlaySound("items/halloween/stabby.wav")
    elseif Settings.Mode == "Sonar" then
        engine.PlaySound(Settings.SoundPath)
    elseif Settings.Mode == "Decloak" then
        engine.PlaySound("ui/system_message_alert.wav")
    elseif Settings.Mode == "Octosteps" then
        engine.PlaySound(string.format("misc/octosteps/octosteps_%02d.wav", engine.RandomInt(1, 6)))
    elseif Settings.Mode == "PegLeg" then
        engine.PlaySound("items/pegleg_0" .. engine.RandomInt(1, 2) .. ".wav")
    else
        engine.PlaySound(Settings.SoundPath)
    end
end

LoadConfig(true)
ApplyScaleChange(true)

local function RadarAudioMuted()
    return Settings.MuteWhileMenuOpen and UI.isOpen
end

local function PlayRadarSound(soundPath)
    if RadarAudioMuted() then
        return false
    end

    engine.PlaySound(soundPath)
    return true
end

-- ==========================================================================
-- 4. RADAR ENGINE LOGIC
-- ==========================================================================
local function IsTrackableEnemySpy(player, localTeam)
    if not player or player:IsDormant() or not player:IsAlive() then
        return false
    end

    if player:GetTeamNumber() == localTeam then
        return false
    end

    return player:GetPropInt("m_iClass") == TF2_Spy
end

local function GetSpyFocusPosition(player, origin)
    local maxs = player:GetMaxs()
    local height = 58.0

    if maxs and maxs.z then
        height = Clamp(maxs.z * 0.72, 48.0, 72.0)
    end

    return origin + Vector3(0, 0, height)
end

local function RefreshPlayers(curTime)
    if curTime < Radar.nextPlayerScanTime then
        return
    end

    activePlayers = entities.FindByClass("CTFPlayer") or {}
    Radar.nextPlayerScanTime = curTime + Settings.ScanInterval
end

local function CleanupSpyHistory(curTime)
    if curTime < Radar.nextHistoryCleanupTime then
        return
    end

    for idx, history in pairs(spyHistory) do
        local entity = entities.GetByIndex(idx)
        if not entity or entity:IsDormant() or not entity:IsAlive() or (curTime - history.lastSeen) > 2.0 then
            spyHistory[idx] = nil
        end
    end

    Radar.nextHistoryCleanupTime = curTime + 1.0
end

local function HandleSpyHistory(player, pos, distSq, curTime)
    local entIdx = player:GetIndex()
    local history = spyHistory[entIdx]
    local isNewHistory = false

    if not history then
        history = {
            x = pos.x,
            y = pos.y,
            z = pos.z,
            distTraveled = 0.0,
            wasCloaked = player:InCond(TFCond_Cloaked),
            wasInRange = true,
            lastSeen = curTime
        }
        spyHistory[entIdx] = history
        isNewHistory = true
    end

    history.lastSeen = curTime

    if distSq <= Settings.MaxDist * Settings.MaxDist then
        if Settings.AlertOnRangeEnter and not isNewHistory and not history.wasInRange and curTime >= Radar.nextRangeAlertTime then
            if PlayRadarSound("misc/hud_warning.wav") then
                Radar.nextRangeAlertTime = curTime + 0.75
            end
        end
        history.wasInRange = true
    else
        history.wasInRange = false
    end

    if Settings.Mode == "Octosteps" or Settings.Mode == "PegLeg" then
        local distMoved2D = Distance2DFromHistory(pos, history)
        local flags = player:GetPropInt("m_fFlags")

        if flags and (flags & FL_ONGROUND) ~= 0 and distMoved2D > 0.1 then
            history.distTraveled = history.distTraveled + distMoved2D
            if history.distTraveled >= Settings.Stride and curTime >= Radar.nextStateSoundTime then
                local footstepSound = Settings.Mode == "PegLeg"
                    and ("items/pegleg_0" .. engine.RandomInt(1, 2) .. ".wav")
                    or string.format("misc/octosteps/octosteps_%02d.wav", engine.RandomInt(1, 6))

                if PlayRadarSound(footstepSound) then
                    history.distTraveled = history.distTraveled % Settings.Stride
                    Radar.nextStateSoundTime = curTime + 0.035
                end
            end
        end
    elseif Settings.Mode == "Decloak" then
        local isCloaked = player:InCond(TFCond_Cloaked)
        if history.wasCloaked and not isCloaked and curTime >= Radar.nextStateSoundTime then
            if PlayRadarSound("ui/system_message_alert.wav") then
                Radar.nextStateSoundTime = curTime + 0.35
            end
        end
        history.wasCloaked = isCloaked
    end

    SaveHistoryPosition(history, pos)
end

local function PlayProximitySound(curTime)
    if not Radar.closestDist or curTime < nextSoundTime then
        return
    end

    if RadarAudioMuted() then
        nextSoundTime = curTime + 0.20
        return
    end

    if Settings.Mode == "Octosteps" or Settings.Mode == "PegLeg" or Settings.Mode == "Decloak" then
        return
    end

    local intensity = Shared.targetIntensity
    local actualDelay

    if Settings.Mode == "Geiger" then
        local soundIdx = (intensity > 0.70 and 3) or (intensity > 0.35 and 2) or 1
        actualDelay = -math.log(engine.RandomFloat(0.01, 1.0)) * FrequencyDelay(intensity, true)
        PlayRadarSound("player/geiger" .. soundIdx .. ".wav")
    elseif Settings.Mode == "Heartbeat" then
        local spyPressure = Clamp(Radar.inRangeCount - 1, 0, 5)
        actualDelay = FrequencyDelay(intensity, false) / (1.0 + spyPressure * 0.22)
        PlayRadarSound("player/cyoa_pda_beep5.wav")
    elseif Settings.Mode == "Stabby" then
        actualDelay = FrequencyDelay(intensity, true)
        PlayRadarSound("items/halloween/stabby.wav")
    elseif Settings.Mode == "Sonar" then
        actualDelay = FrequencyDelay(intensity, true)
        PlayRadarSound(Settings.SoundPath)
    else
        actualDelay = FrequencyDelay(intensity, true)
        PlayRadarSound(Settings.SoundPath)
    end

    nextSoundTime = curTime + math.max(actualDelay, 0.022)
end

local function OnCreateMove(cmd)
    local pLocal = entities.GetLocalPlayer()
    if not pLocal or not pLocal:IsAlive() then
        ResetRadarState()
        return
    end

    if UI.isOpen and not gui.IsMenuOpen() then
        cmd.buttons = cmd.buttons & (~IN_ATTACK) & (~IN_ATTACK2)
        cmd.mousedx = 0
        cmd.mousedy = 0
    end

    ClampSettings()

    local curTime = globals.CurTime()
    RefreshPlayers(curTime)

    local myTeam = pLocal:GetTeamNumber()
    local myPos = pLocal:GetAbsOrigin()
    local maxDistSq = Settings.MaxDist * Settings.MaxDist
    local bestDistSq = maxDistSq
    local closestPos = nil
    local closestAimPos = nil
    local closestName = nil

    Radar.spyCount = 0
    Radar.inRangeCount = 0
    Radar.closestDist = nil
    Radar.closestPos = nil
    Radar.closestAimPos = nil
    Radar.closestName = nil
    Radar.spies = {}
    Radar.lastScanTime = curTime

    if not Settings.Enabled then
        Shared.targetIntensity = 0.0
        nextSoundTime = 0.0
        return
    end

    for _, player in ipairs(activePlayers) do
        if IsTrackableEnemySpy(player, myTeam) then
            local pos = player:GetAbsOrigin()
            if pos then
                Radar.spyCount = Radar.spyCount + 1
                local distSq = DistanceSquared(myPos, pos)

                if distSq <= maxDistSq then
                    Radar.inRangeCount = Radar.inRangeCount + 1
                    HandleSpyHistory(player, pos, distSq, curTime)
                    local focusPos = GetSpyFocusPosition(player, pos)

                    Radar.spies[#Radar.spies + 1] = {
                        origin = pos,
                        focus = focusPos,
                        distSq = distSq
                    }

                    if distSq < bestDistSq then
                        bestDistSq = distSq
                        closestPos = pos
                        closestAimPos = focusPos
                        closestName = player:GetName()
                    end
                else
                    local entIdx = player:GetIndex()
                    if spyHistory[entIdx] then
                        spyHistory[entIdx].wasInRange = false
                    end
                end
            end
        end
    end

    CleanupSpyHistory(curTime)

    if closestPos then
        local bestDist = math.sqrt(bestDistSq)
        Radar.closestDist = bestDist
        Radar.closestPos = closestPos
        Radar.closestAimPos = closestAimPos or closestPos
        Radar.closestName = closestName

        if bestDist <= Settings.MinDist then
            Shared.targetIntensity = 1.0
        else
            local range = math.max(1.0, Settings.MaxDist - Settings.MinDist)
            Shared.targetIntensity = Clamp(1.0 - ((bestDist - Settings.MinDist) / range), 0.0, 1.0)
        end

        PlayProximitySound(curTime)
    else
        Shared.targetIntensity = 0.0
        nextSoundTime = 0.0
    end
end

-- ==========================================================================
-- 5. GUI RENDERING
-- ==========================================================================
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
    draw.Color(math.min(255, r + 25), math.min(255, g + 25), math.min(255, b + 25), math.min(255, a))
    draw.Line(x + inset, y, x + w - inset, y)
    draw.Line(x, y + inset, x, y + h - inset)
    draw.Color(math.max(0, r - 25), math.max(0, g - 25), math.max(0, b - 25), math.min(255, a))
    draw.Line(x + inset, y + h, x + w - inset, y + h)
    draw.Line(x + w, y + inset, x + w, y + h - inset)
end

local function DrawButton(x, y, w, h, label, scale)
    local hovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, x, y, w, h)
    DrawPill(x, y, w, h, hovered and 78 or 42, hovered and 78 or 42, hovered and 78 or 42, 255)
    draw.Color(hovered and 255 or 235, hovered and 255 or 235, hovered and 255 or 235, 255)
    draw.SetFont(fonts.small)
    draw.Text(x + math.floor(8 * scale), y + math.floor(5 * scale), label)
    return hovered and Inp.mbPressed
end

local function DrawPowerToggle(x, y, w, h, scale)
    local hovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, x, y, w, h)
    local enabled = Settings.Enabled
    local pulse = enabled and (0.65 + math.sin(globals.RealTime() * 5.0) * 0.20) or 0.0
    local br = enabled and 28 or 72
    local bg = enabled and math.floor(118 + 80 * pulse) or 40
    local bb = enabled and 66 or 40
    local knobW = math.floor(34 * scale)
    local knobH = h - math.floor(8 * scale)
    local knobX = enabled and (x + w - knobW - math.floor(7 * scale)) or (x + math.floor(7 * scale))
    local knobY = y + math.floor(4 * scale)

    DrawPill(x, y, w, h, hovered and (br + 18) or br, hovered and (bg + 18) or bg, hovered and (bb + 18) or bb, 245)
    DrawPill(knobX, knobY, knobW, knobH, enabled and 225 or 160, enabled and 255 or 160, enabled and 210 or 160, 255)

    draw.SetFont(fonts.text)
    local label = enabled and "RADAR ACTIVE" or "RADAR PAUSED"
    draw.Color(255, 255, 255, 255)
    draw.Text(x + math.floor(68 * scale), y + math.floor(8 * scale), label)

    if hovered and Inp.mbPressed then
        Settings.Enabled = not Settings.Enabled
        OnSettingChanged("Enabled")
    end
end

local function DrawStatusPanel(bx, y, w, scale)
    local panelH = math.floor(54 * scale)
    local threatPct = math.floor(Shared.visualIntensity * 100 + 0.5)
    local stateText = Settings.Enabled and "running" or "paused"
    local nearestText = FormatDistance(Radar.closestDist)
    local countText = tostring(Radar.inRangeCount) .. " in range / " .. tostring(Radar.spyCount) .. " seen"

    draw.Color(15, 15, 15, 230)
    draw.FilledRect(bx, y, bx + w, y + panelH)

    draw.SetFont(fonts.small)
    draw.Color(255, 255, 255, 230)
    draw.Text(bx + math.floor(8 * scale), y + math.floor(7 * scale), "Status: " .. stateText .. " | Threat: " .. threatPct .. "%")
    draw.Text(bx + math.floor(8 * scale), y + math.floor(24 * scale), "Nearest: " .. nearestText .. " | Spies: " .. countText)

    local barX = bx + math.floor(260 * scale)
    local barY = y + math.floor(13 * scale)
    local barW = w - math.floor(275 * scale)
    local barH = math.floor(12 * scale)
    draw.Color(45, 45, 45, 255)
    draw.FilledRect(barX, barY, barX + barW, barY + barH)
    draw.Color(235, 100, 50, 255)
    draw.FilledRect(barX, barY, barX + math.floor(barW * Shared.visualIntensity), barY + barH)
end

local function DrawHUDMeter(scale)
    if not Settings.ShowMeter then
        return
    end

    local meterStyle = Settings.MeterStyle or 1
    local baseW = meterStyle == 2 and 150 or MeterUI.w
    local baseH = meterStyle == 2 and 34 or MeterUI.h
    local scaledW = math.floor(baseW * scale)
    local scaledH = math.floor(baseH * scale)

    if UI.isOpen and UI.canInteract then
        if Inp.mbPressed and MouseInBounds(Inp.mx, Inp.my, MeterUI.x, MeterUI.y, scaledW, scaledH) then
            MeterUI.dragging = true
            MeterUI.dragX = Inp.mx - MeterUI.x
            MeterUI.dragY = Inp.my - MeterUI.y
        end
        if not Inp.mbDown then
            MeterUI.dragging = false
        end
        if MeterUI.dragging then
            MeterUI.x = Inp.mx - MeterUI.dragX
            MeterUI.y = Inp.my - MeterUI.dragY
            ClampWindowToScreen(MeterUI, scaledW, scaledH)
        end
    elseif not UI.isOpen then
        MeterUI.dragging = false
    end

    local frameTime = math.min(globals.FrameTime(), 0.05)
    Shared.visualIntensity = Shared.visualIntensity + (Shared.targetIntensity - Shared.visualIntensity) * 12.0 * frameTime

    local bx = math.floor(MeterUI.x)
    local by = math.floor(MeterUI.y)

    if UI.isOpen then
        local r, g, b = GetChromaColor(0.2)
        DrawGlow(bx, by, scaledW, scaledH, r, g, b)
    end

    draw.Color(15, 15, 15, 210)
    draw.FilledRect(bx, by, bx + scaledW, by + scaledH)

    if UI.isOpen then
        draw.SetFont(fonts.small)
        draw.Color(255, 255, 255, 170)
        draw.Text(bx, by - math.floor(16 * scale), "HUD")
    end

    if meterStyle == 2 then
        local pad = math.max(3, math.floor(4 * scale))
        local trackX = bx + pad
        local trackY = by + math.floor(10 * scale)
        local trackW = scaledW - pad * 2
        local trackH = math.max(8, math.floor(10 * scale))
        local third = math.floor(trackW / 3)
        local fillW = math.floor(trackW * Shared.visualIntensity)
        local markerX = trackX + fillW

        draw.Color(35, 35, 35, 255)
        draw.FilledRect(trackX, trackY, trackX + trackW, trackY + trackH)
        draw.Color(75, 210, 75, 70)
        draw.FilledRect(trackX, trackY, trackX + third, trackY + trackH)
        draw.Color(235, 205, 60, 70)
        draw.FilledRect(trackX + third, trackY, trackX + third * 2, trackY + trackH)
        draw.Color(235, 70, 55, 70)
        draw.FilledRect(trackX + third * 2, trackY, trackX + trackW, trackY + trackH)

        if fillW > 0 then
            draw.Color(255, 240, 180, 210)
            draw.FilledRect(trackX, trackY, trackX + fillW, trackY + trackH)
        end

        draw.Color(255, 255, 255, 235)
        draw.Line(markerX, trackY - math.floor(4 * scale), markerX, trackY + trackH + math.floor(4 * scale))
        draw.SetFont(fonts.tiny)
        draw.Color(255, 255, 255, 210)
        draw.Text(trackX, by + scaledH - math.floor(13 * scale), tostring(math.floor(Shared.visualIntensity * 100 + 0.5)) .. "% threat")
    else
        local numBars = 16
        local padding = math.max(1, math.floor(2 * scale))
        local barHeight = math.max(1, math.floor((scaledH - padding * (numBars - 1)) / numBars))
        local barWidth = scaledW - (padding * 2)

        for i = 1, numBars do
            local ratio = i / numBars
            local isLit = Shared.visualIntensity >= ((i - 1) / numBars)
            local r = math.floor(math.min(255, 510 * ratio))
            local g = math.floor(math.min(255, 510 * (1.0 - ratio)))
            local drawY = math.floor(by + scaledH - padding - (i * (barHeight + padding)) + padding)

            draw.Color(r, g, 0, isLit and 255 or 32)
            draw.FilledRect(bx + padding, drawY, bx + padding + barWidth, drawY + barHeight)
        end
    end

    if Settings.ShowDetails then
        local textY = by + scaledH + math.floor(5 * scale)
        draw.SetFont(fonts.tiny)
        draw.Color(255, 255, 255, 210)
        draw.Text(bx, textY, "Spy: " .. FormatDistance(Radar.closestDist))
        draw.Text(bx, textY + math.floor(13 * scale), "Mode: " .. FormatModeName(Settings.Mode))
    end
end

local function DrawSpyGroundGlow(scale)
    if not Settings.ShowGroundCircle or not Radar.spies or #Radar.spies == 0 then
        return
    end

    local segments = 22
    local radius = 42

    for _, spy in ipairs(Radar.spies) do
        local origin = spy.origin
        local points = {}

        for i = 1, segments do
            local angle = (i / segments) * math.pi * 2.0
            local worldPos = origin + Vector3(math.cos(angle) * radius, math.sin(angle) * radius, 2)
            points[i] = client.WorldToScreen(worldPos)
        end

        local intensity = 1.0
        if spy.distSq and Settings.MaxDist > 0 then
            intensity = Clamp(1.0 - (math.sqrt(spy.distSq) / Settings.MaxDist), 0.25, 1.0)
        end

        local r = math.floor(255 * intensity)
        local g = math.floor(70 + 120 * (1.0 - intensity))

        for pass = 1, 3 do
            draw.Color(r, g, 35, math.floor(95 / pass))
            for i = 1, segments do
                local a = points[i]
                local b = points[(i % segments) + 1]
                if a and b then
                    draw.Line(a[1], a[2], b[1], b[2])
                end
            end
        end

        local center = client.WorldToScreen(origin)
        if center then
            local cross = math.floor(5 * scale)
            draw.Color(r, g, 35, 180)
            draw.Line(center[1] - cross, center[2], center[1] + cross, center[2])
            draw.Line(center[1], center[2] - cross, center[1], center[2] + cross)
        end
    end
end

local function DrawDirectionIndicator(scale)
    if not Settings.ShowDirection or not Radar.closestAimPos then
        return
    end

    local screenPos = client.WorldToScreen(Radar.closestAimPos)
    if not screenPos then
        return
    end

    local cx = math.floor(screenW * 0.5)
    local cy = math.floor(screenH * 0.5)
    local dx = screenPos[1] - cx
    local dy = screenPos[2] - cy
    local len = math.sqrt(dx * dx + dy * dy)

    if len < 1.0 then
        return
    end

    local radius = math.floor(88 * scale)
    local ux = dx / len
    local uy = dy / len
    local px = -uy
    local py = ux
    local ax = math.floor(cx + ux * radius)
    local ay = math.floor(cy + uy * radius)
    local wing = math.floor(15 * scale)
    local body = math.floor(26 * scale)
    local tail = math.floor(42 * scale)
    local r = math.floor(math.min(255, 510 * Shared.visualIntensity))
    local g = math.floor(math.min(255, 510 * (1.0 - Shared.visualIntensity)))
    local bx = math.floor(ax - ux * body)
    local by = math.floor(ay - uy * body)
    local lx = math.floor(bx + px * wing)
    local ly = math.floor(by + py * wing)
    local rx = math.floor(bx - px * wing)
    local ry = math.floor(by - py * wing)
    local tx = math.floor(ax - ux * tail)
    local ty = math.floor(ay - uy * tail)

    draw.Color(0, 0, 0, 150)
    draw.Line(ax + 1, ay + 1, lx + 1, ly + 1)
    draw.Line(ax + 1, ay + 1, rx + 1, ry + 1)
    draw.Line(lx + 1, ly + 1, rx + 1, ry + 1)
    draw.Line(tx + 1, ty + 1, bx + 1, by + 1)

    draw.Color(r, g, 0, 220)
    draw.Line(ax, ay, lx, ly)
    draw.Line(ax, ay, rx, ry)
    draw.Line(lx, ly, rx, ry)
    draw.Line(tx, ty, bx, by)
    draw.Line(math.floor(tx + px * 5 * scale), math.floor(ty + py * 5 * scale), math.floor(bx + px * 5 * scale), math.floor(by + py * 5 * scale))
    draw.Line(math.floor(tx - px * 5 * scale), math.floor(ty - py * 5 * scale), math.floor(bx - px * 5 * scale), math.floor(by - py * 5 * scale))
    draw.Line(math.floor(ax + px * 18 * scale), math.floor(ay + py * 18 * scale), math.floor(ax - px * 18 * scale), math.floor(ay - py * 18 * scale))
    draw.Line(math.floor(ax + ux * 18 * scale), math.floor(ay + uy * 18 * scale), math.floor(ax - ux * 18 * scale), math.floor(ay - uy * 18 * scale))

    if Radar.closestDist then
        local text = FormatDistance(Radar.closestDist)
        draw.SetFont(fonts.tiny)
        draw.Color(255, 245, 205, 230)
        draw.Text(ax + math.floor(8 * scale), ay + math.floor(18 * scale), text)
    end

    if Settings.ShowTargetMarker then
        local markerX = Clamp(math.floor(screenPos[1]), 8, screenW - 8)
        local markerY = Clamp(math.floor(screenPos[2]), 8, screenH - 8)
        draw.SetFont(fonts.small)
        draw.Color(255, 220, 80, 235)
        draw.Text(markerX + math.floor(5 * scale), markerY - math.floor(8 * scale), "SPY")
        local markerSize = math.floor(8 * scale)
        draw.Line(markerX - markerSize, markerY, markerX + markerSize, markerY)
        draw.Line(markerX, markerY - markerSize, markerX, markerY + markerSize)
    end
end

local function DrawMenu(scale)
    if not UI.isOpen then
        return
    end

    local scaledW = math.floor(UI.w * scale)
    local scaledH = math.floor(UI.h * scale)
    local titleBarH = math.floor(30 * scale)

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
    local r, g, b = GetChromaColor(0.2)

    DrawGlow(bx, by, scaledW, scaledH, r, g, b)
    draw.Color(25, 25, 25, 245)
    draw.FilledRect(bx, by, bx + scaledW, by + scaledH)
    draw.Color(r, g, b, 255)
    draw.FilledRect(bx, by, bx + scaledW, by + titleBarH)

    draw.SetFont(fonts.title)
    draw.Color(255, 255, 255, 255)
    draw.Text(bx + math.floor(10 * scale), by + math.floor(7 * scale), "Spy Detection Module | " .. VERSION .. "  " .. FormatModeName(Settings.Mode))

    local closeHovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, bx + scaledW - titleBarH, by, titleBarH, titleBarH)
    draw.Color(closeHovered and 255 or r, closeHovered and 255 or g, closeHovered and 255 or b, closeHovered and 70 or 255)
    draw.FilledRect(bx + scaledW - titleBarH, by, bx + scaledW, by + titleBarH)

    draw.SetFont(fonts.title)
    draw.Color(255, 255, 255, 255)
    draw.Text(bx + scaledW - math.floor(19 * scale), by + math.floor(7 * scale), "X")

    if closeHovered and Inp.mbPressed then
        CloseMenu()
        return
    end

    local currentY = by + math.floor(40 * scale)
    local contentX = bx + math.floor(10 * scale)
    local contentW = scaledW - math.floor(20 * scale)

    DrawStatusPanel(contentX, currentY, contentW, scale)
    currentY = currentY + math.floor(64 * scale)

    local toggleW = math.floor(contentW * 0.72)
    DrawPowerToggle(contentX + math.floor((contentW - toggleW) * 0.5), currentY, toggleW, math.floor(34 * scale), scale)
    currentY = currentY + math.floor(46 * scale)

    draw.SetFont(fonts.text)
    draw.Color(255, 255, 255, 255)
    draw.Text(contentX, currentY, "Quick Presets")
    currentY = currentY + math.floor(20 * scale)

    local px = contentX
    for _, preset in ipairs(Presets) do
        local pw = math.floor(70 * scale)
        local ph = math.floor(24 * scale)
        if DrawButton(px, currentY, pw, ph, preset.name, scale) then
            ApplyPreset(preset)
        end
        px = px + pw + math.floor(5 * scale)
    end

    currentY = currentY + math.floor(34 * scale)

    local function DrawSlider(label, key, minValue, maxValue, isFloat, wheelStep)
        local val = Settings[key]
        local textValue = isFloat and string.format("%.2f", val) or tostring(math.floor(val + 0.5))

        draw.SetFont(fonts.text)
        draw.Color(255, 255, 255, 255)
        draw.Text(contentX, currentY, label .. ": " .. textValue)

        local sx = bx + math.floor(185 * scale)
        local sy = currentY + math.floor(5 * scale)
        local sw = scaledW - math.floor(205 * scale)
        local sh = math.max(8, math.floor(12 * scale))
        local fillRatio = Clamp((val - minValue) / (maxValue - minValue), 0.0, 1.0)
        local fillW = math.floor(sw * fillRatio)
        local knobX = sx + fillW
        local knobY = sy + math.floor(sh * 0.5)

        DrawPill(sx, sy, sw, sh, 45, 45, 45, 255)
        if fillW > 0 then
            DrawPill(sx, sy, math.max(sh, fillW), sh, 235, 100, 50, 255)
        end
        local knobW = math.floor(6 * scale)
        draw.Color(255, 235, 215, 255)
        draw.FilledRect(knobX - knobW, sy - math.floor(3 * scale), knobX + knobW, sy + sh + math.floor(3 * scale))
        draw.Color(70, 45, 30, 200)
        draw.OutlinedRect(knobX - knobW, sy - math.floor(3 * scale), knobX + knobW, sy + sh + math.floor(3 * scale))

        local isHovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, sx - 5, sy - 5, sw + 10, sh + 10)
        local wheelDelta = isHovered and GetWheelDelta() or 0

        if wheelDelta ~= 0 then
            local step = wheelStep or ((maxValue - minValue) / 40.0)
            Settings[key] = Clamp(Settings[key] + wheelDelta * step, minValue, maxValue)
            OnSettingChanged(key)
        end

        if Inp.mbPressed and isHovered then
            UI.activeSlider = key
        end

        if UI.activeSlider == key then
            local newRatio = Clamp((Inp.mx - sx) / sw, 0.0, 1.0)
            Settings[key] = minValue + (newRatio * (maxValue - minValue))
            OnSettingChanged(key)
        end

        currentY = currentY + math.floor(25 * scale)
    end

    DrawSlider("Max Distance", "MaxDist", 500.0, 3000.0, false, 50.0)
    DrawSlider("Max Threat Dist", "MinDist", 50.0, 1000.0, false, 25.0)
    DrawSlider("Scan Interval", "ScanInterval", 0.02, 0.25, true, 0.01)

    if Settings.HighResUI then
        DrawSlider("UI Scale", "UIScale", 1.10, 2.00, true, 0.05)
    end

    if Settings.Mode == "Octosteps" or Settings.Mode == "PegLeg" then
        DrawSlider("Stride Detect", "Stride", 10.0, 60.0, true, 1.0)
        currentY = currentY + math.floor(25 * scale)
    elseif Settings.Mode ~= "Decloak" then
        DrawSlider("Min Frequency", "MinFreq", 0.1, 20.0, true, 0.25)
        DrawSlider("Max Frequency", "MaxFreq", 0.5, 66.0, true, 0.50)
    else
        currentY = currentY + math.floor(50 * scale)
    end

    currentY = currentY + math.floor(4 * scale)

    local function DrawCheckbox(cx, cy, label, key, width)
        local cbSize = math.floor(15 * scale)
        local checkHovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, cx, cy, width or math.floor(220 * scale), cbSize)

        draw.Color(50, 50, 50, 255)
        draw.FilledRect(cx, cy, cx + cbSize, cy + cbSize)

        if Settings[key] then
            local innerPad = math.floor(3 * scale)
            draw.Color(235, 100, 50, 255)
            draw.FilledRect(cx + innerPad, cy + innerPad, cx + cbSize - innerPad, cy + cbSize - innerPad)
        end

        draw.SetFont(fonts.small)
        draw.Color(255, 255, 255, 255)
        draw.Text(cx + cbSize + math.floor(8 * scale), cy + math.floor(1 * scale), label)

        if checkHovered and Inp.mbPressed then
            Settings[key] = not Settings[key]
            OnSettingChanged(key)
        end
    end

    local function DrawMeterStyleToggle(cx, cy)
        local styleW = math.floor(170 * scale)
        local styleH = math.floor(19 * scale)
        local hovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, cx, cy, styleW, styleH)
        local label = Settings.MeterStyle == 2 and "Meter: Sweep" or "Meter: Bars"

        draw.Color(hovered and 72 or 44, hovered and 72 or 44, hovered and 72 or 44, 255)
        draw.FilledRect(cx, cy, cx + styleW, cy + styleH)
        draw.Color(235, 100, 50, 255)
        if Settings.MeterStyle == 2 then
            draw.FilledRect(cx + math.floor(styleW * 0.50), cy + 2, cx + styleW - 2, cy + styleH - 2)
        else
            draw.FilledRect(cx + 2, cy + 2, cx + math.floor(styleW * 0.50), cy + styleH - 2)
        end

        draw.SetFont(fonts.small)
        draw.Color(255, 255, 255, 255)
        draw.Text(cx + math.floor(8 * scale), cy + math.floor(3 * scale), label)

        if hovered and Inp.mbPressed then
            Settings.MeterStyle = Settings.MeterStyle == 2 and 1 or 2
            OnSettingChanged("MeterStyle")
        end
    end

    local col1 = contentX
    local col2 = contentX + math.floor(240 * scale)
    local rowH = math.floor(22 * scale)
    DrawCheckbox(col1, currentY, "HUD LED Meter", "ShowMeter", math.floor(170 * scale))
    DrawCheckbox(col2, currentY, "HUD Details", "ShowDetails", math.floor(170 * scale))
    currentY = currentY + rowH
    DrawMeterStyleToggle(col1, currentY)
    DrawCheckbox(col2, currentY, "Direction Indicator", "ShowDirection", math.floor(190 * scale))
    currentY = currentY + rowH
    DrawCheckbox(col1, currentY, "Target Marker", "ShowTargetMarker", math.floor(170 * scale))
    DrawCheckbox(col2, currentY, "Spy Ground Circle", "ShowGroundCircle", math.floor(180 * scale))
    currentY = currentY + rowH
    DrawCheckbox(col1, currentY, "Range Alert", "AlertOnRangeEnter", math.floor(170 * scale))
    DrawCheckbox(col2, currentY, "Mute While Menu Open", "MuteWhileMenuOpen", math.floor(205 * scale))
    currentY = currentY + rowH
    DrawCheckbox(col1, currentY, "1440p/4K Scaling", "HighResUI", math.floor(170 * scale))
    currentY = currentY + math.floor(28 * scale)

    local buttonW = math.floor(108 * scale)
    local buttonH = math.floor(24 * scale)
    if DrawButton(contentX, currentY, buttonW, buttonH, "Test Sound", scale) then
        PreviewCurrentSound()
    end
    if DrawButton(contentX + buttonW + math.floor(8 * scale), currentY, buttonW, buttonH, "Save Config", scale) then
        SaveConfig()
    end
    if DrawButton(contentX + (buttonW + math.floor(8 * scale)) * 2, currentY, buttonW, buttonH, "Load Config", scale) then
        LoadConfig(false)
    end
    currentY = currentY + math.floor(30 * scale)

    if DrawButton(contentX, currentY, buttonW, buttonH, "Reset UI", scale) then
        ResetWindowPositions()
    end
    if DrawButton(contentX + buttonW + math.floor(8 * scale), currentY, buttonW, buttonH, "Defaults", scale) then
        ResetSettings()
        ApplyScaleChange(true)
    end
    currentY = currentY + math.floor(34 * scale)

    draw.SetFont(fonts.text)
    draw.Color(255, 255, 255, 255)
    draw.Text(contentX, currentY, "Manual Sound Browser")
    currentY = currentY + math.floor(19 * scale)

    local itemH = math.floor(UI.itemHeight * scale)
    local lx = contentX
    local ly = currentY
    local lw = contentW
    local lh = UI.maxVisibleItems * itemH

    draw.Color(15, 15, 15, 255)
    draw.FilledRect(lx, ly, lx + lw, ly + lh)

    local maxOffset = math.max(0, #SOUND_LIST - UI.maxVisibleItems)
    UI.scrollOffset = Clamp(UI.scrollOffset, 0, maxOffset)

    if UI.canInteract and MouseInBounds(Inp.mx, Inp.my, lx, ly, lw, lh) then
        if Inp.wUpPressed then
            UI.scrollOffset = math.max(0, UI.scrollOffset - SOUND_SCROLL_STEP)
        elseif Inp.wDownPressed then
            UI.scrollOffset = math.min(maxOffset, UI.scrollOffset + SOUND_SCROLL_STEP)
        end
    end

    draw.SetFont(fonts.small)
    local startLine = math.floor(UI.scrollOffset)

    for i = 1, UI.maxVisibleItems do
        local index = startLine + i
        if index > #SOUND_LIST then
            break
        end

        local sound = SOUND_LIST[index]
        local itemY = ly + ((i - 1) * itemH)
        local isSelected = sound == Settings.SoundPath and (Settings.Mode == "Single" or Settings.Mode == "Sonar" or Settings.Mode == "PegLeg")
        local isHovered = UI.canInteract and MouseInBounds(Inp.mx, Inp.my, lx, itemY, lw - math.floor(15 * scale), itemH)

        if isSelected then
            draw.Color(235, 100, 50, 150)
        elseif isHovered then
            draw.Color(50, 50, 50, 255)
        else
            draw.Color(0, 0, 0, 0)
        end

        draw.FilledRect(lx, itemY, lx + lw, itemY + itemH)
        draw.Color(255, 255, 255, 255)
        draw.Text(lx + math.floor(5 * scale), itemY + math.floor(4 * scale), sound)

        if isHovered and Inp.mbPressed then
            Settings.Mode = "Single"
            Settings.SoundPath = sound
            engine.PlaySound(sound)
        end
    end

    local sbX = lx + lw - math.floor(10 * scale)
    local sbW = math.floor(10 * scale)

    draw.Color(30, 30, 30, 255)
    draw.FilledRect(sbX, ly, sbX + sbW, ly + lh)

    if maxOffset > 0 then
        local handleH = math.max(math.floor(20 * scale), math.floor(lh * (UI.maxVisibleItems / #SOUND_LIST)))
        local scrollRatio = UI.scrollOffset / maxOffset
        local handleY = math.floor(ly + (scrollRatio * (lh - handleH)))

        if UI.canInteract and Inp.mbPressed and MouseInBounds(Inp.mx, Inp.my, sbX, handleY, sbW, handleH) then
            UI.draggingScroll = true
            UI.dragScrollOffsetY = Inp.my - handleY
        elseif UI.canInteract and Inp.mbPressed and MouseInBounds(Inp.mx, Inp.my, sbX, ly, sbW, lh) then
            UI.draggingScroll = true
            UI.dragScrollOffsetY = handleH / 2
        end

        if not Inp.mbDown then
            UI.draggingScroll = false
        end

        if UI.draggingScroll then
            local newRatio = Clamp((Inp.my - ly - UI.dragScrollOffsetY) / (lh - handleH), 0.0, 1.0)
            UI.scrollOffset = newRatio * maxOffset
            handleY = math.floor(ly + (newRatio * (lh - handleH)))
        end

        draw.Color((UI.draggingScroll or MouseInBounds(Inp.mx, Inp.my, sbX, handleY, sbW, handleH)) and 150 or 100, 100, 100, 255)
        draw.FilledRect(sbX, handleY, sbX + sbW, handleY + handleH)
    end
end

-- ==========================================================================
-- 6. CALLBACK WRAPPER
-- ==========================================================================
local function OnDraw()
    screenW, screenH = draw.GetScreenSize()

    local blockedByGameUi = engine.Con_IsVisible() or engine.IsGameUIVisible()
    if blockedByGameUi then
        SetCustomMouseEnabled(false)
        return
    end

    local isLboxMenuOpen = gui.IsMenuOpen()
    local mousePos = input.GetMousePos()
    Inp.mx = mousePos[1]
    Inp.my = mousePos[2]

    local toggleDown = input.IsButtonDown(UI.toggleKey)
    if toggleDown and not Inp.wasToggleDown and not isLboxMenuOpen and not engine.IsChatOpen() then
        UI.isOpen = not UI.isOpen
        if not UI.isOpen then
            CloseMenu()
        end
    end
    Inp.wasToggleDown = toggleDown

    UI.canInteract = UI.isOpen and not isLboxMenuOpen
    SetCustomMouseEnabled(UI.canInteract)

    local mbDown = input.IsButtonDown(MOUSE_LEFT)
    Inp.mbPressed = mbDown and not Inp.wasMouseDown
    Inp.wasMouseDown = mbDown
    Inp.mbDown = mbDown

    Inp.wUpPressed = input.IsButtonPressed(MOUSE_WHEEL_UP)
    Inp.wDownPressed = input.IsButtonPressed(MOUSE_WHEEL_DOWN)

    if pendingFontRefresh and not Inp.mbDown then
        UpdateFonts(CurrentScale())
        pendingFontRefresh = false
    end

    local scale = CurrentScale()

    DrawSpyGroundGlow(scale)
    DrawDirectionIndicator(scale)
    DrawHUDMeter(scale)
    DrawMenu(scale)
end

local function OnUnload()
    SetCustomMouseEnabled(false)
end

callbacks.Unregister("CreateMove", "SpyRadar_Logic")
callbacks.Unregister("Draw", "SpyRadar_Draw")
callbacks.Unregister("Unload", "SpyRadar_Cleanup")

callbacks.Register("CreateMove", "SpyRadar_Logic", OnCreateMove)
callbacks.Register("Draw", "SpyRadar_Draw", OnDraw)
callbacks.Register("Unload", "SpyRadar_Cleanup", OnUnload)

client.ChatPrintf("\x07FFFB33[Advanced Spy Radar v" .. VERSION .. "]\x01 Loaded. Press \x07FF4444DELETE\x01 to configure.")
