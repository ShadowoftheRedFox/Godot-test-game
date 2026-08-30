## Run a set of instruction from a console.
@abstract class_name Command extends Resource

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

## No requirements. Default.
const NONE: RequirementsFlags = RequirementsFlags.NONE
## Needs to be the host of the game.
const HOST: RequirementsFlags = RequirementsFlags.HOST
## Needs to have privileged permissions, like enabling an option when starting the game.
const PRIVILEGED: RequirementsFlags = RequirementsFlags.PRIVILEGED
## Needs to be in a single player game.
const SINGLE_PLAYER: RequirementsFlags = RequirementsFlags.SINGLE_PLAYER
## Needs to be in a multi player game.
const MULTI_PLAYER: RequirementsFlags = RequirementsFlags.MULTI_PLAYER


## The name that identify this command.
var name: String = ""
## The name to be displayed in messages. If emtpy, use the name instead.
var display_name: String = ""

## List of aliases used to call the command.
var aliases: PackedStringArray = PackedStringArray()

## Short description of the command.
var description: String = ""
## Long description, displayed by the help command.
var help: String = ""
## A list of example usage to display with the help command.
var usages: PackedStringArray = PackedStringArray()

## If this command is enabled. Disabled command will not run.
var enabled: bool = true
## Requirements that the caller needs to verify before firing the command.
var requirements: int = NONE

## If this command id hidden. Hidden command will not appear in the help list.
var hidden: bool = false
## If this command should ignore validation error.
## Useful if it should run even if the arguments are invalid.
var ignore_validation: bool = false

func _init() -> void:
	configure()

## Get the input definitions for the command.
@abstract func get_definition(caller: CommandApplication) -> CommandInputDefinition

## Configure the command when first instantiated.
func configure() -> void:
	pass

## Called after the inputs were bound, but before they are validated.
@warning_ignore("unused_parameter")
func initialize(caller: CommandApplication, input: CommandInput) -> void:
	return

class Suggestion:
	var suggestions: PackedStringArray = PackedStringArray()
	var argument: CommandInputArgument = null
	var argument_position: int = -1
	var require_input: bool = false
	var will_replace_last_word: bool = false

## Called to autocomplete values.
## Returns a Suggestion.
func suggest(_caller: CommandApplication, input: CommandInput) -> Suggestion:
	var response: Suggestion = Suggestion.new()
	var definition: CommandInputDefinition = input._definition

	# no argument to suggest
	if definition.get_arguments_count() == 0:
		return response

	var arg: CommandInputArgument = null
	# we start at -1 because we add +1 at the start of the loop, so the first arg is at index 0
	var index: int = -1
	# look through each argument
	for a: CommandInputArgument in definition._arguments:
		index += 1
		# if argument has not been filled yet, and has no default, fill it
		if !a.has_value_or_default():
			arg = a
			response.require_input = !a.has_suggestions()
			break
		# argument has a default value to suggest
		if !a.has_value():
			arg = a
			break
		# if filled and has suggestion, check if the value match a suggestions
		if a.has_suggestions():
			var suggestions: PackedStringArray = a.get_suggestions()
			if !suggestions.has(a.get_raw_value()):
				arg = a
				response.will_replace_last_word = true
				break

	# if we have an argument, fill the suggestion
	if arg != null:
		response.suggestions = arg.suggest(arg.get_raw_value())
		response.argument = arg
		response.argument_position = index
	return response

## Execute the command after the arguments have been validated.
## If arguments are not valid, this function is not called.
@abstract func execute(caller: CommandApplication, input: CommandInput) -> bool

## Returns if the command is enabled or not.
## Disabled command won't show up in autocomplete or at the execution.
## Return false if the condition doesn't meet the command requirements. True otherwise.
func is_enabled() -> bool:
	if !enabled:
		return false

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

## Run the command.
func run(caller: CommandApplication, input: CommandInput) -> bool:
	if !is_enabled():
		return false

	initialize(caller, input)

	if !ignore_validation:
		var error: String = input.validate()
		if !error.is_empty():
			caller.output.emit(error)
			return false

	return execute(caller, input)
