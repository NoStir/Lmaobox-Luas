-- tf2_hero.lua
-- Hitsound sequencer + reactive note highway for TF2 menu note sounds.
-- If silent, change SOUND_ROOT to the alternate path below.

local SOUND_ROOT = "ui/hitsound_menu_note%s.wav"
-- local SOUND_ROOT = "hitsound_menu_note%s.wav"

local BPM = 92
local LOOP = true
local LOOKAHEAD = 2.35
local START_DELAY = 0.35
local HIT_PULSE_TIME = 0.48
local MAX_BURSTS = 48
local MAX_PARTICLES = 150
local MAX_TIMING_SAMPLES = 48
local MIN_DRAW_ALPHA = 8

local beatTime = 60 / BPM
local stepBeats = 0.5
local stepTime = stepBeats * beatTime

local laneLabels = { "1", "2", "3", "4", "5", "6", "7", "7b", "8", "9" }
local laneCount = #laneLabels
local laneFlash = {}
local laneEnergy = {}
local bursts = {}
local particles = {}
local timingSamples = {}
local events = {}

local running = true
local paused = false
local pauseStarted = 0
local songStart = 0
local playIndex = 1
local playCycle = 0
local songLength = 0
local syncOffset = 0
local soundEnabled = true

local notePulse = 0
local screenKick = 0
local heat = 0
local combo = 0
local maxCombo = 0
local playedEvents = 0
local notesPlayed = 0
local lastNoteText = "-"
local lastEventKind = "ARMED"
local lastTimingMs = 0
local timingRating = "WAIT"

local fontTitle = draw.CreateFont("Verdana", 20, 900)
local fontSmall = draw.CreateFont("Verdana", 12, 500)
local fontTiny = draw.CreateFont("Verdana", 10, 500)
local fontNote = draw.CreateFont("Verdana", 14, 800)
local fontCombo = draw.CreateFont("Verdana", 28, 900)

local laneColors = {
    {  80, 255, 120 },
    { 120, 235, 105 },
    { 255, 205,  75 },
    { 255, 145,  70 },
    { 255,  90, 110 },
    { 235, 105, 190 },
    { 190, 115, 255 },
    { 125, 145, 255 },
    {  80, 200, 255 },
    {  80, 240, 210 },
}

local noteLane = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    ["7b"] = 8,
    [8] = 9,
    [9] = 10,
}

local kindStyle = {
    bass =       { h = 23, w = 0.70, glow = 1.25, spark = 7 },
    flam =       { h = 16, w = 0.54, glow = 0.80, spark = 4, alpha = 0.72 },
    chord =      { h = 25, w = 0.74, glow = 1.20, spark = 8, bridge = true },
    stab =       { h = 22, w = 0.66, glow = 1.15, spark = 7, bridge = true },
    arp =        { h = 14, w = 0.52, glow = 0.78, spark = 4 },
    lead =       { h = 17, w = 0.58, glow = 0.96, spark = 5 },
    harmony =    { h = 13, w = 0.48, glow = 0.70, spark = 3, alpha = 0.80 },
    echo =       { h = 9,  w = 0.44, glow = 0.48, spark = 2, alpha = 0.55 },
    fill =       { h = 16, w = 0.56, glow = 1.05, spark = 6 },
    stutter =    { h = 10, w = 0.45, glow = 0.62, spark = 3, alpha = 0.64 },
    turnaround = { h = 15, w = 0.56, glow = 1.00, spark = 5 },
    finale =     { h = 30, w = 0.82, glow = 1.45, spark = 12, bridge = true },
}

local chordsNocturneHome = { { 1, 3, 6 }, { 5, 7, 9 }, { 1, 4, 6 }, { 5, "7b", 9 } }
local chordsNocturneAnswer = { { 3, 5, 8 }, { 4, 6, 9 }, { 2, 5, 7 }, { 1, 3, 6 } }
local chordsNocturneTurn = { { 5, "7b", 9 }, { 1, 4, 6 }, { 3, 5, 8 }, { 5, 7, 9 } }
local chordsNocturneLift = { { 6, 8, 9 }, { 4, 6, 9 }, { 5, "7b", 9 }, { 1, 5, 8 } }
local chordsNocturneFinal = { { 1, 4, 6 }, { 5, "7b", 9 }, { 1, 3, 6 }, { 1, 5, 9 } }

local bassNocturneHome = { [1] = 1, [4] = 5, [7] = 3, [10] = 5, [13] = 1, [16] = 5 }
local bassNocturneAnswer = { [1] = 3, [4] = 4, [7] = 2, [10] = 5, [13] = 1, [16] = 5 }
local bassNocturneTurn = { [1] = 5, [4] = 1, [7] = 3, [10] = 5, [13] = 1, [16] = 5 }
local bassNocturneLift = { [1] = 6, [4] = 4, [7] = 5, [10] = 1, [13] = 5, [16] = 1 }
local bassNocturneFinal = { [1] = 1, [3] = 5, [5] = 1, [7] = 5, [9] = 1, [11] = 5, [13] = 1, [15] = 1 }

local chordHitsNocturneSoft = { [1] = "chord", [7] = "chord", [13] = "chord" }
local chordHitsNocturnePhrase = { [1] = "chord", [5] = "stab", [9] = "chord", [13] = "stab" }
local chordHitsNocturneFinal = { [1] = "chord", [4] = "stab", [7] = "chord", [10] = "stab", [13] = "chord", [16] = "finale" }

