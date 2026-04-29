--[[
    Player Tracker HUD

    Maintains a player list using connect/disconnect events and refreshes
    the displayed position data periodically.
]]

local hudStartX = 10
local hudStartY = 150
local lineHeight = 16
local hudFontName = "Verdana"
local hudFontSize = 14
local hudFontWeight = 700
local updateInterval = 0.1

local colorSelf = { 0, 255, 255, 255 }
local colorTeam = { 100, 150, 255, 255 }
local colorEnemy = { 255, 100, 100, 255 }
local colorSpectator = { 200, 200, 200, 255 }
local colorDefault = { 255, 255, 255, 255 }
local colorError = { 255, 0, 0, 255 }
local colorInfo = { 0, 255, 0, 255 }
local colorWarn = { 255, 165, 0, 255 }

local trackedPlayers = {}
local playerDisplayData = {}
local lastUpdateTime = 0
local playerCount = 0

local hudFont = draw.CreateFont(hudFontName, hudFontSize, hudFontWeight, FONTFLAG_OUTLINE)
if not hudFont then
    printc(colorError[1], colorError[2], colorError[3], 255, "Error: Failed to create font '", hudFontName, "' for Player Tracker HUD.")
    hudFont = 0
end

local function addOrUpdatePlayer(userID, name, steamID)
    if not userID or userID == 0 then
        return
    end

    local existing = trackedPlayers[userID] or {}
    existing.name = name or existing.name or ("UserID " .. userID)
    existing.steamID = steamID or existing.steamID or "(No SteamID)"
    trackedPlayers[userID] = existing
end

local function removePlayer(userID)
    if userID then
        trackedPlayers[userID] = nil
    end
end

local function clearPlayers()
    trackedPlayers = {}
    playerDisplayData = {}
    playerCount = 0
end

local function syncPlayerInfoForIndex(index)
    local playerInfo = client.GetPlayerInfo(index)
    if not playerInfo or not playerInfo.UserID or playerInfo.UserID == 0 then
        return
    end

    addOrUpdatePlayer(playerInfo.UserID, playerInfo.Name, playerInfo.SteamID)
end

local function initialPlayerScan()
    clearPlayers()

    for index = 1, globals.MaxClients() do
        local entity = entities.GetByIndex(index)
        if entity and entity:IsValid() and entity:IsPlayer() then
            syncPlayerInfoForIndex(index)
        end
    end
end

local function getDisplayColor(playerEntity, localPlayer, myTeam, myIndex)
    local entityIndex = playerEntity:GetIndex()
    if entityIndex == myIndex then
        return colorSelf
    end

    local team = playerEntity:GetTeamNumber()
    if team == E_TeamNumber.TEAM_SPECTATOR or team == E_TeamNumber.TEAM_UNASSIGNED then
        return colorSpectator
    end

    if team == myTeam then
        return colorTeam
    end

    return colorEnemy
end

local function getMedicUberText(playerEntity, chargeLevels)
    local playerClass = playerEntity:GetPropInt("m_iClass")
    if playerClass ~= TF2_Medic then
        return nil
    end

    local playerIndex = playerEntity:GetIndex()
    local chargeLevel = chargeLevels and chargeLevels[playerIndex] or nil
    if chargeLevel == nil or chargeLevel < 0 then
        return "Medic"
    end

    return string.format("Medic Uber: %d%%", chargeLevel)
end

local function buildDisplayRow(name, position, extraText)
    if position then
        local rowText = string.format("%s - X: %.1f Y: %.1f Z: %.1f", name, position.x, position.y, position.z)
        if extraText and extraText ~= "" then
            rowText = rowText .. " - " .. extraText
        end
        return rowText
    end

    return string.format("%s - Position unavailable", name)
end

local function updatePlayerData()
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer or not localPlayer:IsValid() then
        playerDisplayData = {}
        playerCount = 0
        return
    end

    local myTeam = localPlayer:GetTeamNumber()
    local myIndex = localPlayer:GetIndex()
    local newDisplayData = {}
    local playerResources = entities.GetPlayerResources()
    local chargeLevels = playerResources and playerResources:GetPropDataTableInt("m_iChargeLevel") or nil

    for userID, trackedPlayer in pairs(trackedPlayers) do
        local entity = entities.GetByUserID(userID)
        local row = {
            name = trackedPlayer.name,
            text = buildDisplayRow(trackedPlayer.name, nil),
            color = colorDefault,
            priority = 4,
        }

        if entity and entity:IsValid() and entity:IsPlayer() then
            syncPlayerInfoForIndex(entity:GetIndex())

            row.name = trackedPlayers[userID].name
            row.text = buildDisplayRow(row.name, entity:GetAbsOrigin(), getMedicUberText(entity, chargeLevels))
            row.color = getDisplayColor(entity, localPlayer, myTeam, myIndex)

            local team = entity:GetTeamNumber()
            if entity:GetIndex() == myIndex then
                row.priority = 1
            elseif team == myTeam then
                row.priority = 2
            elseif team == E_TeamNumber.TEAM_SPECTATOR or team == E_TeamNumber.TEAM_UNASSIGNED then
                row.priority = 4
            else
                row.priority = 3
            end
        end

        newDisplayData[#newDisplayData + 1] = row
    end

    table.sort(newDisplayData, function(left, right)
        if left.priority ~= right.priority then
            return left.priority < right.priority
        end

        return left.name < right.name
    end)

    playerDisplayData = newDisplayData
    playerCount = #newDisplayData
end

local function onGameEvent(event)
    local eventName = event:GetName()

    if eventName == "player_connect" or eventName == "player_connect_client" then
        addOrUpdatePlayer(
            event:GetInt("userid"),
            event:GetString("name"),
            event:GetString("networkid")
        )
        return
    end

    if eventName == "player_disconnect" then
        removePlayer(event:GetInt("userid"))
        return
    end

    if eventName == "game_newmap" then
        initialPlayerScan()
    end
end

local function drawPlayerTrackerHUD()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return
    end

    local currentTime = globals.CurTime()
    if currentTime >= lastUpdateTime + updateInterval then
        updatePlayerData()
        lastUpdateTime = currentTime
    end

    draw.SetFont(hudFont)

    local drawY = hudStartY
    draw.Color(255, 255, 255, 255)
    draw.Text(math.floor(hudStartX), math.floor(drawY - lineHeight), "Player Positions (" .. playerCount .. ")")

    for _, data in ipairs(playerDisplayData) do
        draw.Color(data.color[1], data.color[2], data.color[3], data.color[4])
        draw.Text(math.floor(hudStartX), math.floor(drawY), data.text)
        drawY = drawY + lineHeight
    end
end

initialPlayerScan()
updatePlayerData()
lastUpdateTime = globals.CurTime()

callbacks.Register("FireGameEvent", "PlayerTrackerEventHandler", onGameEvent)
callbacks.Register("Draw", "PlayerTrackerHUD_EventDriven", drawPlayerTrackerHUD)

printc(colorInfo[1], colorInfo[2], colorInfo[3], 255, "Player Tracker HUD loaded.")

callbacks.Register("Unload", "PlayerTrackerHUD_EventDriven_Unload", function()
    callbacks.Unregister("FireGameEvent", "PlayerTrackerEventHandler")
    callbacks.Unregister("Draw", "PlayerTrackerHUD_EventDriven")
    printc(colorWarn[1], colorWarn[2], colorWarn[3], 255, "Player Tracker HUD unloaded.")
end)
