#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <csgocolors>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME 			"VipMenu"
#define PLUGIN_AUTHOR 			"Kewaii"
#define PLUGIN_DESCRIPTION		"General VipMenu"
#define PLUGIN_VERSION 			"1.6.4"
#define PLUGIN_TAG 				"{pink}[VipMenu by Kewaii]{green}"

public Plugin myinfo =
{
    name				=    PLUGIN_NAME,
    author				=    PLUGIN_AUTHOR,
    description			=    PLUGIN_DESCRIPTION,
    version				=    PLUGIN_VERSION,
    url					= 	   "http://steamcommunity.com/id/KewaiiGamer/"
};

bool revived[MAXPLAYERS+1] = false;
bool choseOnce[MAXPLAYERS + 1] = false;

int BenefitsChosen[MAXPLAYERS + 1] = 0;
int extrasChosen[MAXPLAYERS + 1] = 0;
int weaponsChosen[MAXPLAYERS + 1] = 0;

int MaxBenefits;
int MaxExtras;
int MaxWeapons;

ConVar g_Cvar_BenefitsMax;
ConVar g_Cvar_WeaponsEnabled;
ConVar g_Cvar_WeaponsMax;
ConVar g_Cvar_BuffsEnabled;
ConVar g_Cvar_BuffsMax;
ConVar g_Cvar_WeaponAWPEnabled;
ConVar g_Cvar_WeaponAK47Enabled;
ConVar g_Cvar_WeaponM4A1Enabled;
ConVar g_Cvar_WeaponM4A1_SilencerEnabled;
ConVar g_Cvar_BuffWHEnabled;
ConVar g_Cvar_BuffMedicKitEnabled;

bool g_bWeaponsEnabled, g_bBuffsEnabled, g_bWeaponAWPEnabled, g_bWeaponAK47Enabled, g_bWeaponM4A1Enabled, g_bWeaponM4A1_SilencerEnabled, g_bBuffMedicKitEnabled, g_bBuffWHEnabled;
public void OnPluginStart()
{
	g_Cvar_BenefitsMax = CreateConVar("kewaii_vipmenu_benefits_max", "3", "Maximum allowed amount of benefits per round");
	
	g_Cvar_WeaponsEnabled = CreateConVar("kewaii_vipmenu_weapons", "1", "Enables/Disables Weapons");
	g_Cvar_WeaponsMax = CreateConVar("kewaii_vipmenu_weapons_max", "2", "Maximum allowed amount of weapons per round");
	
	g_Cvar_BuffsEnabled = CreateConVar("kewaii_vipmenu_buffs", "1", "Enables/Disables Buffs");
	g_Cvar_BuffsMax = CreateConVar("kewaii_vipmenu_buffs_max", "2", "Maximum allowed amount of buffs per round");
	
	g_Cvar_WeaponAWPEnabled = CreateConVar("kewaii_vipmenu_weapon_awp", "1", "Enables/Disables AWP");
	g_Cvar_WeaponAK47Enabled = CreateConVar("kewaii_vipmenu_weapon_ak47", "1", "Enables/Disables AK47");
	g_Cvar_WeaponM4A1Enabled = CreateConVar("kewaii_vipmenu_weapon_m4a1", "1", "Enables/Disables M4A4");
	g_Cvar_WeaponM4A1_SilencerEnabled = CreateConVar("kewaii_vipmenu_weapon_m4a1_silencer", "1", "Enables/Disables M4A1-S");
	
	g_Cvar_BuffWHEnabled = CreateConVar("kewaii_vipmenu_buff_wh", "1", "Enables/Disables WH Grenade");
	g_Cvar_BuffMedicKitEnabled = CreateConVar("kewaii_vipmenu_buff_medickit", "1", "Enables/Disables Medic Kit");
	HookEvent("round_start", Event_RoundStart);
	RegConsoleCmd("sm_vipspawn", Command_VIPSpawn);
	RegConsoleCmd("sm_vipmenu", VipMenu, "Opens VIPMenu");
	AutoExecConfig(true, "kewaii_vipmenu");
	MaxBenefits = GetConVarInt(g_Cvar_BenefitsMax);
	MaxWeapons = GetConVarInt(g_Cvar_WeaponsMax);
	MaxExtras = GetConVarInt(g_Cvar_BuffsMax);
}

public Action VipMenu(int client, int args)
{
	if (HasClientFlag(client, ADMFLAG_CUSTOM1))
	{
		CreateMainMenu().Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i)) 
		{
			if (HasClientFlag(i, ADMFLAG_CUSTOM1))
			{
				CreateMainMenu().Display(i, MENU_TIME_FOREVER);			
				BenefitsChosen[i] = 0;
				extrasChosen[i] = 0;
				weaponsChosen[i] = 0;
				revived[i] = false;
			}
        }
    }
}

