# steamworks-getprofileurl
 
central plugin for managing profile picture URLs. all URLs are cached, so don't recache them, just call this plugin to populate your string. Since grabbing profile pictures requires an API key, having one central plugin allows server owners to only need to type it one time(if this is used). Having multiple plugins cache these URLs is a very tiny bit expensive and sending out request after request isn't great either.

 ## Cvar
 * geturl-steam-api-key - Allows the use of the player profile picture, leave blank to disable. The key can be obtained here: https://steamcommunity.com/dev/apikey

## Native
```
Populates buffer with players profile picture URL. I'd recommend 1024 str length.
@param client    target client
@param buffer    buffer to populate
@param maxlen    sizeof(buffer)
@return          true on success, false if empty (no api key) or failure
```
native bool Sw_GetProfileUrl(int client, char[] buffer, int maxlen);

Example from my version of shavit-discord
```
	char playerProfilePicture[1024];
	if(Sw_GetProfileUrl(client, playerProfilePicture, sizeof(playerProfilePicture))) //Dont set the JSON string if the function returns false
	{
		author.SetString("icon_url", playerProfilePicture); //If the plugin got here, the string must've populated with something
	}
```
