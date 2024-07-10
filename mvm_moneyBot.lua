local debug = false

local observed_upgrades_count = 0

-- Functions to interact with game engine for upgrades
local function begin_upgrade()
    assert(engine.SendKeyValues('"MvM_UpgradesBegin" {}'))
    observed_upgrades_count = observed_upgrades_count + 1
end

---@param num_upgrades number 
local function end_upgrade(num_upgrades)
    num_upgrades = num_upgrades or 0
    assert(engine.SendKeyValues(
        '"MvM_UpgradesDone" { "num_upgrades" "' .. num_upgrades .. '" }'))
    observed_upgrades_count = observed_upgrades_count - 1
end

local function respec_upgrades()
    assert(engine.SendKeyValues('"MVM_Respec" {}'))
end

local function mvm_upgrade_weapon(itemslot, upgrade, count)
    assert(engine.SendKeyValues(
        '"MVM_Upgrade" { "Upgrade" { "itemslot" "' ..
        itemslot .. '" "Upgrade" "' .. upgrade .. '" "count" "' .. count .. '" } }'))
end

-- Core variables
local confirmed_upgrades_request, sent_upgrades_request, step, clock, grace, objResource

-- Retrieve Objective Resource Entity
local function GetObjResource()
    for i = 0, entities.GetHighestEntityIndex() - 1 do
        local entity = entities.GetByIndex(i)
        if entity and entity:GetClass() == "CTFObjectiveResource" then
            objResource = entity
            break
        end
    end
end

-- Ensure Objective Resource is valid
if objResource == nil or not objResource:IsValid() then
    GetObjResource()
end

local mvmBetweenWaves = objResource and objResource:IsValid() and objResource:GetPropBool("m_bMannVsMachineBetweenWaves")
if mvmBetweenWaves == nil then
    mvmBetweenWaves = objResource:GetPropBool("m_bMannVsMachineBetweenWaves")
end

-- Reset core variables
local function reset()
    confirmed_upgrades_request = 0
    sent_upgrades_request = 0
    step = 1
    clock = 0
    grace = true
end

-- Upgrade phases
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

-- Check prerequisites before executing main function
local function check_prerequisites()
    local me = entities.GetLocalPlayer()
    if not me then return end
    local server_allowed_respec = client.GetConVar('tf_mvm_respec_enabled') == 1
    local my_credits = me:GetPropInt('m_nCurrency')
    local in_upgrade_zone = me:GetPropInt('m_bInUpgradeZone') == 1
    local xCurrentMap = string.match(engine.GetMapName(), "maps/(.+)%.bsp$")
    local playingMVM = string.sub(xCurrentMap, 1, 4) == "mvm_"
    local broke = my_credits < 12000

    return server_allowed_respec and in_upgrade_zone and playingMVM and (mvmBetweenWaves == true) and broke
end

-- Main execution loop
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

-- Register callbacks for game events and prop updates
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

-- Additional event and message handling functions
local function TextMsg(hud_type, text)
    if text == '#TF_MVM_NoClassUpgradeUI' then
        client.ChatPrintf("[Buy Bot] It seems like you can't change class, try again")
        if attempt_balance_upgrades_count() then
            observed_upgrades_count = observed_upgrades_count + 1
            attempt_balance_upgrades_count()
        end
    end
end

-- Define missing event functions
local function MVMPlayerUpgradedEvent(player_index, current_wave, itemdefinition, attributedefinition, quality, credit_cost)
    -- Implement the required logic here
end

local function MVMLocalPlayerUpgradesValue(mercenary, itemdefinition, upgrade, credit_cost)
    confirmed_upgrades_request = confirmed_upgrades_request + 1
end

local function MVMLocalPlayerWaveSpendingValue(steamID64, current_wave, mvm_event_type, credit_cost)
    -- Implement the required logic here
end

-- User message triggers for various events
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
        MVMPlayerUpgradedEvent(player_index, current_wave, itemdefinition, attributedefinition, quality, credit_cost)
    end,
    [64] = function(UserMessage)
        local mercenary = UserMessage:ReadByte()
        local itemdefinition = UserMessage:ReadInt(16)
        local upgrade = UserMessage:ReadByte()
        local credit_cost = UserMessage:ReadInt(16)
        MVMLocalPlayerUpgradesValue(mercenary, itemdefinition, upgrade, credit_cost)
    end,
    [66] = function(UserMessage)
        local steamID64 = UserMessage:ReadInt(64)
        local current_wave = UserMessage:ReadByte()
        local mvm_event_type = UserMessage:ReadByte()
        local credit_cost = UserMessage:ReadInt(16)
        MVMLocalPlayerWaveSpendingValue(steamID64, current_wave, mvm_event_type, credit_cost)
    end,
}

