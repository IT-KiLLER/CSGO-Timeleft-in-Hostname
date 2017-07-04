
/*	Copyright (C) 2017 IT-KiLLER

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include <sourcemod>
#include <sdktools_gamerules>
#define PLUGIN_VERSION "2.0" 
#pragma semicolon 1
#pragma newdecls required

ConVar hostname, sm_hostname_update, mp_timelimit, sm_hostname;
Handle g_Timer;
char temp_Hostname[250], new_Hostname[250], time_minutes[5], time_seconds[5];
int timeleft, old_timeleft = -1;

public Plugin myinfo = 
{
	name = "[CS:GO] Timeleft in Hostname", 
	author = "AzaZPPL, IT-KILLER", 
	description = "Timeleft in server title or hostname.", 
	version = PLUGIN_VERSION, 
	url = "https://github.com/it-killer" // based on: https://github.com/AzaZPPL/Timeleft-in-Hostname
};

public void OnPluginStart()
{
	hostname = FindConVar("hostname");
	mp_timelimit = FindConVar("mp_timelimit");
	sm_hostname_update = CreateConVar("sm_hostname_update", "5", "Updates the hostname every x.x seconds.", _, true, 1.0, true, 30.0);
	sm_hostname = CreateConVar("sm_hostname", "", "sm_hostname <hostname>", _);
}

public void OnMapStart()
{
	g_Timer = CreateTimer(sm_hostname_update.FloatValue, SetHostnameTime, INVALID_HANDLE, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE	);
}

public Action SetHostnameTime(Handle h_timer)
{
	GetConVarString(sm_hostname, new_Hostname, sizeof (new_Hostname));
	GetMapTimeLeft(timeleft);
	if(StrEqual(new_Hostname, "")) {
		GetConVarString(hostname, temp_Hostname, sizeof (temp_Hostname));
		sm_hostname.SetString(temp_Hostname);
		hostname.Close();
		GetConVarString(sm_hostname, new_Hostname, sizeof (new_Hostname));
	}
	if (timeleft <= -1) {
		if (timeleft == old_timeleft) {
			FormatEx(time_minutes, sizeof(time_minutes), "%i", mp_timelimit.IntValue);
		} else {
			time_minutes = "00";
		}
		time_seconds = "00";
	} else {
		FormatEx(time_minutes, sizeof(time_minutes), "%s%i", ((timeleft / 60) < 10)? "0" : "", timeleft / 60);
		FormatEx(time_seconds, sizeof(time_seconds), "%s%i", ((timeleft % 60) < 10)? "0" : "", timeleft % 60);
	}
	if (StrContains(new_Hostname, "{{timeleft}}") >= 0) {
		char C_Time[15];
		if(GameRules_GetProp("m_bWarmupPeriod") == 1){
			FormatEx(C_Time, sizeof(C_Time), "WARMUP", time_minutes, time_seconds);
		} else if(timeleft == old_timeleft){
			// Future function here -1 == -1  mp_maxrounds
		} else if(timeleft <= -1){
			FormatEx(C_Time, sizeof(C_Time), "LAST ROUND", time_minutes, time_seconds);
		} else {
			FormatEx(C_Time, sizeof(C_Time), "%s:%s", time_minutes, time_seconds);
		}
		ReplaceString(new_Hostname, sizeof(new_Hostname), "{{timeleft}}", C_Time);
		} else {
		if(GameRules_GetProp("m_bWarmupPeriod") == 1){
			FormatEx(new_Hostname, sizeof(new_Hostname), "%s [WARMUP]", new_Hostname, time_minutes, time_seconds);
		} else if(timeleft == old_timeleft){
			// Future function here -1 == -1  mp_maxrounds
		} else if(timeleft <= -1){
			FormatEx(new_Hostname, sizeof(new_Hostname), "%s [LAST ROUND]", new_Hostname, time_minutes, time_seconds);
		} else {
			FormatEx(new_Hostname, sizeof(new_Hostname), "%s [%s:%s]", new_Hostname, time_minutes, time_seconds);
		}
	}
	hostname.SetString(new_Hostname);
	old_timeleft = timeleft;
	return Plugin_Continue;
}

public void OnMapEnd()
{
	GetConVarString(sm_hostname, temp_Hostname, sizeof (temp_Hostname));
	hostname.SetString(temp_Hostname);
	hostname.Close();
	old_timeleft = -1;
	KillTimer(g_Timer);
}

public void OnPluginEnd()
{
	GetConVarString(sm_hostname, temp_Hostname, sizeof (temp_Hostname));
	hostname.SetString(temp_Hostname);
	hostname.Close();
	KillTimer(g_Timer);
} 