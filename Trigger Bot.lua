--[[
    Lmaobox Triggerbot Script with GUI
    Release Version v1.2
    By:
    [GitHub] NoStir
    [Discord] purrspire
    [Lmaobox Forums] TimLeary

    Requires menu.lua by compuserscripts for the custom window UI.
]]

local has_menu, menu_result = pcall(require, "menu")
local menu = has_menu and menu_result or nil

local CONFIG_FILE_NAME = "triggerbot_settings.cfg"

local default_triggerbot_settings = {
    enabled = true,
    trace_range = 8192,
    target_head_only = true,
    zoomed_only = true,
    apply_trace_z_offset = true,
    trigger_key_enabled = false,
    sniper_headshot_delay_enabled = true,
    ignore_ubered_enemies = true,
    ignore_bullet_resist_enemies = true,
    ignore_bonked_enemies = true,
    ignore_buff_banner_enemies = true,
    ignore_cloaked_enemies = true,
    ignore_disguised_enemies = true,
    ignore_deadringer_enemies = true,
    show_status_overlay = true,
    keep_gui_open_independent = false,
}

local triggerbot_settings = {}
for key, value in pairs(default_triggerbot_settings) do
    triggerbot_settings[key] = value
end

local MAX_TRACE_RANGE = E_TraceLine.MAX_TRACE_LENGTH
local MIN_TRACE_RANGE = 1
local TRACE_MASK = MASK_SHOT_HULL
local Z_AXIS_OFFSET_VALUE = 0.1
local SNIPER_HEADSHOT_DELAY_TIME = 0.2

local last_zoomed_state = false
local time_zoomed_in = 0

local UBER_CONDITIONS = {
    TFCond_Ubercharged,
    TFCond_UberchargeFading,
    TFCond_UberchargedHidden,
    TFCond_UberchargedCanteen,
    TFCond_UberchargedOnTakeDamage,
}

local BUFF_BANNER_CONDITIONS = {
    TFCond_DefenseBuffNoCritBlock,
    TFCond_DefenseBuffed,
}

local triggerbot_menu_window
local current_tab_name = "Main"
local indicator_font = draw.CreateFont("Verdana", 18, 500, FONTFLAG_OUTLINE)
local indicator_screen_pos = { x_ratio = 0.03, y_ratio = 0.03 }

local key_code_to_name_map = {}
local builtin_trigger_original_value = gui.GetValue("Trigger Shoot")
local builtin_trigger_was_forced_off = false
local trace_ignore_entity = nil

if E_ButtonCode and type(E_ButtonCode) == "table" then
    for key_name, key_code in pairs(E_ButtonCode) do
        if type(key_code) == "number" then
            key_code_to_name_map[key_code] = key_name
        end
    end
end

local function clamp_trace_range(value)
    value = math.floor(tonumber(value) or default_triggerbot_settings.trace_range)
    if value < MIN_TRACE_RANGE then
        return MIN_TRACE_RANGE
    end

    if value > MAX_TRACE_RANGE then
        return MAX_TRACE_RANGE
    end

    return value
end

local function get_key_code_name(input_code)
    if not E_ButtonCode or next(key_code_to_name_map) == nil then
        return "KeyMap N/A"
    end

    local num_code = tonumber(input_code)
    if num_code == nil then
        if type(input_code) == "string" then
            return 'Inv:"' .. input_code .. '"'
        end

        return "Invalid"
    end

    return key_code_to_name_map[num_code] or ("Unk:" .. tostring(num_code))
end

local function save_settings()
    local file, err = io.open(CONFIG_FILE_NAME, "w")
    if not file then
        printc(255, 100, 100, 255, "Save Error: " .. (err or "Unknown"))
        return
    end

    for key, value in pairs(triggerbot_settings) do
        if type(value) == "boolean" then
            file:write(key .. "=" .. (value and "true" or "false") .. "\n")
        elseif type(value) == "number" then
            file:write(key .. "=" .. tostring(value) .. "\n")
        end
    end

    file:close()
end

