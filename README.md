# steamworks-getprofileurl
 
central plugin for managing profile picture URLs. all URLs are cached, so don't recache them, just call this plugin to populate your string. Since grabbing profile pictures requires an API key, having one central plugin allows server owners to only need to type it one time(if this is used).

 ## Cvar
 * geturl-steam-api-key - Allows the use of the player profile picture, leave blank to disable. The key can be obtained here: https://steamcommunity.com/dev/apikey

## Forward

The central plugin waits for OnClientAuthorized to get the profile picture, so to avoid plugins asking for a url too early, you can just listen for a forward. If you don't need the URL as soon as the player joins (idk too many situations you would honestly), then just don't listen for this, the function still returns false if the string is empty

```
/**
 * Called when a players Profile Url has been set. (Some time after OnAuthorized)
 * @param client    client whos url was cached
 */
```

* forward void Sw_ProfileUrlFound(int client);


## Native
```
Populates buffer with players profile picture URL. I'd recommend 1024 str length.
@param client    target client
@param buffer    buffer to populate
@param maxlen    sizeof(buffer)
@return          true on success, false if empty (no api key) or failure
```

* native bool Sw_GetProfileUrl(int client, char[] buffer, int maxlen);

Example:

```
public void Sw_ProfileUrlFound(int client)
{
	char profileurl[1024];
	if(Sw_GetProfileUrl(client, profileurl, sizeof(profileurl)))
	{
		//do stuff
	}
}
```
