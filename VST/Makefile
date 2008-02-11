#CFLAGS = -I/opt/local/include -Wall
CFLAGS = -Wall
#LDFLAGS = -L/opt/
MACOSX_DEPLOYMENT_TARGET=10.4

#keyb.o: keyb.c
default:
	#@rm keyb.o keyb.so
	gcc $(CFLAGS) -c -o keyb.o keyb.c
	gcc -shared -fpic -o keyb.so keyb.o 
	#gcc -bundle -undefined dynamic_lookup -o keyb.so keyb.o 
	chcon -t textrel_shlib_t /home/chris/Desktop/staplr/VST/keyb.so