local arpNocturneLeft = { [2] = 1, [3] = 2, [5] = 3, [6] = 2, [8] = 1, [9] = 2, [11] = 3, [12] = 2, [14] = 1, [15] = 3 }
local arpNocturneFlow = { [2] = 1, [3] = 2, [4] = 3, [6] = 1, [7] = 2, [8] = 3, [10] = 1, [11] = 2, [12] = 3, [14] = 1, [15] = 2, [16] = 3 }
local arpNocturneFinal = { [2] = 1, [3] = 2, [4] = 3, [5] = 1, [6] = 2, [8] = 3, [10] = 1, [11] = 2, [12] = 3, [14] = 1, [15] = 2 }

local sections = {
    {
        name = "NOCTURNE A",
        chords = chordsNocturneHome,
        bassline = bassNocturneHome,
        chordHits = chordHitsNocturneSoft,
        arp = arpNocturneLeft,
        melody = { [1] = 8, [3] = 6, [5] = 5, [7] = 4, [9] = 5, [11] = 6, [13] = 8, [15] = 9 },
        counter = { [7] = 1, [13] = 3 },
        ornament = { [1] = { 9, 8 }, [13] = { 6, 8, 9 } },
        echo = { [5] = true, [13] = true },
    },
    {
        name = "ANSWER A",
        chords = chordsNocturneAnswer,
        bassline = bassNocturneAnswer,
        chordHits = chordHitsNocturneSoft,
        arp = arpNocturneLeft,
        melody = { [1] = 8, [2] = 9, [4] = 8, [6] = 6, [8] = 5, [10] = 4, [12] = 3, [14] = 5, [16] = 6 },
        counter = { [4] = 3, [10] = 2, [14] = 1 },
        ornament = { [2] = { 8, 9 }, [14] = { 4, 5, 6 } },
        echo = { [6] = true, [16] = true },
    },
    {
        name = "TURN 1",
        chords = chordsNocturneTurn,
        bassline = bassNocturneTurn,
        chordHits = chordHitsNocturnePhrase,
        arp = arpNocturneFlow,
        melody = { [1] = 7, [2] = 8, [3] = 9, [5] = 8, [7] = 6, [9] = 5, [10] = 6, [12] = 8, [14] = 6, [16] = 5 },
        counter = { [5] = 1, [9] = 3, [13] = 5 },
        ornament = { [3] = { 8, 9, 8 }, [12] = { 6, 8, 6 } },
        echo = { [3] = true, [12] = true },
    },
    {
        name = "CADENCE A",
        chords = chordsNocturneHome,
        bassline = bassNocturneHome,
        chordHits = chordHitsNocturnePhrase,
        arp = arpNocturneFlow,
        melody = { [1] = 8, [3] = 6, [5] = 5, [7] = 4, [9] = 3, [11] = 4, [13] = 5, [15] = 6 },
        counter = { [5] = 1, [9] = 5, [13] = 1 },
        ornament = { [1] = { 9, 8 }, [15] = { 5, 6, 8 } },
        echo = { [7] = true, [15] = true },
    },
    {
        name = "FLORID B",
        chords = chordsNocturneLift,
        bassline = bassNocturneLift,
        chordHits = chordHitsNocturnePhrase,
        arp = arpNocturneFlow,
        melody = { [1] = 6, [2] = 8, [3] = 9, [5] = 8, [6] = 6, [8] = 5, [9] = 6, [10] = 8, [11] = 9, [13] = 8, [14] = 6, [16] = 5 },
        counter = { [1] = 3, [5] = 4, [9] = 5, [13] = 1 },
        ornament = { [3] = { 8, 9, 8 }, [11] = { 8, 9, 8 }, [16] = { 6, 5 } },
        echo = { [3] = true, [11] = true },
    },
    {
        name = "FLORID C",
        chords = chordsNocturneLift,
        bassline = bassNocturneLift,
        chordHits = chordHitsNocturnePhrase,
        arp = arpNocturneFlow,
        melody = { [1] = 9, [2] = 8, [4] = 6, [5] = 5, [7] = 4, [8] = 5, [10] = 6, [11] = 8, [13] = 6, [15] = 5, [16] = 3 },
        counter = { [4] = 1, [8] = 4, [12] = 5 },
        ornament = { [1] = { 8, 9 }, [11] = { 6, 8, 9 }, [15] = { 6, 5, 3 } },
        echo = { [1] = true, [11] = true },
    },
    {
        name = "REPRISE A",
        chords = chordsNocturneHome,
        bassline = bassNocturneHome,
        chordHits = chordHitsNocturneSoft,
        arp = arpNocturneLeft,
        melody = { [1] = { 8, 6 }, [3] = 6, [5] = 5, [7] = 4, [9] = 5, [11] = 6, [13] = { 8, 5 }, [15] = 9 },
        counter = { [7] = 1, [13] = 3 },
        ornament = { [1] = { 9, 8 }, [13] = { 6, 8, 9 } },
        echo = { [5] = true, [13] = true },
    },
    {
        name = "REPRISE B",
        chords = chordsNocturneAnswer,
        bassline = bassNocturneAnswer,
        chordHits = chordHitsNocturnePhrase,
        arp = arpNocturneFlow,
        melody = { [1] = 8, [2] = 9, [4] = 8, [6] = 6, [8] = 5, [10] = 4, [12] = 3, [14] = 5, [16] = 6 },
        counter = { [4] = 3, [10] = 2, [14] = 1 },
        ornament = { [2] = { 8, 9 }, [14] = { 4, 5, 6 } },
        echo = { [6] = true, [16] = true },
    },
    {
        name = "CADENZA",
        chords = chordsNocturneTurn,
        bassline = bassNocturneTurn,
        chordHits = chordHitsNocturnePhrase,
        arp = arpNocturneFlow,
        melody = { [1] = 7, [2] = 8, [3] = 9, [5] = 8, [7] = 6, [9] = 5, [10] = 6, [11] = 8, [12] = 9, [13] = 8, [14] = 6, [15] = 5, [16] = 3 },
        fill = { [9] = 5, [10] = 6, [11] = 8, [12] = 9, [13] = 8, [14] = 6, [15] = 5, [16] = 3 },
        ornament = { [3] = { 8, 9, 8 }, [12] = { 8, 9, 8 }, [16] = { 5, 3, 1 } },
        echo = { [3] = true, [12] = true },
    },
    {
        name = "FINALE",
        chords = chordsNocturneFinal,
        bassline = bassNocturneFinal,
        chordHits = chordHitsNocturneFinal,
        arp = arpNocturneFinal,
        melody = { [1] = { 8, 6 }, [2] = 9, [4] = 8, [5] = 6, [7] = 5, [8] = 4, [10] = 3, [12] = 5, [13] = { 1, 3, 6 }, [14] = 5, [15] = 3, [16] = { 1, 5, 9 } },
        fill = { [9] = 5, [10] = 4, [11] = 3, [12] = 5, [13] = 6, [14] = 5, [15] = 3, [16] = 1 },
        ornament = { [2] = { 8, 9, 8 }, [13] = { 3, 5, 6 }, [16] = { 6, 8, 9 } },
        echo = { [4] = true, [13] = true },
        finale = true,
    },
}

