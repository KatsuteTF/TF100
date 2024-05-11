// Copyright (C) 2024 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <dhooks>
#include <sourcemod>
#include <sdktools>

// ConVar mp_tournament;

static const int len = 27;

static const char entities[27][] = {
    "entity_bird",
    "env_ambient_light",
    "env_dustpuff",
    "env_dusttrail",
    "env_funnel",
    "env_lightglow",
    "env_particlelight",
    "env_smokestack",
    "env_smoketrail",
    "env_sniperdot",
    "env_splash",
    "env_sporeexplosion",
    "env_spritetrail",
    "halloween_souls_pack",
    "info_particle_system",
    "keyframe_rope",
    "light_spot",
    "move_rope",
    "point_spotlight",
    "prop_physics_multiplayer",
    // "prop_physics_override", // payload
    "prop_physics_respawnable",
    "prop_physics",
    "prop_ragdoll",
    "tf_ammo_pack",
    "tf_dropped_weapon",
    "tf_ragdoll",
    "tf_wearable"
};

public Plugin myinfo = {
    name        = "TF100",
    author      = "Katsute",
    description = "Optimizations for 100 player servers",
    version     = "1.0",
    url         = "https://github.com/KatsuteTF/TF100"
}

public void OnPluginStart(){
    // Entities
    FindConVar("tf_dropped_weapon_lifetime").SetInt(0);

    // Physics
    FindConVar("sv_turbophysics").SetBool(true);
    FindConVar("tf_resolve_stuck_players").SetBool(false);
    FindConVar("tf_avoidteammates_pushaway").SetBool(false);

    // Network
    FindConVar("sv_parallel_sendsnapshot").SetBool(true);
    FindConVar("net_queued_packet_thread").SetInt(581304);
    FindConVar("net_splitrate").SetInt(200000);
    FindConVar("sv_master_share_game_socket").SetBool(false);

    FindConVar("net_compresspackets").SetBool(true);
    FindConVar("net_compresspackets_minsize").SetInt(1261);

    FindConVar("sv_allowupload").SetBool(false);
    FindConVar("sv_allowdownload").SetBool(false);
    FindConVar("net_maxfilesize").SetInt(0);

    FindConVar("sv_clockcorrection_msecs").SetInt(130);
    FindConVar("sv_playerperfhistorycount").SetInt(0);

    FindConVar("sv_minrate").SetInt(1048576);
    FindConVar("sv_maxrate").SetInt(1048576);
    FindConVar("net_splitpacket_maxrate").SetInt(1048576);
    FindConVar("net_maxcleartime").SetFloat(0.001);

    FindConVar("sv_maxroutable").SetInt(1260);
    FindConVar("net_maxfragments").SetInt(1260);
    FindConVar("net_maxroutable").SetInt(1260);

    FindConVar("mp_ik").SetBool(false);
    FindConVar("sv_lagflushbonecache").SetBool(false);

    // Edicts
    FindConVar("sv_lowedict_action").SetInt(4);
    FindConVar("sv_lowedict_threshold").SetInt(32);

    // MvM
    FindConVar("tf_mvm_defenders_team_size").SetInt(78);
    FindConVar("tf_mvm_max_connected_players").SetInt(78);

    // Client
    FindConVar("breakable_multiplayer").SetBool(false);
    FindConVar("func_break_max_pieces").SetInt(0);

    FindConVar("prop_active_gib_limit").SetInt(0);
    FindConVar("props_break_max_pieces_perframe").SetInt(0);

    FindConVar("g_ragdoll_important_maxcount").SetInt(0);
    FindConVar("g_ragdoll_maxcount").SetInt(0);

    FindConVar("tf_spawn_glows_duration").SetInt(0);
    FindConVar("tf_spec_xray").SetBool(false);

    FindConVar("anim_3wayblend").SetBool(false);

    FindConVar("tf_tournament_hide_domination_icons").SetBool(true);
    FindConVar("mp_show_voice_icons").SetBool(false);

    FindConVar("sv_allow_voice_from_file").SetBool(false);

    FindConVar("sv_client_cmdrate_difference").SetBool(false);
    FindConVar("sv_mincmdrate").SetInt(20);
    FindConVar("sv_maxcmdrate").SetInt(20);
    FindConVar("sv_minupdaterate").SetInt(15);
    FindConVar("sv_maxupdaterate").SetInt(15);
    FindConVar("sv_maxusrcmdprocessticks").SetInt(29);

    FindConVar("sv_client_predict").SetBool(true);

    FindConVar("sv_client_max_interp_ratio").SetInt(2);
    FindConVar("sv_client_min_interp_ratio").SetInt(1);

    // Map Entities
    for(int i = 0; i < len; i++)
        DeleteEntities(entities[i]);

    // // Whitelist Patch https://forums.alliedmods.net/showthread.php?t=346702

    // mp_tournament = FindConVar("mp_tournament");
    // mp_tournament.Flags &= ~FCVAR_NOTIFY;

    // Handle gamedata = LoadGameConfigFile("tf2.100");

    // // broken ↓
    // Handle hookReload = DHookCreateFromConf(gamedata, "ReloadWhitelist");
    // DHookEnableDetour(hookReload, false, TournamentEnable);
    // DHookEnableDetour(hookReload, true, TournamentDisable);

    // // broken ↓
    // Handle hookLoadout = DHookCreateFromConf(gamedata, "GetLoadoutItem");
    // DHookEnableDetour(hookLoadout, false, TournamentEnable);
    // DHookEnableDetour(hookLoadout, true, TournamentDisable);
}

public void OnEntityCreated(int entity, const char[] classname){
    for(int i = 0; i < len; i++)
        if(StrEqual(classname, entities[i])){
            DeleteEntity(entity);
            return;
        }

    // doesn't work b/c model hasn't been set yet
    // if(StrEqual(classname, "item_healthkit_small") || StrEqual(classname, "item_healthkit_medium")){
    //     char model[256];
    //     GetEntPropString(entity, Prop_Data, "m_ModelName", model, 256);
    //     if(!StrContains(model, "plate"))
    //         DeleteEntity(entity);
    // }
}

public void DeleteEntity(const int entity){
    if(IsValidEntity(entity))
        RemoveEntity(entity);
}

public void DeleteEntities(const char[] classname){
    int entity = -1;
    while((entity = FindEntityByClassname(entity, classname)) != -1)
        DeleteEntity(entity);
}

// MRESReturn TournamentEnable(int entity, DHookReturn hReturn) {
//     mp_tournament.SetBool(true, true, false);
//     return MRES_Ignored;
// }

// MRESReturn TournamentDisable(int entity, DHookReturn hReturn) {
//     mp_tournament.SetBool(false, true, false);
//     return MRES_Ignored;
// }