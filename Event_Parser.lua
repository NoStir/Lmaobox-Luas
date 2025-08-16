--[[
    Lmaobox Lua - Enhanced Game Event Listener (Colored Output - Corrected v3)

    Listens for game events fired by the engine/server and prints their names
    and parameters to the developer console with colors for readability.
    Attempts to resolve common IDs (player, entity, weapon, team, class)
    into human-readable names. Differentiates between weaponid and weapon_def_index.

    Instructions:
    1. Place this file in your %localappdata% folder.
    2. Load it in TF2 using the console command: lua_load your_script_name.lua
    3. Open the developer console (`~`) to view the event logs.
]]

-- Color Definitions (RGB)
local COLOR_EVENT_NAME = { 0, 200, 255 }     -- Cyan
local COLOR_PARAM_INFO = { 100, 255, 100 }    -- Light Green
local COLOR_VALUE = { 255, 255, 255 }       -- White
local COLOR_RESOLVED = { 255, 255, 150 }   -- Light Yellow
local COLOR_UNKNOWN = { 255, 165, 0 }      -- Orange
local COLOR_INFO = { 150, 255, 150 }       -- Pale Green (for load/unload)
local COLOR_ERROR = { 255, 100, 100 }      -- Light Red

-- Define known event parameters and their types
-- (eventParameters table remains the same as before)
local eventParameters = {
    ["achievement_earned"] = { { name = "player", type = "byte" }, { name = "achievement", type = "short" } },
    ["achievement_earned_local"] = { { name = "achievement", type = "short" } },
    ["achievement_event"] = { { name = "achievement_name", type = "string" }, { name = "cur_val", type = "short" }, { name = "max_val", type = "short" } },
    ["achievement_increment"] = { { name = "achievement_id", type = "long" }, { name = "cur_val", type = "short" }, { name = "max_val", type = "short" } },
    ["air_dash"] = { { name = "player", type = "byte" } },
    ["ammo_pickup"] = { { name = "ammo_index", type = "long" }, { name = "amount", type = "long" }, { name = "total", type = "long" } },
    ["arena_match_maxstreak"] = { { name = "team", type = "byte" }, { name = "streak", type = "byte" } },
    ["arena_player_notification"] = { { name = "player", type = "byte" }, { name = "message", type = "byte" } },
    ["arena_round_start"] = {},
    ["arena_win_panel"] = { { name = "panel_style", type = "byte" }, { name = "winning_team", type = "byte" }, { name = "winreason", type = "byte" }, { name = "cappers", type = "string" }, { name = "flagcaplimit", type = "short" }, { name = "blue_score", type = "short" }, { name = "red_score", type = "short" }, { name = "blue_score_prev", type = "short" }, { name = "red_score_prev", type = "short" }, { name = "round_complete", type = "short" }, { name = "player_1", type = "short" }, { name = "player_1_damage", type = "short" }, { name = "player_1_healing", type = "short" }, { name = "player_1_lifetime", type = "short" }, { name = "player_1_kills", type = "short" }, { name = "player_2", type = "short" }, { name = "player_2_damage", type = "short" }, { name = "player_2_healing", type = "short" }, { name = "player_2_lifetime", type = "short" }, { name = "player_2_kills", type = "short" }, { name = "player_3", type = "short" }, { name = "player_3_damage", type = "short" }, { name = "player_3_healing", type = "short" }, { name = "player_3_lifetime", type = "short" }, { name = "player_3_kills", type = "short" }, { name = "player_4", type = "short" }, { name = "player_4_damage", type = "short" }, { name = "player_4_healing", type = "short" }, { name = "player_4_lifetime", type = "short" }, { name = "player_4_kills", type = "short" }, { name = "player_5", type = "short" }, { name = "player_5_damage", type = "short" }, { name = "player_5_healing", type = "short" }, { name = "player_5_lifetime", type = "short" }, { name = "player_5_kills", type = "short" }, { name = "player_6", type = "short" }, { name = "player_6_damage", type = "short" }, { name = "player_6_healing", type = "short" }, { name = "player_6_lifetime", type = "short" }, { name = "player_6_kills", type = "short" } },
    ["arrow_impact"] = { { name = "attachedEntity", type = "short" }, { name = "shooter", type = "short" }, { name = "boneIndexAttached", type = "short" }, { name = "bonePositionX", type = "float" }, { name = "bonePositionY", type = "float" }, { name = "bonePositionZ", type = "float" }, { name = "boneAnglesX", type = "float" }, { name = "boneAnglesY", type = "float" }, { name = "boneAnglesZ", type = "float" }, { name = "projectileType", type = "short" }, { name = "isCrit", type = "bool" } },
    ["base_player_teleported"] = { { name = "entindex", type = "short" } },
    ["bonus_updated"] = { { name = "numadvanced", type = "short" }, { name = "numbronze", type = "short" }, { name = "numsilver", type = "short" }, { name = "numgold", type = "short" } },
    ["break_breakable"] = { { name = "entindex", type = "long" }, { name = "userid", type = "short" }, { name = "material", type = "byte" } },
    ["break_prop"] = { { name = "entindex", type = "long" }, { name = "userid", type = "short" } },
    ["browse_replays"] = { { name = "userid", type = "short" } },
    ["building_healed"] = { { name = "building", type = "short" }, { name = "healer", type = "short" }, { name = "amount", type = "short" } },
    ["building_info_changed"] = { { name = "building_type", type = "byte" }, { name = "object_mode", type = "byte" }, { name = "remove", type = "byte" } },
    ["cart_updated"] = {},
    ["christmas_gift_grab"] = { { name = "userid", type = "short" } },
    ["cl_drawline"] = { { name = "player", type = "byte" }, { name = "panel", type = "byte" }, { name = "line", type = "byte" }, { name = "x", type = "float" }, { name = "y", type = "float" } },
    ["client_beginconnect"] = { { name = "address", type = "string" }, { name = "ip", type = "long" }, { name = "port", type = "short" }, { name = "source", type = "string" } },
    ["client_connected"] = { { name = "address", type = "string" }, { name = "ip", type = "long" }, { name = "port", type = "short" } },
    ["client_disconnect"] = { { name = "message", type = "string" } },
    ["client_fullconnect"] = { { name = "address", type = "string" }, { name = "ip", type = "long" }, { name = "port", type = "short" } },
    ["competitive_stats_update"] = { { name = "index", type = "short" }, { name = "kills_rank", type = "byte" }, { name = "score_rank", type = "byte" }, { name = "damage_rank", type = "byte" }, { name = "healing_rank", type = "byte" }, { name = "support_rank", type = "byte" } },
    ["competitive_victory"] = {},
    ["conga_kill"] = { { name = "index", type = "short" } },
    ["controlpoint_endtouch"] = { { name = "player", type = "short" }, { name = "area", type = "short" } },
    ["controlpoint_fake_capture"] = { { name = "player", type = "short" }, { name = "int_data", type = "short" } },
    ["controlpoint_fake_capture_mult"] = { { name = "player", type = "short" }, { name = "int_data", type = "short" } },
    ["controlpoint_initialized"] = {},
    ["controlpoint_pulse_element"] = { { name = "player", type = "short" } },
    ["controlpoint_starttouch"] = { { name = "player", type = "short" }, { name = "area", type = "short" } },
    ["controlpoint_timer_updated"] = { { name = "index", type = "short" }, { name = "time", type = "float" } },
    ["controlpoint_unlock_updated"] = { { name = "index", type = "short" }, { name = "time", type = "float" } },
    ["controlpoint_updatecapping"] = { { name = "index", type = "short" } },
    ["controlpoint_updateimages"] = { { name = "index", type = "short" } },
    ["controlpoint_updatelayout"] = { { name = "index", type = "short" } },
    ["controlpoint_updateowner"] = { { name = "index", type = "short" } },
    ["cross_spectral_bridge"] = { { name = "player", type = "short" } },
    ["crossbow_heal"] = { { name = "healer", type = "byte" }, { name = "target", type = "byte" }, { name = "amount", type = "short" } },
    ["ctf_flag_captured"] = { { name = "capping_team", type = "short" }, { name = "capping_team_score", type = "short" } },
    ["damage_mitigated"] = { { name = "mitigator", type = "byte" }, { name = "damaged", type = "byte" }, { name = "amount", type = "short" }, { name = "itemdefindex", type = "short" } },
    ["damage_prevented"] = { { name = "preventor", type = "short" }, { name = "victim", type = "short" }, { name = "amount", type = "short" }, { name = "condition", type = "short" } },
    ["damage_resisted"] = { { name = "entindex", type = "byte" } },
    ["deadringer_cheat_death"] = { { name = "spy", type = "byte" }, { name = "attacker", type = "byte" } },
    ["demoman_det_stickies"] = { { name = "player", type = "short" } },
    ["deploy_buff_banner"] = { { name = "buff_type", type = "byte" }, { name = "buff_owner", type = "short" } },
    ["doomsday_rocket_open"] = { { name = "team", type = "byte" } },
    ["duck_xp_level_up"] = { { name = "level", type = "short" } },
    ["duel_status"] = { { name = "killer", type = "short" }, { name = "score_type", type = "short" }, { name = "initiator", type = "short" }, { name = "target", type = "short" }, { name = "initiator_score", type = "short" }, { name = "target_score", type = "short" } },
    ["econ_inventory_connected"] = {},
    ["enter_vehicle"] = { { name = "vehicle", type = "long" } },
    ["entered_performance_mode"] = {},
    ["entity_killed"] = { { name = "entindex_killed", type = "long" }, { name = "entindex_attacker", type = "long" }, { name = "entindex_inflictor", type = "long" }, { name = "damagebits", type = "long" } },
    ["environmental_death"] = { { name = "killer", type = "byte" }, { name = "victim", type = "byte" } },
    ["escape_hell"] = { { name = "player", type = "short" } },
    ["escaped_loot_island"] = { { name = "player", type = "short" } },
    ["escort_progress"] = { { name = "team", type = "byte" }, { name = "progress", type = "float" }, { name = "reset", type = "bool" } },
    ["escort_recede"] = { { name = "team", type = "byte" }, { name = "recedetime", type = "float" } },
    ["escort_speed"] = { { name = "team", type = "byte" }, { name = "speed", type = "byte" }, { name = "players", type = "byte" } },
    ["eyeball_boss_escape_imminent"] = { { name = "level", type = "short" }, { name = "time_remaining", type = "byte" } },
    ["eyeball_boss_escaped"] = { { name = "level", type = "short" } },
    ["eyeball_boss_killed"] = { { name = "level", type = "short" } },
    ["eyeball_boss_killer"] = { { name = "level", type = "short" }, { name = "player_entindex", type = "byte" } },
    ["eyeball_boss_stunned"] = { { name = "level", type = "short" }, { name = "player_entindex", type = "byte" } },
    ["eyeball_boss_summoned"] = { { name = "level", type = "short" } },
    ["fish_notice"] = { { name = "userid", type = "short" }, { name = "victim_entindex", type = "long" }, { name = "inflictor_entindex", type = "long" }, { name = "attacker", type = "short" }, { name = "weapon", type = "string" }, { name = "weaponid", type = "short" }, { name = "damagebits", type = "long" }, { name = "customkill", type = "short" }, { name = "assister", type = "short" }, { name = "weapon_logclassname", type = "string" }, { name = "stun_flags", type = "short" }, { name = "death_flags", type = "short" }, { name = "silent_kill", type = "bool" }, { name = "assister_fallback", type = "string" } },
    ["fish_notice__arm"] = { { name = "userid", type = "short" }, { name = "victim_entindex", type = "long" }, { name = "inflictor_entindex", type = "long" }, { name = "attacker", type = "short" }, { name = "weapon", type = "string" }, { name = "weaponid", type = "short" }, { name = "damagebits", type = "long" }, { name = "customkill", type = "short" }, { name = "assister", type = "short" }, { name = "weapon_logclassname", type = "string" }, { name = "stun_flags", type = "short" }, { name = "death_flags", type = "short" }, { name = "silent_kill", type = "bool" }, { name = "assister_fallback", type = "string" } },
    ["flag_carried_in_detection_zone"] = {},
    ["flagstatus_update"] = { { name = "userid", type = "short" }, { name = "entindex", type = "long" } },
    ["flare_ignite_npc"] = { { name = "entindex", type = "long" } },
    ["freezecam_started"] = {},
    ["game_end"] = { { name = "winner", type = "byte" } },
    ["game_init"] = {},
    ["game_message"] = { { name = "target", type = "byte" }, { name = "text", type = "string" } },
    ["game_newmap"] = { { name = "mapname", type = "string" } },
    ["game_start"] = { { name = "roundslimit", type = "long" }, { name = "timelimit", type = "long" }, { name = "fraglimit", type = "long" }, { name = "objective", type = "string" } },
    ["gameui_activate"] = {},
    ["gameui_activated"] = {},
    ["gameui_hidden"] = {},
    ["gameui_hide"] = {},
    ["gc_lost_session"] = {},
    ["gc_new_session"] = {},
    ["halloween_boss_killed"] = { { name = "boss", type = "short" }, { name = "killer", type = "short" } },
    ["halloween_duck_collected"] = { { name = "collector", type = "short" } },
    ["halloween_pumpkin_grab"] = { { name = "userid", type = "short" } },
    ["halloween_skeleton_killed"] = { { name = "player", type = "short" } },
    ["halloween_soul_collected"] = { { name = "intended_target", type = "byte" }, { name = "collecting_player", type = "byte" }, { name = "soul_count", type = "byte" } },
    ["helicopter_grenade_punt_miss"] = {},
    ["hide_annotation"] = { { name = "id", type = "long" } },
    ["hide_freezepanel"] = { { name = "killer", type = "short" } },
    ["hltv_changed_mode"] = { { name = "oldmode", type = "short" }, { name = "newmode", type = "short" }, { name = "obs_target", type = "short" } },
    ["hltv_changed_target"] = { { name = "mode", type = "short" }, { name = "old_target", type = "short" }, { name = "obs_target", type = "short" } },
    ["host_quit"] = {},
    ["intro_finish"] = { { name = "player", type = "short" } },
    ["intro_nextcamera"] = { { name = "player", type = "short" } },
    ["inventory_updated"] = {},
    ["item_found"] = { { name = "player", type = "byte" }, { name = "quality", type = "byte" }, { name = "method", type = "byte" }, { name = "itemdef", type = "long" }, { name = "isstrange", type = "byte" }, { name = "isunusual", type = "byte" }, { name = "wear", type = "float" } },
    ["item_pickup"] = { { name = "userid", type = "short" }, { name = "item", type = "string" } },
    ["item_schema_initialized"] = {},
    ["items_acknowledged"] = { { name = "blocker", type = "short" }, { name = "victim", type = "short" } },
    ["kill_in_hell"] = { { name = "killer", type = "short" }, { name = "victim", type = "short" } },
    ["kill_refills_meter"] = { { name = "index", type = "short" } },
    ["killed_capping_player"] = { { name = "cp", type = "byte" }, { name = "killer", type = "byte" }, { name = "victim", type = "byte" }, { name = "assister", type = "byte" } },
    ["landed"] = { { name = "player", type = "byte" } },
    ["leave_vehicle"] = { { name = "vehicle", type = "long" } },
    ["lobby_updated"] = {},
    ["localplayer_becameobserver"] = {},
    ["localplayer_builtobject"] = { { name = "object", type = "short" }, { name = "object_mode", type = "short" }, { name = "index", type = "short" } },
    ["localplayer_changeclass"] = {},
    ["localplayer_changedisguise"] = { { name = "disguised", type = "bool" } },
    ["localplayer_changeteam"] = {},
    ["localplayer_chargeready"] = {},
    ["localplayer_healed"] = { { name = "amount", type = "short" } },
    ["localplayer_pickup_weapon"] = {},
    ["localplayer_respawn"] = {},
    ["localplayer_score_changed"] = { { name = "score", type = "short" } },
    ["localplayer_winddown"] = {},
    ["mainmenu_stabilized"] = { { name = "attacker", type = "short" }, { name = "victim", type = "short" }, { name = "assister", type = "short" } },
    ["medic_death"] = { { name = "userid", type = "short" }, { name = "attacker", type = "short" }, { name = "healing", type = "short" }, { name = "charged", type = "bool" } },
    ["medic_defended"] = { { name = "userid", type = "short" }, { name = "medic", type = "short" } },
    ["medigun_shield_blocked_damage"] = { { name = "userid", type = "short" }, { name = "damage", type = "float" } },
    ["merasmus_escape_warning"] = { { name = "level", type = "short" }, { name = "time_remaining", type = "byte" } },
    ["merasmus_escaped"] = { { name = "level", type = "short" } },
    ["merasmus_killed"] = { { name = "level", type = "short" } },
    ["merasmus_prop_found"] = { { name = "player", type = "short" } },
    ["merasmus_stunned"] = { { name = "player", type = "short" } },
    ["merasmus_summoned"] = { { name = "level", type = "short" } },
    ["minigame_win"] = { { name = "team", type = "byte" }, { name = "type", type = "byte" } },
    ["minigame_won"] = { { name = "player", type = "short" }, { name = "game", type = "short" } },
    ["mvm_adv_wave_complete_no_gates"] = { { name = "index", type = "short" } },
    ["mvm_adv_wave_killed_stun_radio"] = {},
    ["mvm_begin_wave"] = { { name = "wave_index", type = "short" }, { name = "max_waves", type = "short" }, { name = "advanced", type = "short" } },
    ["mvm_bomb_alarm_triggered"] = {},
    ["mvm_bomb_carrier_killed"] = { { name = "level", type = "short" } },
    ["mvm_bomb_deploy_reset_by_player"] = { { name = "player", type = "short" } },
    ["mvm_bomb_reset_by_player"] = { { name = "player", type = "short" } },
    ["mvm_creditbonus_all"] = {},
    ["mvm_creditbonus_all_advanced"] = {},
    ["mvm_creditbonus_wave"] = {},
    ["mvm_kill_robot_delivering_bomb"] = { { name = "player", type = "short" } },
    ["mvm_mannhattan_pit"] = {},
    ["mvm_medic_powerup_shared"] = { { name = "player", type = "short" } },
    ["mvm_mission_complete"] = { { name = "mission", type = "string" } },
    ["mvm_mission_update"] = { { name = "class", type = "short" }, { name = "count", type = "short" } },
    ["mvm_pickup_currency"] = { { name = "player", type = "short" }, { name = "currency", type = "short" } },
    ["mvm_quick_sentry_upgrade"] = { { name = "player", type = "short" } },
    ["mvm_reset_stats"] = {},
    ["mvm_scout_marked_for_death"] = { { name = "player", type = "short" } },
    ["mvm_sentrybuster_detonate"] = { { name = "player", type = "short" }, { name = "det_x", type = "float" }, { name = "det_y", type = "float" }, { name = "det_z", type = "float" } },
    ["mvm_sentrybuster_killed"] = { { name = "sentry_buster", type = "short" } },
    ["mvm_sniper_headshot_currency"] = { { name = "userid", type = "short" }, { name = "currency", type = "short" } },
    ["mvm_tank_destroyed_by_players"] = {},
    ["mvm_wave_complete"] = { { name = "advanced", type = "bool" } },
    ["mvm_wave_failed"] = {},
    ["nav_blocked"] = { { name = "area", type = "long" }, { name = "blocked", type = "bool" } },
    ["npc_hurt"] = { { name = "entindex", type = "short" }, { name = "health", type = "short" }, { name = "attacker_player", type = "short" }, { name = "weaponid", type = "short" }, { name = "damageamount", type = "short" }, { name = "crit", type = "bool" }, { name = "boss", type = "short" } },
    ["num_cappers_changed"] = { { name = "index", type = "short" }, { name = "count", type = "byte" } },
    ["object_deflected"] = { { name = "userid", type = "short" }, { name = "ownerid", type = "short" }, { name = "weaponid", type = "short" }, { name = "object_entindex", type = "short" } },
    ["object_destroyed"] = { { name = "userid", type = "short" }, { name = "attacker", type = "short" }, { name = "assister", type = "short" }, { name = "weapon", type = "string" }, { name = "weaponid", type = "short" }, { name = "objecttype", type = "short" }, { name = "index", type = "short" }, { name = "was_building", type = "bool" }, { name = "team", type = "short" } },
    ["object_detonated"] = { { name = "userid", type = "short" }, { name = "objecttype", type = "short" }, { name = "index", type = "short" } },
    ["object_removed"] = { { name = "userid", type = "short" }, { name = "objecttype", type = "short" }, { name = "index", type = "short" } },
    ["overtime_nag"] = {},
    ["parachute_deploy"] = { { name = "index", type = "short" } },
    ["parachute_holster"] = { { name = "index", type = "short" } },
    ["party_chat"] = { { name = "steamid", type = "string" }, { name = "text", type = "string" }, { name = "type", type = "short" } },
    ["party_criteria_changed"] = {},
    ["party_invites_changed"] = {},
    ["party_member_join"] = { { name = "steamid", type = "string" } },
    ["party_member_leave"] = { { name = "steamid", type = "string" } },
    ["party_pref_changed"] = {},
    ["party_queue_state_changed"] = { { name = "matchgroup", type = "short" } },
    ["party_updated"] = {},
    ["pass_ball_blocked"] = { { name = "owner", type = "short" }, { name = "blocker", type = "short" } },
    ["pass_ball_stolen"] = { { name = "victim", type = "short" }, { name = "attacker", type = "short" } },
    ["pass_free"] = { { name = "owner", type = "short" }, { name = "attacker", type = "short" } },
    ["pass_get"] = { { name = "owner", type = "short" }, { name = "team", type = "short" } },
    ["pass_pass_caught"] = { { name = "passer", type = "short" }, { name = "catcher", type = "short" }, { name = "dist", type = "float" }, { name = "duration", type = "float" } },
    ["pass_score"] = { { name = "scorer", type = "short" }, { name = "assister", type = "short" }, { name = "points", type = "byte" } },
    ["path_track_passed"] = { { name = "index", type = "short" } },
    ["payload_pushed"] = { { name = "pusher", type = "byte" }, { name = "distance", type = "short" } },
    ["physgun_pickup"] = { { name = "entindex", type = "long" } },
    ["player_abandoned_match"] = { { name = "game_over", type = "bool" } },
    ["player_account_changed"] = { { name = "old_value", type = "short" }, { name = "new_value", type = "short" } },
    ["player_activate"] = { { name = "userid", type = "short" } },
    ["player_askedforball"] = { { name = "userid", type = "short" } },
    ["player_bonuspoints"] = { { name = "points", type = "short" }, { name = "player_entindex", type = "short" }, { name = "source_entindex", type = "short" } },
    ["player_buff"] = { { name = "userid", type = "short" }, { name = "buff_owner", type = "short" }, { name = "buff_type", type = "byte" } },
    ["player_builtobject"] = { { name = "userid", type = "short" }, { name = "object", type = "short" }, { name = "index", type = "short" } },
    ["player_buyback"] = { { name = "player", type = "short" }, { name = "cost", type = "short" } },
    ["player_calledformedic"] = { { name = "userid", type = "short" } },
    ["player_carryobject"] = { { name = "userid", type = "short" }, { name = "object", type = "short" }, { name = "index", type = "short" } },
    ["player_changeclass"] = { { name = "userid", type = "short" }, { name = "class", type = "short" } },
    ["player_changename"] = { { name = "userid", type = "short" }, { name = "oldname", type = "string" }, { name = "newname", type = "string" } },
    ["player_chargedeployed"] = { { name = "userid", type = "short" }, { name = "targetid", type = "short" } },
    ["player_chat"] = { { name = "teamonly", type = "bool" }, { name = "userid", type = "short" }, { name = "text", type = "string" } },
    ["player_class"] = { { name = "userid", type = "short" }, { name = "class", type = "string" } },
    ["player_connect"] = { { name = "name", type = "string" }, { name = "index", type = "byte" }, { name = "userid", type = "short" }, { name = "networkid", type = "string" }, { name = "address", type = "string" }, { name = "bot", type = "short" } },
    ["player_connect_client"] = { { name = "name", type = "string" }, { name = "index", type = "byte" }, { name = "userid", type = "short" }, { name = "networkid", type = "string" }, { name = "bot", type = "short" } },
    ["player_currency_changed"] = { { name = "currency", type = "short" } },
    ["player_damage_dodged"] = { { name = "damage", type = "short" } },
    ["player_damaged"] = { { name = "amount", type = "short" }, { name = "type", type = "long" } },
    ["player_death"] = { { name = "userid", type = "short" }, { name = "victim_entindex", type = "long" }, { name = "inflictor_entindex", type = "long" }, { name = "attacker", type = "short" }, { name = "weapon", type = "string" }, { name = "weaponid", type = "short" }, { name = "damagebits", type = "long" }, { name = "customkill", type = "short" }, { name = "assister", type = "short" }, { name = "weapon_logclassname", type = "string" }, { name = "stun_flags", type = "short" }, { name = "death_flags", type = "short" }, { name = "silent_kill", type = "bool" }, { name = "playerpenetratecount", type = "short" }, { name = "assister_fallback", type = "string" }, { name = "kill_streak_total", type = "short" }, { name = "kill_streak_wep", type = "short" }, { name = "kill_streak_assist", type = "short" }, { name = "kill_streak_victim", type = "short" }, { name = "ducks_streaked", type = "short" }, { name = "duck_streak_total", type = "short" }, { name = "duck_streak_assist", type = "short" }, { name = "duck_streak_victim", type = "short" }, { name = "rocket_jump", type = "bool" }, { name = "weapon_def_index", type = "long" }, { name = "crit_type", type = "short" } },
    ["player_destroyed_pipebomb"] = { { name = "userid", type = "short" } },
    ["player_directhit_stun"] = { { name = "attacker", type = "short" }, { name = "victim", type = "short" } },
    ["player_disconnect"] = { { name = "userid", type = "short" }, { name = "reason", type = "string" }, { name = "name", type = "string" }, { name = "networkid", type = "string" }, { name = "bot", type = "short" } },
    ["player_domination"] = { { name = "dominator", type = "short" }, { name = "dominated", type = "short" }, { name = "dominations", type = "short" } },
    ["player_dropobject"] = { { name = "userid", type = "short" }, { name = "object", type = "short" }, { name = "index", type = "short" } },
    ["player_escort_score"] = { { name = "player", type = "byte" }, { name = "points", type = "byte" } },
    ["player_extinguished"] = { { name = "victim", type = "byte" }, { name = "healer", type = "byte" }, { name = "itemdefindex", type = "short" } },
    ["player_healed"] = { { name = "patient", type = "short" }, { name = "healer", type = "short" }, { name = "amount", type = "short" } },
    ["player_healedbymedic"] = { { name = "medic", type = "byte" } },
    ["player_healedmediccall"] = { { name = "userid", type = "short" } },
    ["player_healonhit"] = { { name = "amount", type = "short" }, { name = "entindex", type = "byte" }, { name = "weapon_def_index", type = "long" } },
    ["player_highfive_cancel"] = { { name = "entindex", type = "byte" } },
    ["player_highfive_start"] = { { name = "entindex", type = "byte" } },
    ["player_highfive_success"] = { { name = "initiator_entindex", type = "byte" }, { name = "partner_entindex", type = "byte" } },
    ["player_hintmessage"] = { { name = "hintmessage", type = "string" } },
    ["player_hurt"] = { { name = "userid", type = "short" }, { name = "health", type = "short" }, { name = "attacker", type = "short" }, { name = "damageamount", type = "short" }, { name = "custom", type = "short" }, { name = "showdisguisedcrit", type = "bool" }, { name = "crit", type = "bool" }, { name = "minicrit", type = "bool" }, { name = "allseecrit", type = "bool" }, { name = "weaponid", type = "short" }, { name = "bonuseffect", type = "byte" } },
    ["player_ignited"] = { { name = "pyro_entindex", type = "byte" }, { name = "victim_entindex", type = "byte" }, { name = "weaponid", type = "byte" } },
    ["player_ignited_inv"] = { { name = "pyro_entindex", type = "byte" }, { name = "victim_entindex", type = "byte" }, { name = "medic_entindex", type = "byte" } },
    ["player_info"] = { { name = "name", type = "string" }, { name = "index", type = "byte" }, { name = "userid", type = "short" }, { name = "networkid", type = "string" }, { name = "bot", type = "bool" } },
    ["player_initial_spawn"] = { { name = "index", type = "short" } },
    ["player_invulned"] = { { name = "userid", type = "short" }, { name = "medic_userid", type = "short" } },
    ["player_jarated"] = { { name = "thrower_entindex", type = "byte" }, { name = "victim_entindex", type = "byte" } },
    ["player_jarated_fade"] = { { name = "thrower_entindex", type = "byte" }, { name = "victim_entindex", type = "byte" } },
    ["player_killed_achievement_zone"] = { { name = "attacker", type = "short" }, { name = "victim", type = "short" }, { name = "zone_id", type = "short" } },
    ["player_mvp"] = { { name = "player", type = "short" } },
    ["player_pinned"] = { { name = "pinned", type = "byte" } },
    ["player_regenerate"] = {},
    ["player_rocketpack_pushed"] = { { name = "pusher", type = "short" }, { name = "pushed", type = "short" } },
    ["player_sapped_object"] = { { name = "userid", type = "short" }, { name = "ownerid", type = "short" }, { name = "object", type = "byte" }, { name = "sapperid", type = "short" } },
    ["player_say"] = { { name = "userid", type = "short" }, { name = "text", type = "string" } },
    ["player_score"] = { { name = "userid", type = "short" }, { name = "kills", type = "short" }, { name = "deaths", type = "short" }, { name = "score", type = "short" } },
    ["player_score_changed"] = { { name = "player", type = "byte" }, { name = "delta", type = "short" } },
    ["player_shield_blocked"] = { { name = "attacker_entindex", type = "byte" }, { name = "blocker_entindex", type = "byte" } },
    ["player_shoot"] = { { name = "userid", type = "short" }, { name = "weapon", type = "byte" }, { name = "mode", type = "byte" } },
    ["player_spawn"] = { { name = "userid", type = "short" }, { name = "team", type = "short" }, { name = "class", type = "short" } },
    ["player_stats_updated"] = { { name = "forceupload", type = "bool" } },
    ["player_stealsandvich"] = { { name = "owner", type = "short" }, { name = "target", type = "short" } },
    ["player_stunned"] = { { name = "stunner", type = "short" }, { name = "victim", type = "short" }, { name = "victim_capping", type = "bool" }, { name = "big_stun", type = "bool" } },
    ["player_team"] = { { name = "userid", type = "short" }, { name = "team", type = "byte" }, { name = "oldteam", type = "byte" }, { name = "disconnect", type = "bool" }, { name = "autoteam", type = "bool" }, { name = "silent", type = "bool" }, { name = "name", type = "string" } },
    ["player_teleported"] = { { name = "userid", type = "short" }, { name = "builderid", type = "short" }, { name = "dist", type = "float" } },
    ["player_turned_to_ghost"] = { { name = "userid", type = "short" } },
    ["player_upgraded"] = {},
    ["player_upgradedobject"] = { { name = "userid", type = "short" }, { name = "object", type = "short" }, { name = "index", type = "short" }, { name = "isbuilder", type = "bool" } },
    ["player_use"] = { { name = "userid", type = "short" }, { name = "entity", type = "short" } },
    ["player_used_powerup_bottle"] = { { name = "player", type = "short" }, { name = "type", type = "short" }, { name = "time", type = "float" } },
    ["playing_commentary"] = {},
    ["post_inventory_application"] = { { name = "userid", type = "short" } },
    ["projectile_direct_hit"] = { { name = "attacker", type = "byte" }, { name = "victim", type = "byte" }, { name = "weapon_def_index", type = "long" } },
    ["projectile_removed"] = { { name = "attacker", type = "byte" }, { name = "weapon_def_index", type = "long" }, { name = "num_hit", type = "byte" }, { name = "num_direct_hit", type = "byte" } },
    ["pumpkin_lord_killed"] = {},
    ["pumpkin_lord_summoned"] = {},
    ["pve_win_panel"] = { { name = "panel_style", type = "byte" }, { name = "winning_team", type = "byte" }, { name = "winreason", type = "byte" } },
    ["quest_map_data_changed"] = { { name = "igniter", type = "short" }, { name = "douser", type = "short" }, { name = "victim", type = "short" } },
    ["quest_objective_completed"] = { { name = "quest_item_id_low", type = "long" }, { name = "quest_item_id_hi", type = "long" }, { name = "quest_objective_id", type = "long" }, { name = "scorer_user_id", type = "short" } },
    ["quest_progress"] = { { name = "owner", type = "short" }, { name = "scorer", type = "short" }, { name = "type", type = "byte" }, { name = "completed", type = "bool" }, { name = "quest_defindex", type = "long" } },
    ["quest_request"] = { { name = "request", type = "long" }, { name = "msg", type = "string" } },
    ["quest_response"] = { { name = "request", type = "long" }, { name = "success", type = "bool" }, { name = "msg", type = "string" } },
    ["quest_turn_in_state"] = { { name = "state", type = "short" } },
    ["questlog_opened"] = {},
    ["ragdoll_dissolved"] = { { name = "entindex", type = "long" } },
    ["raid_spawn_mob"] = {},
    ["raid_spawn_squad"] = {},
    ["rd_player_score_points"] = { { name = "player", type = "short" }, { name = "method", type = "short" }, { name = "amount", type = "short" } },
    ["rd_robot_impact"] = { { name = "entindex", type = "short" }, { name = "impulse_x", type = "float" }, { name = "impulse_y", type = "float" }, { name = "impulse_z", type = "float" } },
    ["rd_robot_killed"] = { { name = "userid", type = "short" }, { name = "victim_entindex", type = "long" }, { name = "inflictor_entindex", type = "long" }, { name = "attacker", type = "short" }, { name = "weapon", type = "string" }, { name = "weaponid", type = "short" }, { name = "damagebits", type = "long" }, { name = "customkill", type = "short" }, { name = "weapon_logclassname", type = "string" } },
    ["rd_rules_state_changed"] = {},
    ["rd_team_points_changed"] = { { name = "points", type = "short" }, { name = "team", type = "byte" }, { name = "method", type = "byte" } },
    ["recalculate_holidays"] = {},
    ["recalculate_truce"] = {},
    ["rematch_failed_to_create"] = { { name = "map_index", type = "byte" }, { name = "vote", type = "byte" } },
    ["remove_nemesis_relationships"] = { { name = "player", type = "short" } },
    ["replay_endrecord"] = {},
    ["replay_replaysavailable"] = {},
    ["replay_saved"] = {},
    ["replay_servererror"] = { { name = "error", type = "string" } },
    ["replay_sessioninfo"] = { { name = "sn", type = "string" }, { name = "di", type = "byte" }, { name = "cb", type = "long" }, { name = "st", type = "long" } },
    ["replay_startrecord"] = {},
    ["replay_youtube_stats"] = { { name = "views", type = "long" }, { name = "likes", type = "long" }, { name = "favorited", type = "long" } },
    ["respawn_ghost"] = { { name = "reviver", type = "short" }, { name = "ghost", type = "short" } },
    ["restart_timer_time"] = { { name = "time", type = "byte" } },
    ["revive_player_complete"] = { { name = "entindex", type = "short" } },
    ["revive_player_notify"] = { { name = "entindex", type = "short" }, { name = "marker_entindex", type = "short" } },
    ["revive_player_stopped"] = { { name = "entindex", type = "short" } },
    ["rocket_jump"] = { { name = "userid", type = "short" }, { name = "playsound", type = "bool" } },
    ["rocket_jump_landed"] = { { name = "userid", type = "short" } },
    ["rocketpack_landed"] = { { name = "userid", type = "short" } },
    ["rocketpack_launch"] = { { name = "userid", type = "short" }, { name = "playsound", type = "bool" } },
    ["round_end"] = { { name = "winner", type = "byte" }, { name = "reason", type = "byte" }, { name = "message", type = "string" } },
    ["round_start"] = { { name = "timelimit", type = "long" }, { name = "fraglimit", type = "long" }, { name = "objective", type = "string" } },
    ["rps_taunt_event"] = { { name = "winner", type = "short" }, { name = "winner_rps", type = "byte" }, { name = "loser", type = "short" }, { name = "loser_rps", type = "byte" } },
    ["schema_updated"] = {},
    ["scorestats_accumulated_reset"] = {},
    ["scorestats_accumulated_update"] = {},
    ["scout_grand_slam"] = { { name = "scout_id", type = "short" }, { name = "target_id", type = "short" } },
    ["scout_slamdoll_landed"] = { { name = "target_index", type = "short" }, { name = "x", type = "float" }, { name = "y", type = "float" }, { name = "z", type = "float" } },
    ["sentry_on_go_active"] = { { name = "index", type = "short" } },
    ["server_addban"] = { { name = "name", type = "string" }, { name = "userid", type = "short" }, { name = "networkid", type = "string" }, { name = "ip", type = "string" }, { name = "duration", type = "string" }, { name = "by", type = "string" }, { name = "kicked", type = "bool" } },
    ["server_changelevel_failed"] = { { name = "levelname", type = "string" } },
    ["server_cvar"] = { { name = "cvarname", type = "string" }, { name = "cvarvalue", type = "string" } },
    ["server_message"] = { { name = "text", type = "string" } },
    ["server_removeban"] = { { name = "networkid", type = "string" }, { name = "ip", type = "string" }, { name = "by", type = "string" } },
    ["server_shutdown"] = { { name = "reason", type = "string" } },
    ["server_spawn"] = { { name = "hostname", type = "string" }, { name = "address", type = "string" }, { name = "ip", type = "long" }, { name = "port", type = "short" }, { name = "game", type = "string" }, { name = "mapname", type = "string" }, { name = "maxplayers", type = "long" }, { name = "os", type = "string" }, { name = "dedicated", type = "bool" }, { name = "password", type = "bool" } },
    ["show_annotation"] = { { name = "worldPosX", type = "float" }, { name = "worldPosY", type = "float" }, { name = "worldPosZ", type = "float" }, { name = "worldNormalX", type = "float" }, { name = "worldNormalY", type = "float" }, { name = "worldNormalZ", type = "float" }, { name = "id", type = "long" }, { name = "text", type = "string" }, { name = "lifetime", type = "float" }, { name = "visibilityBitfield", type = "long" }, { name = "follow_entindex", type = "long" }, { name = "show_distance", type = "bool" }, { name = "play_sound", type = "string" }, { name = "show_effect", type = "bool" } },
    ["show_class_layout"] = { { name = "show", type = "bool" } },
    ["show_freezepanel"] = { { name = "killer", type = "short" } },
    ["show_match_summary"] = { { name = "success", type = "bool" } },
    ["show_vs_panel"] = { { name = "show", type = "bool" } },
    ["single_player_death"] = {},
    ["skeleton_killed_quest"] = { { name = "player", type = "short" } },
    ["skeleton_king_killed_quest"] = { { name = "player", type = "short" } },
    ["slap_notice"] = { { name = "userid", type = "short" }, { name = "victim_entindex", type = "long" }, { name = "inflictor_entindex", type = "long" }, { name = "attacker", type = "short" }, { name = "weapon", type = "string" }, { name = "weaponid", type = "short" }, { name = "damagebits", type = "long" }, { name = "customkill", type = "short" }, { name = "assister", type = "short" }, { name = "weapon_logclassname", type = "string" }, { name = "stun_flags", type = "short" }, { name = "death_flags", type = "short" }, { name = "silent_kill", type = "bool" }, { name = "assister_fallback", type = "string" } },
    ["spec_target_updated"] = {},
    ["special_score"] = { { name = "player", type = "byte" } },
    ["spy_pda_reset"] = {},
    ["stats_resetround"] = {},
    ["sticky_jump"] = { { name = "userid", type = "short" }, { name = "playsound", type = "bool" } },
    ["sticky_jump_landed"] = { { name = "userid", type = "short" } },
    ["store_pricesheet_updated"] = {},
    ["tagged_player_as_it"] = { { name = "player", type = "short" } },
    ["take_armor"] = { { name = "amount", type = "long" }, { name = "total", type = "long" } },
    ["take_health"] = { { name = "amount", type = "long" }, { name = "total", type = "long" } },
    ["team_info"] = { { name = "teamid", type = "byte" }, { name = "teamname", type = "string" } },
    ["team_leader_killed"] = { { name = "killer", type = "byte" }, { name = "victim", type = "byte" } },
    ["team_score"] = { { name = "teamid", type = "byte" }, { name = "score", type = "short" } },
    ["teamplay_alert"] = { { name = "alert_type", type = "short" } },
    ["teamplay_broadcast_audio"] = { { name = "team", type = "byte" }, { name = "sound", type = "string" }, { name = "additional_flags", type = "short" }, { name = "player", type = "short" } },
    ["teamplay_capture_blocked"] = { { name = "cp", type = "byte" }, { name = "cpname", type = "string" }, { name = "blocker", type = "byte" }, { name = "victim", type = "byte" } },
    ["teamplay_capture_broken"] = { { name = "cp", type = "byte" }, { name = "cpname", type = "string" }, { name = "time_remaining", type = "float" } },
    ["teamplay_flag_event"] = { { name = "player", type = "short" }, { name = "carrier", type = "short" }, { name = "eventtype", type = "short" }, { name = "home", type = "byte" }, { name = "team", type = "byte" } },
    ["teamplay_game_over"] = { { name = "reason", type = "string" } },
    ["teamplay_map_time_remaining"] = { { name = "seconds", type = "short" } },
    ["teamplay_overtime_begin"] = {},
    ["teamplay_overtime_end"] = {},
    ["teamplay_point_captured"] = { { name = "cp", type = "byte" }, { name = "cpname", type = "string" }, { name = "team", type = "byte" }, { name = "cappers", type = "string" } },
    ["teamplay_point_locked"] = { { name = "cp", type = "byte" }, { name = "cpname", type = "string" }, { name = "team", type = "byte" } },
    ["teamplay_point_startcapture"] = { { name = "cp", type = "byte" }, { name = "cpname", type = "string" }, { name = "team", type = "byte" }, { name = "capteam", type = "byte" }, { name = "cappers", type = "string" }, { name = "captime", type = "float" } },
    ["teamplay_point_unlocked"] = { { name = "cp", type = "byte" }, { name = "cpname", type = "string" }, { name = "team", type = "byte" } },
    ["teamplay_pre_round_time_left"] = { { name = "time", type = "short" } },
    ["teamplay_ready_restart"] = {},
    ["teamplay_restart_round"] = {},
    ["teamplay_round_active"] = {},
    ["teamplay_round_restart_seconds"] = { { name = "seconds", type = "short" } },
    ["teamplay_round_selected"] = { { name = "round", type = "string" } },
    ["teamplay_round_stalemate"] = { { name = "reason", type = "byte" } },
    ["teamplay_round_start"] = { { name = "full_reset", type = "bool" } },
    ["teamplay_round_win"] = { { name = "team", type = "byte" }, { name = "winreason", type = "byte" }, { name = "flagcaplimit", type = "short" }, { name = "full_round", type = "short" }, { name = "round_time", type = "float" }, { name = "losing_team_num_caps", type = "short" }, { name = "was_sudden_death", type = "byte" } },
    ["teamplay_setup_finished"] = {},
    ["teamplay_suddendeath_begin"] = {},
    ["teamplay_suddendeath_end"] = {},
    ["teamplay_team_ready"] = { { name = "team", type = "byte" } },
    ["teamplay_teambalanced_player"] = { { name = "player", type = "short" }, { name = "team", type = "byte" } },
    ["teamplay_timer_flash"] = { { name = "time_remaining", type = "short" } },
    ["teamplay_timer_time_added"] = { { name = "timer", type = "short" }, { name = "seconds_added", type = "short" } },
    ["teamplay_update_timer"] = {},
    ["teamplay_waiting_abouttoend"] = {},
    ["teamplay_waiting_begins"] = {},
    ["teamplay_waiting_ends"] = {},
    ["teamplay_win_panel"] = { { name = "panel_style", type = "byte" }, { name = "winning_team", type = "byte" }, { name = "winreason", type = "byte" }, { name = "cappers", type = "string" }, { name = "flagcaplimit", type = "short" }, { name = "blue_score", type = "short" }, { name = "red_score", type = "short" }, { name = "blue_score_prev", type = "short" }, { name = "red_score_prev", type = "short" }, { name = "round_complete", type = "short" }, { name = "rounds_remaining", type = "short" }, { name = "player_1", type = "short" }, { name = "player_1_points", type = "short" }, { name = "player_2", type = "short" }, { name = "player_2_points", type = "short" }, { name = "player_3", type = "short" }, { name = "player_3_points", type = "short" }, { name = "killstreak_player_1", type = "short" }, { name = "killstreak_player_1_count", type = "short" }, { name = "game_over", type = "byte" } },
    ["teams_changed"] = {},
    ["tf_game_over"] = { { name = "reason", type = "string" } },
    ["tf_map_time_remaining"] = { { name = "seconds", type = "long" } },
    ["throwable_hit"] = { { name = "userid", type = "short" }, { name = "victim_entindex", type = "long" }, { name = "inflictor_entindex", type = "long" }, { name = "attacker", type = "short" }, { name = "weapon", type = "string" }, { name = "weaponid", type = "short" }, { name = "damagebits", type = "long" }, { name = "customkill", type = "short" }, { name = "assister", type = "short" }, { name = "weapon_logclassname", type = "string" }, { name = "stun_flags", type = "short" }, { name = "death_flags", type = "short" }, { name = "silent_kill", type = "bool" }, { name = "assister_fallback", type = "string" }, { name = "totalhits", type = "short" } },
    ["tournament_enablecountdown"] = {},
    ["tournament_stateupdate"] = { { name = "userid", type = "short" }, { name = "namechange", type = "bool" }, { name = "readystate", type = "short" }, { name = "newname", type = "string" } },
    ["training_complete"] = { { name = "next_map", type = "string" }, { name = "map", type = "string" }, { name = "text", type = "string" } },
    ["update_status_item"] = { { name = "index", type = "byte" }, { name = "object", type = "byte" } },
    ["upgrades_file_changed"] = { { name = "path", type = "string" } },
    ["user_data_downloaded"] = {},
    ["vote_cast"] = { { name = "vote_option", type = "byte" }, { name = "team", type = "short" }, { name = "entityid", type = "long" }, { name = "voteidx", type = "long" } },
    ["vote_changed"] = { { name = "vote_option1", type = "byte" }, { name = "vote_option2", type = "byte" }, { name = "vote_option3", type = "byte" }, { name = "vote_option4", type = "byte" }, { name = "vote_option5", type = "byte" }, { name = "potentialVotes", type = "byte" }, { name = "voteidx", type = "long" } },
    ["vote_ended"] = {},
    ["vote_failed"] = { { name = "team", type = "byte" }, { name = "voteidx", type = "long" } },
    ["vote_maps_changed"] = { { name = "type", type = "byte" }, { name = "defindex", type = "long" }, { name = "created", type = "bool" }, { name = "deleted", type = "bool" }, { name = "erase_history", type = "bool" } },
    ["vote_options"] = { { name = "count", type = "byte" }, { name = "option1", type = "string" }, { name = "option2", type = "string" }, { name = "option3", type = "string" }, { name = "option4", type = "string" }, { name = "option5", type = "string" }, { name = "voteidx", type = "long" } },
    ["vote_passed"] = { { name = "details", type = "string" }, { name = "param1", type = "string" }, { name = "team", type = "byte" }, { name = "voteidx", type = "long" } },
    ["vote_started"] = { { name = "issue", type = "string" }, { name = "param1", type = "string" }, { name = "team", type = "byte" }, { name = "initiator", type = "long" }, { name = "voteidx", type = "long" } },
    ["weapon_equipped"] = { { name = "class", type = "string" }, { name = "entindex", type = "long" } },
    ["winlimit_changed"] = { { name = "delay", type = "float" } }
}


