#include <sourcemod>

#define MAX_MAP_NAME_LENGTH 256

Handle g_airaccelerate_cvar;
int g_previous_airaccelerate;

Handle g_freezetime_cvar;
int g_previous_freezetime;

Handle g_gravity_cvar;
int g_previous_gravity;

Handle g_friendyfire_cvar;
bool g_previous_friendlyfire;

public const Plugin myinfo = {
    name = "Map Settings", author = "LAN of DOOM",
    description = "Sets map settings preferred by the LAN of DOOM",
    version = "1.3.0",
    url = "https://github.com/lanofdoom/counterstrikesource-map-settings"};

public void OnConfigsExecuted() {
  g_previous_airaccelerate = GetConVarInt(g_airaccelerate_cvar);
  g_previous_freezetime = GetConVarInt(g_freezetime_cvar);
  g_previous_gravity = GetConVarInt(g_gravity_cvar);
  g_previous_friendlyfire = GetConVarBool(g_friendyfire_cvar);

  char map_name[MAX_MAP_NAME_LENGTH];
  GetCurrentMap(map_name, MAX_MAP_NAME_LENGTH);

  if (StrEqual(map_name, "scoutzknivez")) {
    SetConVarInt(g_airaccelerate_cvar, 999999);
    SetConVarInt(g_gravity_cvar, 220);
  }

  if (StrEqual(map_name, "aim_ag_texture_city") ||
      StrEqual(map_name, "breakfloor") ||
      StrEqual(map_name, "fun_allinone_css_v2") ||
      StrEqual(map_name, "fy_iceworld_cssource") ||
      StrEqual(map_name, "fy_poolday_reloaded") ||
      StrEqual(map_name, "fy_simpsons_h") ||
      StrEqual(map_name, "glasstrap_final") ||
      StrEqual(map_name, "scoutzknivez")) {
    SetConVarInt(g_freezetime_cvar, 0);
  }

  Handle round_timer_cvar = FindConVar("sm_lanofdoom_round_timer_disabled");
  if (round_timer_cvar == INVALID_HANDLE) {
    return;
  }

  Handle respawn_enabled_cvar = FindConVar("sm_lanofdoom_respawn_enabled");
  if (round_timer_cvar == INVALID_HANDLE) {
    CloseHandle(round_timer_cvar);
    return;
  }

  Handle remove_objectives_cvar = FindConVar("sm_lanofdoom_remove_objectives");
  if (round_timer_cvar == INVALID_HANDLE) {
    CloseHandle(round_timer_cvar);
    CloseHandle(respawn_enabled_cvar);
    return;
  }

  Handle spawn_protection_cvar =
      FindConVar("sm_lanofdoom_spawn_protection_time");
  if (round_timer_cvar == INVALID_HANDLE) {
    CloseHandle(round_timer_cvar);
    CloseHandle(respawn_enabled_cvar);
    CloseHandle(remove_objectives_cvar);
    return;
  }

  Handle gungame_cvar = FindConVar("sm_lanofdoom_gungame_enabled");
  if (gungame_cvar == INVALID_HANDLE) {
    CloseHandle(round_timer_cvar);
    CloseHandle(respawn_enabled_cvar);
    CloseHandle(remove_objectives_cvar);
    CloseHandle(spawn_protection_cvar);
    return;
  }

  Handle buyzones_disabled_cvar = FindConVar("sm_lanofdoom_buyzones_disabled");
  if (buyzones_disabled_cvar == INVALID_HANDLE) {
    CloseHandle(round_timer_cvar);
    CloseHandle(respawn_enabled_cvar);
    CloseHandle(remove_objectives_cvar);
    CloseHandle(spawn_protection_cvar);
    CloseHandle(gungame_cvar);
    return;
  }

  Handle weapon_cleanup_cvar = FindConVar("sm_lanofdoom_weapon_cleanup_enabled");
  if (weapon_cleanup_cvar == INVALID_HANDLE) {
    CloseHandle(round_timer_cvar);
    CloseHandle(respawn_enabled_cvar);
    CloseHandle(remove_objectives_cvar);
    CloseHandle(spawn_protection_cvar);
    CloseHandle(gungame_cvar);
    CloseHandle(buyzones_disabled_cvar);
    return;
  }

  map_name[3] = '\0';
  if (StrEqual(map_name, "gg_")) {
    SetConVarBool(round_timer_cvar, true);
    SetConVarBool(respawn_enabled_cvar, true);
    SetConVarBool(remove_objectives_cvar, true);
    SetConVarFloat(spawn_protection_cvar, 4.0);
    SetConVarBool(gungame_cvar, true);
    SetConVarBool(buyzones_disabled_cvar, true);
    SetConVarBool(weapon_cleanup_cvar, true);
    SetConVarBool(g_friendyfire_cvar, true);
  } else {
    SetConVarBool(round_timer_cvar, false);
    SetConVarBool(respawn_enabled_cvar, false);
    SetConVarBool(remove_objectives_cvar, false);
    SetConVarFloat(spawn_protection_cvar, 0.0);
    SetConVarBool(gungame_cvar, false);
    SetConVarBool(buyzones_disabled_cvar, false);
    SetConVarBool(weapon_cleanup_cvar, false);
  }

  CloseHandle(round_timer_cvar);
  CloseHandle(respawn_enabled_cvar);
  CloseHandle(remove_objectives_cvar);
  CloseHandle(spawn_protection_cvar);
  CloseHandle(gungame_cvar);
  CloseHandle(buyzones_disabled_cvar);
  CloseHandle(weapon_cleanup_cvar);
}

public void OnMapEnd() {
  SetConVarInt(g_airaccelerate_cvar, g_previous_airaccelerate);
  SetConVarInt(g_freezetime_cvar, g_previous_freezetime);
  SetConVarInt(g_gravity_cvar, g_previous_gravity);
  SetConVarBool(g_friendyfire_cvar, g_previous_friendlyfire);
}

public void OnPluginStart() {
  g_airaccelerate_cvar = FindConVar("sv_airaccelerate");
  g_previous_airaccelerate = GetConVarInt(g_airaccelerate_cvar);

  g_freezetime_cvar = FindConVar("mp_freezetime");
  g_previous_freezetime = GetConVarInt(g_freezetime_cvar);

  g_gravity_cvar = FindConVar("sv_gravity");
  g_previous_gravity = GetConVarInt(g_gravity_cvar);

  g_friendyfire_cvar = FindConVar("mp_friendlyfire");
  g_previous_friendlyfire = GetConVarBool(g_friendyfire_cvar);
}

public void OnPluginEnd() {
  SetConVarInt(g_airaccelerate_cvar, g_previous_airaccelerate);
  SetConVarInt(g_freezetime_cvar, g_previous_freezetime);
  SetConVarInt(g_gravity_cvar, g_previous_gravity);
  SetConVarBool(g_friendyfire_cvar, g_previous_friendlyfire);
}