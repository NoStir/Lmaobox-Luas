-- Smart Pumpkin + Status Panel

-- === Config ===
local panelEnabled = false -- set to true to enable status panel
local PUMP_SCAN_INTERVAL = 5.0 -- seconds between pumpkin scans

-- fallback radius if prop fetch fails, pretty sure it does
-- also pretty sure default is 150 but that doesn't do enough damage to kill 125hp enemies
local CUSTOM_RADIUS = 110

-- === State ===
local Status = {
  enabled      = false,
  foundPair    = false,
  inSight      = false,
  canShoot     = false,
  distance     = 0,
  radius       = 0,
  weaponName   = "",
  enemyName    = "",
  shotThisTick = false,
  lastShotTime = 0,
  reason       = "idle"
}

-- === Caches ===
local pumpkinCache, lastPumpScan = {}, 0
local enemiesBuf = {}

-- === Helpers ===
local function DistSqr(a, b) local d = a - b; return d.x*d.x + d.y*d.y + d.z*d.z end

local function VectorToView(dir)
  local yaw = math.deg(math.atan(dir.y, dir.x))
  local hyp = math.sqrt(dir.x*dir.x + dir.y*dir.y)
  local pitch = -math.deg(math.atan(dir.z, hyp))
  if pitch > 89 then pitch = 89 elseif pitch < -89 then pitch = -89 end
  if yaw > 180 then yaw = yaw - 360 elseif yaw < -180 then yaw = yaw + 360 end
  return Vector3(pitch, yaw, 0)
end

local function compact_inplace(t, pred)
  local n = 0
  for i = 1, #t do
    local v = t[i]
    if pred(v) then
      n = n + 1
      t[n] = v
    end
  end
  for i = n + 1, #t do t[i] = nil end
  return t
end

local function GetEnemyPlayers_fast(me)
  local list = entities.FindByClass("CTFPlayer")
  local n = 0
  for i = 1, #list do
    local p = list[i]
    if p:IsValid() and not p:IsDormant() and p:IsAlive()
       and p:GetTeamNumber() ~= me:GetTeamNumber() then
      n = n + 1
      enemiesBuf[n] = p
    end
  end
  for i = n + 1, #enemiesBuf do enemiesBuf[i] = nil end
  return enemiesBuf
end

local function RefreshPumpkins()
  local now = globals.CurTime()
  local function is_pump(e)
    return e and e:IsValid() and not e:IsDormant() and e:GetClass() == "CTFPumpkinBomb"
  end

  compact_inplace(pumpkinCache, is_pump)

  if now - lastPumpScan >= PUMP_SCAN_INTERVAL then
    lastPumpScan = now
    local maxIdx = entities.GetHighestEntityIndex()
    for i = 1, maxIdx do
      local e = entities.GetByIndex(i)
      if is_pump(e) then
        local dup = false
        for j = 1, #pumpkinCache do
          if pumpkinCache[j]:GetIndex() == e:GetIndex() then dup = true; break end
        end
        if not dup then pumpkinCache[#pumpkinCache + 1] = e end
      end
    end
  end

  return pumpkinCache
end

local function TraceLOSTo(me, ent)
  local eye = me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]")
  local tr  = engine.TraceLine(eye, ent:GetAbsOrigin(), MASK_SHOT)
  if tr and tr.entity ~= nil then
    return tr.entity:GetIndex() == ent:GetIndex()
  end
  return tr and tr.fraction and tr.fraction >= 0.99
end

local function CanShootNow(me, wpn)
  if not wpn or not wpn:IsValid() then return false end
  local t  = globals.CurTime()
  local nW = wpn:GetPropFloat("m_flNextPrimaryAttack") or t
  local nP = me:GetPropFloat("m_flNextAttack") or t
  return t >= nW and t >= nP
end

local function FindBestPair(pumpkins, enemies, radius)
  local bestB, bestE, bestD2 = nil, nil, math.huge
  local r2 = radius * radius
  for i = 1, #pumpkins do
    local b = pumpkins[i]
    if b:IsValid() then
      local bp = b:GetAbsOrigin()
      for j = 1, #enemies do
        local e = enemies[j]
        local d2 = DistSqr(bp, e:GetAbsOrigin())
        if d2 <= r2 and d2 < bestD2 then
          bestD2, bestB, bestE = d2, b, e
        end
      end
    end
  end
  return bestB, bestE, bestD2
end

-- === Fire ===
local function FireAtEntity(me, cmd, target)
  local eye = me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]")
  local to  = target:GetAbsOrigin() - eye
  cmd.viewangles = VectorToView(to)
  cmd.buttons    = (cmd.buttons or 0) | IN_ATTACK
  Status.shotThisTick = true
  Status.lastShotTime = globals.CurTime()
  Status.reason       = "FIRE"
end

