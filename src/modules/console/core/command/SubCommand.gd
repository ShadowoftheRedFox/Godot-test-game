## A command that can host other command.
## Useful to make multiple command in a same subcase than a lot of arguments.
@abstract class_name SubCommand extends Command

## List of sub commands to run from this command.
## They should be added by the `configure()` method.
var sub_commands: Array[Command] = []

func _init() -> void:
	configure()
	_check_no_cyclic()
	_check_sub_commands()

## Get the input definitions for the command.
func get_definition(_caller: CommandApplication) -> CommandInputDefinition:
	return CommandInputDefinition.new([
		CommandInputArgument.new("command", "The subcommand to call.", CommandInputArgument.REQUIRED, get_commands_names_and_aliases(), null, CommandInputArgument.STRING),
		CommandInputArgument.new("arguments", "The subcommand arguments.", CommandInputArgument.IS_ARRAY, null, null, CommandInputArgument.STRING),
	])

## Make sure the current SubCommand doesn't reference itself.
func _check_no_cyclic() -> void:
	if sub_commands.has(self):
		sub_commands.remove_at(sub_commands.find(self))
		push_error("The SubCommand \"", name, "\" reference itself in the list of sub_commands!")

## Checks if the given sub commands have no duplicated name or aliases.
func _check_sub_commands() -> void:
	#TODO
	pass

## Called to autocomplete values.
## Returns a Suggestion.
## Will look if the command is valid. If yes, will call the suggestion of this command and so on.
func suggest(caller: CommandApplication, input: CommandInput) -> Suggestion:
	var response: Suggestion = Suggestion.new()
	var definition: CommandInputDefinition = input._definition

	# no argument to suggest
	if definition.get_arguments_count() == 0:
		return response

	var cmd_arg: CommandInputArgument = input.get_argument("command")
	var arguments_arg: CommandInputArgument = input.get_argument("arguments")

	# cmd argument has no value
	if !cmd_arg.has_value():
		response.suggestions = get_commands_names_and_aliases()
		response.argument = cmd_arg
		response.argument_position = 0
		return response

	# check if the value match a command name
	var cmd_value: String = cmd_arg.get_raw_value()
	var candidates: Array[Command] = []
	# get a list of close match from name and aliases
	for cmd: Command in sub_commands:
		if cmd.name.begins_with(cmd_value):
			candidates.append(cmd)
			continue
		for alias: String in cmd.aliases:
			if alias.begins_with(cmd_value):
				candidates.append(cmd)
				continue

	# no candidates, return
	if candidates.size() == 0:
		response.argument = cmd_arg
		response.argument_position = 0
		return response
	# if multiple candidates, suggest the candidates name or alias
	elif candidates.size() > 1:
		response.argument = cmd_arg
		response.argument_position = 0

		for cmd: Command in sub_commands:
			if cmd.name.begins_with(cmd_value):
				response.suggestions.append(cmd.name)
			for alias: String in cmd.aliases:
				if alias.begins_with(cmd_value):
					response.suggestions.append(alias)
		return response

	var cmd: Command = candidates.get(0)
	var cmd_response: Command.Suggestion = cmd.suggest(caller, CommandInput.new(arguments_arg.get_raw_value(), cmd.get_definition(caller)))
	response.argument = cmd_response.argument
	response.argument_position = 1 + cmd_response.argument_position
	response.suggestions = cmd_response.suggestions
	return response

func get_commands_names_and_aliases() -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for cmd: Command in sub_commands:
		names.append(cmd.name)
		for alias: String in cmd.aliases:
			names.append(alias)
	return names

## Execute the command after the arguments have been validated.
## If arguments are not valid, this function is not called.
func execute(caller: CommandApplication, input: CommandInput) -> bool:
	var cmd_arg: CommandInputArgument = input.get_argument("command")
	var arguments_arg: CommandInputArgument = input.get_argument("arguments")

	var command_name: String = cmd_arg.get_raw_value()

	if !cmd_arg.has_value() || !get_commands_names_and_aliases().has(command_name):
		caller.error("Unknown command \"" + command_name + "\"")
		return false

	var commands: Array[Command] = caller.find_command(command_name, sub_commands)

	# no command found
	if commands.size() == 0:
		# TODO show helps instead
		caller.error("No commands name matching \"" + command_name + "\"")
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
		caller.trace(" ".join(response))
		return false

	# a unique command cound
	var command: Command = commands[0]
	var command_arguments: String = arguments_arg.get_raw_value()

	return command.run(caller, CommandInput.new(command_arguments, command.get_definition(caller)))
