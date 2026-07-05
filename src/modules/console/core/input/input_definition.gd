class_name InputDefinition

var _arguments: Array[InputArgument] = []
var _required_count: int = 0
var _last_argument: InputArgument = null

func _init(arguments: Array[InputArgument] = []) -> void:
	set_arguments(arguments)

## Reset and set arguments inputs
func set_arguments(arguments: Array[InputArgument]) -> void:
	_arguments = []
	_required_count = 0
	_last_argument = null
	add_arguments(arguments)

## Add an array of arguments inputs
func add_arguments(arguments: Array[InputArgument]) -> void:
	if arguments == null:
		return

	for argument: InputArgument in arguments:
		add_argument(argument)

## Add a argument
func add_argument(argument: InputArgument) -> void:
	if argument == null:
		return

	assert(!has_argument(argument.name), "An argument with name " + argument.name + " already exists")
	assert(_last_argument == null || !_last_argument.is_array(), "Cannot push argument " + argument.name + " after an array argument " + _last_argument.name)
	if argument.is_optional():
		assert(_last_argument == null || (!_last_argument.is_required() && !_last_argument.is_array()), "Cannot push optional argument " + argument.name + " after argument " + _last_argument.name)

	if argument.is_required():
		_required_count += 1
	_last_argument = argument
	_arguments.append(argument)

## Returns true if the given argument name exists
func has_argument(name: String) -> bool:
	if name.is_empty():
		return false

	for argument: InputArgument in _arguments:
		if argument.name == name:
			return true

	return false

## Returns true if the given argument index exists
func has_argument_index(index: int) -> bool:
	if index < 0:
		return false

	return get_arguments_count() > index

## Returns the argument if it exists by name, or null
func get_argument(name: String) -> InputArgument:
	if name.is_empty():
		return null

	for argument: InputArgument in _arguments:
		if argument.name == name:
			return argument

	return null

## Returns the argument if it exists by index, or null
func get_argument_index(index: int) -> InputArgument:
	if !has_argument_index(index):
		return null

	return _arguments[index]

## Get the number of arguments
func get_arguments_count() -> int:
	return _arguments.size()

## Get the number of required arguments
func get_required_arguments_count() -> int:
	return _required_count

## Get the amount of optional arguments
func get_optional_arguments_count() -> int:
	return get_arguments_count() - get_required_arguments_count()

## Get the synopsys of the inputs
func get_synopsis() -> String:
	var elements: PackedStringArray = PackedStringArray()
	var tail: String = ""

	for argument: InputArgument in _arguments:
		var element: String = "<" + argument.name + " : " + argument.get_type_name() + ">"
		if argument.is_array():
			element += "..."
		if !argument.is_required():
			element = "[" + element
			tail += "]"
		elements.append(element)

	return ", ".join(elements) + tail
