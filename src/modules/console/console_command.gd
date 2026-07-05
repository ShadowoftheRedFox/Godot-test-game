## Manage a command for the console.
@abstract class_name ConsoleCommand extends Resource

# TODO aliases?
# TODO parameters with their type and name to further lessen the load on children?
### TEST
"""
for parameters, we need to take into account:
	- they can be multiple of any type
	- they are optional or required
	- autocompletion need to work on them
	- they need a description

maybe have command and paramter as a same subclass so they share the main things

"""
### TEST

## The command name. Used to invoke the command.
var name: String = ""
## The full description of the command. Should specify what the arguments are, if
## they're optional, and their type.
## Exemple:
## Add multiple integer together.
## Usage: a:Int b:Int [...c:Int]
## \t a: The first value to add.
## \t b: The second value to add.
## \t c: Optional. Any other value to add, separated with spaces.
var description: String = ""
## A quick description of the command. Exemple: Add multiple integer together.
var summary: String = ""
## List of sub command.
var commands: Array[ConsoleCommand] = []
## Quick reference to the amount of commnds registered.
var commands_len: int = 0

## List of requirement flags to berify if the caller (current game client) can call this command.
enum RequirementsFlags {
	## No requirements. Default.
	NONE = 0,
	## Needs to be the host of the game.
	HOST = 1 << 0,
	## Needs to have privileged permissions, like enabling an option when starting the game.
	PRIVILEGED = 1 << 1,
	## Needs to be in a single player game.
	SINGLE_PLAYER = 1 << 2,
	## Needs to be in a multi player game.
	MULTI_PLAYER = 1 << 3,
}

## Requirements that the caller needs to verify before firing the command.
@export_flags("None", "Host", "Privileged", "Single player", "Multi player") var requirements: int = RequirementsFlags.NONE

func _init() -> void:
	# count the amount of commands available on startup
	commands_len = commands.size()

## Register a new sub command.
func register(sub_command: ConsoleCommand) -> void:
	if sub_command == null:
		return
	# check if a command of the same name is already registered
	if commands.map(func(cmd: ConsoleCommand) -> String: return cmd.name).has(sub_command.name):
		printerr("Command " + name + ": a \"" + sub_command.name + "\" subcommand is already registered!")
		return
	commands.push_back(sub_command)
	commands_len += 1

## Display the description of the command.
## [short_description]: Whether or not the description add all the descriptions of sub commands.
func _get_description(short_description: bool = false) -> String:
	var text: String = "Command: " + name + "\n"
	text += "Description: " + description

	if commands.size() == 0:
		return text

	text += "\nCommands: \n"
	for command: ConsoleCommand in commands:
		# only show command that we can execute
		if !command.check_requirements():
			continue

		# display the appropriate amount of informations
		if short_description:
			text += "\t" + command.name + ": " + command.summary + "\n"
		else:
			# for each line of the sub command description, add a \t
			for line: String in command._get_description().split("\n"):
				text += "\t" + line + "\n"
			text += "\n"

	return text

## Display the help message of this command in the console.
## [prefix]: Optional. Prefix for the help message.
func help(prefix: String = "") -> void:
	if prefix.length() > 0:
		info(prefix + "\n" + _get_description(true))
	else:
		info(_get_description(true))

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


## Execute the command with the given parameters.
func execute(parameters: String) -> void:
	# should no execute because it's disabled
	if !is_enabled():
		error("This command is disabled")
		return

	if parameters.begins_with("help") || parameters.begins_with("?"):
		help()
		return

	# command requirements not met
	if !check_requirements():
		return

	# we have no sub command, so call parameters
	# also call if parameters length is 0, in case the command takes no parameters
	if commands_len == 0 || parameters.length() == 0:
		execute_parameters(parameters)
		return

	# check if it's the start of any sub commands
	# get the parts of our line, the sub command and it's parameters
	var parts: PackedStringArray = parameters.split(' ', true, 1)
	for cmd: ConsoleCommand in commands:
		# skip disabled commands
		if !cmd.is_enabled():
			continue

		if parts[0] == cmd.name:
			# if yes, execute the command with the rest of the parameters
			if parts.size() >= 2:
				cmd.execute(parts[1])
			else:
				cmd.execute("")
			return

	# sub command not found
	help("Command \"" + parts[0] + "\" does not exists")


## Checks command requirements before firing command.
## Return false if the condition doesn't meet the command requirements. True otherwise.
func check_requirements() -> bool:
	# no requirements
	if requirements == RequirementsFlags.NONE:
		return true

	if requirements & RequirementsFlags.HOST:
		# for now, the game is single player only, so we're always host
		# TODO check if host
		pass

	if requirements & RequirementsFlags.PRIVILEGED:
		# TODO check if privileged
		pass

	if requirements & RequirementsFlags.SINGLE_PLAYER:
		# for now, the game is single player only
		# TODO check if single player
		pass

	if requirements & RequirementsFlags.MULTI_PLAYER:
		# for now, the game is single player only
		# TODO check if multi player
		return false

	return true

## Should be overridden.
## Must call [super.autocomplete] when overridden.
## Used to autocomplete a partial value at the end of partial, with a parameter value.
## Responses should be passed to [Global.CONSOLE.Print.emit(result)].
## Returns [true] if the autocomplete has already returned a value, and the child autocomplete must return without further process.
## If the autocompletion can resolve to 1 possibilities, call [Global.CONSOLE.Complete.emit(result)] to tell the value to complete.
func autocomplete(partial: String) -> bool:
	# no sub commands to autocomplete or disabled, early return
	if commands_len == 0 || !is_enabled():
		return false

	var words: PackedStringArray = partial.split(" ", true, 1)
	var size: int = words.size()
	var word: String = words[0]
	# if word is the last word in the line, try to autocomplete it with a command name
	if size == 1:
		# array of command names that match the autocompletion
		# and are enabled
		var candidates: Array[String] = []
		for cmd: ConsoleCommand in commands:
			if cmd.name.begins_with(word) && cmd.is_enabled():
				candidates.push_back(cmd.name)

		if candidates.size() == 0:
			# show all command availables
			info(", ".join(commands.map(func(c: ConsoleCommand) -> String: return c.name)))
		elif candidates.size() == 1:
			# call complete since we found our answer
			Global.CONSOLE.Complete.emit(candidates[0])
		else:
			# join results and propose values
			info(", ".join(candidates))
		return true

	# if word is not the last word of the line, send the autocomplete to a
	# subcommand of the same name as word
	# and call the autocomplete of the command
	for cmd: ConsoleCommand in commands:
		if cmd.name == word:
			# if the command is disabled, return
			if !cmd.is_enabled():
				return false
			# call the sub command autocomplete, and return if it did
			if cmd.autocomplete(words[1]):
				return true

	# parameter autocomplete must be done by child autocomplete
	return false

## Should be overridden.
## Used to execute the command parameters when execute have been called.
## [line]: the parameters passed to this command in a single line.
## Results should be passed to [Global.CONSOLE.NewContent.emit(result)].
@abstract func execute_parameters(line: String) -> void

## Returns if the command is enabled or not.
## Disabled command won't show up in autocomplete or at the execution.
@abstract func is_enabled() -> bool
