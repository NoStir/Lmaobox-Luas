--[[
    Player Tracker HUD (Event-Driven Optimization)

    Maintains a player list using player_connect and player_disconnect events.
    Displays a list of players and their current world coordinates.
    Updates position data periodically to improve performance.
    Highlights self, teammates, and enemies with different colors.
]]

-- Configuration
local hudStartX = 10
local hudStartY = 150
local lineHeight = 16
local hudFontName = "Verdana"
local hudFontSize = 14
local hudFontWeight = 700
local updateInterval = 0.1 -- Update visual data 10 times per second

-- Colors (RGBA)
local colorSelf = {0, 255, 255, 255}
local colorTeam = {100, 150, 255, 255}
local colorEnemy = {255, 100, 100, 255}
local colorSpectator = {200, 200, 200, 255}
local colorDefault = {255, 255, 255, 255}
local colorError = {255, 0, 0, 255}
local colorInfo = {0, 255, 0, 255}
local colorWarn = {255, 165, 0, 255}

-- Global storage
local g_TrackedPlayers = {}     -- Key: userID, Value: { name, entityIndex, steamID }
local playerDisplayData = {}    -- Processed data for drawing
local lastUpdateTime = 0
local playerCount = 0

-- Create the font
local hudFont = draw.CreateFont(hudFontName, hudFontSize, hudFontWeight, FONTFLAG_OUTLINE)
if not hudFont then
    printc(colorError[1], colorError[2], colorError[3], 255, "Error: Failed to create font '", hudFontName, "' for Player Tracker HUD.")
    hudFont = 0
end

-- Function to add/update a player in our tracked list
local function addOrUpdatePlayer(userID, name, entityIndex, steamID)
    if userID and userID ~= 0 then
        g_TrackedPlayers[userID] = {
            name = name or "(Unknown)",
            entityIndex = entityIndex,
            steamID = steamID or "(No SteamID)"
        }
        printc(colorInfo[1], colorInfo[2], colorInfo[3], 255, "Player Added/Updated: ", name, " (UID:", userID, " EID:", entityIndex, ")")
    end
end

-- Function to remove a player from our tracked list
local function removePlayer(userID)
    if userID and g_TrackedPlayers[userID] then
        printc(colorWarn[1], colorWarn[2], colorWarn[3], 255, "Player Removed: ", g_TrackedPlayers[userID].name, " (UID:", userID, ")")
        g_TrackedPlayers[userID] = nil
    end
end

-- Function to perform initial scan for players already on the server
local function initialPlayerScan()
    printc(colorInfo[1], colorInfo[2], colorInfo[3], 255, "Performing initial player scan...")
    local currentPlayers = 0
    for i = 1, globals.MaxClients() do
        local ent = entities.GetByIndex(i)
        -- Check if it's a valid player entity
        if ent and ent:IsValid() and ent:IsPlayer() then
            local success, pInfo = pcall(client.GetPlayerInfo, i)
            if success and pInfo and pInfo.UserID and pInfo.UserID ~= 0 then
                addOrUpdatePlayer(pInfo.UserID, pInfo.Name, i, pInfo.SteamID)
                currentPlayers = currentPlayers + 1
            else
                 -- Fallback if GetPlayerInfo fails but entity exists
                 local nameFallback = client.GetPlayerNameByIndex(i) or ("Player_" .. i)
                 -- We don't have UserID here easily, could potentially get later if needed
                 -- For now, we might skip adding them here or add with a placeholder ID if absolutely necessary
                 printc(colorWarn[1], colorWarn[2], colorWarn[3], 255, "Could not get full info for player index:", i, " Name:", nameFallback)
            end
        end
    end
    printc(colorInfo[1], colorInfo[2], colorInfo[3], 255, "Initial scan complete. Found ", currentPlayers, " players.")
end

-- Game Event Handler
local function onGameEvent(event)
    local eventName = event:GetName()

    if eventName == "player_connect" then
        local name = event:GetString("name")
        local index = event:GetInt("index") -- This is player slot (0-based usually for events?) Lmaobox docs say byte, let's assume it's correct index for GetByIndex
        local userID = event:GetInt("userid")
        local networkid = event:GetString("networkid")
        local entityIndex = index
        entityIndex = index + 1

        addOrUpdatePlayer(userID, name, entityIndex, networkid)

    elseif eventName == "player_disconnect" then
        local userID = event:GetInt("userid")
        removePlayer(userID)
    end
