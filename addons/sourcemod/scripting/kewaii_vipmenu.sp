#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <csgocolors>

#define DMG_FALL   (1 << 5)

ConVar g_Cvar_NoFallDamageEnabled;
ConVar g_Cvar_NoFallSoundEnabled;

public Action SoundHook(clients[64], &numClients, String:sound[PLATFORM_MAX_PATH], &Ent, &channel, &Float:volume, &level, &pitch, &flags)
{
	if (view_as<bool>(GetConVarInt(g_Cvar_NoFallSoundEnabled)))
	{
	    if (StrEqual(sound, "player/damage1.wav", false)) return Plugin_Stop;
	    if (StrEqual(sound, "player/damage2.wav", false)) return Plugin_Stop;
	    if (StrEqual(sound, "player/damage3.wav", false)) return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action OnTakeDamage(int client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if ((damagetype & DMG_FALL) && view_as<bool>(GetConVarInt(g_Cvar_NoFallDamageEnabled)))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME 			"VipMenu"
#define PLUGIN_AUTHOR 			"Kewaii"
#define PLUGIN_DESCRIPTION		"General VipMenu"
#define PLUGIN_VERSION 			"1.7.3"
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
bool isUsingUnlimitedAmmo[MAXPLAYERS + 1] = false;

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
ConVar g_Cvar_BuffUnlimitedAmmoEnabled;
ConVar g_Cvar_AutoHelmetEnabled;
ConVar g_Cvar_AutoArmorEnabled;
ConVar g_Cvar_AutoArmorQuantity;
ConVar g_Cvar_VIPSpawnEnabled;
ConVar g_Cvar_HealthRegenEnabled;
ConVar g_Cvar_MaxHealthQuantity;
ConVar g_Cvar_HealthRegenedQuantity;

bool g_bAutoHelmetEnabled, g_bAutoArmorEnabled, g_bBuffUnlimitedAmmoEnabled;
int g_iAutoArmorQuantity;
int g_iMaxHealth, g_iHealthRegenedQuantity;
bool g_bWeaponsEnabled, g_bBuffsEnabled, g_bWeaponAWPEnabled, g_bWeaponAK47Enabled, g_bWeaponM4A1Enabled, g_bWeaponM4A1_SilencerEnabled, g_bBuffMedicKitEnabled, g_bBuffWHEnabled;

public void OnPluginStart()
{
	g_Cvar_BenefitsMax = CreateConVar("kewaii_vipmenu_benefits_max", "3", "Maximum allowed amount of benefits per round");
	
	g_Cvar_WeaponsEnabled = CreateConVar("kewaii_vipmenu_weapons", "1", "Enables/Disables Weapons", _, true, 0.0, true, 1.0);
	g_Cvar_WeaponsMax = CreateConVar("kewaii_vipmenu_weapons_max", "2", "Maximum allowed amount of weapons per round");
	
	g_Cvar_BuffsEnabled = CreateConVar("kewaii_vipmenu_buffs", "1", "Enables/Disables Buffs", _, true, 0.0, true, 1.0);
	g_Cvar_BuffsMax = CreateConVar("kewaii_vipmenu_buffs_max", "2", "Maximum allowed amount of buffs per round");
	
	g_Cvar_WeaponAWPEnabled = CreateConVar("kewaii_vipmenu_weapon_awp", "1", "Enables/Disables AWP", _, true, 0.0, true, 1.0);
	g_Cvar_WeaponAK47Enabled = CreateConVar("kewaii_vipmenu_weapon_ak47", "1", "Enables/Disables AK47", _, true, 0.0, true, 1.0);
	g_Cvar_WeaponM4A1Enabled = CreateConVar("kewaii_vipmenu_weapon_m4a1", "1", "Enables/Disables M4A4", _, true, 0.0, true, 1.0);
	g_Cvar_WeaponM4A1_SilencerEnabled = CreateConVar("kewaii_vipmenu_weapon_m4a1_silencer", "1", "Enables/Disables M4A1-S", _, true, 0.0, true, 1.0);
	
	g_Cvar_BuffWHEnabled = CreateConVar("kewaii_vipmenu_buff_wh", "1", "Enables/Disables WH Grenade", _, true, 0.0, true, 1.0);
	g_Cvar_BuffMedicKitEnabled = CreateConVar("kewaii_vipmenu_buff_medickit", "1", "Enables/Disables Medic Kit", _, true, 0.0, true, 1.0);
	
	g_Cvar_BuffUnlimitedAmmoEnabled = CreateConVar("kewaii_vipmenu_buff_unlimitedammo", "1", "Enables/Disables Unlimited Ammo", _, true, 0.0, true, 1.0);
	
	g_Cvar_AutoHelmetEnabled = CreateConVar("kewaii_vipmenu_auto_helmet", "1", "Enables/Disables Helmet on Spawn", _, true, 0.0, true, 1.0);
	g_Cvar_AutoArmorEnabled = CreateConVar("kewaii_vipmenu_auto_armor", "1", "Enables/Disables Armor on Spawn", _, true, 0.0, true, 1.0);
	g_Cvar_AutoArmorQuantity = CreateConVar("kewaii_vipmenu_auto_armorquantity", "100", "Defines Armor Quantity", _, true, 1.0, true, 500.0);
	
	g_Cvar_VIPSpawnEnabled = CreateConVar("kewaii_vipmenu_vipspawn", "1", "Enables/Disables VIPSpawn", _, true, 0.0, true, 1.0);
	
	g_Cvar_HealthRegenEnabled = CreateConVar("kewaii_vipmenu_healthregen", "1", "Enables/Disables Health Regen", _, true, 0.0, true, 1.0);
	g_Cvar_HealthRegenedQuantity = CreateConVar("kewaii_vipmenu_healthregened", "10", "Defines Quantity of Health Regened per kill", _, true, 1.0, true, 50.0);
	g_Cvar_MaxHealthQuantity = CreateConVar("kewaii_vipmenu_maxhealth", "150", "Defines Max Health that a player can get", _, true, 101.0, true, 500.0);
	g_Cvar_NoFallSoundEnabled = CreateConVar("kewaii_nofallsound", "1", "Enables/Disables No Fall Sound, 1 = No Sound / 0 = Sound", _, true, 0.0, true, 1.0);
	g_Cvar_NoFallDamageEnabled = CreateConVar("kewaii_nofalldamage", "1", "Enables/Disables No Fall Damage, 1 = No Damage / 0 = Damage", _, true, 0.0, true, 1.0);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("weapon_fire", ClientWeaponReload);
	HookEvent("player_death", OnPlayerDeath);
	RegConsoleCmd("sm_vipspawn", Command_VIPSpawn);
	RegConsoleCmd("sm_vipmenu", VipMenu, "Opens VIPMenu");
	
	AutoExecConfig(true, "kewaii_vipmenu");
	
	LoadTranslations("kewaii_vipmenu.phrases");
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
	AddNormalSoundHook(SoundHook);
}

public Action OnPlayerDeath(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "attacker"));
	int dead = GetClientOfUserId(GetEventInt(event, "userid"));
	if (view_as<bool>(GetConVarInt(g_Cvar_HealthRegenEnabled)))
	{
		if (HasClientFlag(client, ADMFLAG_CUSTOM1))
		{
			int OldHealth = GetEntProp(client, Prop_Send, "m_iHealth", 4, 0);
			if (dead != client)
			{
				if (GetClientTeam(client) > 1)
				{				
					g_iHealthRegenedQuantity = GetConVarInt(g_Cvar_HealthRegenedQuantity);
					g_iMaxHealth = GetConVarInt(g_Cvar_MaxHealthQuantity);
					if (g_iHealthRegenedQuantity + OldHealth > g_iMaxHealth)
					{	
						SetEntProp(client, Prop_Send, "m_iHealth", g_iMaxHealth, 4, 0);
					}
					else
					{
						SetEntProp(client, Prop_Send, "m_iHealth", OldHealth + g_iHealthRegenedQuantity, 4, 0);
					}
				}
			}
		}
	}
}
public Action VipMenu(int client, int args)
{
	if (HasClientFlag(client, ADMFLAG_CUSTOM1))
	{
		if (GetClientTeam(client) > 1)
		{
			CreateMainMenu().Display(client, MENU_TIME_FOREVER);
		}
	}
	return Plugin_Handled;
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	MaxBenefits = GetConVarInt(g_Cvar_BenefitsMax);
	MaxWeapons = GetConVarInt(g_Cvar_WeaponsMax);
	MaxExtras = GetConVarInt(g_Cvar_BuffsMax);
	g_iAutoArmorQuantity = GetConVarInt(g_Cvar_AutoArmorQuantity);
	g_bAutoArmorEnabled = view_as<bool> (GetConVarInt(g_Cvar_AutoArmorEnabled));
	g_bAutoHelmetEnabled = view_as<bool> (GetConVarInt(g_Cvar_AutoHelmetEnabled));
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i)) 
		{
			if (HasClientFlag(i, ADMFLAG_CUSTOM1))
			{
				if (GetClientTeam(i) > 1)
				{
					CreateMainMenu().Display(i, MENU_TIME_FOREVER);		
					if (g_bAutoArmorEnabled)
					{
						SetEntProp(i, Prop_Send, "m_ArmorValue", g_iAutoArmorQuantity);
					}
					if (g_bAutoHelmetEnabled)
					{
						SetEntProp(i, Prop_Send, "m_bHasHelmet", 1);
					}		
				}			
				BenefitsChosen[i] = 0;
				extrasChosen[i] = 0;
				weaponsChosen[i] = 0;
				revived[i] = false;			
			}
			isUsingUnlimitedAmmo[i] = false;
        }
    }
 
}

