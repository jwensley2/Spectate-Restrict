#include <sourcemod>
#undef REQUIRE_PLUGIN


// Defines
#define PLUGIN_VERSION "1.0.0"
#define RED_TEAM_INDEX 2
#define BLUE_TEAM_INDEX 3
#define SPEC_TEAM_NAME "spectate"

// Convar Handles
new Handle:cvar_restrict_blue = INVALID_HANDLE;
new Handle:cvar_restrict_red = INVALID_HANDLE;
new Handle:cvar_immunity = INVALID_HANDLE;
new Handle:cvar_immunity_flag = INVALID_HANDLE;


public Plugin:myinfo = 
{
	name = "Spectator Restrict",
	author = "Joseph Wensley",
	description = "Restricts players from changing to the spectator team",
	version = PLUGIN_VERSION,
	url = "http://addictiontogaming.com"
}

public OnPluginStart()
{
	cvar_restrict_blue = CreateConVar("spectators_restrict_blue", "0", "Restrict blue from changing to spectators", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvar_restrict_red = CreateConVar("spectators_restrict_red", "0", "Restrict red from changing to spectators", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvar_immunity = CreateConVar("spectators_restrict_immunity", "0", "Enable  admin immunity", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvar_immunity_flag = CreateConVar("spectators_restrict_immunity_flag", "b", "Anyone with this flag is immune", FCVAR_PLUGIN);
		
	AutoExecConfig(true);
	
	AddCommandListener(Hook_JoinTeam, "jointeam");
}


public Action:Hook_JoinTeam(client, const String:command[], argc)
{
	if(argc < 1) return Plugin_Handled;
	
	// Get the team id of the clients old team
	new old_team = GetClientTeam(client);
	
	// Get the team string of the clients new team
	decl String:new_team[32];
	GetCmdArg(1, new_team, sizeof(new_team));
	
	new bool:restrict_red = GetConVarBool(cvar_restrict_red);
	new bool:restrict_blue = GetConVarBool(cvar_restrict_blue);
	
	//Get admin immunity cvar
	new bool:immunity = GetConVarBool(cvar_immunity);
	
	// Get the admin immunity flag
	decl String:immunity_flag[2];
	GetConVarString(cvar_immunity_flag, immunity_flag, sizeof(immunity_flag));
	
	if(StrEqual(new_team, SPEC_TEAM_NAME, false))
	{
		if(IsAdmin(client, immunity_flag) && immunity)
		{
			return Plugin_Continue;
		}
		else if(old_team == RED_TEAM_INDEX && restrict_red)
		{
			return Plugin_Handled;
		}
		else if(old_team == BLUE_TEAM_INDEX && restrict_blue)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;

}

// Check if a user is an administrator
bool:IsAdmin(client, const String:flags[])
{
	new bits = GetUserFlagBits(client);	
	if (bits & ADMFLAG_ROOT)
		return true;
	new iFlags = ReadFlagString(flags);
	if (bits & iFlags)
		return true;	
	return false;
}