--[[
    Lmaobox Triggerbot Script with GUI
    Public Release Version 1.0
    By:
    [GitHub] NoStir
    [Discord] purrspire
    [Lmaobox Forums] TimLeary
    Automatically fires when the crosshair is over an enemy.
    GUI allows toggling, adjusting trace range, head/body targeting, zoomed_only, Z-offset,
    trigger key requirement, sniper headshot delay, and ignoring enemies based on conditions.

    Requires menu.lua by compuserscripts
    https://github.com/compuserscripts/lmaomenu/blob/main/menu.lua
]]

-- Import the menu library
local menu = require("menu") -- Make sure menu.lua is accessible

-- Main Tab Settings
local triggerbot_enabled = true
local triggerbot_trace_range = 4096
local triggerbot_target_head_only = true
local triggerbot_zoomed_only = true
local apply_trace_z_offset = true
local trigger_key_enabled = false
local sniper_headshot_delay_enabled = true

-- Ignore Tab Settings
local ignore_ubered_enemies = true
local ignore_bullet_resist_enemies = true
local ignore_bonked_enemies = true
local ignore_buff_banner_enemies = true
local ignore_cloaked_enemies = true
local ignore_disguised_enemies = true
local ignore_deadringer_enemies = true

-- Constants for settings
local MAX_TRACE_RANGE = 8192
local MIN_TRACE_RANGE = 1
local Z_AXIS_OFFSET_VALUE = 0.1
local SNIPER_HEADSHOT_DELAY_TIME = 0.2 -- Delay in seconds

-- Sniper Delay State Tracking
local last_zoomed_state = false
local time_zoomed_in = 0

-- Uber conditions to group
local UBER_CONDITIONS = {
    TFCond_Ubercharged,
    TFCond_UberchargeFading,
    TFCond_UberchargedHidden,
    TFCond_UberchargedCanteen,
    TFCond_UberchargedOnTakeDamage
}
-- Buff Banner conditions to group
local BUFF_BANNER_CONDITIONS = {
    TFCond_DefenseBuffNoCritBlock,
    TFCond_DefenseBuffed
}

-- GUI Elements
local triggerbot_menu_window = nil
local MENU_TOGGLE_KEY = KEY_DELETE
local last_menu_key_state = false
local current_tab_name = "Main"

-- Visual Indicator
local indicator_font = draw.CreateFont("Verdana", 18, 500, FONTFLAG_OUTLINE)
local indicator_screen_pos = {x_ratio = 0.03, y_ratio = 0.03}

-- KeyCode to Name Mapping
local keyCodeToNameMap = {}
if E_ButtonCode and type(E_ButtonCode) == "table" then
    for keyName, keyCode in pairs(E_ButtonCode) do
        if type(keyCode) == "number" then
            keyCodeToNameMap[keyCode] = keyName
        end
    end
else
    printc(255, 100, 100, 255, "Error: E_ButtonCode table not defined. Key name remapping will not work.")
end

function GetKeyCodeName(inputCode)
    if not E_ButtonCode or next(keyCodeToNameMap) == nil then
        return "Error: Key map not initialized."
    end
    local numericCode = tonumber(inputCode)
    if numericCode == nil then
        return type(inputCode) == "string" and ("Invalid: \"" .. inputCode .. "\"") or "Invalid Input"
    end
    return keyCodeToNameMap[numericCode] or ("Unknown: " .. tostring(numericCode))
end


local update_triggerbot_menu_tabs
local render_main_tab_widgets
local render_ignore_tab_widgets