-- === Main ===
local function SmartPumpkinShooter(cmd)
  Status.shotThisTick = false
  Status.reason       = "idle"

  local me = entities.GetLocalPlayer()
  if not me or not me:IsAlive() then
    Status.enabled = false
    return
  end
  Status.enabled = true

  local weapon = me:GetPropEntity("m_hActiveWeapon")
  if not weapon or not weapon:IsValid() then Status.reason="no weapon"; return end
  if weapon:IsMeleeWeapon() then Status.reason="melee"; return end
  Status.weaponName = weapon:GetClass() or "?"

  local pumpkins = RefreshPumpkins()
  if #pumpkins == 0 then Status.reason="no pumpkins"; return end

  local enemies = GetEnemyPlayers_fast(me)
  if #enemies == 0 then Status.reason="no enemies"; return end

  local p0 = pumpkins[1]
  local radius = (p0 and p0:GetPropFloat("m_flRadius")) or CUSTOM_RADIUS
  Status.radius = radius

  local bomb, enemy, d2 = FindBestPair(pumpkins, enemies, radius)
  if not bomb or not enemy then
    Status.foundPair = false
    Status.reason = "no pair in radius"
    return
  end

  Status.foundPair = true
  Status.enemyName = enemy:GetName() or "enemy"
  Status.distance  = math.sqrt(d2)
  Status.inSight   = TraceLOSTo(me, bomb)
  Status.canShoot  = CanShootNow(me, weapon)

  if Status.inSight and Status.canShoot then
    FireAtEntity(me, cmd, bomb)
  else
    Status.reason = (not Status.inSight and "blocked")
                 or (not Status.canShoot and "cooldown")
                 or "hold"
  end
end

callbacks.Register("CreateMove", "SmartPumpkinShooter", SmartPumpkinShooter)

-- === Status Panel ===
if panelEnabled then
  local UI = { margin=24, width=420, pad=10, headerH=30, lineH=20, labelCol=200 }
  local font_main  = draw.CreateFont("Consolas", 22, 700)
  local font_small = draw.CreateFont("Consolas", 18, 600)

  local function drawRectOutline(x, y, w, h)
    draw.Line(x, y, x+w, y); draw.Line(x+w, y, x+w, y+h)
    draw.Line(x+w, y+h, x, y+h); draw.Line(x, y+h, x, y)
  end

  local function BoolLamp(b) return b and "ON" or "OFF" end

  local function DrawStatusPanel()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then return end
    local sw, sh = draw.GetScreenSize()

    local rows = 11
    local w = UI.width
    local h = UI.headerH + UI.pad + rows * UI.lineH + UI.pad
    local x = sw - w - UI.margin
    local y = UI.margin

    draw.Color(0, 0, 0, 170)
    for i = 0, h, 2 do draw.Line(x, y+i, x+w, y+i) end
    draw.Color(255, 255, 255, 230)
    drawRectOutline(x, y, w, h)

    draw.SetFont(font_main); draw.Color(255, 255, 255, 255)
    draw.Text(x + UI.pad, y + (UI.headerH - 20), "[Smart Pumpkin]")

    draw.SetFont(font_small)
    local line = y + UI.headerH + UI.pad
    local labelX = x + UI.pad
    local valueX = x + UI.pad + UI.labelCol

    local function row(label, value, good)
      draw.Color(190, 190, 190, 255); draw.Text(labelX, line, label)
      if     good == true  then draw.Color(110, 220, 110, 255)
      elseif good == false then draw.Color(230, 110, 110, 255)
      else                     draw.Color(230, 230, 230, 255) end
      draw.Text(valueX, line, tostring(value))
      line = line + UI.lineH
    end

    row("Enabled",           BoolLamp(Status.enabled),      Status.enabled)
    row("Pair Found",        BoolLamp(Status.foundPair),    Status.foundPair)
    row("LOS",               BoolLamp(Status.inSight),      Status.inSight)
    row("Can Shoot",         BoolLamp(Status.canShoot),     Status.canShoot)
    row("Enemy",             (Status.enemyName ~= "" and Status.enemyName) or "-")
    row("Weapon",            (Status.weaponName ~= "" and Status.weaponName) or "-")
    row("Dist→Bomb",         string.format("%.0f u", Status.distance))
    row("Pumpkin Radius",    string.format("%.0f u", Status.radius))
    row("Shot (this tick)",  BoolLamp(Status.shotThisTick), Status.shotThisTick)
    row("Last Shot @",       string.format("%.2f", Status.lastShotTime))
    row("Reason",            Status.reason)

    draw.Color(255, 255, 255, 60)
    draw.Line(x + UI.pad, y + h - UI.pad, x + w - UI.pad, y + h - UI.pad)
  end

  callbacks.Register("Draw", "SmartPumpkin_StatusPanel", DrawStatusPanel)
end