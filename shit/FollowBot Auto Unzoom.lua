local botSID = ""

-- Set targetSteamID in [U:x:xxxxxxxxxx] format or leave it to automatically target the party leader
local targetSteamID = botSID -- Default placeholder SteamID, change this.
local pLeader = party.GetLeader() -- Retrieve the SteamID of the party leader

-- Settings for the sniper unzoom feature
local distanceThreshold = 250 -- Maximum allowed distance from the target in hammer units
local detectionShrinkPercentage = 30 -- Shrink percentage for visibility detection

local cachedTargetPlayer = nil

-- Find the target player based on SteamID or party leader
local function findTargetPlayer(targetSteamID, pLeader)
    local isDefaultTargetID = targetSteamID == "[U:x:xxxxxxxxxx]"

    if cachedTargetPlayer and cachedTargetPlayer:IsValid() then
        local playerInfo = client.GetPlayerInfo(cachedTargetPlayer:GetIndex())
        if playerInfo and ((not isDefaultTargetID and playerInfo.SteamID == targetSteamID) or playerInfo.SteamID == pLeader) then
            return cachedTargetPlayer
        end
    end

    for _, player in ipairs(entities.FindByClass("CTFPlayer")) do
        local playerInfo = client.GetPlayerInfo(player:GetIndex())
        if playerInfo and ((not isDefaultTargetID and playerInfo.SteamID == targetSteamID) or playerInfo.SteamID == pLeader) then
            cachedTargetPlayer = player
            return player
        end
    end

    return nil 
end

-- Calculate distance between two players
local function calculateDistance(localPlayer, targetPlayer)
    if localPlayer and localPlayer:IsValid() and targetPlayer and targetPlayer:IsValid() then
        local localPos = localPlayer:GetAbsOrigin()
        local targetPos = targetPlayer:GetAbsOrigin()
        return (targetPos - localPos):Length()
    else
        return -1 
    end
end

-- Unzoom the sniper rifle
local function unzoomSniper(cmd)
    cmd.buttons = cmd.buttons | IN_ATTACK2 
end

-- Function to get eye position of a player
local function get_eye_position(player)
    local origin = player:GetAbsOrigin()
    local viewOffset = player:GetPropVector("localdata", "m_vecViewOffset[0]")
    return origin + viewOffset
end

-- Check if a part of the target is visible
local function is_part_visible(target, from, shrink_percentage)
    local mins, maxs = target:GetMins(), target:GetMaxs()
    local shrink_factor = 1 - (shrink_percentage / 100)
    local shrinked_mins = mins + (maxs - mins) * (1 - shrink_factor) * 0.5
    local shrinked_maxs = maxs - (maxs - mins) * (1 - shrink_factor) * 0.5

    -- Define the points to check for visibility
    local points = {
        Vector3(shrinked_mins.x, shrinked_mins.y, shrinked_mins.z), 
        Vector3(shrinked_maxs.x, shrinked_maxs.y, shrinked_maxs.z),
        Vector3(shrinked_mins.x, shrinked_maxs.y, shrinked_mins.z), 
        Vector3(shrinked_maxs.x, shrinked_mins.y, shrinked_maxs.z),
        Vector3(shrinked_mins.x, shrinked_maxs.y, shrinked_maxs.z), 
        Vector3(shrinked_maxs.x, shrinked_mins.y, shrinked_maxs.z),
        Vector3(shrinked_mins.x, shrinked_mins.y, shrinked_maxs.z), 
        Vector3(shrinked_maxs.x, shrinked_maxs.y, shrinked_mins.z)
    }

    for _, point in ipairs(points) do
        local worldPoint = target:GetAbsOrigin() + point
        local trace = engine.TraceLine(from, worldPoint, MASK_SHOT)
        if trace.entity == target or trace.fraction > 0.99 then
            return true
        end
    end

    return false
end

-- Check if any enemy is visible
local function any_enemy_visible(localPlayer)
    local local_eye_pos = get_eye_position(localPlayer)
    local players = entities.FindByClass("CTFPlayer")

    for _, player in ipairs(players) do
        if player:IsAlive() and player:GetTeamNumber() ~= localPlayer:GetTeamNumber() then
            if is_part_visible(player, local_eye_pos, detectionShrinkPercentage) then
                return true
            end
        end
    end

    return false
end

-- Main function to auto unzoom and check enemy visibility
function autoUnzoom(cmd)
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer or not localPlayer:IsAlive() then
        return
    end

    local isZoomedIn = localPlayer:InCond(TFCond_Zoomed)

    local targetPlayer = findTargetPlayer(targetSteamID, pLeader)
    local distance = calculateDistance(localPlayer, targetPlayer)

    -- Unzoom sniper if the target is too far and no enemies are visible
    if isZoomedIn and distance >= distanceThreshold and not any_enemy_visible(localPlayer) then
        unzoomSniper(cmd)
    end
end

callbacks.Register("CreateMove", "AutoUnzoom", autoUnzoom)
