## Holds a list of commands.
##
## An application is not aware of other application, except by calling through the command module.
## Multiple applications can have the same command, yet does very different things.
@abstract class_name CommandApplication

## The name that identify this application.
var name: String = ""

## List of registered commands
var _commands: Dictionary[String, Command] = {}

## Signal that sends the string outputed by the application.
signal output(out: String)
## Signal with the list of possible completion options.
@warning_ignore("unused_signal")
signal suggest(options: PackedStringArray)

## Create a new command application.
## The name must be only made of ASCII characters, without spaces or escapes characters.
func _init(application_name: String) -> void:
	assert(application_name != null, "Name given is null")
	# clean all non ASCII characters from the name, as well as all spaces
	var clean: String = application_name.to_ascii_buffer().get_string_from_ascii().strip_escapes().strip_edges()
	assert(clean.length() > 0, "Name given is empty")
	name = clean;
	print("Registered application " + name)
	# always register the help command
	register(HelpCommand.new())
	init_register()

## Function called after initialisation to register commands automatically.
## Should be overriden as needed.
func init_register() -> void:
	pass

## Register a new command. If a command of this name already exists, false is returned.
func register(command: Command) -> bool:
	# make sure no command has the same name or aliases
	if has_command(command.name):
		return false

	for cmd: Command in _commands.values():
		if cmd.aliases.has(command.name):
			printerr("Tried to register command \"" + command.name + "\" but command \"" + cmd.name + "\" already is registered with an alias of the same value")
			return false
		for alias: String in command.aliases:
			if cmd.aliases.has(alias):
				printerr("Tried to register command \"" + command.name + "\" but command \"" + cmd.name + "\" already is registered with a matching alias \"" + alias + "\"")
				return false

	return _commands.set(command.name, command)

## Unregister a command command. Return true on success.
func unregister(command_name: String) -> bool:
	if !has_command(command_name):
		return false

	return _commands.erase(command_name)

## Return true if a command of this name is registered.
func has_command(command_name: String) -> bool:
	return _commands.has(command_name)

## Return true if a command who has this alias is registered.
func has_alias(command_alias: String) -> bool:
	for cmd: Command in _commands.values():
		if cmd.aliases.has(command_alias):
			return true
	return false

## Return the command command if it is registered, null otherwise.
func get_command(command_name: String) -> Command:
	return _commands.get(command_name)

## Return the command command if it is registered, null otherwise.
## Same as get_command, but will look at registered command aliases too, so is a bit slower.
func get_command_or_alias(command_name_or_alias: String, source: Array[Command] = _commands.values()) -> Command:
	for cmd: Command in source:
		if cmd.name == command_name_or_alias || cmd.aliases.has(command_name_or_alias):
			return cmd
	return null

## Tries to find a command whose name or alias match the given value.
## If no match is found, tries to find the best name or alias starting with the value.
## Returns the list of candidates.
func find_command(command_name: String, source: Array[Command] = _commands.values()) -> Array[Command]:
	# if command_name is empty, just send back all commands
	if command_name.is_empty():
		return source

	# if we have an exact match, return it
	var _cmd: Command = get_command_or_alias(command_name, source)
	if _cmd != null:
		return [_cmd]

	var candidates: Array[Command] = []

	# otherwise, get a list of close match from name and aliases
	for cmd: Command in source:
		if cmd.name.begins_with(command_name):
			candidates.append(cmd)
			continue
		for alias: String in cmd.aliases:
			if alias.begins_with(command_name):
				candidates.append(cmd)
				continue

	return candidates

## Execute the command line. Return true on command success, false otherwise.
func run(command_line: String) -> bool:
	var name_arguments: PackedStringArray = command_line.split(" ", true, 1)
	var command_name: String = name_arguments[0]
	var commands: Array[Command] = find_command(command_name)

	# no command found
	if commands.size() == 0:
		# TODO show helps instead
		output.emit("No commands name matching \"" + command_name + "\"")
		return false

	# multiple commands found
	if commands.size() > 1:
		var response: PackedStringArray = PackedStringArray()
		# print the list of candidates name
		for cmd: Command in commands:
			if cmd.name.begins_with(command_name):
				response.append(cmd.name)
			for alias: String in cmd.aliases:
				if alias.begins_with(command_name):
					response.append(alias)

		response.sort()
		output.emit(" ".join(response))
		return false

	# a unique command cound
	var command: Command = commands[0]
	var command_arguments: String = name_arguments[1] if name_arguments.size() == 2 else ""

	return command.run(self, CommandInput.new(command_arguments, command.get_definition(self)))

## Tries to autocomplete the given command line.
## Multiple options should be outputed.
## Single option should be sent by the suggest signal.
func complete(command_line: String) -> bool:
	# TODO split with regex to ignore multiple spaces
	var name_arguments: PackedStringArray = command_line.split(" ", true, 1)
	var command_name: String = name_arguments[0]
	var commands: Array[Command] = find_command(command_name)

	# no command found
	if commands.size() == 0:
		# TODO show helps instead
		output.emit("No commands name matching \"" + command_name + "\"")
		return false

	# multiple commands found
	if commands.size() > 1:
		var response: PackedStringArray = PackedStringArray()
		# print the list of candidates name
		for cmd: Command in commands:
			# skip disabled commands
			if !cmd.is_enabled():
				continue
			if cmd.name.begins_with(command_name):
				response.append(cmd.name)
			for alias: String in cmd.aliases:
				if alias.begins_with(command_name):
					response.append(alias)

		output.emit(" ".join(response))
		return false

	# a unique command cound
	var command: Command = commands[0]
	var command_arguments: String = name_arguments[1] if name_arguments.size() == 2 else ""

	# no arguments, just emit the command name
	if name_arguments.size() == 1:
		suggest.emit(command.name)
		return true

	# get the suggestions from the arguments
	var res: Command.Suggestion = command.suggest(self, CommandInput.new(command_arguments, command.get_definition(self)))

	# nothing to suggest
	if res.argument == null:
		return true

	# the argument to fill require a manual input of some sort, and has nothing to suggest
	if res.require_input:
		output.emit(res.argument.name + ": " + res.argument.get_type_name())
		return true

	var suggestions: PackedStringArray = res.suggestions
	# multiple possibilities are printed
	if suggestions.size() > 1:
		output.emit(" ".join(suggestions))
	elif suggestions.size() == 0:
		# no suggestions, should never happen
		output.emit("Whatever you're trying to say, I've got no ideas")
	else:
		# a single suggestion, append it to the line or replace the last word as needed
		var words: PackedStringArray = command_line.split(" ", false)
		if res.will_replace_last_word:
			words.set(res.argument_position + 1, suggestions.get(0))
		else:
			words.append(suggestions.get(0))
		suggest.emit(" ".join(words))

	return true
