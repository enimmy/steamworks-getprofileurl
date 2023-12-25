#include <sourcemod>
#include <SteamWorks>
#include <json>

#pragma newdecls required
#pragma semicolon 1

char g_sPlayerPictureUrl[MAXPLAYERS + 1][1024];

ConVar g_cvSteamWebAPIKey;

public Plugin myinfo =
{
	name = "steamworks-getprofileurl",
	author = "nimmy",
	description = "simple native/central cache for steam profile picture urls",
	version = "0.1",
	url = "https://github.com/Nimmy2222/GetProfileUrl"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("steamworks-profileurl");
	CreateNative("Sw_GetProfileUrl", Native_Sw_GetProfileUrl);
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_cvSteamWebAPIKey = CreateConVar("geturl-steam-api-key", "", "Allows the use of the player profile picture, leave blank to disable. The key can be obtained here: https://steamcommunity.com/dev/apikey", FCVAR_PROTECTED);

	for(int i = 1; i < MaxClients; i++)
	{
		if(IsClientConnected(i) && !IsFakeClient(i))
		{
			OnClientAuthorized(i, "");
		}
	}

	AutoExecConfig();
}

int Native_Sw_GetProfileUrl(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int size = GetNativeCell(3);
	if(StrEqual(g_sPlayerPictureUrl[client], ""))
	{
		return false;
	}

	if (SetNativeString(2, g_sPlayerPictureUrl[client], size) != SP_ERROR_NONE)
	{
		return false;
	}
	return true;
}

//listen

public void OnClientAuthorized(int client, const char[] auth)
{
	if(IsFakeClient(client))
	{
		return;
	}

	char apiKey[512];
	g_cvSteamWebAPIKey.GetString(apiKey, sizeof(apiKey));

	if(!StrEqual(apiKey, ""))
	{
		SteamAPIRequest(client);
	}
	else
	{
		g_sPlayerPictureUrl[client] = "";
	}
}

public void OnClientDisconnect(int client)
{
	g_sPlayerPictureUrl[client] = "";
}

//http

void SteamAPIRequest(int client)
{
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.Reset();

	char steamid[64];
	GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));
	char endpoint[1024];

	char apiKey[512];
	g_cvSteamWebAPIKey.GetString(apiKey, sizeof(apiKey));
	Format(endpoint, sizeof(endpoint), "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=%s&steamids=%s", apiKey, steamid);

	Handle request;
	if (!(request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, endpoint))
	  || !SteamWorks_SetHTTPRequestHeaderValue(request, "accept", "application/json")
	  || !SteamWorks_SetHTTPRequestContextValue(request, pack)
	  || !SteamWorks_SetHTTPRequestAbsoluteTimeoutMS(request, 4000)
	  || !SteamWorks_SetHTTPCallbacks(request, RequestCompletedCallback)
	  || !SteamWorks_SendHTTPRequest(request)
	)
	{
		delete pack;
		delete request;
		LogError("GetProfileUrl: failed to setup & send HTTP request");
	}
	return;
}

public void RequestCompletedCallback(Handle request, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, DataPack pack)
{
	if (bFailure || !bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK)
	{
		LogError("GetProfileUrl: API request failed");
		return;
	}
	SteamWorks_GetHTTPResponseBodyCallback(request, ResponseBodyCallback, pack);
}

void ResponseBodyCallback(const char[] data, DataPack pack)
{

	pack.Reset();
	int client = pack.ReadCell();
	delete pack;

	JSON_Object objects = view_as<JSON_Object>(json_decode(data));

	if (objects == INVALID_HANDLE || objects == null)
	{
		delete objects;
		g_sPlayerPictureUrl[client] = "";
	}

	char profilePictureUrl[1024];

	JSON_Object response = objects.GetObject("response");
	JSON_Array players = view_as<JSON_Array>(response.GetObject("players"));

	JSON_Object player;
	for (int i = 0; i < players.Length; i++)
	{
		player = view_as<JSON_Object>(players.GetObject(i));
		player.GetString("avatarmedium", profilePictureUrl, sizeof(profilePictureUrl));
	}

	json_cleanup_and_delete(objects);
	g_sPlayerPictureUrl[client] = profilePictureUrl;
	return;
}
