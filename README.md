# Aliases
A simple MoonScript-scriptable, directory-dependant aliasing tool.

- `aliases build` -> `make`, `cargo build`, `moonc .`, or whatever your project defines
- `aliases run` -> `make run`, `cargo run`, `lua init.lua`, `./program`, or whatever
- `aliases ls` -> `ls --color=auto`, or whatever

## Examples
In some C project, `.aliases`:
```moonscript
local exists
exists=(file) -> os.execute "test -f '#{file}'"

build=make
run=fn =>
	#make unless exists './bin/binary'
	#cmd './bin/binary'
debug=fn =>
	#make unless exists './bin/binary'
	#valgrind './bin/binary'
```

Then, in some MoonScript project, `.aliases`:
```moonscript
local exists
exists=(file) -> os.execute "test -f '#{file}'"

build=moonc '.'
run=if exists 'script.lua'
	lua 'script.lua'
else
	fn => print "Not compiled"
```

## How to use it
This tool looks for scripts in `~/.config/aliases`, and for `.aliases` and `.aliases.moon` in the current directory and the user home. It then runs all of them as MoonScript code and collects all exported values to be used as aliases. When called without argument, lists all available aliases, and when called with arguments, calls the given alias with its arguments, or the actual command if it is not aliased.
To make this easier and get a more familiar syntax, variables get exported by default, a `cmd` constructor is provided which builds a `Command` object, as well as `fn`, which builds a `Function` object. Additionally, undeclared variables generate a `Command` object when instanciated. You also have access to the `env` object, which contains all the environment variables.

### `Command` objects
Command objects represent, well, commands, along with arguments. To create one, you can either use the `cmd` constructor, or simply use the name of the command if it is a valid MoonScript identifier. The constructor also accepts a list of arguments, and `Command` objects also act as constructors. To execute a command, the `#` operator can be used.

```moonscript
ll=ls '-lah'
la=cmd 'ls', '-a'
```

### `Function` objects
Function object represent, well, functions. With `Command` objects, they are the only objects which will be exported. They can be built with the `fn` constructor, and have the same interface as `Command`. The given function can take any number of arguments, and will be called with itself as first argument.

```moonscript
test=fn => print "It works!"
hello=fn (txt) => print "Hello, #{txt}!"
```

## Installing
To install this tool, you'll need the MoonScript compiler and `luastatic`. You can get them on Luarocks. You also need a C compiler and Make, and Lua 5.3.

On Debian and derivates (like Ubuntu or Mint), you can use these commands
```bash
sudo apt install luarocks lua5.3 liblua5.3-dev git
sudo luarocks install moonscript luastatic
git clone https://github.com/natnat-mc/aliases
cd aliases
make
sudo make install
```

## TODO
- [ ] README.md
- [ ] Examples
- [ ] Common functions for bash and fish
- [ ] Easy way to be used as a fallback in fish, with `fish_command_not_found`
