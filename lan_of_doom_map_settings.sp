#include <sourcemod>

#define MAX_MAP_NAME_LENGTH 256

Handle g_gravity_cvar;
int g_default_gravity;

public const Plugin myinfo = {
    name = "LAN of DOOM Map Settings",
    author = "LAN of DOOM",
    description = "Sets map settings preferred by the LAN of DOOM",
    version = "1.0.0",
    url = "https://github.com/lanofdoom/counterstrikesource-map-settings"};

public void OnMapStart() {
  char map_name[MAX_MAP_NAME_LENGTH];
  GetCurrentMap(map_name, MAX_MAP_NAME_LENGTH);

  if (StrEqual(map_name, "scoutzknivez")) {
    SetConVarInt(g_gravity_cvar, 220);
  } else {
    SetConVarInt(g_gravity_cvar, g_default_gravity);
  }
}

public void OnPluginStart() {
  g_gravity_cvar = FindConVar("sv_gravity");
  g_default_gravity = GetConVarInt(g_gravity_cvar);
}

public void OnPluginEnd() {
  SetConVarInt(g_gravity_cvar, g_default_gravity);
}