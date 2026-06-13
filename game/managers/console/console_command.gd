## Manage a command for the console.
class_name ConsoleCommand extends Resource

# TODO aliases?
## The command name. Used to invoke the command.
@export var name: String = ""
## The full description of the command. Should specify what the arguments are, if they're optional, and their type.
## Exemple:
## Add multiple integer together.
## Usage: a:Int b:Int [...c:Int]
## \t a: The first value to add.
## \t b: The second value to add.
## \t c: Optional. Any other value to add, separated with spaces.
@export var description: String = ""
## A quick description of the command. Exemple: Add multiple integer together.
@export var summary: String = ""
## List of sub command.
@export var commands: Array[ConsoleCommand] = []
## Quick reference to the amount of commnds registered.
var commands_len: int = 0

func _init() -> void:
	commands_len = len(commands)

## Register a new sub command.
func register(sub_command: ConsoleCommand) -> void:
	if sub_command == null:
		return
	commands.push_back(sub_command)
	commands_len += 1

## Display the description of the command.
## [short_description]: Whether or not the description add all the descriptions of sub commands.
func get_description(short_description: bool = false) -> String:
	var text: String = "Command: " + name + "\n"
	text += "Description: " + description

	if len(commands) > 0:
		text += "\nCommands: \n"
		for command: ConsoleCommand in commands:
			if short_description:
				text += "\t" + command.name + ": " + command.summary + "\n"
			else:
				# for each line of the sub command description, add a \t
				for line: String in command.get_description().split("\n"):
					text += "\t" + line + "\n"
				text += "\n"

	return text

## Display the help message of this command in the console.
## [prefix]: Optional. Prefix for the help message.
func help(prefix: String = "") -> void:
	if len(prefix) > 0:
		GameState.CONSOLE.NewContent.emit(prefix + "\n" + get_description(true))
	else:
		GameState.CONSOLE.NewContent.emit(get_description(true))

## Display an error message in the console.
## [message]: The message to display.
func error(message: String) -> void:
	if len(message) == 0:
		return
	GameState.CONSOLE.NewContent.emit("[error]" + message + "[/error]")

## Display a message in the console.
## [message]: The message to display.
func info(message: String) -> void:
	if len(message) == 0:
		return
	GameState.CONSOLE.NewContent.emit(message)

# TODO
func autocomplete(partial: String) -> void:
	pass

## Execute the command with the given parameters.
func execute(parameters: String) -> void:
	if len(parameters) == 0 || parameters.begins_with("help") || parameters.begins_with("?"):
		help()
		return

	# check if it's the start of any sub commands
	if commands_len > 0:
		for command: ConsoleCommand in commands:
			if parameters.begins_with(command.name):
				# if yes, remove the command name from the start and execute command
				command.execute(parameters.substr(len(command.name)).strip_escapes())
				return


	# else, execute the parameters
	_execute_parameters(parameters)

## Should be overriden.
## Used to execute the command parameters when execute have been called.
## [line]: the parameters passed to this command in a single line.
## Results should be passed to [GameState.CONSOLE.NewContent.emit(result)].
@warning_ignore("unused_parameter")
func _execute_parameters(line: String) -> void:
	pass
