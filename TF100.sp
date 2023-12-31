// Copyright (C) 2023 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sourcescramble>

static const int len = 23;

static const char entities[23][] = {
    "tf_ragdoll",
    "prop_ragdoll",
    "entity_bird",
    "keyframe_rope",
    "move_rope",
    "prop_physics",
    "prop_physics_multiplayer",
    "prop_physics_override",
    "prop_physics_respawnable",
    "info_particle_system",
    "env_ambient_light",
    "env_dustpuff",
    "env_dusttrail",
    "env_funnel",
    "env_lightglow",
    "env_particlelight",
    "env_smokestack",
    "env_smoketrail",
    "env_splash",
    "env_sporeexplosion",
    "env_spritetrail",
    "light_spot",
    "point_spotlight"
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

    // Voice Commands
    AddCommandListener(DisableCommand, "voicemenu");

    // Whitelist Patch https://github.com/sapphonie/tf2rue
    GameData gamedata = LoadGameConfigFile("tf2.100"); // https://github.com/sapphonie/tf2rue/blob/main/gamedata/tf2.rue.txt
    if(gamedata == null){
        SetFailState("Failed to load TF100 gamedata");
    }else{
        MemoryPatch mpatch = MemoryPatch.CreateFromConf(gamedata, "CEconItemSystem::ReloadWhitelist::nopnop");
        if(!mpatch.Validate())
            ThrowError("Failed to verify CEconItemSystem::ReloadWhitelist::nopnop");
        if(!mpatch.Enable())
            ThrowError("Failed to enable patch for CEconItemSystem::ReloadWhitelist::nopnop");
    }
}

public void OnEntityCreated(int entity, const char[] classname){
    for(int i = 0; i < len; i++)
        if(StrEqual(classname, entities[i])){
            DeleteEntity(entity);
            return;
        }

    if(StrEqual(classname, "tf_ammo_pack"))
        DeleteEntity(entity);
    else if(StrEqual(classname, "item_healthkit_small"), StrEqual(classname, "item_healthkit_medium")){
        char model[256];
        GetEntPropString(entity, Prop_Data, "m_ModelName", model, 256);
        if(!StrContains(model, "plate", false))
            DeleteEntity(entity);
    }
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

public Action DisableCommand(const int client, const char[] command, const int args){
    return Plugin_Stop;
}