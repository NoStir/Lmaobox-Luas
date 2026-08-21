local me = entities.GetLocalPlayer()
if not me then
    print("Local player not found.")
    return
end

local font = draw.CreateFont("Tahoma", 16, 800)
draw.SetFont(font)

local MAX_DISTANCE = 200
local CHECK_INTERVAL = 0.2  -- Check every 1 second
local lastCheckTime = 0
local pdaOpened = false
local entityInfo = {}

-- Function to calculate the distance between two positions
local function calculateDistance(pos1, pos2)
    return ((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2 + (pos1.z - pos2.z)^2)^0.5
end

local function updateEntityInfo()
    -- Clear the entity info table
    entityInfo = {}

    -- Get the local player's position and team number
    local myPos = me:GetAbsOrigin()
    local myTeam = me:GetTeamNumber()

    -- Get the highest entity index on the server
    local highestEntityIndex = entities.GetHighestEntityIndex()

    -- Iterate through all entity indices from 0 to highestEntityIndex
    for i = 0, highestEntityIndex do
        -- Get the entity at the current index
        local entity = entities.GetByIndex(i)
        
        -- Check if the entity exists (is not nil)
        if entity then
            -- Get the class of the entity
            local entityClass = entity:GetClass()

            -- Check if the entity is a sentry gun
            if entityClass == "CObjectSentrygun" then
                -- Get the team number of the entity
                local entityTeam = entity:GetTeamNumber()

                -- Get the entity's position
                local entityPos = entity:GetAbsOrigin()

                -- Store the entity class and position in the table if the team is different from the local player's team
                if myTeam ~= entityTeam then
                    table.insert(entityInfo, {class = entityClass, pos = entityPos, team = entityTeam})
                end
            end
        end
    end
end

local function main()
    draw.Color(255, 255, 255, 255)
    local screenSize = {x = 0, y = 0}
    screenSize.x, screenSize.y = draw.GetScreenSize()
    local drawPOS = {x = screenSize.x * 0.05, y = screenSize.y * 0.20}
    -- Check if we need to update the entity info
    local currentTime = globals.CurTime()
    if currentTime - lastCheckTime > CHECK_INTERVAL then
        updateEntityInfo()
        lastCheckTime = currentTime
    end

    if me:InCond(TFCond_Ubercharged) and not me:InCond(TFCond_UberchargeFading) and not pdaOpened then
        local myPos = me:GetAbsOrigin()
        for _, info in ipairs(entityInfo) do
            local distance = calculateDistance(myPos, info.pos)
            if distance <= MAX_DISTANCE then
                client.Command("cyoa_pda_open 1", "true")
                draw.Text(drawPOS.x, drawPOS.y, "TRIGGERED!")
                pdaOpened = true
                return
            end
        end
    end

    if me:InCond(TFCond_UberchargeFading) and pdaOpened then
        client.Command("cyoa_pda_open 0", "true")
        pdaOpened = false
    end
end

callbacks.Register("Draw", main)