Menu CreateBuffsMenu()
{
	Menu menu = new Menu(BuffsMenuHandler);
	menu.SetTitle("Buffs Menu by Kewaii");	
	g_bBuffWHEnabled = view_as<bool> (GetConVarInt(g_Cvar_BuffWHEnabled));
	g_bBuffMedicKitEnabled = view_as<bool> (GetConVarInt(g_Cvar_BuffMedicKitEnabled));
	g_bBuffUnlimitedAmmoEnabled = view_as<bool> (GetConVarInt(g_Cvar_BuffUnlimitedAmmoEnabled));
	if (g_bBuffWHEnabled) { 
		menu.AddItem("WH", "Granada de WallHack");
	}
	if (g_bBuffMedicKitEnabled) { 
		menu.AddItem("Medkit", "MedKit");	
	}
	if (g_bBuffUnlimitedAmmoEnabled) { 
		menu.AddItem("UnlimitedAmmo", "Balas Infinitas");	
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
		if (g_bBuffUnlimitedAmmoEnabled) { 
			menu.AddItem("UnlimitedAmmo", "Balas Infinitas");	
		}	
	}
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
					if (StrEqual(menuIdStr, "UnlimitedAmmo"))
					{
						CPrintToChat(client, "%s Escolheste o bônus: {red}Balas Infinitas{green}.", PLUGIN_TAG);
						isUsingUnlimitedAmmo[client] = true;
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
	
	if (view_as<bool> (GetConVarInt(g_Cvar_VIPSpawnEnabled)))
	{
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
	}
	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponEquipPost, EventItemPickup2);
}