function render_main_tab_widgets()
    if not triggerbot_menu_window then return end

    triggerbot_menu_window:createCheckbox("Enable Triggerbot", triggerbot_enabled, function(checked)
        triggerbot_enabled = checked
        client.ChatPrintf(triggerbot_enabled and "\x0700FF00Triggerbot Enabled (GUI)" or "\x07FF0000Triggerbot Disabled (GUI)")
    end)

    triggerbot_menu_window:createCheckbox("Use Lmaobox Trigger Key [" .. (GetKeyCodeName(gui.GetValue("Trigger Shoot Key") or "NOT SET") .. "]"), trigger_key_enabled, function(checked)
        trigger_key_enabled = checked
        client.ChatPrintf(trigger_key_enabled and "\x0700FF00Triggerbot: Trigger Key Required" or "\x07FFFF00Triggerbot: Trigger Key Not Required")
    end)

    triggerbot_menu_window:createCheckbox("Target Head Only", triggerbot_target_head_only, function(checked)
        triggerbot_target_head_only = checked
        client.ChatPrintf(triggerbot_target_head_only and "\x0700FF00Triggerbot: Targeting Head Only" or "\x07FFFF00Triggerbot: Targeting Body")
    end)

    triggerbot_menu_window:createCheckbox(">>Wait For Headshot", sniper_headshot_delay_enabled, function(checked)
        sniper_headshot_delay_enabled = checked
        client.ChatPrintf(sniper_headshot_delay_enabled and "\x0700FF00Sniper Headshot Delay Enabled" or "\x07FFFF00Sniper Headshot Delay Disabled")
    end)


    triggerbot_menu_window:createCheckbox("Zoomed Only", triggerbot_zoomed_only, function(checked)
        triggerbot_zoomed_only = checked
        client.ChatPrintf(triggerbot_zoomed_only and "\x0700FF00Triggerbot: Active Only When Zoomed" or "\x07FFFF00Triggerbot: Active Regardless of Zoom")
    end)
    triggerbot_menu_window:createCheckbox("Adjust Trace Z-Offset", apply_trace_z_offset, function(checked)
        apply_trace_z_offset = checked
        client.ChatPrintf(apply_trace_z_offset and "\x0700FF00Triggerbot: Z-Offset Enabled" or "\x07FFFF00Triggerbot: Z-Offset Disabled")
    end)
    local z_offset_description_items = {
        {text = string.format("     ^ Applies +%.1f to trace start Z", Z_AXIS_OFFSET_VALUE), extraText = ""},
        {text = "       (Helps with shots at top of head)", extraText = ""},
        {text = "===========================", extraText = ""},
    }
    triggerbot_menu_window:createList(z_offset_description_items, nil)
    triggerbot_menu_window:createSlider("Trace Range", triggerbot_trace_range, MIN_TRACE_RANGE, MAX_TRACE_RANGE, function(value)
        triggerbot_trace_range = math.floor(value)
    end)
end

function render_ignore_tab_widgets()
    if not triggerbot_menu_window then return end
    triggerbot_menu_window:createCheckbox("Ignore Ubered", ignore_ubered_enemies, function(checked)
        ignore_ubered_enemies = checked
        client.ChatPrintf(ignore_ubered_enemies and "\x07FF0000Ignoring Ubered" or "\x0700FF00Targeting Ubered")
    end)
    triggerbot_menu_window:createCheckbox("Ignore Bullet Resist", ignore_bullet_resist_enemies, function(checked)
        ignore_bullet_resist_enemies = checked
        client.ChatPrintf(ignore_bullet_resist_enemies and "\x07FF0000Ignoring Bullet Resist" or "\x0700FF00Targeting Bullet Resist")
    end)
    triggerbot_menu_window:createCheckbox("Ignore Bonked", ignore_bonked_enemies, function(checked)
        ignore_bonked_enemies = checked
        client.ChatPrintf(ignore_bonked_enemies and "\x07FF0000Ignoring Bonked" or "\x0700FF00Targeting Bonked")
    end)
    triggerbot_menu_window:createCheckbox("Ignore Buff Banner", ignore_buff_banner_enemies, function(checked)
        ignore_buff_banner_enemies = checked
        client.ChatPrintf(ignore_buff_banner_enemies and "\x07FF0000Ignoring Buff Banner" or "\x0700FF00Targeting Buff Banner")
    end)
    triggerbot_menu_window:createCheckbox("Ignore Cloaked", ignore_cloaked_enemies, function(checked)
        ignore_cloaked_enemies = checked
        client.ChatPrintf(ignore_cloaked_enemies and "\x07FF0000Ignoring Cloaked" or "\x0700FF00Targeting Cloaked")
    end)
    triggerbot_menu_window:createCheckbox("Ignore Disguised", ignore_disguised_enemies, function(checked)
        ignore_disguised_enemies = checked
        client.ChatPrintf(ignore_disguised_enemies and "\x07FF0000Ignoring Disguised" or "\x0700FF00Targeting Disguised")
    end)
    triggerbot_menu_window:createCheckbox("Ignore Dead Ringer", ignore_deadringer_enemies, function(checked)
        ignore_deadringer_enemies = checked
        client.ChatPrintf(ignore_deadringer_enemies and "\x07FF0000Ignoring Dead Ringer" or "\x0700FF00Targeting Dead Ringer")
    end)