local function load_settings()
    local file, err = io.open(CONFIG_FILE_NAME, "r")
    if not file then
        if err then
            printc(255, 165, 0, 255, "Config not found or error: " .. err .. ". Using defaults.")
        end
        triggerbot_settings.trace_range = clamp_trace_range(triggerbot_settings.trace_range)
        return
    end

    for line in file:lines() do
        local key, value_str = line:match("([^=]+)=(.*)")
        if key and value_str and triggerbot_settings[key] ~= nil then
            local current_type = type(triggerbot_settings[key])
            if current_type == "boolean" then
                triggerbot_settings[key] = value_str == "true"
            elseif current_type == "number" then
                local num_value = tonumber(value_str)
                if num_value ~= nil then
                    triggerbot_settings[key] = num_value
                end
            end
        end
    end

    file:close()
    triggerbot_settings.trace_range = clamp_trace_range(triggerbot_settings.trace_range)
    printc(100, 255, 100, 255, "Triggerbot settings loaded.")
end

local function restore_default_settings()
    for key, value in pairs(default_triggerbot_settings) do
        triggerbot_settings[key] = value
    end

    triggerbot_settings.trace_range = clamp_trace_range(triggerbot_settings.trace_range)
end

local function round_for_draw(num)
    return math.floor(num + 0.5)
end

local function is_entity_ubered(entity)
    if not entity or not entity:IsValid() then
        return false
    end

    for _, condition in ipairs(UBER_CONDITIONS) do
        if entity:InCond(condition) then
            return true
        end
    end

    return false
end

local function is_entity_buff_bannered(entity)
    if not entity or not entity:IsValid() then
        return false
    end

    for _, condition in ipairs(BUFF_BANNER_CONDITIONS) do
        if entity:InCond(condition) then
            return true
        end
    end

    return false
end

local function should_ignore_target(target)
    if triggerbot_settings.ignore_ubered_enemies and is_entity_ubered(target) then
        return true
    end

    if triggerbot_settings.ignore_bullet_resist_enemies and target:InCond(TFCond_UberBulletResist) then
        return true
    end

    if triggerbot_settings.ignore_bonked_enemies and target:InCond(TFCond_Bonked) then
        return true
    end

    if triggerbot_settings.ignore_buff_banner_enemies and is_entity_buff_bannered(target) then
        return true
    end

    if triggerbot_settings.ignore_cloaked_enemies and target:InCond(TFCond_Cloaked) then
        return true
    end

    if triggerbot_settings.ignore_disguised_enemies and target:InCond(TFCond_Disguised) then
        return true
    end

    if triggerbot_settings.ignore_deadringer_enemies and target:InCond(TFCond_DeadRingered) then
        return true
    end

    return false
end

local function sync_builtin_triggerbot()
    local builtin_value = gui.GetValue("Trigger Shoot")
    if type(builtin_value) ~= "number" then
        return
    end

    if triggerbot_settings.enabled then
        if builtin_value == 1 then
            if not builtin_trigger_was_forced_off then
                builtin_trigger_original_value = builtin_value
            end
            gui.SetValue("Trigger Shoot", 0)
            builtin_trigger_was_forced_off = true
        end
        return
    end

    if builtin_trigger_was_forced_off then
        gui.SetValue("Trigger Shoot", builtin_trigger_original_value or 0)
        builtin_trigger_was_forced_off = false
    end
end

local function restore_builtin_triggerbot()
    if builtin_trigger_was_forced_off then
        gui.SetValue("Trigger Shoot", builtin_trigger_original_value or 0)
        builtin_trigger_was_forced_off = false
    end
end

local function trigger_trace_filter(entity)
    return entity ~= trace_ignore_entity
end

local update_triggerbot_menu_tabs