-- Mappings for IDs to Names
local teamNames = {
    [E_TeamNumber.TEAM_UNASSIGNED] = "Unassigned",
    [E_TeamNumber.TEAM_SPECTATOR] = "Spectator",
    [E_TeamNumber.TEAM_RED] = "RED",
    [E_TeamNumber.TEAM_BLU] = "BLU"
}

local classNames = {
    [E_Character.TF2_Scout] = "Scout",
    [E_Character.TF2_Soldier] = "Soldier",
    [E_Character.TF2_Pyro] = "Pyro",
    [E_Character.TF2_Demoman] = "Demoman",
    [E_Character.TF2_Heavy] = "Heavy",
    [E_Character.TF2_Engineer] = "Engineer",
    [E_Character.TF2_Medic] = "Medic",
    [E_Character.TF2_Sniper] = "Sniper",
    [E_Character.TF2_Spy] = "Spy"
}

-- Create a reverse lookup table for E_WeaponBaseID
-- We need to do this manually as we can't iterate the constant table directly
local weaponBaseNames = {
    [E_WeaponBaseID.TF_WEAPON_NONE] = "TF_WEAPON_NONE",
    [E_WeaponBaseID.TF_WEAPON_BAT] = "TF_WEAPON_BAT",
    [E_WeaponBaseID.TF_WEAPON_BAT_WOOD] = "TF_WEAPON_BAT_WOOD",
    [E_WeaponBaseID.TF_WEAPON_BOTTLE] = "TF_WEAPON_BOTTLE",
    [E_WeaponBaseID.TF_WEAPON_FIREAXE] = "TF_WEAPON_FIREAXE",
    [E_WeaponBaseID.TF_WEAPON_CLUB] = "TF_WEAPON_CLUB",
    [E_WeaponBaseID.TF_WEAPON_CROWBAR] = "TF_WEAPON_CROWBAR",
    [E_WeaponBaseID.TF_WEAPON_KNIFE] = "TF_WEAPON_KNIFE",
    [E_WeaponBaseID.TF_WEAPON_FISTS] = "TF_WEAPON_FISTS",
    [E_WeaponBaseID.TF_WEAPON_SHOVEL] = "TF_WEAPON_SHOVEL",
    [E_WeaponBaseID.TF_WEAPON_WRENCH] = "TF_WEAPON_WRENCH",
    [E_WeaponBaseID.TF_WEAPON_BONESAW] = "TF_WEAPON_BONESAW",
    [E_WeaponBaseID.TF_WEAPON_SHOTGUN_PRIMARY] = "TF_WEAPON_SHOTGUN_PRIMARY",
    [E_WeaponBaseID.TF_WEAPON_SHOTGUN_SOLDIER] = "TF_WEAPON_SHOTGUN_SOLDIER",
    [E_WeaponBaseID.TF_WEAPON_SHOTGUN_HWG] = "TF_WEAPON_SHOTGUN_HWG",
    [E_WeaponBaseID.TF_WEAPON_SHOTGUN_PYRO] = "TF_WEAPON_SHOTGUN_PYRO",
    [E_WeaponBaseID.TF_WEAPON_SCATTERGUN] = "TF_WEAPON_SCATTERGUN",
    [E_WeaponBaseID.TF_WEAPON_SNIPERRIFLE] = "TF_WEAPON_SNIPERRIFLE",
    [E_WeaponBaseID.TF_WEAPON_MINIGUN] = "TF_WEAPON_MINIGUN",
    [E_WeaponBaseID.TF_WEAPON_SMG] = "TF_WEAPON_SMG",
    [E_WeaponBaseID.TF_WEAPON_SYRINGEGUN_MEDIC] = "TF_WEAPON_SYRINGEGUN_MEDIC",
    [E_WeaponBaseID.TF_WEAPON_TRANQ] = "TF_WEAPON_TRANQ",
    [E_WeaponBaseID.TF_WEAPON_ROCKETLAUNCHER] = "TF_WEAPON_ROCKETLAUNCHER",
    [E_WeaponBaseID.TF_WEAPON_GRENADELAUNCHER] = "TF_WEAPON_GRENADELAUNCHER",
    [E_WeaponBaseID.TF_WEAPON_PIPEBOMBLAUNCHER] = "TF_WEAPON_PIPEBOMBLAUNCHER",
    [E_WeaponBaseID.TF_WEAPON_FLAMETHROWER] = "TF_WEAPON_FLAMETHROWER",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_NORMAL] = "TF_WEAPON_GRENADE_NORMAL",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_CONCUSSION] = "TF_WEAPON_GRENADE_CONCUSSION",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_NAIL] = "TF_WEAPON_GRENADE_NAIL",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_MIRV] = "TF_WEAPON_GRENADE_MIRV",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_MIRV_DEMOMAN] = "TF_WEAPON_GRENADE_MIRV_DEMOMAN",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_NAPALM] = "TF_WEAPON_GRENADE_NAPALM",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_GAS] = "TF_WEAPON_GRENADE_GAS",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_EMP] = "TF_WEAPON_GRENADE_EMP",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_CALTROP] = "TF_WEAPON_GRENADE_CALTROP",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_PIPEBOMB] = "TF_WEAPON_GRENADE_PIPEBOMB",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_SMOKE_BOMB] = "TF_WEAPON_GRENADE_SMOKE_BOMB",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_HEAL] = "TF_WEAPON_GRENADE_HEAL",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_STUNBALL] = "TF_WEAPON_GRENADE_STUNBALL",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_JAR] = "TF_WEAPON_GRENADE_JAR",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_JAR_MILK] = "TF_WEAPON_GRENADE_JAR_MILK",
    [E_WeaponBaseID.TF_WEAPON_PISTOL] = "TF_WEAPON_PISTOL",
    [E_WeaponBaseID.TF_WEAPON_PISTOL_SCOUT] = "TF_WEAPON_PISTOL_SCOUT",
    [E_WeaponBaseID.TF_WEAPON_REVOLVER] = "TF_WEAPON_REVOLVER",
    [E_WeaponBaseID.TF_WEAPON_NAILGUN] = "TF_WEAPON_NAILGUN",
    [E_WeaponBaseID.TF_WEAPON_PDA] = "TF_WEAPON_PDA",
    [E_WeaponBaseID.TF_WEAPON_PDA_ENGINEER_BUILD] = "TF_WEAPON_PDA_ENGINEER_BUILD",
    [E_WeaponBaseID.TF_WEAPON_PDA_ENGINEER_DESTROY] = "TF_WEAPON_PDA_ENGINEER_DESTROY",
    [E_WeaponBaseID.TF_WEAPON_PDA_SPY] = "TF_WEAPON_PDA_SPY",
    [E_WeaponBaseID.TF_WEAPON_BUILDER] = "TF_WEAPON_BUILDER",
    [E_WeaponBaseID.TF_WEAPON_MEDIGUN] = "TF_WEAPON_MEDIGUN",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_MIRVBOMB] = "TF_WEAPON_GRENADE_MIRVBOMB",
    [E_WeaponBaseID.TF_WEAPON_FLAMETHROWER_ROCKET] = "TF_WEAPON_FLAMETHROWER_ROCKET",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_DEMOMAN] = "TF_WEAPON_GRENADE_DEMOMAN",
    [E_WeaponBaseID.TF_WEAPON_SENTRY_BULLET] = "TF_WEAPON_SENTRY_BULLET",
    [E_WeaponBaseID.TF_WEAPON_SENTRY_ROCKET] = "TF_WEAPON_SENTRY_ROCKET",
    [E_WeaponBaseID.TF_WEAPON_DISPENSER] = "TF_WEAPON_DISPENSER",
    [E_WeaponBaseID.TF_WEAPON_INVIS] = "TF_WEAPON_INVIS",
    [E_WeaponBaseID.TF_WEAPON_FLAREGUN] = "TF_WEAPON_FLAREGUN",
    [E_WeaponBaseID.TF_WEAPON_LUNCHBOX] = "TF_WEAPON_LUNCHBOX",
    [E_WeaponBaseID.TF_WEAPON_JAR] = "TF_WEAPON_JAR",
    [E_WeaponBaseID.TF_WEAPON_COMPOUND_BOW] = "TF_WEAPON_COMPOUND_BOW",
    [E_WeaponBaseID.TF_WEAPON_BUFF_ITEM] = "TF_WEAPON_BUFF_ITEM",
    [E_WeaponBaseID.TF_WEAPON_PUMPKIN_BOMB] = "TF_WEAPON_PUMPKIN_BOMB",
    [E_WeaponBaseID.TF_WEAPON_SWORD] = "TF_WEAPON_SWORD",
    [E_WeaponBaseID.TF_WEAPON_DIRECTHIT] = "TF_WEAPON_DIRECTHIT",
    [E_WeaponBaseID.TF_WEAPON_LIFELINE] = "TF_WEAPON_LIFELINE",
    [E_WeaponBaseID.TF_WEAPON_LASER_POINTER] = "TF_WEAPON_LASER_POINTER",
    [E_WeaponBaseID.TF_WEAPON_DISPENSER_GUN] = "TF_WEAPON_DISPENSER_GUN",
    [E_WeaponBaseID.TF_WEAPON_SENTRY_REVENGE] = "TF_WEAPON_SENTRY_REVENGE",
    [E_WeaponBaseID.TF_WEAPON_JAR_MILK] = "TF_WEAPON_JAR_MILK",
    [E_WeaponBaseID.TF_WEAPON_HANDGUN_SCOUT_PRIMARY] = "TF_WEAPON_HANDGUN_SCOUT_PRIMARY",
    [E_WeaponBaseID.TF_WEAPON_BAT_FISH] = "TF_WEAPON_BAT_FISH",
    [E_WeaponBaseID.TF_WEAPON_CROSSBOW] = "TF_WEAPON_CROSSBOW",
    [E_WeaponBaseID.TF_WEAPON_STICKBOMB] = "TF_WEAPON_STICKBOMB",
    [E_WeaponBaseID.TF_WEAPON_HANDGUN_SCOUT_SEC] = "TF_WEAPON_HANDGUN_SCOUT_SEC",
    [E_WeaponBaseID.TF_WEAPON_SODA_POPPER] = "TF_WEAPON_SODA_POPPER",
    [E_WeaponBaseID.TF_WEAPON_SNIPERRIFLE_DECAP] = "TF_WEAPON_SNIPERRIFLE_DECAP",
    [E_WeaponBaseID.TF_WEAPON_RAYGUN] = "TF_WEAPON_RAYGUN",
    [E_WeaponBaseID.TF_WEAPON_PARTICLE_CANNON] = "TF_WEAPON_PARTICLE_CANNON",
    [E_WeaponBaseID.TF_WEAPON_MECHANICAL_ARM] = "TF_WEAPON_MECHANICAL_ARM",
    [E_WeaponBaseID.TF_WEAPON_DRG_POMSON] = "TF_WEAPON_DRG_POMSON",
    [E_WeaponBaseID.TF_WEAPON_BAT_GIFTWRAP] = "TF_WEAPON_BAT_GIFTWRAP",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_ORNAMENT] = "TF_WEAPON_GRENADE_ORNAMENT",
    [E_WeaponBaseID.TF_WEAPON_RAYGUN_REVENGE] = "TF_WEAPON_RAYGUN_REVENGE",
    [E_WeaponBaseID.TF_WEAPON_PEP_BRAWLER_BLASTER] = "TF_WEAPON_PEP_BRAWLER_BLASTER",
    [E_WeaponBaseID.TF_WEAPON_CLEAVER] = "TF_WEAPON_CLEAVER",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_CLEAVER] = "TF_WEAPON_GRENADE_CLEAVER",
    [E_WeaponBaseID.TF_WEAPON_STICKY_BALL_LAUNCHER] = "TF_WEAPON_STICKY_BALL_LAUNCHER",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_STICKY_BALL] = "TF_WEAPON_GRENADE_STICKY_BALL",
    [E_WeaponBaseID.TF_WEAPON_SHOTGUN_BUILDING_RESCUE] = "TF_WEAPON_SHOTGUN_BUILDING_RESCUE",
    [E_WeaponBaseID.TF_WEAPON_CANNON] = "TF_WEAPON_CANNON",
    [E_WeaponBaseID.TF_WEAPON_THROWABLE] = "TF_WEAPON_THROWABLE",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_THROWABLE] = "TF_WEAPON_GRENADE_THROWABLE",
    [E_WeaponBaseID.TF_WEAPON_PDA_SPY_BUILD] = "TF_WEAPON_PDA_SPY_BUILD",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_WATERBALLOON] = "TF_WEAPON_GRENADE_WATERBALLOON",
    [E_WeaponBaseID.TF_WEAPON_HARVESTER_SAW] = "TF_WEAPON_HARVESTER_SAW",
    [E_WeaponBaseID.TF_WEAPON_SPELLBOOK] = "TF_WEAPON_SPELLBOOK",
    [E_WeaponBaseID.TF_WEAPON_SPELLBOOK_PROJECTILE] = "TF_WEAPON_SPELLBOOK_PROJECTILE",
    [E_WeaponBaseID.TF_WEAPON_SNIPERRIFLE_CLASSIC] = "TF_WEAPON_SNIPERRIFLE_CLASSIC",
    [E_WeaponBaseID.TF_WEAPON_PARACHUTE] = "TF_WEAPON_PARACHUTE",
    [E_WeaponBaseID.TF_WEAPON_GRAPPLINGHOOK] = "TF_WEAPON_GRAPPLINGHOOK",
    [E_WeaponBaseID.TF_WEAPON_PASSTIME_GUN] = "TF_WEAPON_PASSTIME_GUN",
    [E_WeaponBaseID.TF_WEAPON_CHARGED_SMG] = "TF_WEAPON_CHARGED_SMG",
    [E_WeaponBaseID.TF_WEAPON_BREAKABLE_SIGN] = "TF_WEAPON_BREAKABLE_SIGN",
    [E_WeaponBaseID.TF_WEAPON_ROCKETPACK] = "TF_WEAPON_ROCKETPACK",
    [E_WeaponBaseID.TF_WEAPON_SLAP] = "TF_WEAPON_SLAP",
    [E_WeaponBaseID.TF_WEAPON_JAR_GAS] = "TF_WEAPON_JAR_GAS",
    [E_WeaponBaseID.TF_WEAPON_GRENADE_JAR_GAS] = "TF_WEAPON_GRENADE_JAR_GAS",
    [E_WeaponBaseID.TF_WEAPON_FLAME_BALL] = "TF_WEAPON_FLAME_BALL",
}

