--[[
    Lmaobox Triggerbot Script with GUI
    Release Version v1.2
    By:
    [GitHub] NoStir
    [Discord] purrspire
    [Lmaobox Forums] TimLeary
    Automatically fires when the crosshair is over an enemy.
    GUI allows toggling, adjusting trace range, head/body targeting, zoomed_only, Z-offset,
    trigger key requirement, sniper headshot delay, and ignoring enemies based on conditions.

    Requires menu.lua by compuserscripts
    https://github.com/compuserscripts/lmaomenu/blob/main/menu.lua

    Update log:
    v1.0 - Initial release
    v1.1 - Increased default trace distance, set max trace distance to E_TraceLine.MAX_TRACE_LENGTH
    v1.2 - Added automatic loading/saving of user settings to a config file,
         - Fixed sniper headshot delay logic to only apply when zoomed
         - Removed GUI toggle hotkey feature, now syncs with Lmaobox menu
         - Added Reset to Default button

]]

--[[
    Lmaobox Triggerbot Script with GUI, Settings Persistence.
    GUI syncs with Lmaobox main menu (gui.IsMenuOpen()).
    Includes option to toggle status overlay.
]]

local menu = require("menu")

local CONFIG_FILE_NAME = "triggerbot_settings.cfg"

-- Default settings values
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
    show_status_overlay = true -- New: Toggle for the status text
}

-- Settings Table
local triggerbot_settings = {}
for k, v in pairs(default_triggerbot_settings) do
    triggerbot_settings[k] = v
end

-- Constants
local MAX_TRACE_RANGE = E_TraceLine.MAX_TRACE_LENGTH
local MIN_TRACE_RANGE = 1
local Z_AXIS_OFFSET_VALUE = 0.1
local SNIPER_HEADSHOT_DELAY_TIME = 0.2

local last_zoomed_state = false
local time_zoomed_in = 0

local UBER_CONDITIONS = {
    TFCond_Ubercharged, TFCond_UberchargeFading, TFCond_UberchargedHidden,
    TFCond_UberchargedCanteen, TFCond_UberchargedOnTakeDamage
}
local BUFF_BANNER_CONDITIONS = {
    TFCond_DefenseBuffNoCritBlock, TFCond_DefenseBuffed
}

local triggerbot_menu_window = nil
local current_tab_name = "Main"

local indicator_font = draw.CreateFont("Verdana", 18, 500, FONTFLAG_OUTLINE)
local indicator_screen_pos = {x_ratio = 0.03, y_ratio = 0.03}

local keyCodeToNameMap = {}
if E_ButtonCode and type(E_ButtonCode) == "table" then
    for keyName, keyCode in pairs(E_ButtonCode) do
        if type(keyCode) == "number" then keyCodeToNameMap[keyCode] = keyName end
    end
else
    printc(255,100,100,255, "Error: E_ButtonCode table not defined.")
end

function GetKeyCodeName(inputCode)
    if not E_ButtonCode or next(keyCodeToNameMap) == nil then return "KeyMap N/A" end
    local numCode = tonumber(inputCode)
    if numCode == nil then return type(inputCode) == "string" and ("Inv:\"" .. inputCode .. "\"") or "Invalid" end
    return keyCodeToNameMap[numCode] or ("Unk:" .. tostring(numCode))
end

function save_settings()
    local file, err = io.open(CONFIG_FILE_NAME, "w")
    if not file then
        printc(255,100,100,255, "Save Error: " .. (err or "Unknown"))
        return
    end
    for key, value in pairs(triggerbot_settings) do
        local line
        if type(value) == "boolean" then line = key .. "=" .. (value and "true" or "false") .. "\n"
        elseif type(value) == "number" then line = key .. "=" .. tostring(value) .. "\n"
        end
        if line then file:write(line) end
    end
    file:close()
end