local function render_main_tab_widgets()
    if not triggerbot_menu_window then
        return
    end

    triggerbot_menu_window:createCheckbox("Enable Triggerbot", triggerbot_settings.enabled, function(checked)
        triggerbot_settings.enabled = checked
        save_settings()
        client.ChatPrintf(checked and "\x0700FF00Trigger Bot On" or "\x07FF0000Trigger Bot Off")
    end)

    triggerbot_menu_window:createCheckbox(
        "Use Lmaobox Trigger Key [" .. get_key_code_name(gui.GetValue("Trigger Shoot Key") or "N/A") .. "]",
        triggerbot_settings.trigger_key_enabled,
        function(checked)
            triggerbot_settings.trigger_key_enabled = checked
            save_settings()
            client.ChatPrintf(checked and "\x0700FF00Lmaobox Trigger Sync On" or "\x07FFFF00Lmaobox Trigger Sync Off")
        end
    )

    triggerbot_menu_window:createCheckbox("Target Head Only", triggerbot_settings.target_head_only, function(checked)
        triggerbot_settings.target_head_only = checked
        save_settings()
        client.ChatPrintf(checked and "\x0700FF00Head Only On" or "\x07FFFF00Head Only Off")
    end)

    triggerbot_menu_window:createCheckbox("Zoomed Only", triggerbot_settings.zoomed_only, function(checked)
        triggerbot_settings.zoomed_only = checked
        save_settings()
        client.ChatPrintf(checked and "\x0700FF00Zoomed Only On" or "\x07FFFF00Zoomed Only Off")
    end)

    triggerbot_menu_window:createCheckbox("(Zoomed) Wait For Headshot", triggerbot_settings.sniper_headshot_delay_enabled, function(checked)
        triggerbot_settings.sniper_headshot_delay_enabled = checked
        save_settings()
        client.ChatPrintf(checked and "\x0700FF00Headshot Delay On" or "\x07FFFF00Headshot Delay Off")
    end)

    triggerbot_menu_window:createCheckbox("Adjust Trace Z-Offset", triggerbot_settings.apply_trace_z_offset, function(checked)
        triggerbot_settings.apply_trace_z_offset = checked
        save_settings()
        client.ChatPrintf(checked and "\x0700FF00Z-Adjust On" or "\x07FFFF00Z-Adjust Off")
    end)

    triggerbot_menu_window:createList({
        { text = "     ^ Adjusts trace Z-offset" },
        { text = "(Helps avoid grazing the top edge of a head trace)" },
        { text = string.rep("=", 27) },
    }, nil)

    triggerbot_menu_window:createSlider("Trace Range", triggerbot_settings.trace_range, MIN_TRACE_RANGE, MAX_TRACE_RANGE, function(value)
        triggerbot_settings.trace_range = clamp_trace_range(value)
        save_settings()
    end)
end

local function render_ignore_tab_widgets()
    if not triggerbot_menu_window then
        return
    end

    local options = {
        { "Ignore Ubered", "ignore_ubered_enemies", "Ignoring Ubered", "Targeting Ubered" },
        { "Ignore Bullet Resist", "ignore_bullet_resist_enemies", "Ignoring BulletRes", "Targeting BulletRes" },
        { "Ignore Bonked", "ignore_bonked_enemies", "Ignoring Bonked", "Targeting Bonked" },
        { "Ignore Buff Banner", "ignore_buff_banner_enemies", "Ignoring BuffBanner", "Targeting BuffBanner" },
        { "Ignore Cloaked", "ignore_cloaked_enemies", "Ignoring Cloaked", "Targeting Cloaked" },
        { "Ignore Disguised", "ignore_disguised_enemies", "Ignoring Disguised", "Targeting Disguised" },
        { "Ignore Dead Ringer", "ignore_deadringer_enemies", "Ignoring DeadRinger", "Targeting DeadRinger" },
    }

    for _, option in ipairs(options) do
        local label, key, true_text, false_text = table.unpack(option)
        triggerbot_menu_window:createCheckbox(label, triggerbot_settings[key], function(checked)
            triggerbot_settings[key] = checked
            save_settings()
            client.ChatPrintf(checked and ("\x07FF0000" .. true_text) or ("\x0700FF00" .. false_text))
        end)
    end
end

local function render_settings_tab_widgets()
    if not triggerbot_menu_window then
        return
    end

    triggerbot_menu_window:createCheckbox("Show Status Overlay", triggerbot_settings.show_status_overlay, function(checked)
        triggerbot_settings.show_status_overlay = checked
        save_settings()
        client.ChatPrintf(checked and "\x0700FF00Status Overlay: ON" or "\x07FF0000Status Overlay: OFF")
    end)

    triggerbot_menu_window:createCheckbox("Keep GUI Open (Independent)", triggerbot_settings.keep_gui_open_independent, function(checked)
        triggerbot_settings.keep_gui_open_independent = checked
        save_settings()
        client.ChatPrintf(checked and "\x0700FF00GUI Independent Mode: ON" or "\x07FF0000GUI Independent Mode: OFF")
    end)

    triggerbot_menu_window:createButton("Reset All Settings to Default", function()
        restore_default_settings()
        save_settings()
        client.ChatPrintf("\x0700FF00All settings reset to defaults.")
        update_triggerbot_menu_tabs()
    end)

    triggerbot_menu_window:createList({
        { text = "Lmaobox Triggerbot v1.2 //NoStir" },
        { text = "[GitHub]: NoStir" },
        { text = "[Discord]: purrspire" },
        { text = "[Lmaobox Forums]: TimLeary" },
        { text = "Settings are saved to " .. CONFIG_FILE_NAME },
    }, nil)
