--[[
    Weapon Profiles
    ---------------
    Per-weapon settings profiles for lmaobox.

    - Tracks the local player's active weapon by item definition index.
    - Changes made to tracked settings while a weapon is active are captured
      into that weapon's profile.
    - Switching to a weapon with a saved profile applies it.
    - Switching to a weapon with no profile clones the current live settings
      (copy-on-write inheritance from whatever was active before).
    - Profiles persist to disk ( <TF2 dir>/weapon_profiles/profiles.lua ),
      saved on unload and autosaved periodically.

    Performance model: all gui.GetValue/SetValue work is spread across ticks
    with a per-tick budget so a weapon switch never does a large burst of gui
    calls in a single frame. A switch settles over a few ticks (~75ms) instead
    of stalling one frame.

    Set DEBUG = true for summary printouts, DEBUG_VERBOSE = true for per-key
    capture/apply lines (spammy).
]]

--------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------

local DEBUG             = false   -- summary printouts (switches, saves, warnings)
local DEBUG_VERBOSE     = false  -- per-key capture/apply printouts (spammy)
local JOB_BUDGET        = 16     -- keys processed per tick while switching profiles
local SCAN_BUDGET       = 6      -- keys scanned per tick for user changes when idle
local AUTOSAVE_INTERVAL = 30.0   -- seconds between autosaves (only if dirty)
local INDICATOR_TIME    = 0    -- seconds the on-screen indicator stays up, change to ~2 for a visible indicator.

-- These are the only settings that will be tracked and saved to the profile file.
-- If a setting is not in this list, it will not be saved or loaded from the profile file.
-- It currently covers the AIMBOT and TRIGGER sections of the lmaobox menu, but can be extended to other sections if desired.

local TRACKED_SETTINGS = {
    -- aim
    "aim bot",
    "aim key",
    "aim key mode",
    "aim fov",
    "aim method",
    "aim position",
    "priority",
    "auto shoot",
    "smooth value",
    "smooth type",
    "preserve target",
    "target switch delay (ms)",
    "first shot delay (ms)",
    "projectile aimbot",
    "projectile aim fov",
    "projectile aim method",
    "prediction mode",
    "leading mode",
    "melee aimbot",
    "medigun aim",
    "aim when reloading",
    "nospread",
    "norecoil",
    "crit hack",
    "melee crit hack",
    "crit hack key",
    "sentry",
    "other buildings",
    "stickies",
    "sentry buster",
    "npc",
    "steam friends",
    "deadringer",
    "cloaked",
    "disguised",
    "taunting",
    "bonked",
    "vacc ubercharge",
    "heal/buff weapons",
    "prefer medics",
    "minigun spinup",
    "minigun tapfire",
    "sniper: zoomed only",
    "sniper: auto zoom",
    "wait for charge",
    "minimal priority",
    "spread: max distance",
    "backtrack",
    "backtrack size (ticks)",
    "fake latency",
    "fake latency value (ms)",
    "double tap",
    "double tap key",
    "force recharge key",
    -- trigger
    "trigger key",
    "auto backstab",
    "auto backstab fov",
    "disguise after attack",
    "ignore razorback",
    "auto sapper",
    "auto detonate sticky",
    "auto detonator",
    "auto airblast",
    "- ignore projectiles",
    "auto vaccinator",
    "auto ubercharge",
    "health percentage",
    "'activate uber' trigger",
    "trigger shoot",
    "trigger shoot key",
    "trigger melee",
    "trigger position",
    "trigger shoot delay (ms)",
    "sniper: shoot thru teammates",
}

--------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------

