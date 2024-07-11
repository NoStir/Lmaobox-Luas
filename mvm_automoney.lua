local debug = false

-- Core variables
local observed_upgrades_count = 0
local confirmed_upgrades_request, sent_upgrades_request, step, clock, grace, objResource
local me, playingMVM, broke, inUpgradeZone, midpoint, inSpawn
local enabled = true
local waveActive = false
local screenSize = {x = 0, y = 0}
screenSize.x, screenSize.y = draw.GetScreenSize()

draw.SetFont(draw.CreateFont("Tahoma", 16, 800))

-- Core functions
local function begin_upgrade()
    assert(engine.SendKeyValues('"MvM_UpgradesBegin" {}'))
    observed_upgrades_count = observed_upgrades_count + 1
end

local function end_upgrade(num_upgrades)
    num_upgrades = num_upgrades or 0
    assert(engine.SendKeyValues('"MvM_UpgradesDone" { "num_upgrades" "' .. num_upgrades .. '" }'))
    observed_upgrades_count = observed_upgrades_count - 1
end

local function respec_upgrades()
    assert(engine.SendKeyValues('"MVM_Respec" {}'))
end

local function mvm_upgrade_weapon(itemslot, upgrade, count)
    assert(engine.SendKeyValues('"MVM_Upgrade" { "Upgrade" { "itemslot" "' .. itemslot .. '" "Upgrade" "' .. upgrade .. '" "count" "' .. count .. '" } }'))
end

local function reset()
    confirmed_upgrades_request = 0
    sent_upgrades_request = 0
    step = 1
    clock = 0
    grace = true
end

local phase = {
    function()
        begin_upgrade()
        mvm_upgrade_weapon(1, 19, 1)
        mvm_upgrade_weapon(1, 19, 1)
        end_upgrade(2)
    end,
    function()
        begin_upgrade()
        mvm_upgrade_weapon(1, 19, -1)
        mvm_upgrade_weapon(1, 19, 1)
        respec_upgrades()
        end_upgrade(-1)
    end,
    function()
        begin_upgrade()
        mvm_upgrade_weapon(1, 19, 1)
        mvm_upgrade_weapon(1, 19, 1)
        mvm_upgrade_weapon(1, 19, -1)
        mvm_upgrade_weapon(1, 19, -1)
        end_upgrade(0)
    end
}

local function BetweenWaves()
    if not objResource or objResource:IsValid() then
        for i = 0, entities.GetHighestEntityIndex() do
            local entity = entities.GetByIndex(i)
            if entity and entity:GetClass() == "CTFObjectiveResource" then
                objResource = entity
                break
            end
        end
    end
    if objResource and objResource:GetPropBool("m_bMannVsMachineBetweenWaves") then
        waveActive = false
    elseif objResource and not objResource:GetPropBool("m_bMannVsMachineBetweenWaves") then
        waveActive = true
    end
    return objResource:GetPropBool("m_bMannVsMachineBetweenWaves")
end

local function check_prerequisites()
    local server_allowed_respec = client.GetConVar('tf_mvm_respec_enabled') == 1
    return server_allowed_respec and inUpgradeZone and playingMVM and BetweenWaves() and broke and enabled
end

local function exec_main()
    if clock > globals.CurTime() then return end

    if confirmed_upgrades_request < sent_upgrades_request then
        if grace then
            grace = false
        else
            confirmed_upgrades_request = 0
            sent_upgrades_request = 0
        end
    end

    if step == 4 then
        step = 1
    else
        phase[step]()
        step = step + 1
        grace = true
    end

    clock = globals.CurTime() + clientstate.GetLatencyOut()
end

callbacks.Register("PostPropUpdate", function()
    if check_prerequisites() then
        exec_main()
    end
end)

callbacks.Register("FireGameEvent", function(event)
    if event:GetName() == "game_newmap" then
        reset()
    end
end)

reset()

local function TextMsg(hud_type, text)
    if text == '#TF_MVM_NoClassUpgradeUI' then
        client.ChatPrintf("[Buy Bot] It seems like you can't change class, try again")
        if attempt_balance_upgrades_count() then
            observed_upgrades_count = observed_upgrades_count + 1
            attempt_balance_upgrades_count()
        end
    end
end

local user_message_triggers = {
    [5] = function(UserMessage)
        local hud_type = UserMessage:ReadByte()
        local text = UserMessage:ReadString(256)
        TextMsg(hud_type, text)
    end,
    [60] = function(UserMessage)
        local player_index = UserMessage:ReadByte()
        local current_wave = UserMessage:ReadByte()
        local itemdefinition = UserMessage:ReadInt(16)
        local attributedefinition = UserMessage:ReadInt(16)
        local quality = UserMessage:ReadByte()
        local credit_cost = UserMessage:ReadInt(16)
    end,
    [64] = function(UserMessage)
        local mercenary = UserMessage:ReadByte()
        local itemdefinition = UserMessage:ReadInt(16)
        local upgrade = UserMessage:ReadByte()
        local credit_cost = UserMessage:ReadInt(16)
        confirmed_upgrades_request = confirmed_upgrades_request + 1
    end,
    [66] = function(UserMessage)
        local steamID64 = UserMessage:ReadInt(64)
        local current_wave = UserMessage:ReadByte()
        local mvm_event_type = UserMessage:ReadByte()
        local credit_cost = UserMessage:ReadInt(16)
    end,
}

