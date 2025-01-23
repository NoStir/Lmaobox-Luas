-- Cache player data and avoid redundant calls
local playerCache = {player = nil, position = nil}

-- Function to update player cache
local function updatePlayerCache()
    playerCache.player = entities.GetLocalPlayer()
    playerCache.position = playerCache.player and playerCache.player:GetAbsOrigin() or nil
end

-- Function to calculate delta distance between cached player and entity
local function delta_distance(entity)
    if not playerCache.position then return 0 end
    local entityPos = entity:GetAbsOrigin()
    local dx = playerCache.position.x - entityPos.x
    local dy = playerCache.position.y - entityPos.y
    local dz = playerCache.position.z - entityPos.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- Cache entity data for the current frame
local entityCache = {}

local function updateEntityCache()
    entityCache = {}
    local max_entities = entities.GetHighestEntityIndex()

    for i = 0, max_entities - 1 do
        local entity = entities.GetByIndex(i)
        if entity and entity:IsValid() then
            local distance = delta_distance(entity)
            if distance <= 500 then
                table.insert(entityCache, {
                    entity = entity,
                    index = i,
                    class = entity:GetClass(),
                    name = entity:GetName() or "Unknown",
                    health = entity:GetHealth() or 0,
                    position = entity:GetAbsOrigin(),
                    distance = distance,
                })
            end
        end
    end

    -- Sort entities by distance
    table.sort(entityCache, function(a, b) return a.distance < b.distance end)
end

-- Function to draw entity indicators in world space
local function draw_entities()
    for _, data in ipairs(entityCache) do
        local screenPos = client.WorldToScreen(data.position)
        if screenPos then
            -- Draw the entity indicator in screen space
            draw.Color(255, 255, 255, 255) -- Default white color
            if data.distance > 42 and data.distance <= 100 then
                draw.Color(255, 0, 0, 255) -- Red for close distances
            elseif data.distance > 100 then
                draw.Color(255, 255, 0, 255) -- Yellow for mid distances
            end

            -- Draw a small cross at the entity's position
            local size = 5
            draw.Line(screenPos[1] - size, screenPos[2], screenPos[1] + size, screenPos[2]) -- Horizontal line
            draw.Line(screenPos[1], screenPos[2] - size, screenPos[1], screenPos[2] + size) -- Vertical line

            -- Draw entity information text
            local info = string.format("%s (%.2f)", data.class, data.distance)
            draw.Text(screenPos[1] + 10, screenPos[2] - 5, info)
        end
    end
end

-- Main function executed on every frame
local lastUpdateTime = 0
local updateInterval = 0.02 -- Update entities every 0.02 seconds

local function main()
    if globals.RealTime() - lastUpdateTime > updateInterval then
        updatePlayerCache()
        updateEntityCache()
        lastUpdateTime = globals.RealTime()
    end

    draw_entities()
end

-- Register the main function to run on Draw
callbacks.Register("Draw", main)
