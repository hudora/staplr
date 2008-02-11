#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/time.h>
#include <lua.h>
#include <lauxlib.h>

#define KEY_F1  0x81
#define KEY_F2  0x82
#define KEY_F3  0x83
#define KEY_F4  0x84
#define KEY_F5  0x85

struct _K_TAB {
    char *s;
    int k;
};

struct _K_TAB key_tab[] = {
    { "[[A", KEY_F1 }, 
    { "[[B", KEY_F2 }, 
    { "[[C", KEY_F3 }, 
    { "[[D", KEY_F4 }, 
    { "[[E", KEY_F5 }, 
    { NULL, 0}
};

static struct termios saved_state;
static int tty_fd;

static int l_init_tty(lua_State *L);
static int l_restore_tty(lua_State *L);
static int l_readkey(lua_State *L);

static const struct luaL_reg keyb[] =
{
    {"init_tty", l_init_tty},
    {"restore_tty", l_restore_tty},
    {"readkey", l_readkey},
    {NULL, NULL}
};

static int keyb_get(void);
static int keyb_wait(int);
static int keyb_wait_esc(int);

int luaopen_keyb(lua_State *L)
{
    luaL_openlib(L, "keyb", keyb, 0);
    return 1;
}

static int l_init_tty(lua_State *L)
{
    struct termios s;
    const char *tty = luaL_checkstring(L, 1);
    if((tty_fd = open(tty, O_RDONLY)) < 0)
    {
        // raise error!
        return 0;
    }
    
    tcgetattr(tty_fd, &s);
    saved_state = s;
    s.c_lflag &= ~(0
#ifdef ICANON
                        | ICANON
#endif
#ifdef ECHO
                        | ECHO
#endif
#ifdef ECHOE
                        | ECHOE
#endif
#ifdef ECHOK
                        | ECHOK
#endif
#if ECHONL
                        | ECHONL
#endif    
    );
    
    tcsetattr(tty_fd, TCSADRAIN, &s);
    return 0;
}

static int l_restore_tty(lua_State *L)
{
    tcsetattr(tty_fd, TCSADRAIN, &saved_state);
    close(tty_fd);
    return 0;
}

static int l_readkey(lua_State *L)
{
    int key = keyb_wait_esc(10);
    char *fkey;

    switch(key) {
        case KEY_F1:
            fkey = "F1";
            break;
        case KEY_F2:
            fkey = "F2";
            break;
        case KEY_F3:
            fkey = "F3";
            break;
        case KEY_F4:
            fkey = "F4";
            break;
        case KEY_F5:
            fkey = "F5";
            break;
        default:
            fkey = "UNKNOWN";
    }
    lua_pushlstring(L, fkey, strlen(fkey));
    return 1;
}

/* private functions */
static int keyb_get(void)
{
    int key = 0;
    if(read(tty_fd, &key, sizeof(char)) != 1)
        return -1;
    return key;
}

static int keyb_wait(int msec)
{
    fd_set rfds;
    struct timeval tv;

    FD_ZERO(&rfds);
    FD_SET(tty_fd, &rfds);

	tv.tv_sec = msec / 1000;
	tv.tv_usec = (msec % 1000) * 1000;

    if (select(1, &rfds, NULL, NULL, &tv))
	    return (keyb_get());

    return -1;
}

static int keyb_wait_esc(int msec)
{
    static char buf[10], *ptr;
    struct _K_TAB *pKey;
    int key = 0, len, start;

    // Falls noch Taste im Buffer: Diese nehmen.
    if(ptr)
    {
        if(*ptr)
            key = *ptr++;
        else
            ptr = NULL;
    }

    // Keine Taste im Buffer: Auf neue warten.
    if (key == 0)
        key = keyb_wait(msec);

    if (key == 27)
    {
        ptr = buf;
        buf[0] = 0;
        len = 0;

        // Auf Folge-Code mit kleinstem Timeout (10 ms) warten.
        while((key = keyb_wait (10)) > 0 && len < 10)
        {
            *ptr++ = key;
            *ptr = 0;
            len++;
            start = 0;

            // Sofort diese Taste suchen
            for (pKey = key_tab; pKey->k; pKey++)
            {
                if (strcmp (buf, pKey->s) == 0)
                {
                    // Taste gefunden: Also Ende
                    ptr = buf+len;
                    return pKey->k;
                }

                // Anfang fuer irgendeine Taste korrekt?
                if (memcmp(buf, pKey->s, len) == 0)
                    start = 1;  // Ja
            }

            // ANSI-Zeichen fuer Keycode?
            if (start == 0)
                break;  // Nein
        }

        ptr = buf;

        // Ein simples ESC. Rest im Buffer (ptr)
        key = 27;
    }

    return key;
}