function load_settings()
    local file, err = io.open(CONFIG_FILE_NAME, "r")
    if not file then
        if err then printc(255,165,0,255, "Config not found or error: " .. err .. ". Using defaults.") end
        return
    end
    for line in file:lines() do
        local key, value_str = line:match("([^=]+)=(.*)")
        if key and value_str and triggerbot_settings[key] ~= nil then
            local current_type = type(triggerbot_settings[key])
            if current_type == "boolean" then triggerbot_settings[key] = (value_str == "true")
            elseif current_type == "number" then
                local num_val = tonumber(value_str)
                if num_val ~= nil then triggerbot_settings[key] = num_val end
            end
        end
    end
    file:close()
    printc(100,255,100,255, "Triggerbot settings loaded.")
end
load_settings()

local update_triggerbot_menu_tabs
local render_main_tab_widgets
local render_ignore_tab_widgets
local render_settings_tab_widgets

function render_main_tab_widgets()
    if not triggerbot_menu_window then return end
    triggerbot_menu_window:createCheckbox("Enable Triggerbot", triggerbot_settings.enabled, function(checked)
        triggerbot_settings.enabled = checked; save_settings()
        client.ChatPrintf(checked and "\x0700FF00Trigger Bot On" or "\x07FF0000Trigger Bot Off")
    end)
    triggerbot_menu_window:createCheckbox("Use Lmaobox Trigger Key [" .. (GetKeyCodeName(gui.GetValue("Trigger Shoot Key") or "N/A") .. "]"), triggerbot_settings.trigger_key_enabled, function(checked)
        triggerbot_settings.trigger_key_enabled = checked; save_settings()
        client.ChatPrintf(checked and "\x0700FF00Lmaobox Trigger Sync On" or "\x07FFFF00Lmaobox Trigger Sync Off")
    end)
    triggerbot_menu_window:createCheckbox("Target Head Only", triggerbot_settings.target_head_only, function(checked)
        triggerbot_settings.target_head_only = checked; save_settings()
        client.ChatPrintf(checked and "\x0700FF00Head Only On" or "\x07FFFF00Head Only Off")
    end)
    triggerbot_menu_window:createCheckbox("Zoomed Only", triggerbot_settings.zoomed_only, function(checked)
        triggerbot_settings.zoomed_only = checked; save_settings()
        client.ChatPrintf(checked and "\x0700FF00Zoomed Only On" or "\x07FFFF00Zoomed Only Off")
    end)
    triggerbot_menu_window:createCheckbox("(Zoomed) Wait For Headshot", triggerbot_settings.sniper_headshot_delay_enabled, function(checked)
        triggerbot_settings.sniper_headshot_delay_enabled = checked; save_settings()
        client.ChatPrintf(checked and "\x0700FF00Headshot Delay On" or "\x07FFFF00Headshot Delay Off")
    end)
    triggerbot_menu_window:createCheckbox("Adjust Trace Z-Offset", triggerbot_settings.apply_trace_z_offset, function(checked)
        triggerbot_settings.apply_trace_z_offset = checked; save_settings()
        client.ChatPrintf(checked and "\x0700FF00Z-Adjust On" or "\x07FFFF00Z-Adjust Off")
    end)
    local z_desc = {{text = string.format("     ^ Adjusts trace Z-offset", Z_AXIS_OFFSET_VALUE)}, {text = "(Helps misfiring on top edge of head)"}, {text = string.rep("=", 27)}}
    triggerbot_menu_window:createList(z_desc, nil)
    triggerbot_menu_window:createSlider("Trace Range", triggerbot_settings.trace_range, MIN_TRACE_RANGE, MAX_TRACE_RANGE, function(value)
        triggerbot_settings.trace_range = math.floor(value); save_settings()
    end)
end

