#include <unistd.h>
#include <lua.h>
#include <lauxlib.h>

static int l_sleep(lua_State *L);

static const struct luaL_reg aux[] =
{
    {"sleep", l_sleep},
    {NULL, NULL}
};

int luaopen_aux(lua_State *L)
{
    luaL_openlib(L, "aux", aux, 0);
    return 1;
}

static int l_sleep(lua_State *L)
{
    lua_Number interval = luaL_checknumber(L, 1);
    sleep((unsigned int) interval);
    return 0;
}