end

function update_triggerbot_menu_tabs()
    if not triggerbot_menu_window or not triggerbot_menu_window.isOpen then
        return
    end
    local tabPanel = triggerbot_menu_window:renderTabPanel()
    if #tabPanel.tabOrder == 0 then
        tabPanel:addTab("Main", function()
            current_tab_name = "Main"
            triggerbot_menu_window:clearWidgets()
            render_main_tab_widgets()
            triggerbot_menu_window.height = triggerbot_menu_window:calculateHeight()
        end)
        tabPanel:addTab("Ignore", function()
            current_tab_name = "Ignore"
            triggerbot_menu_window:clearWidgets()
            render_ignore_tab_widgets()
            triggerbot_menu_window.height = triggerbot_menu_window:calculateHeight()
        end)
        if tabPanel.currentTab == "Main" and tabPanel.tabs["Main"] then
             tabPanel.tabs["Main"]()
        end
    end
end

local function initialize_triggerbot_menu()
    if triggerbot_menu_window then return end
    triggerbot_menu_window = menu.createWindow("Triggerbot v1.0 //NoStir", {
        x = 50,
        y = 50,
        width = 360,
        desiredItems = 12
    })
end

local function handle_menu_interaction()
    local current_key_state = input.IsButtonDown(MENU_TOGGLE_KEY)
    if current_key_state and not last_menu_key_state then
        if not triggerbot_menu_window then
            initialize_triggerbot_menu()
        end
        if triggerbot_menu_window then
            if not triggerbot_menu_window.isOpen then
                triggerbot_menu_window:focus()
                update_triggerbot_menu_tabs()
            else
                triggerbot_menu_window:unfocus()
            end
        end
    end
    last_menu_key_state = current_key_state
end

local function round_for_draw(num)
    return math.floor(num + 0.5)
end

local function is_entity_ubered(entity)
    if not entity or not entity:IsValid() then return false end
    for _, cond in ipairs(UBER_CONDITIONS) do
        if entity:InCond(cond) then return true end
    end
    return false
end

local function is_entity_buff_bannered(entity)
    if not entity or not entity:IsValid() then return false end
    for _, cond in ipairs(BUFF_BANNER_CONDITIONS) do
        if entity:InCond(cond) then return true end
    end
    return false
end