callbacks.Register("DispatchUserMessage", function(UserMessage)
    local id = UserMessage:GetID()
    if user_message_triggers[id] then
        user_message_triggers[id](UserMessage)
    end
end)

callbacks.Register("FireGameEvent", function(event)
    if event:GetName() == "mvm_begin_wave" then
        enabled = false
    end
end)

local function FindUpgradeStations()
    draw.Color(255, 255, 255, 255)

    if me == nil then
        me = entities.GetLocalPlayer()
        if not me then
            return
        end
    end

    playingMVM = gamerules.IsMvM()
    if not playingMVM then
        return
    end

    if me:IsAlive() then
        broke = me:GetPropInt('m_nCurrency') < 10000
        inUpgradeZone = me:GetPropBool("m_bInUpgradeZone")
        if not broke or not BetweenWaves() then
            return
        end
    end

    if inSpawn == nil then
        inSpawn = 1
    end

    if not inSpawn then
        return
    end

    local myPos = me:GetAbsOrigin()
    local upgradeSigns = {}
    local max_entities = entities.GetHighestEntityIndex()
    for i = 0, max_entities do
        local entity = entities.GetByIndex(i)
        if entity and entity:GetClass() == "CDynamicProp" then
            local modelName = models.GetModelName(entity:GetModel())
            if modelName == "models/props_mvm/mvm_upgrade_sign.mdl" then
                local entityPos = entity:GetAbsOrigin()
                if entityPos then
                    local entityDistance = vector.Length(vector.Subtract(entityPos, myPos))
                    if entityDistance < 5000 then
                        table.insert(upgradeSigns, {pos = entityPos, distance = entityDistance})
                    end
                end
            end
        end
    end    

    -- Sort by distance from the player
    table.sort(upgradeSigns, function(a, b) return a.distance < b.distance end)

    if #upgradeSigns >= 2 then
        local pos1 = upgradeSigns[1].pos
        local closestDistance = math.huge
        local pos2

        -- Find the nearest sign to the first nearest sign
        for i = 2, #upgradeSigns do
            local pos = upgradeSigns[i].pos
            local distance = vector.Length(vector.Subtract(pos, pos1))
            if distance < closestDistance then
                closestDistance = distance
                pos2 = pos
            end
        end

        if pos2 then
            midpoint = Vector3(
                (pos1.x + pos2.x) / 2,
                (pos1.y + pos2.y) / 2,
                (pos1.z + pos2.z) / 2
            )

            local screenPos = client.WorldToScreen(midpoint)
            if screenPos and debug then
                draw.Text(screenPos[1], screenPos[2], string.format("Midpoint: %.f, %.f, %.f", midpoint.x, midpoint.y, midpoint.z))
            end
        end
    end
end

callbacks.Register("Draw", FindUpgradeStations)

callbacks.Register("FireGameEvent", function(event)
    local eventname = event:GetName()
    if eventname == "player_spawn" then
        local spawnID = event:GetInt("userid")
        local myIndex = client.GetLocalPlayerIndex()
        local pInfo = client.GetPlayerInfo(myIndex)
        local myID = pInfo["UserID"]
        if spawnID == myID then
            inSpawn = 1
        end
    end
end)

local function info()
    if not debug then return end
    local drawPOS = {x = screenSize.x * 0.05, y = screenSize.y * 0.20}
    local moveFactorY = screenSize.y * 0.05
    local moveFactorX = screenSize.x * 0.15
    local info = {
        "Spawned: " .. tostring(inSpawn),
        "Playing MVM: " .. tostring(playingMVM),
        "Broke: " .. tostring(broke),
        "In Upgrade Zone: " .. tostring(inUpgradeZone)
    }
    local maxY = screenSize.y * 0.80

    for _, log in ipairs(info) do
        draw.Text(drawPOS.x, drawPOS.y, log)
        drawPOS.y = drawPOS.y + moveFactorY

        if drawPOS.y > maxY then
            drawPOS.y = screenSize.y * 0.20
            drawPOS.x = drawPOS.x + moveFactorX
        end
    end
end


callbacks.Register("Draw", info)

local function ComputeMove(userCmd, a, b)
    local diff = (b - a)
    if diff:Length() == 0 then return Vector3(0, 0, 0) end

    local x = diff.x
    local y = diff.y
    local vSilent = Vector3(x, y, 0)

    local ang = vSilent:Angles()
    local cPitch, cYaw, cRoll = userCmd:GetViewAngles()
    local yaw = math.rad(ang.y - cYaw)
    local pitch = math.rad(ang.x - cPitch)
    local move = Vector3(math.cos(yaw) * 450, -math.sin(yaw) * 450, -math.cos(pitch) * 450)

    return move
end

function WalkTo(userCmd, me, destination)
    local myPos = me:GetAbsOrigin()
    local result = ComputeMove(userCmd, myPos, destination)

    userCmd:SetForwardMove(result.x)
    userCmd:SetSideMove(result.y)
end

callbacks.Register("CreateMove", function(cmd)
    if (inSpawn == 1 or nil) and broke and not inUpgradeZone and waveActive == false and midpoint then
        WalkTo(cmd, me, midpoint)
    end
end)
