--[[
    Auto Building Manager v2.0
    
    Description:
    - Utility: Automatically swings a melee weapon to remove sappers from any of your buildings (Sentry, Dispenser, Teleporters) when in range.
    - GUI: Displays a dynamic info panel showing the status of all your active buildings.
    
    Improvements:
    - [FEATURE] Now supports all Engineer buildings, not just the Sentry.
    - [PERFORMANCE] Re-architected with an efficient helper function to find all owned buildings in one pass,
      eliminating duplicated and expensive entity scans in the main callbacks.
    - [GUI] The info panel is now fully dynamic, listing all buildings and correctly identifying Teleporter Entrance/Exit.
    - [ROBUSTNESS] Added checks for building validity and dormancy.
]]

-- A simple toggle to enable or disable the on-screen GUI.
local SHOW_BUILDING_GUI = true
local building_info_font = draw.CreateFont("Verdana", 14, 500, FONTFLAG_OUTLINE)

-- #################################################################################
-- ### EFFICIENT HELPER FUNCTION
-- #################################################################################

-- This single, efficient function finds all buildings constructed by the player.
-- It is called by both CreateMove and Draw to avoid redundant code and entity scans.
local function find_owned_buildings(player)
    local owned_buildings = {}
    if not player or not player:IsValid() then
        return owned_buildings
    end
    
    -- A lookup table for the classes we care about.
    local building_classes = {
        ["CObjectSentrygun"] = true,
        ["CObjectDispenser"] = true,
        ["CObjectTeleporter"] = true
    }

    for i = 1, entities.GetHighestEntityIndex() do
        local entity = entities.GetByIndex(i)
        
        -- Check if the entity is a valid building and its builder is the specified player.
        if entity and not entity:IsDormant() and building_classes[entity:GetClass()] then
            local builder = entity:GetPropEntity("m_hBuilder")
            if builder and builder:GetIndex() == player:GetIndex() then
                table.insert(owned_buildings, entity)
            end
        end
    end
    return owned_buildings
end

-- #################################################################################
-- ### CORE UTILITY: Auto Sapper Removal (runs in CreateMove)
-- #################################################################################

local function on_create_move(cmd)
    local local_player = entities.GetLocalPlayer()

    -- 1. Initial checks: Ensure we are a valid, living Engineer.
    if not local_player or not local_player:IsAlive() or local_player:GetPropInt("m_PlayerClass", "m_iClass") ~= TF2_Engineer then
        return
    end

    -- 2. Weapon Check: Ensure we are holding a melee weapon.
    local active_weapon = local_player:GetPropEntity("m_hActiveWeapon")
    if not active_weapon or not active_weapon:IsMeleeWeapon() then
        return
    end

    -- 3. Find our buildings using the efficient helper function.
    local my_buildings = find_owned_buildings(local_player)
    if #my_buildings == 0 then return end
    
    local player_pos = local_player:GetAbsOrigin()
    local swing_range = active_weapon:GetSwingRange()

    -- 4. Loop through our small list of buildings (max 4) instead of all game entities.
    for _, building in ipairs(my_buildings) do
        if building:GetPropInt("m_bHasSapper") == 1 then
            local distance = (building:GetAbsOrigin() - player_pos):Length()
            
            if distance < swing_range then
                -- Prevent auto-attack if player is already manually attacking.
                if (cmd.buttons & IN_ATTACK) == 0 then
                    cmd.buttons = cmd.buttons | IN_ATTACK
                end
                -- We found a target and are attacking, no need to check others this tick.
                return 
            end
        end
    end
end

-- #################################################################################
-- ### GUI FEATURE: Building Info Panel (runs in Draw)
-- #################################################################################

local function on_draw()
    if not SHOW_BUILDING_GUI or gui.IsMenuOpen() or engine.IsGameUIVisible() then
        return
    end

    local local_player = entities.GetLocalPlayer()
    if not local_player or not local_player:IsAlive() or local_player:GetPropInt("m_PlayerClass", "m_iClass") ~= TF2_Engineer then
        return
    end

    -- Use the same helper function to get our buildings for the GUI.
    local my_buildings = find_owned_buildings(local_player)
    
    -- Prepare the text to display
    local info_text = { "Building Status:" }
    if #my_buildings > 0 then
        for _, building in ipairs(my_buildings) do
            local name = string.gsub(building:GetClass(), "CObject", "") -- "Sentrygun", "Dispenser", "Teleporter"
            
            -- Special handling to distinguish Teleporter entrance and exit.
            if name == "Teleporter" then
                local state = building:GetPropInt("m_iState")
                if state == 1 or state == 2 or state == 3 then -- Idle, Active, Upgrading Entrance
                    name = "Teleporter Entrance"
                elseif state == 4 or state == 5 or state == 6 then -- Idle, Active, Upgrading Exit
                    name = "Teleporter Exit"
                end
            end
            
            local health = building:GetHealth()
            local sapper_status = building:GetPropInt("m_bHasSapper") == 1 and " - SAPPED!" or ""
            table.insert(info_text, string.format("%s: %d HP%s", name, health, sapper_status))
        end
    else
        table.insert(info_text, "None Found")
    end

    -- Draw the info box
    draw.SetFont(building_info_font)
    local screen_w, _ = draw.GetScreenSize()
    local box_x, box_y = screen_w - 220, 100
    local box_w, box_h = 200, 20 + (#info_text * 16)
    
    draw.Color(20, 20, 20, 200)
    draw.FilledRect(box_x, box_y, box_x + box_w, box_y + box_h)
    draw.Color(255, 255, 255, 255)
    draw.OutlinedRect(box_x, box_y, box_x + box_w, box_y + box_h)

    for i, line in ipairs(info_text) do
        -- Color the line red if it's sapped for better visibility
        if string.find(line, "SAPPED!") then
            draw.Color(255, 80, 80, 255)
        else
            draw.Color(255, 255, 255, 255)
        end
        draw.Text(box_x + 10, box_y + 5 + (i-1) * 16, line)
    end
end

-- Register the separated, optimized callbacks.
callbacks.Register("CreateMove", "AutoBuildingManager", on_create_move)
callbacks.Register("Draw", "BuildingInfoGUI", on_draw)