class_name InputArgument
## Represents a command line argument

## Tells this argument is required.
const REQUIRED: int = 1 << 0
## Tells this argument is optional. This is the default behavior.
const OPTIONAL: int = 1 << 1
## This argument accepts multiple values and turn them into an array.
const IS_ARRAY: int = 1 << 2

enum ArgumentType {
	STRING = TYPE_STRING,
	FLOAT = TYPE_FLOAT,
	INT = TYPE_INT,
	BOOL = TYPE_BOOL,
	ANY = TYPE_NIL,
}

const STRING: ArgumentType = ArgumentType.STRING
const FLOAT: ArgumentType = ArgumentType.FLOAT
const INT: ArgumentType = ArgumentType.INT
const BOOL: ArgumentType = ArgumentType.BOOL
const ANY: ArgumentType = ArgumentType.ANY

## The argument name
var name: String = ""
## The description of the argument.
var description: String = ""
## One of InputArgument.required, InputArgument.OPTIONAL or InputArgument.IS_ARRAY
var _mode: int = OPTIONAL
## The values used to auto completion. Can either be an array, or a callable returning an array.
## NOTE: The array values will be converted to string.
var _suggestedValues: Variant = []
## The default value of this argument. Only valid with mode OPTIONAL.
var _default: Variant = null
## The type of the argument.
var _type: ArgumentType = ANY

func _init(
	argument_name: String,
	argument_description: String,
	argument_mode: int,
	argument_suggestedValues: Variant = [],
	argument_default: Variant = null,
	argument_type: ArgumentType = ANY
) -> void:
	assert(!argument_name.is_empty(), "The argument's name must not be empty")
	name = argument_name

	assert(!argument_description.is_empty(), "The argument's description must not be empty")
	description = argument_description

	assert(argument_mode == REQUIRED || argument_mode == OPTIONAL || argument_mode == IS_ARRAY, "Unknown mode")
	_mode = argument_mode

	assert(typeof(argument_suggestedValues) == TYPE_ARRAY || typeof(argument_suggestedValues) == TYPE_CALLABLE, "The argument suggested values must be an array or a callable")
	if typeof(argument_suggestedValues) == TYPE_CALLABLE:
		@warning_ignore("unsafe_cast")
		assert(typeof((argument_suggestedValues as Callable).call()) == TYPE_ARRAY, "The return type of suggested values callable is not an array")
	_suggestedValues = argument_suggestedValues

	if !is_optional():
		push_warning(argument_type != ANY, "Argument is not OPTIONAL, and no type has been given")

	if is_optional():
		if argument_default != null:
			push_warning(argument_type != ANY, "Default value given, but type has not been provided")
		_default = argument_default
	elif argument_default != null:
		push_warning("Argument mode is not OPTIONAL but a default argument value has been given")

func is_required() -> bool:
	return _mode == REQUIRED

func is_optional() -> bool:
	return _mode == OPTIONAL

func is_array() -> bool:
	return _mode == IS_ARRAY

func has_suggestions() -> bool:
	return get_suggestions().size() != 0

func get_suggestions() -> PackedStringArray:
	var values: Array[Variant] = []

	if typeof(_suggestedValues) == TYPE_CALLABLE:
		@warning_ignore("unsafe_cast")
		values = (_suggestedValues as Callable).call()
	else:
		values = _suggestedValues

	# convert all values to string
	var result: PackedStringArray = PackedStringArray([])

	for value: Variant in values:
		result.append(str(value))

	return result

func suggest(input: String, case_insensitive: bool = false) -> PackedStringArray:
	var suggestions: PackedStringArray = get_suggestions()
	if input.is_empty():
		return suggestions

	var result: PackedStringArray = PackedStringArray([])
	for suggestion: String in suggestions:
		if suggestion.begins_with(suggestion.to_lower() if case_insensitive else suggestion):
			result.append(suggestion)

	return result

## Get the type of this argument.
func get_type() -> ArgumentType:
	return _type

## Get the type name of this argument.
func get_type_name() -> String:
	match _type:
		STRING:
			return "STRING"
		FLOAT:
			return "FLOAT"
		INT:
			return "INT"
		BOOL:
			return "BOOL"
		ANY, _:
			return "ANY"

## Convert the type of the argument to the given type.
## If ANY type if given, no convertion is made.
func apply_type(value: Variant) -> Variant:
	if _type == ANY:
		return value
	return type_convert(value, _type);