end

update_triggerbot_menu_tabs = function()
    if not menu or not triggerbot_menu_window or not triggerbot_menu_window.isOpen then
        return
    end

    local tab_panel = triggerbot_menu_window:renderTabPanel()
    if #tab_panel.tabOrder == 0 then
        tab_panel:addTab("Main", function()
            current_tab_name = "Main"
            triggerbot_menu_window:clearWidgets()
            render_main_tab_widgets()
            triggerbot_menu_window.height = triggerbot_menu_window:calculateHeight()
        end)

        tab_panel:addTab("Ignore", function()
            current_tab_name = "Ignore"
            triggerbot_menu_window:clearWidgets()
            render_ignore_tab_widgets()
            triggerbot_menu_window.height = triggerbot_menu_window:calculateHeight()
        end)

        tab_panel:addTab("Settings", function()
            current_tab_name = "Settings"
            triggerbot_menu_window:clearWidgets()
            render_settings_tab_widgets()
            triggerbot_menu_window.height = triggerbot_menu_window:calculateHeight()
        end)
    end

    local selected_tab = tab_panel.currentTab or current_tab_name
    if tab_panel.tabs[selected_tab] then
        tab_panel:selectTab(selected_tab)
    elseif tab_panel.tabs["Main"] then
        tab_panel:selectTab("Main")
    end
end

local function initialize_triggerbot_menu()
    if not menu or triggerbot_menu_window then
        return
    end

    triggerbot_menu_window = menu.createWindow("Triggerbot v1.2 //NoStir", {
        x = 50,
        y = 50,
        width = 390,
        desiredItems = 12,
    })
end

local function handle_menu_interaction()
    if not menu then
        return
    end

    local lmaobox_menu_is_open_now = gui.IsMenuOpen()
    if triggerbot_settings.keep_gui_open_independent then
        if not triggerbot_menu_window then
            initialize_triggerbot_menu()
        end

        if triggerbot_menu_window and not triggerbot_menu_window.isOpen then
            triggerbot_menu_window:focus()
            update_triggerbot_menu_tabs()
        end

        return
    end

    if lmaobox_menu_is_open_now then
        if not triggerbot_menu_window then
            initialize_triggerbot_menu()
        end

        if triggerbot_menu_window and not triggerbot_menu_window.isOpen then
            triggerbot_menu_window:focus()
            update_triggerbot_menu_tabs()
        end
    elseif triggerbot_menu_window and triggerbot_menu_window.isOpen then
        triggerbot_menu_window:unfocus()
    end
end