Menu CreateBuffsMenu()
{
	Menu menu = new Menu(BuffsMenuHandler);
	menu.SetTitle("Buffs Menu by Kewaii");	
	g_bBuffWHEnabled = view_as<bool> (GetConVarInt(g_Cvar_BuffWHEnabled));
	g_bBuffMedicKitEnabled = view_as<bool> (GetConVarInt(g_Cvar_BuffMedicKitEnabled));
	if (g_bBuffWHEnabled) { 
		menu.AddItem("WH", "Granada de WallHack");
	}
	if (g_bBuffMedicKitEnabled) { 
		menu.AddItem("Medkit", "MedKit");	
	}
	menu.ExitBackButton = true;
	return menu;
}

Menu CreateWeaponsMenu()
{
	Menu menu = new Menu(WeaponsMenuHandler);
	menu.SetTitle("Weapons Menu by Kewaii");	
	g_bWeaponAWPEnabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponAWPEnabled));
	g_bWeaponAK47Enabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponAK47Enabled));
	g_bWeaponM4A1Enabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponM4A1Enabled));
	g_bWeaponM4A1_SilencerEnabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponM4A1_SilencerEnabled));
	if (g_bWeaponAWPEnabled) {
		menu.AddItem("AWP_Deagle", "AWP & Deagle");
	}	
	if (g_bWeaponAK47Enabled) {
		menu.AddItem("AK47_Deagle", "AK47 & Deagle");
	}
	if (g_bWeaponM4A1Enabled) {
		menu.AddItem("M4A4_Deagle", "M4A4 & Deagle");
	}
	if (g_bWeaponM4A1_SilencerEnabled) {
		menu.AddItem("M4A1S_Deagle", "M4A1S & Deagle");
	}
	menu.ExitBackButton = true;
	return menu;
}

Menu CreateMainMenu()
{
	Menu menu;
	g_bWeaponsEnabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponsEnabled));
	g_bWeaponAWPEnabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponAWPEnabled));
	g_bWeaponAK47Enabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponAK47Enabled));
	g_bWeaponM4A1Enabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponM4A1Enabled));
	g_bWeaponM4A1_SilencerEnabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponM4A1_SilencerEnabled));
	g_bWeaponsEnabled = view_as<bool> (GetConVarInt(g_Cvar_WeaponsEnabled));
	g_bBuffsEnabled = view_as<bool> (GetConVarInt(g_Cvar_BuffsEnabled));
	g_bBuffWHEnabled = view_as<bool> (GetConVarInt(g_Cvar_BuffWHEnabled));
	g_bBuffMedicKitEnabled = view_as<bool> (GetConVarInt(g_Cvar_BuffMedicKitEnabled));
	if (g_bWeaponsEnabled && g_bBuffsEnabled) {
		menu = new Menu(MainMenuHandler);
		menu.SetTitle("Vip Menu by Kewaii");	
		menu.AddItem("Weapons", "Armas");
		menu.AddItem("Buffs", "Buffs");
	}
	else if (g_bWeaponsEnabled) {
		menu = new Menu(WeaponsMenuHandler);
		menu.SetTitle("Vip Menu by Kewaii");
		if (g_bWeaponAWPEnabled) {
			menu.AddItem("AWP_Deagle", "AWP & Deagle");
		}	
		if (g_bWeaponAK47Enabled) {
			menu.AddItem("AK47_Deagle", "AK47 & Deagle");
		}
		if (g_bWeaponM4A1Enabled) {
			menu.AddItem("M4A4_Deagle", "M4A4 & Deagle");
		}
		if (g_bWeaponM4A1_SilencerEnabled) {
			menu.AddItem("M4A1S_Deagle", "M4A1S & Deagle");
		}
	}
	else if (g_bBuffsEnabled) {
		menu = new Menu(BuffsMenuHandler);
		menu.SetTitle("Vip Menu by Kewaii");
		if (g_bBuffWHEnabled) { 
			menu.AddItem("WH", "Granada de WallHack");
		}
		if (g_bBuffMedicKitEnabled) { 
			menu.AddItem("Medkit", "MedKit");	
		}	
	}
	/*
	if (g_bWeaponsEnabled && (g_bWeaponAWPEnabled || g_bWeaponAK47Enabled || g_bWeaponM4A1Enabled || g_bWeaponM4A1_SilencerEnabled)) {
		menu.AddItem("Weapons", "Armas");		
	}
	if (g_bBuffsEnabled && (g_bBuffWHEnabled || g_bBuffMedicKitEnabled)) {
		menu.AddItem("Buffs", "Buffs");	
	}
	*/
	menu.AddItem("Leave", "Sair");
	menu.ExitButton = false;
	return menu;
}

