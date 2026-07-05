class_name CommandInput

var _definition: InputDefinition = null
var _arguments: Dictionary[String, Variant] = {}

func _init(line: String, definition: InputDefinition) -> void:
	if (definition == null):
		_definition = InputDefinition.new()
	else:
		_definition = definition

	parse(line)
	validate()

## Processes the command line argument
func parse(line: String) -> void:
	var words: PackedStringArray = line.strip_edges().split(" ", false)

	for i: int in words.size():
		# the true index of the input argument is curent size of _arguments
		# because there can be an array that hold multiple words at the end
		var index: int = _arguments.size()
		var argument: InputArgument = _definition.get_argument_index(index)

		# the current word being parsed
		var word: String = words[i]
		# if the definition expect another argument, add it
		if _definition.has_argument_index(index):
			# if argument is an array, save it in an array
			if argument.is_array():
				_arguments.set(argument.name, [argument.apply_type(word)])
			else:
				_arguments.set(argument.name, argument.apply_type(word))
		# last argument is an array, append the value word to it
		elif _definition.has_argument_index(index - 1) && _definition.get_argument_index(index - 1).is_array():
			var values: Array[String] = _arguments.get_or_add(argument.name, [])
			values.push_back(argument.apply_type(word))
			_arguments.set(argument.name, values)
		else:
			assert(false, "Too many arguments, starting from " + word)

func validate() -> void:
	var missing_arguments: Array[InputArgument] = _definition._arguments.filter(\
		func(arg: InputArgument) -> bool:
			return !_arguments.has(arg.name) && arg.is_required()
	);

	if missing_arguments.size() == 0:
		return

	push_error("Missing arguments: " + ", ".join(\
		missing_arguments.map(func(arg: InputArgument) -> String: return arg.name))
	)

## Checks if the argument exists.
func has_argument(name: String) -> bool:
	return _definition.has_argument(name)

## Get the argument by its name.
func get_argument(name: String) -> Variant:
	assert(_definition.has_argument(name), "The " + name + " argument doesn't exists.")
	return _arguments.get_or_add(name, _definition.get_argument(name))

## Set the current value of the argument to the given value.
func set_argument(name: String, value: Variant) -> void:
	assert(_definition.has_argument(name), "The " + name + " argument doesn't exists.")
	var argument: InputArgument = _definition.get_argument(name)
	# if argument is an array, make sure value is one as well, of the correct type
	if argument.is_array():
		if typeof(value) == TYPE_ARRAY:
			var array: Array = value
			for i: int in array.size():
				array[i] = argument.apply_type(array[i])
			value = array
		else:
			value = [argument.apply_type(value)]
		_arguments.set(name, value)
	else:
		_arguments.set(name, argument.apply_type(value))
