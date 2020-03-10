.PHONY: all clean mrproper install

all: aliases

aliases: aliases.lua
	luastatic aliases.lua -I/usr/include/lua5.3 -llua5.3

aliases.lua: aliases.moon
	moonc aliases.moon

clean:
	rm -f aliases.lua aliases.lua.c

mrproper: clean
	rm -f aliases

install: aliases
	install aliases /usr/local/bin