public void ClientWeaponReload(Handle event, const char [] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event,  "userid"));
    SetUnlimitedAmmo(client);
}

void SetUnlimitedAmmo(int client)
{
	if (view_as<bool> (GetConVarInt(g_Cvar_BuffUnlimitedAmmoEnabled)))
	{
		if(IsPlayerAlive(client))
		{
			if (HasClientFlag(client, ADMFLAG_CUSTOM1))
			{
				if (isUsingUnlimitedAmmo[client])
				{
					SetPrimaryAmmo(client, 201);
				}
			}
		}
	}
}

int SetPrimaryAmmo(int client, int ammo)
{
	int iWeapon = GetEntDataEnt2(client, FindSendPropInfo("CCSPlayer", "m_hActiveWeapon"));
	return SetEntData(iWeapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), ammo);
}

public Action EventItemPickup2(int client, int weapon)
{
	if (view_as<bool> (GetConVarInt(g_Cvar_BuffUnlimitedAmmoEnabled)))
	{
		if (HasClientFlag(client, ADMFLAG_CUSTOM1)) 
		{
			if (isUsingUnlimitedAmmo[client])
			{
				SetPrimaryAmmo(client, 201);
			}
		}
	}
}

public bool HasClientFlag(int client, int flag)
{
	return CheckCommandAccess(client, "", flag, true);
}