local function on_create_move(cmd)
    local me = entities.GetLocalPlayer()
    if not me or not me:IsValid() or not me:IsAlive() then
        last_zoomed_state = false
        return
    end

    local currently_zoomed = me:InCond(TFCond_Zoomed)
    if currently_zoomed and not last_zoomed_state then
        time_zoomed_in = globals.RealTime()
    end
    last_zoomed_state = currently_zoomed

    if not triggerbot_settings.enabled then
        return
    end

    local active_weapon = me:GetPropEntity("m_hActiveWeapon")
    if not active_weapon or not active_weapon:IsValid() or not active_weapon:IsShootingWeapon() then
        return
    end

    if triggerbot_settings.trigger_key_enabled then
        local trigger_key_code = gui.GetValue("Trigger Shoot Key")
        if not E_ButtonCode
            or type(trigger_key_code) ~= "number"
            or trigger_key_code == E_ButtonCode.KEY_NONE
            or not input.IsButtonDown(trigger_key_code)
        then
            return
        end
    end

    if triggerbot_settings.zoomed_only and not currently_zoomed then
        return
    end

    local eye_position = me:GetAbsOrigin()
    local view_offset = me:GetPropVector("localdata", "m_vecViewOffset[0]")
    if not eye_position or not view_offset then
        return
    end

    eye_position = eye_position + view_offset
    if triggerbot_settings.apply_trace_z_offset then
        eye_position.z = eye_position.z + Z_AXIS_OFFSET_VALUE
    end

    local trace_end = eye_position + cmd.viewangles:Forward() * triggerbot_settings.trace_range

    trace_ignore_entity = me
    local trace = engine.TraceLine(eye_position, trace_end, TRACE_MASK, trigger_trace_filter)
    trace_ignore_entity = nil

    if not trace or not trace.entity or not trace.entity:IsValid() then
        return
    end

    local target = trace.entity
    if target:GetClass() ~= "CTFPlayer"
        or not target:IsAlive()
        or target:IsDormant()
        or target:GetTeamNumber() == me:GetTeamNumber()
    then
        return
    end

    local target_team = target:GetTeamNumber()
    if target_team ~= E_TeamNumber.TEAM_RED and target_team ~= E_TeamNumber.TEAM_BLU then
        return
    end

    if should_ignore_target(target) then
        return
    end

    local hitgroup = trace.hitgroup
    local should_fire = false

    if triggerbot_settings.target_head_only then
        if hitgroup == 1 then
            if not triggerbot_settings.sniper_headshot_delay_enabled
                or not currently_zoomed
                or globals.RealTime() - time_zoomed_in >= SNIPER_HEADSHOT_DELAY_TIME
            then
                should_fire = true
            end
        end
    else
        should_fire = hitgroup ~= nil
    end

    if should_fire then
        cmd.buttons = cmd.buttons | IN_ATTACK
    end
end

local function on_draw()
    handle_menu_interaction()
    sync_builtin_triggerbot()

    if not triggerbot_settings.show_status_overlay or not indicator_font then
        return
    end

    local screen_w, screen_h = draw.GetScreenSize()
    if not screen_w or not screen_h then
        return
    end

    local draw_x = round_for_draw(screen_w * indicator_screen_pos.x_ratio)
    local draw_y = round_for_draw(screen_h * indicator_screen_pos.y_ratio)

    draw.SetFont(indicator_font)

    local status_text = "Trigger: "
    if triggerbot_settings.enabled then
        draw.Color(0, 255, 0, 255)
        status_text = status_text .. "ON"

        if triggerbot_settings.trigger_key_enabled then
            status_text = status_text .. " (Key)"
        end

        if triggerbot_settings.target_head_only then
            status_text = status_text .. " (Head)"
            if triggerbot_settings.sniper_headshot_delay_enabled then
                status_text = status_text .. " (HS Delay)"
            end
        else
            status_text = status_text .. " (Body)"
        end

        if triggerbot_settings.zoomed_only then
            status_text = status_text .. " (Zoomed)"
        end

        if triggerbot_settings.apply_trace_z_offset then
            status_text = status_text .. " (ZAdj)"
        end
    else
        draw.Color(255, 0, 0, 255)
        status_text = status_text .. "OFF"
    end

    draw.Text(draw_x, draw_y, status_text)
end

load_settings()

callbacks.Register("CreateMove", "TriggerbotCM", on_create_move)
callbacks.Register("Draw", "TriggerbotDraw", on_draw)

initialize_triggerbot_menu()
if triggerbot_menu_window and gui.IsMenuOpen() then
    triggerbot_menu_window:focus()
    update_triggerbot_menu_tabs()
end

if not menu then
    printc(255, 165, 0, 255, "Triggerbot: menu.lua not found, custom GUI window disabled.")
end

print("Lmaobox Triggerbot v1.2 //NoStir loaded. GUI syncs with Lmaobox menu.")
client.ChatPrintf("Lmaobox Triggerbot v1.2 //NoStir loaded. GUI syncs with Lmaobox menu.")

callbacks.Register("Unload", "TriggerbotUnload", function()
    save_settings()
    restore_builtin_triggerbot()
    callbacks.Unregister("CreateMove", "TriggerbotCM")
    callbacks.Unregister("Draw", "TriggerbotDraw")

    if menu and triggerbot_menu_window and menu.closeAll then
        menu.closeAll()
    end

    triggerbot_menu_window = nil
    print("Lmaobox Triggerbot v1.2 //NoStir unloaded. Settings saved.")
end)