end

-- Function to update visual player data (iterates g_TrackedPlayers)
local function updatePlayerData()
    local me = entities.GetLocalPlayer()
    if not me or not me:IsValid() then
        playerDisplayData = {}
        playerCount = 0
        return
    end
    local myTeam = me:GetTeamNumber()
    local myIndex = me:GetIndex()

    local newDisplayData = {}
    local currentCount = 0
    local playersToRemove = {} -- List of userIDs to remove after iteration

    for userID, playerData in pairs(g_TrackedPlayers) do
        local ent = entities.GetByIndex(playerData.entityIndex)

        if not ent or not ent:IsValid() then
            -- Mark for removal if entity is no longer valid
            table.insert(playersToRemove, userID)
            goto continue_update -- Skip to next player in loop
        end

        -- Entity is valid, proceed
        local pOrigin = ent:GetAbsOrigin()
        local pTeam = ent:GetTeamNumber()
        local pName = playerData.name -- Use stored name

        local color = colorDefault

        -- Determine color
        if playerData.entityIndex == myIndex then
            color = colorSelf
        elseif pTeam == TEAM_SPECTATOR then
            color = colorSpectator
        elseif pTeam == myTeam then
            color = colorTeam
        else
            color = colorEnemy
        end

        -- Format position string
        local posStr = "???"
        if pOrigin then
            posStr = string.format("X: %.1f Y: %.1f Z: %.1f", pOrigin.x, pOrigin.y, pOrigin.z)
        end

        -- Store processed data for drawing
        table.insert(newDisplayData, {
            name = pName,
            text = string.format("%s - %s", pName, posStr),
            color = color
        })
        currentCount = currentCount + 1

        ::continue_update::
    end

    -- Remove players marked for removal
    for _, uidToRemove in ipairs(playersToRemove) do
        removePlayer(uidToRemove)
        printc(colorWarn[1], colorWarn[2], colorWarn[3], 255, "Removed invalid player entry for UserID:", uidToRemove)
    end

    -- Update the display data and count
    playerDisplayData = newDisplayData
    playerCount = currentCount
end

-- Main drawing function (lightweight)
local function drawPlayerTrackerHUD()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return
    end

    -- Check if it's time to update the visual data
    local currentTime = globals.CurTime()
    if currentTime >= lastUpdateTime + updateInterval then
        updatePlayerData()
        lastUpdateTime = currentTime
    end

    -- Set the font for drawing
    draw.SetFont(hudFont)

    local drawY = hudStartY

    -- Draw the header
    draw.Color(255, 255, 255, 255) -- White for header
    draw.Text(math.floor(hudStartX), math.floor(drawY - lineHeight), "Player Positions (" .. playerCount .. ")")

    -- Iterate through the *pre-processed* display data and draw
    for i, data in ipairs(playerDisplayData) do
        local r, g, b, a = data.color[1], data.color[2], data.color[3], data.color[4]
        draw.Color(r, g, b, a)
        draw.Text(math.floor(hudStartX), math.floor(drawY), data.text)
        drawY = drawY + lineHeight
    end
end

-- Perform initial scan *before* registering Draw
initialPlayerScan()
updatePlayerData() -- Populate display data initially
lastUpdateTime = globals.CurTime()

-- Register callbacks
callbacks.Register("FireGameEvent", "PlayerTrackerEventHandler", onGameEvent)
callbacks.Register("Draw", "PlayerTrackerHUD_EventDriven", drawPlayerTrackerHUD)

printc(colorInfo[1], colorInfo[2], colorInfo[3], 255, "Player Tracker HUD script loaded (Event-Driven).")

-- Unregister callbacks on unload
callbacks.Register("Unload", "PlayerTrackerHUD_EventDriven_Unload", function()
    callbacks.Unregister("FireGameEvent", "PlayerTrackerEventHandler")
    callbacks.Unregister("Draw", "PlayerTrackerHUD_EventDriven")
    printc(colorWarn[1], colorWarn[2], colorWarn[3], 255, "Player Tracker HUD script unloaded (Event-Driven).")
end)