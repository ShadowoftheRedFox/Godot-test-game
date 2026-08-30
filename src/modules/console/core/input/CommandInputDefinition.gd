class_name CommandInputDefinition

## The default command input definition.
static func DEFAULT() -> CommandInputDefinition:
	return CommandInputDefinition.new([
		CommandInputArgument.new('command', "The command to execute", CommandInputArgument.REQUIRED)
	])

var _arguments: Array[CommandInputArgument] = []
var _required_count: int = 0
var _last_argument: CommandInputArgument = null

func _init(arguments: Array[CommandInputArgument] = []) -> void:
	set_arguments(arguments)

## Reset and set arguments inputs
func set_arguments(arguments: Array[CommandInputArgument]) -> CommandInputDefinition:
	_arguments = []
	_required_count = 0
	_last_argument = null
	add_arguments(arguments)
	return self

## Add an array of arguments inputs
func add_arguments(arguments: Array[CommandInputArgument]) -> CommandInputDefinition:
	if arguments != null:
		for argument: CommandInputArgument in arguments:
			add_argument(argument)
	return self

## Add a argument
func add_argument(argument: CommandInputArgument) -> CommandInputDefinition:
	if argument == null:
		return

	assert(!has_argument(argument.name), "An argument with name " + argument.name + " already exists")
	if _last_argument != null:
		assert(!_last_argument.is_array(), "Cannot push argument " + argument.name + " after an array argument " + _last_argument.name)

	if argument.is_required():
		_required_count += 1
	_last_argument = argument
	_arguments.append(argument)
	return self

## Returns true if the given argument name exists
func has_argument(name: String) -> bool:
	if name.is_empty():
		return false

	for argument: CommandInputArgument in _arguments:
		if argument.name == name:
			return true

	return false

## Returns true if the given argument index exists
func has_argument_index(index: int) -> bool:
	if index < 0:
		return false

	return get_arguments_count() > index

## Returns the argument if it exists by name, or null
func get_argument(name: String) -> CommandInputArgument:
	if name.is_empty():
		return null

	for argument: CommandInputArgument in _arguments:
		if argument.name == name:
			return argument

	return null

## Returns the argument if it exists by index, or null
func get_argument_from_index(index: int) -> CommandInputArgument:
	if !has_argument_index(index):
		return null

	return _arguments[index]

## Get the position of the argument in the list of argument.
## Return -1 is the agrument does not exists.
func get_argument_index(name: String) -> int:
	var i: int = 0
	for arg: CommandInputArgument in _arguments:
		if arg.name == name:
			return i
		i += 1
	return -1

## Returns the argument if it exists by reversed index, or null
func get_argument_from_index_reversed(index: int) -> CommandInputArgument:
	var i: int = get_arguments_count() - index - 1
	if !has_argument_index(i):
		return null

	return _arguments[i]

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

	for argument: CommandInputArgument in _arguments:
		var element: String = argument.name + " : " + argument.get_type_name()
		if argument.is_array():
			element += "..."
		if !argument.is_required():
			element = "[" + element + "]"
		elif argument.is_required():
			element = "<" + element + ">"
		elements.append(element)

	return " ".join(elements)
