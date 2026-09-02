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
		CommandInputArgument.new("command", "The command name to get help on", CommandInputArgument.OPTIONAL, _suggested_values.bind(caller), "help", CommandInputArgument.STRING),
		CommandInputArgument.new("args", "Additional arguments to get help with.", CommandInputArgument.IS_ARRAY, null, null, CommandInputArgument.STRING)
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
			caller.error("Unkown command \"" + cmd_arg.get_raw_value() + "\"")
			return true

	if cmd != null:
		_help_subcommand(caller, input, cmd)
	else:
		_display_help(caller, self)

	return true

## Check if the given command is a subcommand.
## If yes, check if we need help on a further command.
func _help_subcommand(caller: CommandApplication, input: CommandInput, command: Command) -> void:
	if command is not SubCommand:
		_display_help(caller, command)
		return

	var cmd: SubCommand = command
	#if the command is a subcommand, check if it has the "command" argument filled
	var cmd_arg: CommandInputArgument = input.get_argument("command")
	if cmd_arg == null:
		caller.error(command.name + " is a subcommand without a command argument")
		return

	if !cmd_arg.has_value():
		_display_help(caller, command)
		return

	# if yes, check if it's a valid command of the sub command
	cmd = caller.get_command_or_alias(cmd_arg.get_raw_value(), cmd.sub_commands)
	if cmd == null:
		caller.error("Unkown command \"" + cmd_arg.get_raw_value() + "\"")
		_display_help(caller, command)
		return

	# if it's a valid value, go again, in case this command is also a subcommand
	_help_subcommand(caller, input, cmd)


func _display_help(caller: CommandApplication, cmd: Command) -> void:
	var text: String = "Command: " + TextEffectWrapper.new(cmd.name if cmd.display_name.is_empty() else cmd.display_name).u().get_value() + "\n"
	if cmd.hidden:
		text += TextEffectWrapper.new("This command is hidden.").color(Color.GRAY).i().get_value()
		caller.print(text)
		return

	if cmd.aliases.size() > 0:
		text += "Alias" + ("es" if aliases.size() > 1 else "") + ": " + (", ".join(TextEffectWrapper.i_array(cmd.aliases))) + "\n\n"

	if !cmd.description.is_empty():
		text += "Description: " + cmd.description + "\n\n"

	if !cmd.help.is_empty():
		text += cmd.help + "\n\n"

	text += "Usage: " + cmd.name + " " + cmd.get_definition(caller).get_synopsis() + "\n"
	for arg: CommandInputArgument in cmd.get_definition(caller)._arguments:
		var mode: TextEffectWrapper = TextEffectWrapper.new().bracket(arg.get_mode_name())
		if arg.is_optional():
			mode.color(Color.GRAY)

		text += mode.get_value() + " " + arg.name + ": " + arg.description + "\n"

	if cmd.usages.size() > 0:
		text += "\n\nExample" + ("s" if cmd.usages.size() > 1 else "") + ":\n" + "\n".join(TextEffectWrapper.i_array(cmd.usages))

	caller.print(text)
