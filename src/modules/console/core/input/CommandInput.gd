class_name CommandInput

var _definition: CommandInputDefinition = null
var _unknwown_arguments_values: PackedStringArray = PackedStringArray()
## The last argument parsed. Empty string if none were parsed.
var last_argument: String = ""

func _init(line: String, definition: CommandInputDefinition = null) -> void:
	if (definition == null):
		_definition = CommandInputDefinition.DEFAULT()
	else:
		_definition = definition

	parse(line)

## Process the command line arguments
func parse(line: String) -> void:
	var words: PackedStringArray = line.split(" ", false)

	# the true index of the input argument is curent size of _arguments
	# because there can be an array that hold multiple words at the end
	var index: int = 0
	for i: int in words.size():
		var argument: CommandInputArgument = _definition.get_argument_from_index(index)

		# the current word being parsed
		var word: String = words[i]

		# if the definition expect another argument, add it
		if _definition.has_argument_index(index):
			argument.set_value(word)
			last_argument = argument.name
			index += 1
		# last argument is an array, append the value word to it
		elif _definition.has_argument_index(index - 1) && _definition.get_argument_from_index(index - 1).is_array():
			argument.add_values(word)
		else:
			# else too many arguments
			_unknwown_arguments_values.append(word)

	while _definition.has_argument_index(index + 1):
		index += 1
		_definition.get_argument_from_index(index).set_value("")

## Validate if all the arguments are valid. Return an empty string if valid, the error otherwise.
func validate() -> String:
	if _unknwown_arguments_values.size() > 0:
		return "Unexpected values after last argument \"" + _definition.get_argument_from_index_reversed(0).name + "\": " + " ".join(_unknwown_arguments_values)

	var missing_arguments: Array[CommandInputArgument] = _definition._arguments.filter(\
		func(arg: CommandInputArgument) -> bool:
			print(arg.name, " ", arg.get_value())
			if arg.is_required():
				return !arg.has_value()
			if arg.is_optional():
				return false
			if arg.is_array():
				return false
			return false
	);

	if missing_arguments.size() == 0:
		return ""

	return "Missing arguments: " + ", ".join(missing_arguments.map(func(arg: CommandInputArgument) -> String: return arg.name))

## Checks if the argument exists.
func has_argument(name: String) -> bool:
	return _definition.has_argument(name)

## Get the argument by its name.
func get_argument(name: String) -> CommandInputArgument:
	return _definition.get_argument(name)

func get_argument_index(name: String) -> int:
	return _definition.get_argument_index(name)