local validKeys       = {}    -- array of tracked keys that passed validation
local profiles        = {}    -- profiles[defindex] = { [settingName] = value }
local snapshot        = {}    -- tracked values as of the last pass, for diffing
local currentDefIndex = nil   -- defindex of the weapon we consider active
local dirty           = false -- unsaved profile changes exist
local lastSaveTime    = 0
local savePath        = nil
local weaponNames     = {}    -- defindex -> name cache (itemschema lookups aren't free)

-- in-progress switch job: processed JOB_BUDGET keys per tick.
-- mode "apply"  = target profile exists, write its values out
-- mode "adopt"  = new weapon, populate its profile from live values
-- fromProf gets last-moment user edits captured into it as we go.
local job       = nil  -- { mode, fromProf, fromDefIndex, prof, defindex, index, applied, startTick }
local scanIndex = 1    -- round-robin cursor for the idle change scan

local indicatorText   = nil
local indicatorUntil  = 0
local indicatorFont   = draw.CreateFont("Verdana", 14, 700)

local function dprint(msg)
    if DEBUG then
        print("[WeaponProfiles] " .. msg)
    end
end

local function vprint(msg)
    if DEBUG_VERBOSE then
        print("[WeaponProfiles] " .. msg)
    end
end

local function warn(msg)
    print("[WeaponProfiles] " .. msg)
end

--------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------

local function getWeaponName(defindex)
    local name = weaponNames[defindex]
    if name then
        return name
    end
    local def = itemschema.GetItemDefinitionByID(defindex)
    name = def and def:GetName() or ("defindex " .. tostring(defindex))
    weaponNames[defindex] = name
    return name
end

local function readSetting(key)
    local ok, v = pcall(gui.GetValue, key)
    if ok then
        return v
    end
    return nil
end

local function writeSetting(key, value)
    local ok, err = pcall(gui.SetValue, key, value)
    if not ok then
        warn(("ERROR: SetValue failed for '%s' = %s (%s)"):format(key, tostring(value), tostring(err)))
    end
    return ok
end

local function profileCount()
    local n = 0
    for _ in pairs(profiles) do n = n + 1 end
    return n
end

local function showIndicator(text)
    indicatorText = text
    indicatorUntil = globals.RealTime() + INDICATOR_TIME
end

--------------------------------------------------------------------------
-- Persistence
--------------------------------------------------------------------------

local function serializeProfiles()
    local out = { "return {" }
    for defindex, prof in pairs(profiles) do
        out[#out + 1] = ("  [%d] = { -- %s"):format(defindex, getWeaponName(defindex))
        for key, value in pairs(prof) do
            if type(value) == "string" then
                out[#out + 1] = ("    [%q] = %q,"):format(key, value)
            else
                out[#out + 1] = ("    [%q] = %s,"):format(key, tostring(value))
            end
        end
        out[#out + 1] = "  },"
    end
    out[#out + 1] = "}"
    return table.concat(out, "\n")
end

local function saveProfiles(reason)
    if not savePath or not dirty then
        return
    end
    local f = io.open(savePath, "w")
    if not f then
        warn("ERROR: could not open '" .. savePath .. "' for writing")
        return
    end
    f:write(serializeProfiles())
    f:close()
    dirty = false
    lastSaveTime = globals.RealTime()
    dprint(("saved %d profile(s) to disk (%s)"):format(profileCount(), reason))
end

local function loadProfiles(validKeySet)
    local f = io.open(savePath, "r")
    if not f then
        dprint("no profile file found, starting fresh")
        return
    end
    local content = f:read("*a")
    f:close()

    local chunk, err = load(content, "weapon_profiles", "t", {})
    if not chunk then
        warn("ERROR: could not parse profile file: " .. tostring(err))
        return
    end
    local ok, data = pcall(chunk)
    if not ok or type(data) ~= "table" then
        warn("ERROR: profile file did not return a table, ignoring it")
        return
    end

    local loaded, droppedKeys = 0, 0
    for defindex, prof in pairs(data) do
        if type(defindex) == "number" and type(prof) == "table" then
            local clean = {}
            for key, value in pairs(prof) do
                if validKeySet[key] then
                    clean[key] = value
                else
                    droppedKeys = droppedKeys + 1
                end
            end
            profiles[defindex] = clean
            loaded = loaded + 1
        end
    end
    dprint(("loaded %d profile(s) from disk"):format(loaded))
    if droppedKeys > 0 then
        dprint(("dropped %d saved value(s) whose setting is no longer tracked/valid"):format(droppedKeys))
    end
end

--------------------------------------------------------------------------
-- Core logic
--------------------------------------------------------------------------

-- one key's worth of switch work: capture any last-moment user edit into the
-- outgoing profile, then apply/adopt for the incoming one. Single GetValue,
-- at most one SetValue.
local function processJobKey(key)
    local live = readSetting(key)
    if live == nil then
        return
    end

    if job.fromProf and snapshot[key] ~= nil and live ~= snapshot[key] then
        vprint(("change captured on '%s' [%s]: %s -> %s")
            :format(getWeaponName(job.fromDefIndex), key, tostring(snapshot[key]), tostring(live)))
        job.fromProf[key] = live
        dirty = true
    end

    if job.mode == "apply" then
        local wanted = job.prof[key]
        if wanted ~= nil and wanted ~= live then
            vprint(("applying '%s' = %s for [%s]"):format(key, tostring(wanted), getWeaponName(job.defindex)))
            writeSetting(key, wanted)
            snapshot[key] = wanted
            job.applied = job.applied + 1
        else
            snapshot[key] = live
        end
    else -- adopt
        job.prof[key] = live
        snapshot[key] = live
        dirty = true
    end
end

local function finishJob()
    local name = getWeaponName(job.defindex)
    local ticks = globals.TickCount() - job.startTick + 1
    if job.mode == "apply" then
        dprint(("switched to [%s] (defindex %d): profile loaded, %d setting(s) applied over %d tick(s)")
            :format(name, job.defindex, job.applied, ticks))
    else
        dprint(("switched to [%s] (defindex %d): new profile created from current settings")
            :format(name, job.defindex))
    end
    job = nil
end

local function processJob(budget)
    while budget > 0 do
        local key = validKeys[job.index]
        if not key then
            finishJob()
            return
        end
        processJobKey(key)
        job.index = job.index + 1
        budget = budget - 1
    end
end

-- start (or retarget) a switch job. Safe to call while a previous job is
-- mid-flight: unprocessed keys still match the snapshot, so no false captures.
local function startSwitchJob(defindex)
    local name = getWeaponName(defindex)
    local fromProf = currentDefIndex and profiles[currentDefIndex] or nil
    local prof = profiles[defindex]
    local mode

    if prof then
        mode = "apply"
        showIndicator(("%s — profile loaded"):format(name))
    else
        mode = "adopt"
        prof = {}
        profiles[defindex] = prof
        showIndicator(("%s — new profile"):format(name))
    end

    job = {
        mode         = mode,
        fromProf     = fromProf,
        fromDefIndex = currentDefIndex,
        prof         = prof,
        defindex     = defindex,
        index        = 1,
        applied      = 0,
        startTick    = globals.TickCount(),
    }
    currentDefIndex = defindex
end

-- idle change scan: a few keys per tick, round-robin, so user edits get
-- absorbed into the active profile without ever doing a full-list burst
local function processScan(budget)
    local prof = profiles[currentDefIndex]
    if not prof or #validKeys == 0 then
        return
    end
    while budget > 0 do
        local key = validKeys[scanIndex]
        local live = readSetting(key)
        if live ~= nil and live ~= snapshot[key] then
            vprint(("change captured on '%s' [%s]: %s -> %s")
                :format(getWeaponName(currentDefIndex), key, tostring(snapshot[key]), tostring(live)))
            prof[key] = live
            snapshot[key] = live
            dirty = true
        end
        scanIndex = scanIndex % #validKeys + 1
        budget = budget - 1
    end
end

local function onCreateMove()
    local me = entities.GetLocalPlayer()
    if not me or not me:IsAlive() then
        return
    end
    local wpn = me:GetPropEntity("m_hActiveWeapon")
    if not wpn then
        return
    end
    local ok, defindex = pcall(wpn.GetPropInt, wpn, "m_iItemDefinitionIndex")
    if not ok or type(defindex) ~= "number" or defindex < 0 then
        return
    end

    if defindex ~= currentDefIndex then
        startSwitchJob(defindex)
    end

    if job then
        processJob(JOB_BUDGET)
    else
        processScan(SCAN_BUDGET)
    end

    local now = globals.RealTime()
    if dirty and now - lastSaveTime >= AUTOSAVE_INTERVAL then
        saveProfiles("autosave")
    end
end

local function onDraw()
    if not indicatorText or globals.RealTime() > indicatorUntil then
        return
    end
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return
    end
    draw.SetFont(indicatorFont)
    local w, _ = draw.GetScreenSize()
    local tw, th = draw.GetTextSize(indicatorText)
    local x = math.floor(w / 2 - tw / 2)
    local y = 120
    draw.Color(0, 0, 0, 180)
    draw.FilledRect(x - 6, y - 4, x + tw + 6, y + th + 4)
    draw.Color(255, 255, 255, 255)
    draw.Text(x, y, indicatorText)
end

local function onUnload()
    -- finish any in-flight switch, then do one final full capture pass.
    -- Bursting here is fine: the script is going away anyway.
    if job then
        processJob(math.huge)
    end
    local prof = currentDefIndex and profiles[currentDefIndex] or nil
    if prof then
        for _, key in ipairs(validKeys) do
            local live = readSetting(key)
            if live ~= nil and live ~= snapshot[key] then
                prof[key] = live
                snapshot[key] = live
                dirty = true
            end
        end
    end
    saveProfiles("unload")
    dprint("unloaded")
end

--------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------

do
    -- validate the whitelist: any key GetValue can't read is dropped for
    -- the session so a typo can't wedge the scan loop. One-time burst at
    -- script load; not gameplay-critical.
    local validKeySet = {}
    local invalid = {}
    for _, key in ipairs(TRACKED_SETTINGS) do
        if readSetting(key) ~= nil then
            validKeys[#validKeys + 1] = key
            validKeySet[key] = true
        else
            invalid[#invalid + 1] = key
        end
    end
    dprint(("tracking %d/%d settings"):format(#validKeys, #TRACKED_SETTINGS))
    if #invalid > 0 then
        warn("WARNING: these setting names returned nil and are NOT tracked (typo or renamed?):")
        for _, key in ipairs(invalid) do
            warn("  - '" .. key .. "'")
        end
    end

    -- resolve the save path ( <game dir>/weapon_profiles/profiles.lua )
    local created, fullPath = filesystem.CreateDirectory([[weapon_profiles]])
    if fullPath then
        savePath = fullPath .. [[\profiles.lua]]
    else
        savePath = [[weapon_profiles\profiles.lua]]
    end
    dprint("profile file: " .. savePath)

    loadProfiles(validKeySet)

    -- currentDefIndex stays nil here; the first CreateMove tick either loads
    -- the saved profile for the weapon in hand or establishes the base
    -- profile from the current live settings

    callbacks.Register("CreateMove", "weapon_profiles_tick", onCreateMove)
    callbacks.Register("Draw", "weapon_profiles_draw", onDraw)
    callbacks.Register("Unload", "weapon_profiles_unload", onUnload)

    dprint("initialized — waiting for first tick to detect active weapon")
end
