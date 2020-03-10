local exists
exists=(file) -> os.execute "test -f '#{file}'"

compile=moonc 'aliases.moon'

link=if exists 'aliases.lua'
	luastatic 'aliases.lua', '-I/usr/include/lua5.3', '-llua5.3'
else
	fn => print "Not compiled"

build=make 'all'
clean=rm '-f', 'aliases.lua', 'aliases.lua.c', 'aliases'

test=fn ->
	#printf "This was a %s\n", "Triumph"
	print "I'm making a note here"

hello=fn (a) =>
	print "Hello, #{a}!"

run=fn =>
	#build unless exists './aliases'
	#cmd './aliases'
