#include <sdktools>
#include <sourcemod>

#define MAX_FLASHBANGS_PER_ROUND 2
#define MAX_HEGRENADES_PER_ROUND 2
#define MAX_SMOKEGRENADES_PER_ROUND 2

public const Plugin myinfo = {
    name = "Map Settings", author = "LAN of DOOM",
    description = "Sets map settings preferred by the LAN of DOOM",
    version = "1.6.0",
    url = "https://github.com/lanofdoom/counterstrikesource-map-settings"};

static Handle g_airaccelerate_cvar;
static Handle g_freezetime_cvar;
static Handle g_gravity_cvar;
static Handle g_friendyfire_cvar;

static int g_previous_airaccelerate;
static int g_previous_freezetime;
int g_previous_gravity;
bool g_previous_friendlyfire;

static ArrayList g_flashbangs;
static ArrayList g_hegrenades;
static ArrayList g_smokegrenades;

//
// Logic
//

static int GetGrenadeCount(int client, const char[] weapon_name) {
	int weapon = FindEntityByClassname(-1, weapon_name);
	if (weapon == INVALID_ENT_REFERENCE || !IsValidEntity(weapon)) {
		return -1;
  }

	int ammo_type = GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType");

	return GetEntProp(client, Prop_Send, "m_iAmmo", _, ammo_type);
}

static Action TryBuyGrenade(int userid, ArrayList list, int max) {
  while (userid <= list.Length) {
    list.Push(0);
  }

  int grenades = list.Get(userid) + 1;
  if (grenades >= max) {
    return Plugin_Stop;
  }

  list.Set(userid, grenades);

  return Plugin_Continue;
}

//
// Hooks
//

public void OnRoundStart(Event event, const char[] name, bool dont_broadcast) {  
  g_flashbangs.Clear();
  g_hegrenades.Clear();
  g_smokegrenades.Clear();

  for (int client = 0; client < MaxClients; client++) {
    if (!IsClientConnected(client)) {
      continue;
    }

    int userid = GetClientUserId(client);
    if (!userid) {
      continue;
    }

    while (g_flashbangs.Length <= userid) {
      g_flashbangs.Push(0);
      g_hegrenades.Push(0);
      g_smokegrenades.Push(0);
    }

    g_flashbangs.Set(userid, GetGrenadeCount(client, "weapon_flashbang"));
    g_hegrenades.Set(userid, GetGrenadeCount(client, "weapon_hegrenade"));
    g_smokegrenades.Set(userid, GetGrenadeCount(client, "weapon_somkegrenade"));
  }
}

//
// Forwards
//

public Action CS_OnBuyCommand(int client, const char[] weapon) {
  char map_name[PLATFORM_MAX_PATH];
  GetCurrentMap(map_name, PLATFORM_MAX_PATH);

  if (StrContains(map_name, "cs_") != 0 &&
      StrContains(map_name, "de_") != 0) {
    return Plugin_Continue;
  }

  int userid = GetClientUserId(client);
  if (!userid) {
    return Plugin_Continue;
  }

  if (StrEqual(weapon, "weapon_flashbang")) {
    return TryBuyGrenade(userid, g_flashbangs, MAX_FLASHBANGS_PER_ROUND);
  } else if (StrEqual(weapon, "weapon_hegrenade")) {
    return TryBuyGrenade(userid, g_hegrenades, MAX_HEGRENADES_PER_ROUND);
  } else if (StrEqual(weapon, "weapon_smokegrenade")) {
    return TryBuyGrenade(userid, g_smokegrenades, MAX_SMOKEGRENADES_PER_ROUND);
  } else {
    return Plugin_Continue;
  }
}

public void OnConfigsExecuted() {
  g_previous_airaccelerate = GetConVarInt(g_airaccelerate_cvar);
  g_previous_freezetime = GetConVarInt(g_freezetime_cvar);
  g_previous_gravity = GetConVarInt(g_gravity_cvar);
  g_previous_friendlyfire = GetConVarBool(g_friendyfire_cvar);

  char map_name[PLATFORM_MAX_PATH];
  GetCurrentMap(map_name, PLATFORM_MAX_PATH);

  if (StrEqual(map_name, "scoutzknivez")) {
    SetConVarInt(g_airaccelerate_cvar, 999999);
    SetConVarInt(g_gravity_cvar, 220);
  }

  if (StrContains(map_name, "aim_") == 0 ||
      StrContains(map_name, "fy_") == 0 ||
      StrEqual(map_name, "$2000$") ||
      StrEqual(map_name, "breakfloor") ||
      StrEqual(map_name, "fun_allinone_css_v2") ||
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

  Handle radar_disabled_cvar = FindConVar("sm_lanofdoom_radar_disabled");
  if (radar_disabled_cvar == INVALID_HANDLE) {
    CloseHandle(round_timer_cvar);
    CloseHandle(respawn_enabled_cvar);
    CloseHandle(remove_objectives_cvar);
    CloseHandle(spawn_protection_cvar);
    CloseHandle(gungame_cvar);
    CloseHandle(buyzones_disabled_cvar);
    return;
  }

  Handle paintball_enabled_cvar = FindConVar("sm_paintball_mode_enabled");
  if (paintball_enabled_cvar == INVALID_HANDLE) {
    CloseHandle(round_timer_cvar);
    CloseHandle(respawn_enabled_cvar);
    CloseHandle(remove_objectives_cvar);
    CloseHandle(spawn_protection_cvar);
    CloseHandle(gungame_cvar);
    CloseHandle(buyzones_disabled_cvar);
    CloseHandle(radar_disabled_cvar);
    return;
  }

  if (StrContains(map_name, "gg_") == 0) {
    SetConVarBool(round_timer_cvar, true);
    SetConVarBool(respawn_enabled_cvar, true);
    SetConVarBool(remove_objectives_cvar, true);
    SetConVarFloat(spawn_protection_cvar, 4.0);
    SetConVarBool(gungame_cvar, true);
    SetConVarBool(buyzones_disabled_cvar, true);
    SetConVarBool(radar_disabled_cvar, true);
    SetConVarBool(paintball_enabled_cvar, true);
    SetConVarBool(g_friendyfire_cvar, true);
  } else {
    SetConVarBool(round_timer_cvar, false);
    SetConVarBool(respawn_enabled_cvar, false);
    SetConVarBool(remove_objectives_cvar, false);
    SetConVarFloat(spawn_protection_cvar, 0.0);
    SetConVarBool(gungame_cvar, false);
    SetConVarBool(buyzones_disabled_cvar, false);
    SetConVarBool(radar_disabled_cvar, false);
    SetConVarBool(paintball_enabled_cvar, false);
  }

  CloseHandle(round_timer_cvar);
  CloseHandle(respawn_enabled_cvar);
  CloseHandle(remove_objectives_cvar);
  CloseHandle(spawn_protection_cvar);
  CloseHandle(gungame_cvar);
  CloseHandle(buyzones_disabled_cvar);
  CloseHandle(radar_disabled_cvar);
  CloseHandle(paintball_enabled_cvar);
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

  g_flashbangs = CreateArray();
  g_hegrenades = CreateArray();
  g_smokegrenades = CreateArray();

  HookEvent("round_start", OnRoundStart);
}

public void OnPluginEnd() {
  SetConVarInt(g_airaccelerate_cvar, g_previous_airaccelerate);
  SetConVarInt(g_freezetime_cvar, g_previous_freezetime);
  SetConVarInt(g_gravity_cvar, g_previous_gravity);
  SetConVarBool(g_friendyfire_cvar, g_previous_friendlyfire);
}