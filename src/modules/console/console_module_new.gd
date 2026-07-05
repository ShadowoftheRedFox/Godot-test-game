class_name ConsoleModuleNew
## Manage the game state with commend received with the "get_command" function.
## The manager exetends console command, but since it's the root, it has empty name a description

## Emitted when the console prints text.
@warning_ignore("unused_signal")
signal print(text: String)

## Emitted when the autocomplete solved the next value.
@warning_ignore("unused_signal")
signal complete(word: String)

## Number of chars max that can be displayed on the console.
const CONSOLE_MAX_LENGTH: int = 10000

"""
What i want from this module:
	- register commands
	- print utility
	- calls command
	- autocomplete command
	- handle helps automatically
"""

## List of registered command for this class.
var _commands: Dictionary[String, Command] = {}

## Display a message in the console.
## [message]: The message to display.
func info(message: String) -> void:
	if message.length() == 0:
		return
	Global.CONSOLE.Print.emit(message)

## Display an trace message in the console.
## [message]: The message to display.
func trace(message: String) -> void:
	if message.length() == 0:
			return
	info("[color=web_gray][i]" + message + "[/i][/color]")

## Display an error message in the console.
## [message]: The message to display.
func error(message: String) -> void:
	if message.length() == 0:
		return
	info("[color=red]" + message + "[/color]")

func execute(line: String) -> void:
	if line == null || line.strip_edges().is_empty():
		return

	var words: PackedStringArray = line.split(" ", false, 2)
	if words.size() < 1:
		return

	var command_name: String = words[0]
	if !has_command(command_name):
		help(command_name)

func execute_command(command: Command, arguments: String) -> void:
	if command == null:
		return

	command.execute(CommandInput.new(arguments, command.definition))

## The main help response. Pass a command to display the help for the command.
func help(command_name: String) -> void:
	var msg: String = ""
	if command_name == null || command_name.is_empty():
		var names: String = ", ".join(_commands.keys())
		msg = "Command available: " + names
	elif !has_command(command_name) || !get_command(command_name).is_enabled():
		msg = "Unknown command \"" + command_name + "\". Type \"?\" or \"help\" for help."
	else:
		var command: Command = get_command(command_name)
		msg = command.name + command.definition.get_synopsis() + "\n" \
			+"Description: " + command.description

	info(msg)

## Register a command.
func register(command: Command) -> void:
	assert(!_commands.has(command.name), "A command named \"" + command.name + "\" is already registered.")
	_commands.set(command.name, command)

## Get the list of registered commands.
func get_commands() -> Array[Command]:
	return _commands.values()

## Check if the command with the given name is registered.
func has_command(name: String) -> bool:
	return _commands.has(name)

## Get the registered command of the same name
func get_command(name: String) -> Command:
	return _commands.get(name)