function render_ignore_tab_widgets()
    if not triggerbot_menu_window then return end
    local map = {
        {"Ignore Ubered", "ignore_ubered_enemies", "Ignoring Ubered", "Targeting Ubered"},
        {"Ignore Bullet Resist", "ignore_bullet_resist_enemies", "Ignoring BulletRes", "Targeting BulletRes"},
        {"Ignore Bonked", "ignore_bonked_enemies", "Ignoring Bonked", "Targeting Bonked"},
        {"Ignore Buff Banner", "ignore_buff_banner_enemies", "Ignoring BuffBanner", "Targeting BuffBanner"},
        {"Ignore Cloaked", "ignore_cloaked_enemies", "Ignoring Cloaked", "Targeting Cloaked"},
        {"Ignore Disguised", "ignore_disguised_enemies", "Ignoring Disguised", "Targeting Disguised"},
        {"Ignore Dead Ringer", "ignore_deadringer_enemies", "Ignoring DeadRinger", "Targeting DeadRinger"}
    }
    for _, s in ipairs(map) do
        local l, k, t, f = table.unpack(s)
        triggerbot_menu_window:createCheckbox(l, triggerbot_settings[k], function(c)
            triggerbot_settings[k] = c; save_settings()
            client.ChatPrintf(c and ("\x07FF0000"..t) or ("\x0700FF00"..f))
        end)
    end
end

function render_settings_tab_widgets()
    if not triggerbot_menu_window then return end

    -- Toggle for Status Overlay
    triggerbot_menu_window:createCheckbox("Show Status Overlay", triggerbot_settings.show_status_overlay, function(checked)
        triggerbot_settings.show_status_overlay = checked; save_settings()
        client.ChatPrintf(checked and "\x0700FF00Status Overlay: ON" or "\x07FF0000Status Overlay: OFF")
    end)

    triggerbot_menu_window:createButton("Reset All Settings to Default", function()
        for key, value in pairs(default_triggerbot_settings) do
            triggerbot_settings[key] = value
        end
        save_settings()
        client.ChatPrintf("\x0700FF00All settings reset to defaults.")
        if triggerbot_menu_window and triggerbot_menu_window.isOpen then
            local tabPanel = triggerbot_menu_window._tabPanel
            if tabPanel and tabPanel.tabs[current_tab_name] then
                triggerbot_menu_window:clearWidgets()
                tabPanel.tabs[current_tab_name]()
                triggerbot_menu_window.height = triggerbot_menu_window:calculateHeight()
            else
                update_triggerbot_menu_tabs()
            end
        end
    end)

    local desc_items = {
        {text = "Lmaobox Triggerbot v1.2 //NoStir"}, -- Kept your version
        {text = "[GitHub]: NoStir"},
        {text = "[Discord]: purrspire"},
        {text = "[Lmaobox Forums]: TimLeary"},
        {text = "Settings are saved to " .. CONFIG_FILE_NAME}
    }
    triggerbot_menu_window:createList(desc_items, nil)
end

function update_triggerbot_menu_tabs()
    if not triggerbot_menu_window or not triggerbot_menu_window.isOpen then return end
    local tabPanel = triggerbot_menu_window:renderTabPanel()
    if #tabPanel.tabOrder == 0 then
        tabPanel:addTab("Main", function()
            current_tab_name = "Main"; triggerbot_menu_window:clearWidgets()
            render_main_tab_widgets(); triggerbot_menu_window.height = triggerbot_menu_window:calculateHeight()
        end)
        tabPanel:addTab("Ignore", function()
            current_tab_name = "Ignore"; triggerbot_menu_window:clearWidgets()
            render_ignore_tab_widgets(); triggerbot_menu_window.height = triggerbot_menu_window:calculateHeight()
        end)
        tabPanel:addTab("Settings", function()
            current_tab_name = "Settings"; triggerbot_menu_window:clearWidgets()
            render_settings_tab_widgets(); triggerbot_menu_window.height = triggerbot_menu_window:calculateHeight()
        end)

        if tabPanel.currentTab == nil and tabPanel.tabs["Main"] then
            tabPanel:selectTab("Main")
        elseif tabPanel.tabs[tabPanel.currentTab or "Main"] then
             tabPanel.tabs[tabPanel.currentTab or "Main"]()
        end
    end