for i = 1, laneCount do
    laneFlash[i] = 0
    laneEnergy[i] = 0
end

local function Clamp(v, lo, hi)
    if v < lo then
        return lo
    elseif v > hi then
        return hi
    end

    return v
end

local function ToInt(v)
    return math.floor(v + 0.5)
end

local function Lerp(a, b, t)
    return a + ((b - a) * t)
end

local function Brighten(c, amount)
    return {
        Clamp(c[1] + amount, 0, 255),
        Clamp(c[2] + amount, 0, 255),
        Clamp(c[3] + amount, 0, 255),
    }
end

local function SetDrawColor(r, g, b, a)
    r = ToInt(Clamp(r or 0, 0, 255))
    g = ToInt(Clamp(g or 0, 0, 255))
    b = ToInt(Clamp(b or 0, 0, 255))
    a = ToInt(Clamp(a or 255, 0, 255))

    if a < MIN_DRAW_ALPHA then
        return false
    end

    draw.Color(r, g, b, a)
    return true
end

local function ForEachNote(noteOrTable, fn)
    if noteOrTable == nil or noteOrTable == "R" then
        return
    end

    if type(noteOrTable) == "table" then
        for _, n in ipairs(noteOrTable) do
            fn(n)
        end
    else
        fn(noteOrTable)
    end
end

local function NoteCount(noteOrTable)
    local count = 0

    ForEachNote(noteOrTable, function()
        count = count + 1
    end)

    return count
end

local function AddEvent(stepNumber, note, kind, delay, strength, sectionName)
    events[#events + 1] = {
        time = (stepNumber * stepTime) + (delay or 0),
        note = note,
        kind = kind or "lead",
        strength = strength or 1,
        section = sectionName or "",
    }
end

for barIndex, section in ipairs(sections) do
    for pos = 1, 16 do
        local step = ((barIndex - 1) * 16) + (pos - 1)
        local chordIndex = math.floor((pos - 1) / 4) + 1
        local chord = (section.chords and section.chords[chordIndex]) or section.chord or { 1, 3, 5 }
        local sectionName = section.name
        local bassNote = section.bassline and section.bassline[pos]

        if bassNote then
            AddEvent(step, bassNote, "bass", 0, section.bassStrength or 1.08, sectionName)

            if pos == 1 or (section.flamBass and section.flamBass[pos]) then
                AddEvent(step, bassNote, "flam", 0.034, 0.58, sectionName)
            end
        end

        local chordKind = section.chordHits and section.chordHits[pos]
        if chordKind then
            AddEvent(step, chord, chordKind, 0, chordKind == "finale" and 1.28 or 0.96, sectionName)
        end

        local arpIndex = section.arp and section.arp[pos]
        if arpIndex then
            AddEvent(step, chord[arpIndex] or arpIndex, "arp", 0, 0.74, sectionName)
        end

        local lead = section.melody[pos]
        if lead then
            AddEvent(step, lead, "lead", 0, section.leadStrength or 1.0, sectionName)

            if section.echo and section.echo[pos] then
                AddEvent(step, lead, "echo", 0.075, 0.48, sectionName)
            end
        end

        local counter = section.counter and section.counter[pos]
        if counter then
            AddEvent(step, counter, "harmony", 0.025, 0.58, sectionName)
        end

        local fill = section.fill and section.fill[pos]
        if fill then
            AddEvent(step, fill, "fill", 0, 1.05, sectionName)

            if pos % 2 == 0 then
                AddEvent(step, fill, "stutter", 0.045, 0.62, sectionName)
            end
        end

        local ornament = section.ornament and section.ornament[pos]
        if ornament then
            if type(ornament) == "table" then
                for ornamentIndex, note in ipairs(ornament) do
                    AddEvent(step, note, "turnaround", 0.026 * ornamentIndex, 0.52, sectionName)
                end
            else
                AddEvent(step, ornament, "turnaround", 0.026, 0.52, sectionName)
            end
        end

        if section.finale and pos == 16 then
            AddEvent(step, { 1, 5, 9 }, "finale", 0, 1.25, sectionName)
            AddEvent(step, "7b", "turnaround", 0.060, 0.92, sectionName)
            AddEvent(step, 9, "turnaround", 0.120, 1.00, sectionName)
        end
    end
