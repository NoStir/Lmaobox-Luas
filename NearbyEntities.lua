-- Combined entity lister, drawer, and direction indicator

draw.SetFont(draw.CreateFont("Tahoma", 16, 800))

-- Function to calculate delta distance between player and entity
local function delta_distance(entity)
    local me = entities.GetLocalPlayer()
    if not (me and me:IsValid()) then
        return 0 -- Return 0 if the player is invalid
    end

    local myPos = me:GetAbsOrigin()
    local entityPos = entity:GetAbsOrigin()

    -- Calculate the 3D distance
    local delta = math.sqrt((myPos.x - entityPos.x)^2 + (myPos.y - entityPos.y)^2 + (myPos.z - entityPos.z)^2)
    
    return delta
end

-- Function to calculate angle between player view direction and entity position
local function get_entity_direction(entity)
    local me = entities.GetLocalPlayer()
    if not (me and me:IsValid()) then
        return "Unknown"
    end

    local myPos = me:GetAbsOrigin()
    local entityPos = entity:GetAbsOrigin()
    local directionToEntity = entityPos - myPos

    -- Normalize the direction vector
    directionToEntity:Normalize()

    -- Get player's view angles (yaw)
    local viewAngles = engine.GetViewAngles()
    local forward = viewAngles:Forward()

    -- Calculate the dot product between forward vector and direction to entity
    local dotProduct = forward:Dot(directionToEntity)

    -- Calculate the right vector to determine left or right direction
    local right = viewAngles:Right()
    local rightDot = right:Dot(directionToEntity)

    -- Determine direction based on the dot product results
    if dotProduct > 0.9 then
        return "Ahead"
    elseif dotProduct < -0.9 then
        return "Behind"
    elseif rightDot > 0 then
        return "Right"
    else
        return "Left"
    end
end

-- Function to list all entities within 500 units
local function list_all_entities()
    local entities_list = {}
    local max_entities = entities.GetHighestEntityIndex()

    for i = 0, max_entities - 1 do
        local entity = entities.GetByIndex(i)
        if entity and entity:IsValid() then
            local distance = delta_distance(entity)
            if distance <= 500 then -- Skip entities that are too far away
                table.insert(entities_list, {
                    entity = entity,
                    index = i,
                    class = entity:GetClass(),
                    name = entity:GetName() or "Unknown",
                    health = entity:GetHealth() or 0,
                    position = entity:GetAbsOrigin(),
                    distance = distance,
                    direction = get_entity_direction(entity)
                })
            end
        end
    end

    -- Sort entities by distance
    table.sort(entities_list, function(a, b) return a.distance < b.distance end)

    return entities_list
end

-- Function to draw an indicator on the screen for an entity
local function draw_entity_indicator(entity)
    local screenPos = client.WorldToScreen(entity:GetAbsOrigin())
    
    if screenPos then
        -- Set indicator color (white)
        draw.Color(255, 255, 255, 255)
        
        -- Draw a small cross as an indicator
        local size = 5
        draw.Line(screenPos[1] - size, screenPos[2], screenPos[1] + size, screenPos[2]) -- Horizontal line
        draw.Line(screenPos[1], screenPos[2] - size, screenPos[1], screenPos[2] + size) -- Vertical line
        
        -- Optionally, draw the entity's name/class and direction next to the indicator
        local info = string.format("%s (%.2f) - %s", entity:GetClass(), delta_distance(entity), get_entity_direction(entity))
        draw.Text(screenPos[1] + 10, screenPos[2] - 5, info)
    end
end

-- Function to draw indicators for all entities on the screen
local function draw_entities_indicators(entities_list)
    for _, entity_info in ipairs(entities_list) do
        draw_entity_indicator(entity_info.entity)
    end
end

-- Function to draw the entities list on screen
local function draw_entities_list(entities_list)
    local screenSizeX, screenSizeY = draw.GetScreenSize()
    local drawPOS = {x = screenSizeX * 0.05, y = screenSizeY * 0.20}
    local moveFactorY = 0.05
    local moveFactorX = 0.2

    local displayed_classes = {}

    for _, entity in ipairs(entities_list) do
        if not displayed_classes[entity.class] then
            local info = string.format("#%d: %s - %.2f - %s", entity.index, entity.class, entity.distance, entity.direction)
            
            -- Set text color based on distance
            if entity.distance >= 42 and entity.distance <= 100 then
                draw.Color(255, 0, 0, 255) -- Red for distances greater than 41
            elseif entity.distance > 80 then
                draw.Color(255, 255, 0, 255) -- Yellow for distances greater than 80
            else
                draw.Color(255, 255, 255, 255) -- White for other distances
            end
            
            draw.Text(drawPOS.x, drawPOS.y, info)
            drawPOS.y = drawPOS.y + (screenSizeY * moveFactorY)

            if drawPOS.y > screenSizeY * 0.90 then
                drawPOS.y = screenSizeY * 0.10
                drawPOS.x = drawPOS.x + (screenSizeX * moveFactorX)
            end

            displayed_classes[entity.class] = true
        end
    end
end

-- Main execution function
local function main()
    local entities_list = list_all_entities()
    draw_entities_indicators(entities_list)
    draw_entities_list(entities_list)
end

-- Register the Draw callback to execute the script
callbacks.Register("Draw", main)
