-- Function to list all entities on the server
local function list_all_entities()
    local entities_list = {}
    local max_entities = entities.GetHighestEntityIndex()
    
    for i = 0, max_entities - 1 do
        local entity = entities.GetByIndex(i)
        if entity then
            table.insert(entities_list, {
                index = i,
                class = entity:GetClass(),
                name = entity:GetName(),
                health = entity:GetHealth(),
                position = entity:GetAbsOrigin()
            })
        end
    end
    
    return entities_list
end

-- Function to print the entities list to the console
local function print_entities_list(entities_list)
    for _, entity in ipairs(entities_list) do
        print(string.format("Index: %d | Class: %s | Name: %s | Health: %d | Position: (%.2f, %.2f, %.2f)",
            entity.index, entity.class, entity.name, entity.health, entity.position.x, entity.position.y, entity.position.z))
    end
end

-- Main execution
local function main()
    local entities_list = list_all_entities()
    print_entities_list(entities_list)
end

-- Register a command to execute the script
callbacks.Register("Draw", main)
