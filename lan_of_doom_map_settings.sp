#include <sourcemod>

#define MAX_MAP_NAME_LENGTH 256

Handle g_airaccelerate_cvar;
int g_previous_airaccelerate;

Handle g_freezetime_cvar;
int g_previous_freezetime;

Handle g_gravity_cvar;
int g_previous_gravity;

public const Plugin myinfo = {
    name = "LAN of DOOM Map Settings",
    author = "LAN of DOOM",
    description = "Sets map settings preferred by the LAN of DOOM",
    version = "1.2.0",
    url = "https://github.com/lanofdoom/counterstrikesource-map-settings"};

public void OnConfigsExecuted() {
  g_previous_airaccelerate = GetConVarInt(g_airaccelerate_cvar);
  g_previous_freezetime = GetConVarInt(g_freezetime_cvar);
  g_previous_gravity = GetConVarInt(g_gravity_cvar);

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

  Handle deathmatch_cvar = FindConVar("sm_lanofdoom_deathmatch_enabled");
  if (deathmatch_cvar == INVALID_HANDLE) {
    return;
  }

  Handle gungame_cvar = FindConVar("sm_lanofdoom_gungame_enabled");
  if (gungame_cvar == INVALID_HANDLE) {
    CloseHandle(deathmatch_cvar);
    return;
  }

  map_name[4] = '\0';
  if (StrEqual(map_name, "gg_")) {
    SetConVarBool(deathmatch_cvar, true);
    SetConVarBool(gungame_cvar, true);
  } else {
    SetConVarBool(deathmatch_cvar, false);
    SetConVarBool(gungame_cvar, false);
  }

  CloseHandle(deathmatch_cvar);
  CloseHandle(gungame_cvar);
}

public void OnMapEnd() {
  SetConVarInt(g_airaccelerate_cvar, g_previous_airaccelerate);
  SetConVarInt(g_freezetime_cvar, g_previous_freezetime);
  SetConVarInt(g_gravity_cvar, g_previous_gravity);
}

public void OnPluginStart() {
  g_airaccelerate_cvar = FindConVar("sv_airaccelerate");
  g_previous_airaccelerate = GetConVarInt(g_airaccelerate_cvar);

  g_freezetime_cvar = FindConVar("mp_freezetime");
  g_previous_freezetime = GetConVarInt(g_freezetime_cvar);

  g_gravity_cvar = FindConVar("sv_gravity");
  g_previous_gravity = GetConVarInt(g_gravity_cvar);
}

public void OnPluginEnd() {
  SetConVarInt(g_airaccelerate_cvar, g_previous_airaccelerate);
  SetConVarInt(g_freezetime_cvar, g_previous_freezetime);
  SetConVarInt(g_gravity_cvar, g_previous_gravity);
}