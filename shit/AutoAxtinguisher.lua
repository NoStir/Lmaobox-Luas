--[[
    Axtinguisher Assist

    Description:
    When the configured key is pressed, this script checks if you are a Pyro
    with the Axtinguisher equipped. If so, it scans for nearby enemies who
    are on fire. If a valid target is found, it automatically switches to
    your melee weapon.

    How to Use:
    1. Save this file and load it in-game with `lua_load axtinguisher_assist.lua`.
    2. Change the `KEYBIND` variable below to your desired key.
    3. Press the key in-game when near a burning enemy.
]]

-- ========= CONFIGURATION =========

local KEYBIND = MOUSE_4
local ACTIVATION_RANGE = 300.0

local AXTINGUISHER_DEF_INDEXES = {
    [38] = true,
    [457] = true,
}

-- ========= SCRIPT LOGIC =========

local original_aim_key
local original_auto_shoot
local melee_assist_active = false

local function is_valid_local_pyro(player)
    return player
        and player:IsValid()
        and player:IsAlive()
        and player:GetPropInt("m_iClass") == TF2_Pyro
end

local function get_equipped_axtinguisher(player)
    if not is_valid_local_pyro(player) then
        return nil
    end

    local melee_weapon = player:GetEntityForLoadoutSlot(LOADOUT_POSITION_MELEE)
    if not melee_weapon or not melee_weapon:IsValid() then
        return nil
    end

    local def_index = melee_weapon:GetPropInt("m_iItemDefinitionIndex")
    if not AXTINGUISHER_DEF_INDEXES[def_index] then
        return nil
    end

    return melee_weapon
end

local function apply_melee_assist()
    if melee_assist_active then
        return
    end

    original_aim_key = gui.GetValue("aim key")
    original_auto_shoot = gui.GetValue("auto shoot")

    gui.SetValue("aim key", 0)
    gui.SetValue("auto shoot", 1)

    melee_assist_active = true
end

local function restore_melee_assist()
    if not melee_assist_active then
        return
    end

    if original_aim_key ~= nil then
        gui.SetValue("aim key", original_aim_key)
    end

    if original_auto_shoot ~= nil then
        gui.SetValue("auto shoot", original_auto_shoot)
    end

    melee_assist_active = false
end

local function on_create_move(cmd)
    if not input.IsButtonDown(KEYBIND) then
        return
    end

    local me = entities.GetLocalPlayer()
    local melee_weapon = get_equipped_axtinguisher(me)
    if not melee_weapon then
        return
    end

    local my_pos = me:GetAbsOrigin()
    if not my_pos then
        return
    end

    local my_team = me:GetTeamNumber()
    local melee_index = melee_weapon:GetIndex()
    local active_weapon = me:GetPropEntity("m_hActiveWeapon")
    local active_weapon_index = active_weapon and active_weapon:GetIndex() or nil

    for _, player in ipairs(entities.FindByClass("CTFPlayer")) do
        if player ~= me
            and player:IsValid()
            and player:IsAlive()
            and not player:IsDormant()
            and player:GetTeamNumber() ~= my_team
            and player:InCond(TFCond_OnFire)
        then
            local enemy_pos = player:GetAbsOrigin()
            if enemy_pos and (my_pos - enemy_pos):Length() <= ACTIVATION_RANGE then
                if active_weapon_index ~= melee_index then
                    cmd.weaponselect = melee_index
                end
                return
            end
        end
    end
end

local function update_melee_assist_state()
    local me = entities.GetLocalPlayer()
    local melee_weapon = get_equipped_axtinguisher(me)
    if not melee_weapon then
        restore_melee_assist()
        return
    end

    local active_weapon = me:GetPropEntity("m_hActiveWeapon")
    if active_weapon
        and active_weapon:IsValid()
        and active_weapon:GetIndex() == melee_weapon:GetIndex()
    then
        apply_melee_assist()
        return
    end

    restore_melee_assist()
end

callbacks.Register("CreateMove", "AxtinguisherAssist", on_create_move)
callbacks.Register("Draw", "AxtinguisherAssistState", update_melee_assist_state)
callbacks.Register("Unload", "AxtinguisherAssistUnload", restore_melee_assist)

printc(0, 255, 0, 255, "Axtinguisher Assist loaded.")
