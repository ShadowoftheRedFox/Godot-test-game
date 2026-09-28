## Initialize a new command input argument.
##
## **name**: The name of the argument, used in help messages.
## **description**: The description of the argument, used in help messages.
## **mode**: Whether this argument is required (1), optional (2) or is an array of values (4).
## **suggested_values**: Either an array of string, or a callable returning an array of string to suggest.
## I
## **default**: The default value or the argument. Only used if the mode is optional.
## **type**: The type expected to be given as the argument value. Helps when parsing the argument.
class_name CommandInputArgument

enum ArgumentMode {
	REQUIRED = 1 << 0,
	OPTIONAL = 1 << 1,
	IS_ARRAY = 1 << 2,
}

## Tells this argument is required.
const REQUIRED: int = ArgumentMode.REQUIRED
## Tells this argument is optional. This is the default behavior.
const OPTIONAL: int = ArgumentMode.OPTIONAL
## This argument accepts multiple values and turn them into an array.
const IS_ARRAY: int = ArgumentMode.IS_ARRAY

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
var _mode: int = REQUIRED
## The values used to auto completion. Can either be null for no suggestions, a PackedStringArray, or a callable returning a PackedStringArray.
var _suggested_values: Variant = null
## The default value of this argument. Only valid with mode OPTIONAL.
var _default: Variant = null
## The type of the argument.
var _type: ArgumentType = ANY
## The value filled by the command input parsing. Only reliable when _filled is true.
## When argument is not an array, only the first value is returned.
var _values: PackedStringArray = PackedStringArray()

func _init(
	argument_name: String,
	argument_description: String,
	argument_mode: int = REQUIRED,
	argument_suggested_values: Variant = null,
	argument_default: Variant = null,
	argument_type: ArgumentType = ANY,
) -> void:
	_type = argument_type

	assert(!argument_name.is_empty(), "The argument's name must not be empty")
	name = argument_name

	assert(!argument_description.is_empty(), "The argument's description must not be empty")
	description = argument_description

	assert(argument_mode == REQUIRED || argument_mode == OPTIONAL || argument_mode == IS_ARRAY, "Unknown mode")
	_mode = argument_mode

	if argument_suggested_values != null:
		assert(typeof(argument_suggested_values) == TYPE_PACKED_STRING_ARRAY || typeof(argument_suggested_values) == TYPE_CALLABLE, "The argument suggested values must be a PackedStringArray or a callable returning a PackedStringArray")
		if typeof(argument_suggested_values) == TYPE_CALLABLE:
			@warning_ignore("unsafe_cast")
			assert(typeof((argument_suggested_values as Callable).call()) == TYPE_PACKED_STRING_ARRAY, "The return type of suggested values callable is not a PackedStringArray")
	_suggested_values = argument_suggested_values

	if !is_optional() && argument_type == ANY:
		push_warning("Argument is not OPTIONAL, and no type has been given")

	if is_optional():
		if argument_default != null && argument_type == ANY:
			push_warning("Default value given, but type has not been provided")
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
	return _suggested_values != null

func get_suggestions() -> PackedStringArray:
	var values: PackedStringArray = PackedStringArray()
	if _suggested_values == null:
		return PackedStringArray()

	if typeof(_suggested_values) == TYPE_CALLABLE:
		@warning_ignore("unsafe_cast")
		var res: Variant = (_suggested_values as Callable).call()
		if typeof(res) == TYPE_PACKED_STRING_ARRAY:
			values = res
	elif typeof(_suggested_values) == TYPE_PACKED_STRING_ARRAY:
		values = _suggested_values

	return values

## Suggest what the value could be for this argument, given the start of the input.
## Returns the list of suggestions.
func suggest(input: String = "", case_insensitive: bool = false) -> PackedStringArray:
	var suggestions: PackedStringArray = get_suggestions()
	if input.is_empty():
		# suggest the default value if there is no suggestions
		if suggestions.size() == 0 && _mode == OPTIONAL && _default != null:
			return PackedStringArray([str(_default)])
		return suggestions

	var result: PackedStringArray = PackedStringArray([])
	for suggestion: String in suggestions:
		if (suggestion if case_insensitive else suggestion.to_lower()).begins_with(input if case_insensitive else input.to_lower()):
			result.append(suggestion)

	return result