public int BuffsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char menuIdStr[32];
				menu.GetItem(selection, menuIdStr, sizeof(menuIdStr));
				if (extrasChosen[client] < MaxExtras && BenefitsChosen[client] < MaxBenefits)
				{				
					if (StrEqual(menuIdStr, "Medkit"))
					{		
						CPrintToChat(client, "%s Escolheste o bônus: {red}Medic Kit{green}.", PLUGIN_TAG);
						GivePlayerItem(client, "weapon_healthshot");
						extrasChosen[client]++;
						BenefitsChosen[client]++;
					}
					if (StrEqual(menuIdStr, "WH"))
					{
						CPrintToChat(client, "%s Escolheste o bônus: {red}Granada de WallHack{green}.", PLUGIN_TAG);
						GivePlayerItem(client, "weapon_tagrenade");
						extrasChosen[client]++;
						BenefitsChosen[client]++;
					}
				}
				else
				{
					CPrintToChat(client, "%s Já chegaste ao máximo de buffs esta ronda", PLUGIN_TAG);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				CreateMainMenu().Display(client, 15);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int WeaponsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char menuIdStr[32];
				menu.GetItem(selection, menuIdStr, sizeof(menuIdStr));
				if (weaponsChosen[client] < MaxWeapons && BenefitsChosen[client] < MaxBenefits)
				{		
					if (StrEqual(menuIdStr, "AWP_Deagle"))
					{
						CPrintToChat(client, "%s Escolheste o bônus: {red}AWP e Deagle{green}.", PLUGIN_TAG);
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
						if(wep != -1) 
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_awp");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						choseOnce[client] = true;
					}
					if (StrEqual(menuIdStr, "AK47_Deagle"))
					{
						CPrintToChat(client, "%s Escolheste o bônus: {red}AK47 e Deagle{green}.", PLUGIN_TAG);
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
						if(wep != -1) 
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_ak47");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						choseOnce[client] = true;
					}
					if (StrEqual(menuIdStr, "M4A4_Deagle"))
					{
						CPrintToChat(client, "%s Escolheste o bônus: {red}M4A4 e Deagle{green}.", PLUGIN_TAG);
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
						if(wep != -1) 
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_m4a1");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						choseOnce[client] = true;
					}
					if (StrEqual(menuIdStr, "M4A1S_Deagle"))
					{
						CPrintToChat(client, "%s Escolheste o bônus: {red}M4A1-S e Deagle{green}.", PLUGIN_TAG);
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
						if(wep != -1) 
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_m4a1_silencer");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						choseOnce[client] = true;
					}
					if(choseOnce[client])
					{
						weaponsChosen[client]++;
						BenefitsChosen[client]++;
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
						if(wep != -1)
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_deagle");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						choseOnce[client] = false;
					}
				}
				else
				{
					CPrintToChat(client, "%s Já chegaste ao máximo de armas esta ronda", PLUGIN_TAG);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(client) && selection == MenuCancel_ExitBack)
			{
				CreateMainMenu().Display(client, 15);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int MainMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char menuIdStr[32];
				menu.GetItem(selection, menuIdStr, sizeof(menuIdStr));
				if (StrEqual(menuIdStr, "Weapons"))
				{
					CreateWeaponsMenu().Display(client, MENU_TIME_FOREVER);
				}
				if (StrEqual(menuIdStr, "Buffs"))
				{
					CreateBuffsMenu().Display(client, MENU_TIME_FOREVER);
				}
				if (StrEqual(menuIdStr, "Leave"))
				{
					delete menu;
				}
			}
		}
	}
}

public Action Command_VIPSpawn(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("%t","Command is in-game only");
		return Plugin_Handled;
	}
	
	if (!IsPlayerAlive(client))
	{
		if (HasClientFlag(client, ADMFLAG_CUSTOM1))
		{
			if (revived[client] == false) 
			{			
				CS_RespawnPlayer(client);
				CPrintToChatAll("%s O jogador{red} %N {green}foi revivido!", PLUGIN_TAG, client);
				revived[client] = true;
			}
		}
		else
		{
			CPrintToChat(client, "%s Se queres reviver tens que comprar {red}VIP{green}. faz {red}!vip", PLUGIN_TAG);		
		}
	}
	else
	{
		CPrintToChat(client, "%s Não Estás morto", PLUGIN_TAG);
	}
	return Plugin_Handled;
}

public bool HasClientFlag(int client, int flag)
{
	return CheckCommandAccess(client, "", flag, true);
}
