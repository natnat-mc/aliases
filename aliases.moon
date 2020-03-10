if _VERSION < "Lua 5.3"
	error "Requires at least Lua 5.3, got #{_VERSION}"

import to_lua from require 'moonscript'
import type from require 'moon'

CONFIG_DIR="#{os.getenv 'HOME'}/.config/aliases"
unless os.execute "test -d '#{CONFIG_DIR}'"
	os.execute "mkdir '#{CONFIG_DIR}'"

options=(os.getenv 'ALIAS_OPTIONS') or ''

escape=(s) ->
	return s if s\match '^[a-zA-Z0-9_./=+-]+$'
	"'#{s\gsub('\'', '\\\'')}'"

class Command
	new: (@name, ...) =>
		@args={...}

	__call: (...) =>
		@@ (tostring @), ...

	__tostring: =>
		if #@args!=0
			return "#{@name} #{table.concat [escape arg for arg in *@args], ' '}"
		else
			return @name

	__len: =>
		cmd=tostring @
		print cmd if options\match 'p'
		os.execute cmd

class Function
	new: (@fn, ...) =>
		@args={...}

	__call: (...) =>
		al={a for a in *@args}
		table.insert al, a for a in *({...})
		@@ @fn, table.unpack al

	__len: =>
		@fn table.unpack @args

env=setmetatable {}, {
		__index: (a) => os.getenv a
	}

loadincontext=(ctx, code) ->
	fn, err=load code, 'chunk', 't', ctx
	error err if err
	fn

aliases={}
setmetatable aliases, {
	__index: (k) =>
		return env if k=='env'
		return Command if k=='Command' or k=='cmd'
		return Function if k=='Function' or k=='fn'
		return (rawget _G, k) or Command k
}
loadaliases=(code) ->
	code='export *\n'..code
	code=to_lua code
	(loadincontext aliases, code)!

aliasfiles=["#{CONFIG_DIR}/#{line}" for line in (io.popen "ls -1 '#{CONFIG_DIR}'")\lines!]
do
	addifexist=(file) -> table.insert aliasfiles, file if os.execute "test -f '#{file}'"
	addifexist "#{os.getenv 'HOME'}/.aliases.moon"
	addifexist "#{os.getenv 'HOME'}/.aliases"
	addifexist ".aliases.moon"
	addifexist ".aliases"

for file in *aliasfiles
	fd=io.open file, 'r'
	code, err=fd\read '*a'
	fd\close!
	error "can't read file #{file}: #{err}" if err
	loadaliases code, aliases

exe=(cmd, ...) ->
	unless cmd
		print alias, value for alias, value in pairs aliases
		return

	alias=rawget aliases, cmd
	if (Command==type alias) or Function==type alias
		#alias ...
	else
		#Command cmd, ...
exe ...