-- Register user message dispatch callback
callbacks.Register("DispatchUserMessage", function(UserMessage)
    local id = UserMessage:GetID()
    if user_message_triggers[id] then
        user_message_triggers[id](UserMessage)
    end
end)

-- New Script Integration

local font = draw.CreateFont("Tahoma", 16, 800)
draw.SetFont(font)

local displayDuration = 3  -- Duration to display each event (in seconds)
local me, playingMVM, broke, inUpgradeZone, midpoint, spawned
local spawnTick = 0

local function test()
    draw.Color(255, 255, 255, 255)

    if me == nil or not me:IsValid() then
        me = entities.GetLocalPlayer()
        if not me then
            return
        end
    end
    if not me then return end

    if playingMVM == nil and engine.GetMapName() ~= nil then
        local currentMap = string.match(engine.GetMapName(), "maps/(.+)%.bsp$")
        playingMVM = string.sub(currentMap, 1, 4) == "mvm_"
    end

    if not playingMVM then
        return
    end

    if not spawned then
        broke = me:GetPropInt("m_nCurrency") < 12000
        inUpgradeZone = me:GetPropBool("m_bInUpgradeZone")
    end

    local myPos = me:GetAbsOrigin()

    local upgradeSigns = {}
    local max_entities = entities.GetHighestEntityIndex()
    for i = 0, max_entities do
        local entity = entities.GetByIndex(i)
        if entity and entity:GetClass() == "CDynamicProp" then
            if models.GetModelName(entity:GetModel()) == "models/props_mvm/mvm_upgrade_sign.mdl" then
                local entityPos = entity:GetAbsOrigin()
                local entityDistance = vector.Length(vector.Subtract(entityPos, myPos))
                if entityPos and entityDistance < 1000 then
                    table.insert(upgradeSigns, {pos = entityPos, distance = entityDistance})
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

    if spawnTick and (globals.TickCount() - spawnTick < 5000) then
        spawned = false
    end
end

callbacks.Register("Draw", test)

callbacks.Register("FireGameEvent", function(event)
    local eventname = event:GetName()
    if eventname == "player_spawn" then
        local spawnID = tostring(event:GetInt("userid"))
        local myIndex = tostring(client.GetLocalPlayerIndex())
        local pInfo = client.GetPlayerInfo(myIndex)
        local myID = pInfo["UserID"]
        assert(debug == false, "player_spawn: " .. spawnID .. " and your ID is: " .. myID)
        spawnTick = globals.TickCount()
        spawned = true
    end
end)

local function drawDebug()
    if not debug then return end
    local screenSize = {x = 0, y = 0}
    screenSize.x, screenSize.y = draw.GetScreenSize()

    local drawPOS = {x = screenSize.x * 0.05, y = screenSize.y * 0.20}
    local moveFactorY = 0.05
    local moveFactorX = 0.15

    -- Draw remaining events
    local eventLogs = {
        "Spawned: " .. tostring(spawned),
        "Playing MVM: " .. tostring(playingMVM),
        "Broke: " .. tostring(broke),
        "In Upgrade Zone: " .. tostring(inUpgradeZone),
        "Tick Difference: " .. tostring(globals.TickCount() - spawnTick),
        "mvmBetweenWaves: " .. tostring(mvmBetweenWaves)
    }

    for _, log in ipairs(eventLogs) do
        draw.Text(drawPOS.x, drawPOS.y, log)
        drawPOS.y = drawPOS.y + (screenSize.y * moveFactorY)

        if drawPOS.y > screenSize.y * 0.80 then
            drawPOS.y = screenSize.y * 0.20
            drawPOS.x = drawPOS.x + (screenSize.x * moveFactorX)
        end
    end
end

callbacks.Register("Draw", drawDebug)

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

-- Walks to the destination
function WalkTo(userCmd, me, destination)
    local myPos = me:GetAbsOrigin()
    local result = ComputeMove(userCmd, myPos, destination)

    userCmd:SetForwardMove(result.x)
    userCmd:SetSideMove(result.y)
end

callbacks.Register("CreateMove", function(cmd)
    if not playingMVM or not broke or inUpgradeZone or not mvmBetweenWaves then
        return
    end

    if midpoint then
        WalkTo(cmd, me, midpoint)
    end
end)