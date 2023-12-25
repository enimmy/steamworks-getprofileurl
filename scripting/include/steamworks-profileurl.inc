#if defined _getprofileurl_included
	#endinput
#endif
#define _getprofileurl_included

public SharedPlugin __pl_getprofileurl =
{
    name = "steamworks-profileurl",
    file = "steamworks-profileurl.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_getprofileurl_SetNTVOptional()
{
    MarkNativeAsOptional("Sw_GetProfileUrl");
}
#endif

native bool Sw_GetProfileUrl(int client, char[] buffer, int maxlen);