end

local function initialize_triggerbot_menu()
    if triggerbot_menu_window then return end
    triggerbot_menu_window = menu.createWindow("Triggerbot v1.2 //NoStir", { -- Kept your version
        x = 50, y = 50, width = 390,
        desiredItems = 12 -- Main tab is likely largest
    })
end

local function handle_menu_interaction()
    local lmaobox_menu_is_open_now = gui.IsMenuOpen()
    if lmaobox_menu_is_open_now then
        if not triggerbot_menu_window then initialize_triggerbot_menu() end
        if triggerbot_menu_window and not triggerbot_menu_window.isOpen then
            triggerbot_menu_window:focus(); update_triggerbot_menu_tabs()
        end
    else
        if triggerbot_menu_window and triggerbot_menu_window.isOpen then
            triggerbot_menu_window:unfocus()
        end
    end
end

local function round_for_draw(num) return math.floor(num + 0.5) end
local function is_entity_ubered(entity)
    if not entity or not entity:IsValid() then return false end
    for _, cond in ipairs(UBER_CONDITIONS) do if entity:InCond(cond) then return true end end; return false
end
local function is_entity_buff_bannered(entity)
    if not entity or not entity:IsValid() then return false end
    for _, cond in ipairs(BUFF_BANNER_CONDITIONS) do if entity:InCond(cond) then return true end end; return false
end

local function on_create_move(cmd)
    local me = entities.GetLocalPlayer()
    if not me or not me:IsValid() or not me:IsAlive() then return end
    local currently_zoomed = me:InCond(TFCond_Zoomed)
    if currently_zoomed and not last_zoomed_state then time_zoomed_in = globals.RealTime() end
    last_zoomed_state = currently_zoomed
    if not triggerbot_settings.enabled then return end
    if triggerbot_settings.trigger_key_enabled then
        local tkc = gui.GetValue("Trigger Shoot Key")
        if type(tkc) ~= "number" or tkc == E_ButtonCode.KEY_NONE or not input.IsButtonDown(tkc) then return end
    end
    if triggerbot_settings.zoomed_only and not currently_zoomed then return end
    local ep_val; local es, pr = pcall(function() return me:GetAbsOrigin()+me:GetPropVector("localdata","m_vecViewOffset[0]") end)
    if not es or pr == nil then return end; ep_val = pr
    if triggerbot_settings.apply_trace_z_offset then ep_val.z = ep_val.z + Z_AXIS_OFFSET_VALUE end
    local va = cmd.viewangles; local te_pos = ep_val + va:Forward() * triggerbot_settings.trace_range
    local function tff(e,c) return e~=me end
    local tr_val; local ts,ptr=pcall(engine.TraceLine,ep_val,te_pos,MASK_ALL,tff)
    if not ts or ptr==nil then return end; tr_val=ptr
    if tr_val.entity and tr_val.entity:IsValid() then
        local t_ent=tr_val.entity
        if t_ent:GetClass()=="CTFPlayer" and t_ent:IsAlive() and not t_ent:IsDormant() and
           t_ent:GetTeamNumber()~=me:GetTeamNumber() and
           (t_ent:GetTeamNumber()==E_TeamNumber.TEAM_RED or t_ent:GetTeamNumber()==E_TeamNumber.TEAM_BLU) then
            if triggerbot_settings.ignore_ubered_enemies and is_entity_ubered(t_ent) then return end
            if triggerbot_settings.ignore_bullet_resist_enemies and t_ent:InCond(TFCond_UberBulletResist) then return end
            if triggerbot_settings.ignore_bonked_enemies and t_ent:InCond(TFCond_Bonked) then return end
            if triggerbot_settings.ignore_buff_banner_enemies and is_entity_buff_bannered(t_ent) then return end
            if triggerbot_settings.ignore_cloaked_enemies and t_ent:InCond(TFCond_Cloaked) then return end
            if triggerbot_settings.ignore_disguised_enemies and t_ent:InCond(TFCond_Disguised) then return end
            if triggerbot_settings.ignore_deadringer_enemies and t_ent:InCond(TFCond_DeadRingered) then return end
            local aw=me:GetPropEntity("m_hActiveWeapon")
            if aw and aw:IsValid() and aw:IsShootingWeapon() then
                local sf=false; local hg=tr_val.hitgroup
                if triggerbot_settings.target_head_only then
                    if hg==1 then
                        if triggerbot_settings.sniper_headshot_delay_enabled then
                            if currently_zoomed then
                                if(globals.RealTime()-time_zoomed_in>=SNIPER_HEADSHOT_DELAY_TIME)then sf=true end
                            else sf=true end
                        else sf=true end
                    end
                else if hg~=nil and hg~=1 then sf=true end end
                if sf then cmd.buttons=cmd.buttons|IN_ATTACK end
            end
        end
    end