## Get the type of this argument.
func get_type() -> ArgumentType:
	return _type

## Get the type name of this argument.
func get_type_name() -> String:
	match _type:
		STRING:
			return "ARRAY[STRING]" if is_array() else "STRING"
		FLOAT:
			return "ARRAY[FLOAT]" if is_array() else "FLOAT"
		INT:
			return "ARRAY[INT]" if is_array() else "INT"
		BOOL:
			return "ARRAY[true|false]" if is_array() else "true|false"
		ANY, _:
			return "ARRAY[ANY]" if is_array() else "ANY"

## Get the mode name of this argument.
func get_mode_name() -> String:
	match _mode:
		REQUIRED:
			return "REQUIRED"
		OPTIONAL:
			return "OPTIONAL"
		IS_ARRAY:
			return "IS_ARRAY"
		_:
			return "unknown"

## Convert the type of the argument to the given type.
## If ANY type if given, no convertion is made.
func apply_type(value: Variant) -> Variant:
	if _type == ANY:
		return value
	return type_convert(value, _type);

## Check if this argument has a value.
func has_value() -> bool:
	return _values.size() > 0 && !_values.get(0).is_empty()

## Check if this argument has a parsed value or a default value if the argument is optional.
func has_value_or_default() -> bool:
	return has_value() || (_default != null && _mode == OPTIONAL)

## Set the raw value for this argument.
func set_value(value: String) -> void:
	if _values.size() == 0:
		_values.append(value)
		return
	_values.set(0, value)

func _get_value_or_default() -> Variant:
	if _values.size() == 0:
		return _default if _mode == OPTIONAL else null
	return _values.get(0)

## Get the argument value if it has been set. Returns the given argument type if it is set, null otherwise.
func get_value() -> Variant:
	if !has_value_or_default():
		return apply_type(null)
	return apply_type(_get_value_or_default())

## Get the argument value if it has been set. Returns the raw value.
func get_raw_value() -> String:
	return " ".join(_values)

## Set the raw values for this array argument.
func set_values(values: PackedStringArray) -> void:
	if values == null:
		values = PackedStringArray()
	_values = values

## Add raw values for this array argument.
func add_values(...values: Array) -> void:
	for v: Variant in values:
		_values.append(str(v))

## Get the argument value if it has been set. Returns the packed array of the argument type if it is set, null otherwise.
## Set raw to true to get the raw PackedStringArray.
## Set use_float_64 to true to get the corresponding packed array when argument type is float or int.
## If the argument type is any, an PackedStringArray is returned instead of a Array[Variant].
## If the argument type is bool, values are expected to be either "true" or "false", and the result is a PackedByteArray.
func get_values(raw: bool = false, use_64: bool = false) -> Variant:
	if !has_value():
		return null
	if raw:
		return _values

	match _type:
		FLOAT when use_64:
			var res: PackedFloat64Array = PackedFloat64Array()
			res.resize(_values.size())
			for v: String in _values:
				res.append(float(v))
			return res
		FLOAT when !use_64:
			var res: PackedFloat32Array = PackedFloat32Array()
			res.resize(_values.size())
			for v: String in _values:
				res.append(float(v))
			return res
		INT when use_64:
			var res: PackedInt64Array = PackedInt64Array()
			res.resize(_values.size())
			for v: String in _values:
				res.append(int(v))
			return res
		INT when !use_64:
			var res: PackedInt32Array = PackedInt32Array()
			res.resize(_values.size())
			for v: String in _values:
				res.append(int(v))
			return res
		BOOL:
			var res: PackedByteArray = PackedByteArray()
			for i: int in _values.size():
				res.encode_var(i, _values.get(i) == "true")
			return res
		STRING, ANY, _:
			return _values