-- Core triggerbot logic
local function on_create_move(cmd)
    local me = entities.GetLocalPlayer()
    if not me or not me:IsValid() or not me:IsAlive() then
        return
    end

    -- Track zoom state changes
    local currently_zoomed = me:InCond(TFCond_Zoomed)
    if currently_zoomed and not last_zoomed_state then
        time_zoomed_in = globals.RealTime() -- Player just zoomed in
    end
    last_zoomed_state = currently_zoomed

    if not triggerbot_enabled then
        return
    end

    if trigger_key_enabled then
        local trigger_key_code = gui.GetValue("Trigger Shoot Key")
        if type(trigger_key_code) ~= "number" or trigger_key_code == E_ButtonCode.KEY_NONE then
            return
        end
        if not input.IsButtonDown(trigger_key_code) then
            return
        end
    end

    if triggerbot_zoomed_only and not currently_zoomed then
        return
    end

    local eye_pos_val
    local eye_pos_success, pcall_result = pcall(function() return me:GetAbsOrigin() + me:GetPropVector("localdata", "m_vecViewOffset[0]") end)
    if not eye_pos_success or pcall_result == nil then
        return
    end
    eye_pos_val = pcall_result

    if apply_trace_z_offset then
        eye_pos_val.z = eye_pos_val.z + Z_AXIS_OFFSET_VALUE
    end

    local view_angles = cmd.viewangles
    local trace_end_pos = eye_pos_val + view_angles:Forward() * triggerbot_trace_range

    local function trace_filter_func(entity_to_check, contents_mask)
        return entity_to_check ~= me
    end

    local trace_result_val
    local trace_success, pcall_trace_result = pcall(engine.TraceLine, eye_pos_val, trace_end_pos, MASK_ALL, trace_filter_func)
    if not trace_success or pcall_trace_result == nil then
        return
    end
    trace_result_val = pcall_trace_result

    if trace_result_val.entity and trace_result_val.entity:IsValid() then
        local target_entity = trace_result_val.entity
        if target_entity:GetClass() == "CTFPlayer" and
           target_entity:IsAlive() and
           not target_entity:IsDormant() and
           target_entity:GetTeamNumber() ~= me:GetTeamNumber() and
           (target_entity:GetTeamNumber() == E_TeamNumber.TEAM_RED or target_entity:GetTeamNumber() == E_TeamNumber.TEAM_BLU) then

            if ignore_ubered_enemies and is_entity_ubered(target_entity) then return end
            if ignore_bullet_resist_enemies and target_entity:InCond(TFCond_UberBulletResist) then return end
            if ignore_bonked_enemies and target_entity:InCond(TFCond_Bonked) then return end
            if ignore_buff_banner_enemies and is_entity_buff_bannered(target_entity) then return end
            if ignore_cloaked_enemies and target_entity:InCond(TFCond_Cloaked) then return end
            if ignore_disguised_enemies and target_entity:InCond(TFCond_Disguised) then return end
            if ignore_deadringer_enemies and target_entity:InCond(TFCond_DeadRingered) then return end

            local active_weapon = me:GetPropEntity("m_hActiveWeapon")
            if active_weapon and active_weapon:IsValid() and active_weapon:IsShootingWeapon() then
                local should_fire = false
                local hitgroup = trace_result_val.hitgroup

                if triggerbot_target_head_only then
                    if hitgroup == 1 then
                        if sniper_headshot_delay_enabled then
                            if currently_zoomed and (globals.RealTime() - time_zoomed_in >= SNIPER_HEADSHOT_DELAY_TIME) then
                                should_fire = true
                            end
                        else
                            should_fire = true
                        end
                    end
                else
                    if hitgroup ~= nil and hitgroup ~= 1 then
                        should_fire = true
                    end
                end

                if should_fire then
                    cmd.buttons = cmd.buttons | IN_ATTACK
                end
            end
        end
    end
end

local function on_draw()
    handle_menu_interaction()

    if not indicator_font then return end
    local screen_w, screen_h = draw.GetScreenSize()
    if not screen_w or not screen_h then return end
    local draw_x = round_for_draw(screen_w * indicator_screen_pos.x_ratio)
    local draw_y = round_for_draw(screen_h * indicator_screen_pos.y_ratio)

    draw.SetFont(indicator_font)
    local indicator_text = "Trigger: "
    if triggerbot_enabled then
        if gui.GetValue("Trigger Shoot") == 1 then
            gui.SetValue("Trigger Shoot", 0)
        end
        draw.Color(0, 255, 0, 255)
        indicator_text = indicator_text .. "ON"
        if trigger_key_enabled then indicator_text = indicator_text .. " (Key)" end
        if triggerbot_target_head_only then
            indicator_text = indicator_text .. " (Head)"
            if sniper_headshot_delay_enabled then indicator_text = indicator_text .. " (HS Delay)" end
        else
            indicator_text = indicator_text .. " (Body)"
        end
        if triggerbot_zoomed_only then indicator_text = indicator_text .. " (Zoomed)" end
        if apply_trace_z_offset then indicator_text = indicator_text .. " (ZAdj)" end
    else
        draw.Color(255, 0, 0, 255)
        indicator_text = indicator_text .. "OFF"
    end
    draw.Text(draw_x, draw_y, indicator_text)
end

callbacks.Register("CreateMove", "TriggerbotCM", on_create_move)
callbacks.Register("Draw", "TriggerbotDraw", on_draw)

initialize_triggerbot_menu()
if triggerbot_menu_window then
    triggerbot_menu_window:focus()
    update_triggerbot_menu_tabs()
end

print("Lmaobox Triggerbot script loaded. Press DELETE to open/close settings.")
client.ChatPrintf("Lmaobox Triggerbot script loaded. Press DELETE for GUI.")

callbacks.Register("Unload", "TriggerbotUnload", function()
    callbacks.Unregister("CreateMove", "TriggerbotCM")
    callbacks.Unregister("Draw", "TriggerbotDraw")
    if triggerbot_menu_window then
        menu.closeAll()
        triggerbot_menu_window = nil
    end
    print("Lmaobox Triggerbot script unloaded.")
end)