end

table.sort(events, function(a, b)
    if a.time == b.time then
        return NoteCount(a.note) > NoteCount(b.note)
    end

    return a.time < b.time
end)

songLength = (#sections * 16) * stepTime

local function GetLayout()
    local sw, sh = draw.GetScreenSize()
    local boardW = math.floor(math.min(sw * 0.62, 760))
    local boardH = math.floor(math.min(sh * 0.76, 620))

    local x = math.floor((sw - boardW) / 2)
    local y = math.floor(sh * 0.10)

    if screenKick > 0 then
        y = y + math.floor(screenKick * 6)
    end

    return {
        sw = sw,
        sh = sh,
        x = x,
        y = y,
        boardW = boardW,
        boardH = boardH,
        topY = y + 64,
        hitY = y + boardH - 90,
        centerX = x + (boardW / 2),
        roadTopW = boardW * 0.50,
        roadBottomW = boardW * 0.92,
    }
end

local function LaneBoundsAtY(layout, lane, y)
    local t = Clamp((y - layout.topY) / math.max(layout.hitY - layout.topY, 1), 0, 1)
    local roadW = Lerp(layout.roadTopW, layout.roadBottomW, t)
    local laneW = roadW / laneCount
    local left = layout.centerX - (roadW / 2) + ((lane - 1) * laneW)

    return left, left + laneW, laneW, t
end

local function LaneCenterAtY(layout, lane, y)
    local left, right = LaneBoundsAtY(layout, lane, y)
    return (left + right) / 2
end

local function GetEventHitTime(cycle, event)
    return songStart + (cycle * songLength) + event.time + syncOffset
end

local function GetSongClock(now)
    if songStart == 0 then
        return 0
    end

    return math.max(0, now - songStart - syncOffset)
end

local function GetCurrentSection(now)
    if songLength <= 0 or songStart == 0 then
        return "ARMED"
    end

    local clock = GetSongClock(now) % songLength
    local bar = math.floor(clock / (16 * stepTime)) + 1
    bar = Clamp(bar, 1, #sections)

    return sections[bar].name
end

local function AddTimingSample(ms)
    timingSamples[#timingSamples + 1] = ms

    if #timingSamples > MAX_TIMING_SAMPLES then
        table.remove(timingSamples, 1)
    end
end

local function GetTimingStats()
    if #timingSamples == 0 then
        return 0, 0
    end

    local sum = 0
    local worst = 0

    for i = 1, #timingSamples do
        local sample = math.abs(timingSamples[i])
        sum = sum + sample

        if sample > worst then
            worst = sample
        end
    end

    return sum / #timingSamples, worst
end

local function AddBurst(lane, note, kind, strength, now)
    bursts[#bursts + 1] = {
        lane = lane,
        note = tostring(note),
        kind = kind,
        strength = strength or 1,
        born = now,
    }

    while #bursts > MAX_BURSTS do
        table.remove(bursts, 1)
    end
end

local function AddParticle(layout, lane, kind, strength, now)
    local style = kindStyle[kind] or kindStyle.lead
    local c = laneColors[lane] or laneColors[3]
    local cx = LaneCenterAtY(layout, lane, layout.hitY)
    local cy = layout.hitY + 26
    local count = math.floor((style.spark or 4) * Clamp(strength or 1, 0.4, 1.5))

    for i = 1, count do
        local side = ((i % 2) * 2) - 1
        local arc = (i / math.max(count, 1)) * 6.28318
        local speed = 42 + (i * 7) + (18 * (strength or 1))

        particles[#particles + 1] = {
            x = cx,
            y = cy,
            vx = (math.cos(arc) * speed * 0.42) + (side * 22),
            vy = -math.abs(math.sin(arc) * speed) - 28,
            born = now,
            life = 0.30 + ((i % 4) * 0.045),
            size = 2 + (i % 3),
            r = c[1],
            g = c[2],
            b = c[3],
        }
    end

    while #particles > MAX_PARTICLES do
        table.remove(particles, 1)
    end
end

local function PlayNote(note, event, now)
    if soundEnabled then
        engine.PlaySound(string.format(SOUND_ROOT, tostring(note)))
    end

    local lane = noteLane[note] or 3
    local style = kindStyle[event.kind] or kindStyle.lead
    local strength = event.strength or 1

    laneFlash[lane] = Clamp(laneFlash[lane] + (0.62 * strength * (style.glow or 1)), 0, 1.45)
    laneEnergy[lane] = Clamp(laneEnergy[lane] + (0.34 * strength), 0, 1.35)
    notePulse = Clamp(notePulse + (0.28 * strength), 0, 1.55)
    screenKick = Clamp(screenKick + (0.09 * strength), 0, 1.0)
    lastNoteText = tostring(note)

    local layout = GetLayout()
    AddBurst(lane, note, event.kind, strength, now)
    AddParticle(layout, lane, event.kind, strength, now)
end

local function PlayEvent(event, lateBy, now)
    local count = 0

    ForEachNote(event.note, function(note)
        count = count + 1
        PlayNote(note, event, now)
    end)

    playedEvents = playedEvents + 1
    notesPlayed = notesPlayed + count
    combo = combo + count
    maxCombo = math.max(maxCombo, combo)
    heat = Clamp(heat + (0.08 * (event.strength or 1)) + (count * 0.025), 0, 1.35)
    lastEventKind = string.upper(event.kind or "NOTE")

    lastTimingMs = (lateBy or 0) * 1000
    AddTimingSample(lastTimingMs)

    local absLate = math.abs(lastTimingMs)
    if absLate <= 4 then
        timingRating = "LOCK"
    elseif absLate <= 12 then
        timingRating = "TIGHT"
    elseif absLate <= 28 then
        timingRating = "GOOD"
    else
        timingRating = "LATE"
        combo = 0
    end
end

local function ResetSong(now)
    songStart = now + START_DELAY
    playIndex = 1
    playCycle = 0
    running = true
    paused = false
    pauseStarted = 0
    bursts = {}
    particles = {}
    timingSamples = {}
    notePulse = 0
    screenKick = 0
    heat = 0
    combo = 0
    maxCombo = 0
    playedEvents = 0
    notesPlayed = 0
    lastNoteText = "-"
    lastEventKind = "ARMED"
    lastTimingMs = 0
    timingRating = "WAIT"

    for i = 1, laneCount do
        laneFlash[i] = 0
        laneEnergy[i] = 0
    end
end

local function TogglePause(now)
    if songStart == 0 then
        ResetSong(now)
    end

    if paused then
        songStart = songStart + (now - pauseStarted)
        paused = false
        pauseStarted = 0
    else
        paused = true
        pauseStarted = now
    end
end

local function HandleInput(now)
    if input.IsButtonPressed(KEY_SPACE) then
        TogglePause(now)
    end

    if input.IsButtonPressed(KEY_R) then
        ResetSong(now)
    end

    if input.IsButtonPressed(KEY_M) then
        soundEnabled = not soundEnabled
    end

    if input.IsButtonPressed(KEY_LEFT) then
        syncOffset = Clamp(syncOffset - 0.010, -0.250, 0.250)
    end

    if input.IsButtonPressed(KEY_RIGHT) then
        syncOffset = Clamp(syncOffset + 0.010, -0.250, 0.250)
    end
end

local function RunSequencer(now)
    if songStart == 0 then
        ResetSong(now)
    end

    if paused or not running then
        return
    end

    local guard = 0

    while guard < 96 do
        local event = events[playIndex]

        if not event then
            if LOOP then
                playIndex = 1
                playCycle = playCycle + 1
                event = events[playIndex]
            else
                running = false
                return
            end
        end

        local hitTime = GetEventHitTime(playCycle, event)

        if now < hitTime then
            break
        end

        PlayEvent(event, now - hitTime, now)

        playIndex = playIndex + 1
        guard = guard + 1
    end
end

local function DrawGlowRect(x1, y1, x2, y2, r, g, b, strength)
    strength = Clamp(strength or 1, 0, 1.5)

    for i = 5, 1, -1 do
        local spread = i * 4
        local alpha = ToInt(15 * strength * (6 - i))

        if SetDrawColor(r, g, b, alpha) then
            draw.OutlinedRect(x1 - spread, y1 - spread, x2 + spread, y2 + spread)
        end
    end
end

local function DrawTextRight(font, right, y, text, r, g, b, a)
    draw.SetFont(font)
    local tw = draw.GetTextSize(text)

    if SetDrawColor(r, g, b, a) then
        draw.TextShadow(right - tw, y, text)
    end
end

local function DrawBackdrop(layout, now)
    local x = layout.x
    local y = layout.y
    local boardW = layout.boardW
    local boardH = layout.boardH
    local panelPulse = Clamp(notePulse, 0, 1)
    local bgAlpha = 174 + math.floor(panelPulse * 42)

    draw.Color(4, 6, 11, bgAlpha)
    draw.FilledRect(x, y, x + boardW, y + boardH)

    draw.Color(22, 32, 48, 110)
    draw.FilledRectFade(x, y, x + boardW, y + boardH, 120, 12, false)

    if SetDrawColor(255, 255, 255, 20 + math.floor(panelPulse * 30)) then
        draw.OutlinedRect(x, y, x + boardW, y + boardH)
    end

    if SetDrawColor(120, 210, 255, 28 + math.floor(heat * 22)) then
        draw.OutlinedRect(x + 3, y + 3, x + boardW - 3, y + boardH - 3)
    end

    draw.SetFont(fontTitle)
    draw.Color(255, 255, 255, 242)
    draw.TextShadow(x + 16, y + 13, "TF2 HERO")

    draw.SetFont(fontSmall)
    draw.Color(177, 214, 255, 220)
    draw.Text(x + 17, y + 38, GetCurrentSection(now) .. "  " .. BPM .. " BPM")

    local soundText = soundEnabled and "SOUND ON" or "SOUND OFF"
    DrawTextRight(fontSmall, x + boardW - 16, y + 15, soundText, 205, 225, 255, 210)
    DrawTextRight(fontSmall, x + boardW - 16, y + 34, string.format("SYNC %+.0f ms", syncOffset * 1000), 205, 225, 255, 190)
end

local function DrawGrid(layout, now)
    local topY = layout.topY
    local hitY = layout.hitY
    local roadBottomY = hitY + 48
    local centerX = layout.centerX
    local x = layout.x
    local boardW = layout.boardW

    for lane = 1, laneCount do
        local c = laneColors[lane]
        local flash = Clamp(laneFlash[lane] or 0, 0, 1)

        for band = 0, 9 do
            local t1 = band / 10
            local t2 = (band + 1) / 10
            local by1 = math.floor(Lerp(topY, roadBottomY, t1))
            local by2 = math.floor(Lerp(topY, roadBottomY, t2)) + 1
            local midY = (by1 + by2) / 2
            local left, right = LaneBoundsAtY(layout, lane, midY)
            local alpha = math.floor(9 + (flash * 32) + (t2 * 10))

            if SetDrawColor(c[1], c[2], c[3], alpha) then
                draw.FilledRect(math.floor(left) + 2, by1, math.floor(right) - 2, by2)
            end
        end
    end

    SetDrawColor(255, 255, 255, 38)
    for i = 0, laneCount do
        local topX = centerX - (layout.roadTopW / 2) + ((layout.roadTopW / laneCount) * i)
        local bottomX = centerX - (layout.roadBottomW / 2) + ((layout.roadBottomW / laneCount) * i)
        draw.Line(math.floor(topX), topY, math.floor(bottomX), roadBottomY)
    end

    local clock = GetSongClock(now)
    local firstStep = math.max(0, math.floor((clock - 0.20) / stepTime))
    local stepWindow = math.ceil((LOOKAHEAD + 0.30) / stepTime) + 2

    for step = firstStep, firstStep + stepWindow do
        local hitTime = songStart + (step * stepTime) + syncOffset
        local untilHit = hitTime - now

        if untilHit >= -0.18 and untilHit <= LOOKAHEAD then
            local progress = Clamp(1 - (untilHit / LOOKAHEAD), 0, 1)
            local sy = math.floor(Lerp(topY, hitY, progress))
            local roadW = Lerp(layout.roadTopW, layout.roadBottomW, progress)
            local left = math.floor(centerX - (roadW / 2))
            local right = math.floor(centerX + (roadW / 2))
            local alpha = 24 + math.floor(42 * progress)

            if (step % 16) == 0 then
                alpha = alpha + 42
            elseif (step % 2) == 0 then
                alpha = alpha + 18
            end

            if untilHit < 0 then
                alpha = math.floor(alpha * (1 + (untilHit / 0.18)))
            end

            if SetDrawColor(255, 255, 255, alpha) then
                draw.Line(left, sy, right, sy)
            end
        end
    end

    if SetDrawColor(255, 255, 255, 18) then
        draw.Line(x + 12, topY - 1, x + boardW - 12, topY - 1)
    end
end

local function CollectLanes(noteOrTable)
    local lanes = {}

    ForEachNote(noteOrTable, function(note)
        lanes[#lanes + 1] = noteLane[note] or 3
    end)

    return lanes
end

local function DrawChordBridge(layout, lanes, y, alpha, event)
    if #lanes < 2 then
        return
    end

    local minLane = lanes[1]
    local maxLane = lanes[1]

    for i = 2, #lanes do
        minLane = math.min(minLane, lanes[i])
        maxLane = math.max(maxLane, lanes[i])
    end

    local left = LaneBoundsAtY(layout, minLane, y)
    local _, right = LaneBoundsAtY(layout, maxLane, y)
    local c = laneColors[maxLane] or laneColors[3]
    local strength = (kindStyle[event.kind] and kindStyle[event.kind].glow) or 1

    if SetDrawColor(c[1], c[2], c[3], math.floor(alpha * 0.20 * strength)) then
        draw.FilledRect(math.floor(left) + 8, math.floor(y) - 6, math.floor(right) - 8, math.floor(y) + 6)
    end

    if SetDrawColor(255, 255, 255, math.floor(alpha * 0.22)) then
        draw.Line(math.floor(left) + 10, math.floor(y), math.floor(right) - 10, math.floor(y))
    end
end

local function DrawNoteBlock(layout, lane, y, progress, alpha, event)
    local c = laneColors[lane] or laneColors[3]
    local left, right, laneW = LaneBoundsAtY(layout, lane, y)
    local style = kindStyle[event.kind] or kindStyle.lead
    local widthScale = (style.w or 0.56) + (progress * 0.16)
    local noteW = math.floor(Clamp(laneW * widthScale, 16, laneW - 6))
    local noteH = math.floor((style.h or 16) + (progress * 8))
    local noteAlpha = math.floor(alpha * (style.alpha or 1))
    local cx = (left + right) / 2
    local nx = math.floor(cx - (noteW / 2))
    local ny = math.floor(y - (noteH / 2))

    DrawGlowRect(nx, ny, nx + noteW, ny + noteH, c[1], c[2], c[3], (noteAlpha / 255) * (style.glow or 1))

    if SetDrawColor(c[1], c[2], c[3], noteAlpha) then
        draw.FilledRect(nx, ny, nx + noteW, ny + noteH)
    end

    if SetDrawColor(255, 255, 255, math.floor(noteAlpha * 0.70)) then
        draw.Line(nx + 2, ny + 2, nx + noteW - 2, ny + 2)
    end

    if SetDrawColor(0, 0, 0, math.floor(noteAlpha * 0.55)) then
        draw.OutlinedRect(nx, ny, nx + noteW, ny + noteH)
    end
end

local function DrawEventOnHighway(layout, event, hitTime, now)
    local untilHit = hitTime - now

    if untilHit < -0.18 or untilHit > LOOKAHEAD then
        return
    end

    local progress = Clamp(1 - (untilHit / LOOKAHEAD), 0, 1)
    local y = Lerp(layout.topY, layout.hitY, progress)
    local alpha

    if untilHit < 0 then
        alpha = math.floor(255 * (1 + (untilHit / 0.18)))
    else
        alpha = math.floor(72 + (183 * progress))
    end

    alpha = Clamp(alpha, 0, 255)

    local lanes = CollectLanes(event.note)
    if kindStyle[event.kind] and kindStyle[event.kind].bridge then
        DrawChordBridge(layout, lanes, y, alpha, event)
    end

    ForEachNote(event.note, function(note)
        local lane = noteLane[note] or 3
        DrawNoteBlock(layout, lane, y, progress, alpha, event)
    end)
end

local function DrawHitLine(layout)
    local x = layout.x
    local boardW = layout.boardW
    local hitY = layout.hitY

    draw.Color(255, 255, 255, 218)
    draw.FilledRect(x + 22, hitY - 3, x + boardW - 22, hitY + 3)

    draw.Color(255, 255, 255, 50)
    draw.FilledRect(x + 22, hitY - 18, x + boardW - 22, hitY + 18)
end

local function DrawReceptors(layout)
    for lane = 1, laneCount do
        local c = laneColors[lane]
        local flash = Clamp(laneFlash[lane] or 0, 0, 1)
        local energy = Clamp(laneEnergy[lane] or 0, 0, 1)
        local hot = Brighten(c, math.floor(96 * flash))
        local cx = math.floor(LaneCenterAtY(layout, lane, layout.hitY))
        local cy = layout.hitY + 31
        local radius = 17 + math.floor(8 * flash)

        draw.ColoredCircle(cx, cy, radius + math.floor(4 * energy), c[1], c[2], c[3], 64 + math.floor(52 * energy))
        draw.ColoredCircle(cx, cy, radius, hot[1], hot[2], hot[3], 136 + math.floor(92 * flash))

        if SetDrawColor(255, 255, 255, 124 + math.floor(110 * flash)) then
            draw.OutlinedCircle(cx, cy, radius, 30)
        end

        draw.SetFont(fontSmall)
        if SetDrawColor(255, 255, 255, 155) then
            local label = laneLabels[lane] or tostring(lane)
            local tw = draw.GetTextSize(label)
            draw.Text(math.floor(cx - (tw / 2)), cy + 23, label)
        end
    end
end

local function DrawBursts(layout, now)
    for i = #bursts, 1, -1 do
        local b = bursts[i]
        local age = now - b.born

        if age > HIT_PULSE_TIME then
            table.remove(bursts, i)
        else
            local lane = b.lane
            local c = laneColors[lane] or laneColors[3]
            local cx = math.floor(LaneCenterAtY(layout, lane, layout.hitY))
            local cy = layout.hitY + 31
            local t = age / HIT_PULSE_TIME
            local radius = math.floor(18 + (74 * t * (b.strength or 1)))
            local alpha = math.floor(220 * (1 - t))

            if SetDrawColor(c[1], c[2], c[3], alpha) then
                draw.OutlinedCircle(cx, cy, radius, 34)
            end

            draw.SetFont(fontNote)
            if SetDrawColor(255, 255, 255, alpha) then
                draw.TextShadow(cx - 8, cy - radius - 9, b.note)
            end
        end
    end
end

local function DrawParticles(now)
    for i = #particles, 1, -1 do
        local p = particles[i]
        local age = now - p.born

        if age > p.life then
            table.remove(particles, i)
        else
            local t = age / p.life
            local alpha = math.floor(210 * (1 - t))
            local size = math.max(1, math.floor(p.size * (1 - (t * 0.55))))

            if SetDrawColor(p.r, p.g, p.b, alpha) then
                draw.FilledRect(math.floor(p.x) - size, math.floor(p.y) - size, math.floor(p.x) + size, math.floor(p.y) + size)
            end
        end
    end
end

local function DrawMeters(layout, now)
    local x = layout.x
    local y = layout.y
    local boardW = layout.boardW
    local boardH = layout.boardH
    local meterX = x + 18
    local meterY = y + boardH - 28
    local meterW = boardW - 36
    local progress = 0

    if songLength > 0 then
        progress = (GetSongClock(now) % songLength) / songLength
    end

    draw.Color(255, 255, 255, 36)
    draw.FilledRect(meterX, meterY, meterX + meterW, meterY + 8)

    draw.Color(120, 210, 255, 170)
    draw.FilledRect(meterX, meterY, meterX + math.floor(meterW * progress), meterY + 8)

    draw.Color(255, 255, 255, 30)
    draw.OutlinedRect(meterX, meterY, meterX + meterW, meterY + 8)

    local heatW = math.floor((boardW * 0.18) * Clamp(heat, 0, 1))
    draw.Color(255, 225, 120, 170)
    draw.FilledRect(x + boardW - 152, y + boardH - 49, x + boardW - 152 + heatW, y + boardH - 42)

    draw.Color(255, 255, 255, 40)
    draw.OutlinedRect(x + boardW - 152, y + boardH - 49, x + boardW - 16, y + boardH - 42)

    for lane = 1, laneCount do
        local c = laneColors[lane]
        local e = Clamp(laneEnergy[lane] or 0, 0, 1)
        local barW = 8
        local barH = math.floor(34 * e)
        local bx = x + 18 + ((lane - 1) * 12)
        local by = y + boardH - 44

        draw.Color(c[1], c[2], c[3], 150)
        draw.FilledRect(bx, by - barH, bx + barW, by)
    end
end

local function DrawDashboard(layout, now)
    local x = layout.x
    local y = layout.y
    local boardW = layout.boardW
    local avg, worst = GetTimingStats()
    local status = paused and "PAUSED" or timingRating

    draw.SetFont(fontSmall)
    draw.Color(215, 228, 255, 225)
    draw.TextShadow(x + 17, y + layout.boardH - 54, "NOTE " .. lastNoteText .. "  " .. lastEventKind)

    draw.SetFont(fontTiny)
    draw.Color(174, 198, 232, 172)
    draw.Text(x + 18, y + layout.boardH - 38, string.format("EVENT %03d  NOTES %03d", playedEvents, notesPlayed))

    DrawTextRight(fontSmall, x + boardW - 16, y + layout.boardH - 74, string.format("DRIFT %+.1f ms", lastTimingMs), 220, 232, 255, 220)
    DrawTextRight(fontSmall, x + boardW - 16, y + layout.boardH - 57, string.format("AVG %.1f / WORST %.1f", avg, worst), 180, 204, 240, 185)

    if combo > 0 then
        local text = tostring(combo)
        draw.SetFont(fontCombo)
        local tw = draw.GetTextSize(text)
        draw.Color(255, 255, 255, 64 + math.floor(120 * Clamp(notePulse, 0, 1)))
        draw.TextShadow(math.floor(layout.centerX - (tw / 2)), layout.hitY - 62, text)
    end

    draw.SetFont(fontSmall)
    local statusText = status .. "  MAX " .. maxCombo
    local tw = draw.GetTextSize(statusText)
    draw.Color(255, 255, 255, 210)
    draw.TextShadow(math.floor(layout.centerX - (tw / 2)), layout.y + 39, statusText)
end

local function DrawHighway(now)
    local layout = GetLayout()

    DrawBackdrop(layout, now)
    DrawGrid(layout, now)

    local baseCycle = 0
    if songStart > 0 then
        baseCycle = math.floor(GetSongClock(now) / songLength)
    end

    baseCycle = math.max(baseCycle, 0)

    for cycle = baseCycle, baseCycle + 1 do
        for _, event in ipairs(events) do
            DrawEventOnHighway(layout, event, GetEventHitTime(cycle, event), now)
        end
    end

    DrawHitLine(layout)
    DrawReceptors(layout)
    DrawBursts(layout, now)
    DrawParticles(now)
    DrawMeters(layout, now)
    DrawDashboard(layout, now)
end

local function DecayVisuals(now)
    local ft = math.min(globals.FrameTime(), 0.05)

    notePulse = math.max(0, notePulse - (ft * 2.65))
    screenKick = math.max(0, screenKick - (ft * 4.25))
    heat = math.max(0, heat - (ft * 0.18))

    for i = 1, laneCount do
        laneFlash[i] = math.max(0, laneFlash[i] - (ft * 4.1))
        laneEnergy[i] = math.max(0, laneEnergy[i] - (ft * 2.8))
    end

    if not paused then
        for i = #particles, 1, -1 do
            local p = particles[i]
            local age = now - p.born

            if age > p.life then
                table.remove(particles, i)
            else
                p.x = p.x + (p.vx * ft)
                p.y = p.y + (p.vy * ft)
                p.vy = p.vy + (210 * ft)
            end
        end
    end
end

local function ShouldHideOverlay()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return true
    end

    if engine.IsTakingScreenshot ~= nil and engine.IsTakingScreenshot() then
        return true
    end

    return false
end

local function OnDraw()
    local realNow = globals.RealTime()
    local drawNow = paused and pauseStarted or realNow

    HandleInput(realNow)
    RunSequencer(realNow)
    DecayVisuals(realNow)

    if ShouldHideOverlay() then
        return
    end

    DrawHighway(drawNow)
end

local function OnUnload()
    running = false
    bursts = {}
    particles = {}
end

callbacks.Unregister("Draw", "tf2_hero_draw")
callbacks.Unregister("Unload", "tf2_hero_unload")
callbacks.Unregister("Draw", "hitsound_note_highway_draw")
callbacks.Unregister("Unload", "hitsound_note_highway_unload")

callbacks.Register("Draw", "tf2_hero_draw", OnDraw)
callbacks.Register("Unload", "tf2_hero_unload", OnUnload)
