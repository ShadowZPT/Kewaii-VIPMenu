#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <csgocolors>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME 			"VipMenu"
#define PLUGIN_AUTHOR 			"Kewaii"
#define PLUGIN_DESCRIPTION		"General VipMenu"
#define PLUGIN_VERSION 			"1.6.1"
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

int MaxBenefits = 3;
int MaxExtras = 2;
int MaxWeapons = 2;

public void OnPluginStart()
{
    HookEvent("round_start", Event_RoundStart);
    RegConsoleCmd("sm_vipspawn", Command_VIPSpawn);
    RegConsoleCmd("sm_vipmenu", VipMenu, "Opens VIPMenu");
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
			}
        }
    }
}

Menu CreateBuffsMenu()
{
	Menu menu = new Menu(BuffsMenuHandler);
	menu.SetTitle("Buffs Menu by Kewaii");		
	menu.AddItem("WH", "Granada de WallHack");
	menu.AddItem("Medkit", "MedKit");	
	menu.ExitBackButton = true;
	return menu;
}

Menu CreateWeaponsMenu()
{
	Menu menu = new Menu(WeaponsMenuHandler);
	menu.SetTitle("Weapons Menu by Kewaii");	
	menu.AddItem("AWP_Deagle", "AWP & Deagle");
	menu.AddItem("AK47_Deagle", "AK47 & Deagle");
	menu.AddItem("M4A4_Deagle", "M4A4 & Deagle");
	menu.AddItem("M4A1S_Deagle", "M4A1S & Deagle");
	menu.ExitBackButton = true;
	return menu;
}

Menu CreateMainMenu()
{
	Menu menu = new Menu(MainMenuHandler);
	menu.SetTitle("Vip Menu by Kewaii");	
	menu.AddItem("Weapons", "Armas");
	menu.AddItem("Buffs", "Buffs");
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