end

local function on_draw()
    handle_menu_interaction()

    -- Only draw the overlay if the setting is enabled
    if not triggerbot_settings.show_status_overlay then
        -- If overlay is off, but triggerbot is on, we might still want to disable Lmaobox's internal one
        if triggerbot_settings.enabled and gui.GetValue("Trigger Shoot") == 1 then
            gui.SetValue("Trigger Shoot", 0)
        end
        return
    end

    if not indicator_font then return end
    local screen_w, screen_h = draw.GetScreenSize()
    if not screen_w or not screen_h then return end
    local draw_x = round_for_draw(screen_w * indicator_screen_pos.x_ratio)
    local draw_y = round_for_draw(screen_h * indicator_screen_pos.y_ratio)

    draw.SetFont(indicator_font); local itxt="Trigger: "
    if triggerbot_settings.enabled then
        if gui.GetValue("Trigger Shoot")==1 then gui.SetValue("Trigger Shoot",0) end
        draw.Color(0,255,0,255); itxt=itxt.."ON"
        if triggerbot_settings.trigger_key_enabled then itxt=itxt.." (Key)" end
        if triggerbot_settings.target_head_only then
            itxt=itxt.." (Head)"; if triggerbot_settings.sniper_headshot_delay_enabled then itxt=itxt.." (HS Delay)" end
        else itxt=itxt.." (Body)" end
        if triggerbot_settings.zoomed_only then itxt=itxt.." (Zoomed)" end
        if triggerbot_settings.apply_trace_z_offset then itxt=itxt.." (ZAdj)" end
    else draw.Color(255,0,0,255); itxt=itxt.."OFF" end
    draw.Text(draw_x,draw_y,itxt)
end

callbacks.Register("CreateMove","TriggerbotCM",on_create_move)
callbacks.Register("Draw","TriggerbotDraw",on_draw)

initialize_triggerbot_menu()
if triggerbot_menu_window and gui.IsMenuOpen() then
    triggerbot_menu_window:focus(); update_triggerbot_menu_tabs()
end

print("Lmaobox Triggerbot v1.2 //NoStir loaded. GUI syncs with Lmaobox menu.") -- Kept your version
client.ChatPrintf("Lmaobox Triggerbot v1.2 //NoStir loaded. GUI syncs with Lmaobox menu.") -- Kept your version

callbacks.Register("Unload","TriggerbotUnload",function()
    save_settings()
    callbacks.Unregister("CreateMove","TriggerbotCM"); callbacks.Unregister("Draw","TriggerbotDraw")
    if triggerbot_menu_window then menu.closeAll(); triggerbot_menu_window=nil end
    print("Lmaobox Triggerbot v1.2 //NoStir unloaded. Settings saved.") -- Kept your version
end)