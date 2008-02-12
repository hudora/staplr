CC = /usr/local/i486-linux/bin/i486-linux-gcc
CFLAGS = -Wall -I/usr/local/i486-linux/include

default: keyb.c
	$(CC) $(CFLAGS) -c -o keyb.o keyb.c
	$(CC) -shared -fpic -o keyb.so keyb.o 
	$(CC) $(CFLAGS) -c -o aux.o aux.c -I/opt/local/include
	$(CC) -shared -fpic -o aux.so aux.o 

local: keyb.c
	gcc $(CFLAGS) -c -o keyb.o keyb.c
	gcc -shared -fpic -o keyb.so keyb.o 

clean:
	rm keyb.o keyb.so
