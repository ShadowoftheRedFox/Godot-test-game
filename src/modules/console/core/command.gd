# TODO look at symfony how they do it bruh

## Base class for all commands.
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

## The consolable name. Used to invoke the consolable. Must be lowercase.
var name: String = ""
## A quick description of the command. Example: Add multiple integer together.
var summary: String = ""
## The full description of the consolable. Example: Add multiple integer together, by doing magic (a.k.a. mathematics).
var description: String = ""
## The input definition attached to this command.
var definition: InputDefinition = InputDefinition.new();
## Requirements that the caller needs to verify before firing the command.
var requirements: int = NONE

## Must call [super.autocomplete] when overridden.
## Used to autocomplete a partial value at the end of partial, with a parameter value.
## Responses should be passed to [Global.CONSOLE.Print.emit(result)].
## Returns [true] if the autocomplete has already returned a value, and the child autocomplete must return without further process.
## If the autocompletion can resolve to 1 possibilities, call [Global.CONSOLE.Complete.emit(result)] to tell the value to complete.
@abstract func autocomplete(partial: String) -> bool

## Display the description of the command.
## [short_description]: Whether or not the description add all the descriptions of sub commands.
@abstract func get_description(short_description: bool = false) -> String

func _init(definition_: InputDefinition) -> void:
	if (definition_ != null):
		definition = definition_
	configure()

func run() -> void:
	pass
	# TODO

## Called after the initialization to set up arguments for the command.
func configure() -> void:
	pass

func execute(_input: CommandInput) -> void:
	push_error("You must override the xecute() method in your command class")

## Returns if the command is enabled or not.
## Disabled command won't show up in autocomplete or at the execution.
## Return false if the condition doesn't meet the command requirements. True otherwise.
func is_enabled() -> bool:
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
