## Manage the game state with commend received with the "get_command" function.
class_name ConsoleManager extends ConsoleCommand

## The manager exetends console command, but since it's the root, it has empty name a description

## Emitted when the new text is added
@warning_ignore("unused_signal")
signal NewContent(text: String)

func _init() -> void:
	name = "Console"
	description = "Display the list of available commands."
	summary = description
	# register commands
	register(CommandGiveItem.new())
	register(CommandClearItem.new())
	register(CommandTime.new())

## Receive a new command text to parse.
## Multiple commands are separated with a new line.
func get_command(text: String) -> void:
	# early return if empty
	if len(text) == 0:
		return

	# get each line to prcess individually
	for line: String in text.split("\n", false):
		_get_command_line(line)

func _get_command_line(line: String) -> void:
	# early return if empty
	if len(line) == 0:
		return

	execute(line)

func autocomplete(partial: String) -> bool:
	if super.autocomplete(partial):
		return true

	# TODO only try to autocomplete paramters

	return false


func _execute_parameters(line: String) -> void:
	# if we're reaching here, we have found the sub command
	var parameter: String = line.split(" ", false, 1)[0]
	help("Unknown command \"" + parameter + "\"")
