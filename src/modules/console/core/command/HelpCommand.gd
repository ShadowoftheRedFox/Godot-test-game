class_name HelpCommand extends Command

func configure() -> void:
	ignore_validation = true
	name = "help"
	display_name = "Help"
	aliases.append("?")
	description = "Display the description of a command."
	help = "The help command gives informations and usages about a given command.

For the usage:
	- arguments between < > are mandatory.
	- arguments between [ ] are optional.
The argument name is given by its name before the values it expect:
	- int: Integer.
	- float: Floating point number.
	- string: String.
	- bool: 'true' or 'false'.
	- any: Anything.
If the type is surrounded by 'ARRAY[type]' then you can put multiples values.
Values separated by a '|' are possibilities, such as boolean: 'true|false'.
"
	usages.append_array(["help help", "help", "help foo"])

func get_definition(caller: CommandApplication) -> CommandInputDefinition:
	return CommandInputDefinition.new([
		CommandInputArgument.new("command", "The command name to get help on", CommandInputArgument.OPTIONAL, _suggested_values.bind(caller), "help", CommandInputArgument.STRING)
	])

func _suggested_values(caller: CommandApplication) -> PackedStringArray:
	var list: PackedStringArray = PackedStringArray(caller._commands.keys())
	list.sort()
	return list

func execute(caller: CommandApplication, input: CommandInput) -> bool:
	var cmd: Command = null
	var cmd_arg: CommandInputArgument = input.get_argument("command")

	if cmd_arg.has_value():
		cmd = caller.get_command_or_alias(cmd_arg.get_raw_value())
		if cmd == null:
			display_unknown(caller, cmd_arg.get_raw_value())
			return true

	if cmd != null:
		_display_help(caller, cmd)
	else:
		_display_help(caller, self)

	return true

func _display_help(caller: CommandApplication, cmd: Command) -> void:
	var text: String = "Command: " + (cmd.name if cmd.display_name.is_empty() else cmd.display_name) + "\n"
	if cmd.hidden:
		text += "This command is hidden."
		caller.output.emit(text)
		return

	if cmd.aliases.size() > 0:
		text += "Aliase" + ("s" if aliases.size() > 1 else "") + ": " + (", ".join(cmd.aliases)) + "\n\n"

	if !cmd.description.is_empty():
		text += "Description: " + cmd.description + "\n\n"

	if !cmd.help.is_empty():
		text += cmd.help + "\n\n"

	text += "Usage: " + cmd.name + " " + cmd.get_definition(caller).get_synopsis()

	if cmd.usages.size() > 0:
		text += "\n\nExample" + ("s" if cmd.usages.size() > 1 else "") + ":\n" + "\n".join(cmd.usages)

	caller.output.emit(text)

func display_unknown(caller: CommandApplication, cmd: String) -> void:
	# TODO display message like "did you mean ..."
	caller.output.emit("Unkown command \"" + cmd + "\"")
