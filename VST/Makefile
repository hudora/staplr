CFLAGS = -I/opt/local/include -Wall
#LDFLAGS = -L/opt/

keyb.o: keyb.c
	gcc $(CFLAGS) -c -o keyb.o keyb.c
	gcc -bundle -undefined dynamic_lookup -o keyb.so keyb.o 