-- Helper function to resolve player name from UserID
local function resolvePlayerNameFromUserID(userID)
    if userID == nil or userID == 0 then
        return "(None/World)"
    end
    local status, name = pcall(client.GetPlayerNameByUserID, userID)
    if status and name then
        return name
    else
        return "(Invalid UserID: " .. tostring(userID) .. ")"
    end
end

-- Helper function to resolve player name from Entity Index
local function resolvePlayerNameFromIndex(index)
    if index == nil or index == 0 then
        return "(None/World)"
    end
    local status, name = pcall(client.GetPlayerNameByIndex, index)
     if status and name then
        return name
    else
        return "(Invalid Index: " .. tostring(index) .. ")"
    end
end

-- Helper function to resolve entity info from Entity Index
local function resolveEntityInfo(index)
    if index == nil or index == 0 then
        return "(None/World)"
    end
    local status, ent = pcall(entities.GetByIndex, index)
    if status and ent and ent:IsValid() then
        local class = ent:GetClass() or "(No Class)"
        if class == "CTFPlayer" then
            local name = ent:GetName()
            return name and (class .. ": " .. name) or (class .. ": (No Name)")
        else
            return class
        end
    else
        return "(Invalid Index: " .. tostring(index) .. ")"
    end
end

-- Helper function to resolve weapon name from Definition Index (Item Schema)
local function resolveWeaponNameFromDefIndex(defIndex)
    if defIndex == nil or defIndex == 0 then
        return "(None)"
    end
    -- Special case for weaponid 79 which seems to be 'default' but not in itemschema
    if defIndex == 79 then
        return "default"
    end
    local status, itemDef = pcall(itemschema.GetItemDefinitionByID, defIndex)
    if status and itemDef then
        local name = itemDef:GetNameTranslated() or itemDef:GetName()
        return name or "(Unknown DefIndex: " .. tostring(defIndex) .. ")"
    else
        return "(Invalid DefIndex: " .. tostring(defIndex) .. ")"
    end
end

-- Helper function to resolve weapon name from Base Weapon ID (Enum)
local function resolveBaseWeaponName(weaponID)
    if weaponID == nil then return "(nil ID)" end
    return weaponBaseNames[weaponID] or "(Unknown BaseWeaponID: " .. tostring(weaponID) .. ")"
end


-- Helper function to resolve team name from Team ID
local function resolveTeamName(teamID)
    return teamNames[teamID] or "(Unknown Team: " .. tostring(teamID) .. ")"
end

-- Helper function to resolve class name from Class ID
local function resolveClassName(classID)
    return classNames[classID] or "(Unknown Class: " .. tostring(classID) .. ")"
end


-- The callback function that processes game events
local function onGameEvent(event)
    local eventName = event:GetName()

    -- Filter out high-frequency UI events to reduce console spam
    if eventName == "gameui_hidden" or eventName == "gameui_activated" or eventName == "gameui_hide" or eventName == "gameui_activate" then
        return
    end

    -- Check if we have defined parameters for this event
    local params = eventParameters[eventName]

    if params then
        -- Event is known, print its name and parameters
        printc(COLOR_EVENT_NAME[1], COLOR_EVENT_NAME[2], COLOR_EVENT_NAME[3], 255, "--- Event Fired: " .. eventName .. " ---")
        if #params == 0 then
            printc(COLOR_VALUE[1], COLOR_VALUE[2], COLOR_VALUE[3], 255, "  (No parameters defined for this event)")
        else
            for i, paramInfo in ipairs(params) do
                local paramName = paramInfo.name
                local paramType = paramInfo.type
                local value = nil
                local resolvedValueStr = ""
                local valueStr = "nil" -- Default value string

                -- Use pcall for safety when getting event data
                local getStatus, rawValue = pcall(function()
                    if paramType == "string" then
                        return event:GetString(paramName)
                    elseif paramType == "float" then
                        return event:GetFloat(paramName)
                    elseif paramType == "bool" then
                        return event:GetInt(paramName) == 1 -- Assuming bools are 0 or 1
                    else -- byte, short, long are all integers
                        return event:GetInt(paramName)
                    end
                end)

                if getStatus and rawValue ~= nil then
                    value = rawValue
                    valueStr = tostring(value) -- Convert raw value to string for printing
                else
                    -- Error getting value, print error message instead
                    valueStr = "(Error getting value)"
                    printc(COLOR_ERROR[1], COLOR_ERROR[2], COLOR_ERROR[3], 255, "  Error retrieving param '" .. paramName .. "' for event '" .. eventName .. "'")
                end

                -- Attempt to resolve common IDs to names only if value was retrieved successfully
                if value ~= nil then
                    -- Use pcall for safety during resolution as well
                    local resolveStatus, resolved = pcall(function()
                        local pNameLower = string.lower(paramName) -- Case-insensitive check

                        -- Player/User ID Resolution
                        if string.find(pNameLower, "userid") or pNameLower == "attacker" or pNameLower == "victim" or
                           pNameLower == "healer" or pNameLower == "target" or pNameLower == "dominator" or
                           pNameLower == "dominated" or pNameLower == "killer" or pNameLower == "spy" or
                           pNameLower == "medic" or pNameLower == "stunner" or pNameLower == "pusher" or
                           pNameLower == "pushed" or pNameLower == "ownerid" or pNameLower == "preventor" or
                           pNameLower == "mitigator" or pNameLower == "damaged" or pNameLower == "passer" or
                           pNameLower == "catcher" or pNameLower == "scorer" or pNameLower == "assister" or
                           pNameLower == "builderid" or pNameLower == "initiator" or pNameLower == "targetid" or
                           pNameLower == "medic_userid" or pNameLower == "reviver" or pNameLower == "ghost" or
                           pNameLower == "scout_id" or pNameLower == "target_id" or pNameLower == "collector" or
                           pNameLower == "collecting_player" or pNameLower == "intended_target" or
                           pNameLower == "buff_owner" or pNameLower == "blocker" or pNameLower == "patient" or
                           pNameLower == "scorer_user_id" or pNameLower == "player" then
                            return resolvePlayerNameFromUserID(value)

                        -- Entity Index Resolution (excluding player connect/info index)
                        elseif string.find(pNameLower, "entindex") or pNameLower == "vehicle" or
                               pNameLower == "attachedentity" or pNameLower == "entity" or pNameLower == "sapperid" or
                               pNameLower == "marker_entindex" or pNameLower == "follow_entindex" or
                               pNameLower == "sentry_buster" or pNameLower == "building" or
                               (pNameLower == "index" and eventName ~= "player_connect" and eventName ~= "player_info") or
                               string.find(pNameLower, "_id") and not string.find(pNameLower, "userid") then
                            return resolveEntityInfo(value)

                        -- Player Index Resolution (specific events)
                        elseif pNameLower == "index" and (eventName == "player_connect" or eventName == "player_info") then
                             return resolvePlayerNameFromIndex(value)

                        -- Base Weapon ID Resolution
                        elseif pNameLower == "weaponid" then
                            return resolveBaseWeaponName(value)

                        -- Item Definition Index Resolution
                        elseif pNameLower == "weapon_def_index" or pNameLower == "itemdefindex" or pNameLower == "itemdef" then
                            return resolveWeaponNameFromDefIndex(value)

                        -- Team ID Resolution
                        elseif pNameLower == "team" or pNameLower == "teamid" or pNameLower == "capping_team" or pNameLower == "winning_team" or pNameLower == "capteam" then
                            return resolveTeamName(value)

                        -- Class ID Resolution (numeric only)
                        elseif pNameLower == "class" and paramType ~= "string" then
                             return resolveClassName(value)
                        end
                        return nil -- No resolution needed/possible
                    end)

                    -- Process the result of the pcall
                    if resolveStatus then
                        if resolved ~= nil then
                            resolvedValueStr = tostring(resolved)
                        else
                            resolvedValueStr = ""
                        end
                    else
                        resolvedValueStr = "(Error resolving)"
                        printc(COLOR_ERROR[1], COLOR_ERROR[2], COLOR_ERROR[3], 255, "  Error resolving value for param '" .. paramName .. "': " .. tostring(resolved)) -- Print the error message from pcall
                    end
                end

                -- Print parameter info (Name/Type)
                printc(COLOR_PARAM_INFO[1], COLOR_PARAM_INFO[2], COLOR_PARAM_INFO[3], 255, "  " .. paramName .. " (" .. paramType .. "): ")
                -- Print the raw value
                printc(COLOR_VALUE[1], COLOR_VALUE[2], COLOR_VALUE[3], 255, "    " .. valueStr)

                -- If there's a resolved value (and it's not an error message or empty), print it
                if resolvedValueStr ~= "" and resolvedValueStr ~= "nil" and resolvedValueStr ~= "()" and resolvedValueStr ~= "(Error resolving)" then
                     printc(COLOR_RESOLVED[1], COLOR_RESOLVED[2], COLOR_RESOLVED[3], 255, "      -> " .. resolvedValueStr)
                end
            end
        end
    else
        -- Event is not in our predefined list
        printc(COLOR_UNKNOWN[1], COLOR_UNKNOWN[2], COLOR_UNKNOWN[3], 255, "--- Unknown Event Fired: " .. eventName .. " ---")
    end
end

-- Register the callback for the FireGameEvent
callbacks.Register("FireGameEvent", "EnhancedColoredGameEventListener", onGameEvent)

printc(COLOR_INFO[1], COLOR_INFO[2], COLOR_INFO[3], 255, "Enhanced Colored Game Event Listener loaded.")

-- Optional: Add an Unload callback
callbacks.Register("Unload", "EnhancedColoredGameEventListenerUnload", function()
    printc(COLOR_INFO[1], COLOR_INFO[2], COLOR_INFO[3], 255, "Enhanced Colored Game Event Listener unloaded.")
end)