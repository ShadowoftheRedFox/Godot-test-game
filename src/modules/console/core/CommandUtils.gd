## Utilitary class for various task needed by mutliple command classes.
class_name CommandUtils

## Return the command command if it is registered, null otherwise.
static func get_command_or_alias(command_name_or_alias: String, source: Array[Command]) -> Command:
	# no source or empty
	if source == null || source.size() == 0 || command_name_or_alias == null:
		return null

	for cmd: Command in source:
		if cmd.name == command_name_or_alias || cmd.aliases.has(command_name_or_alias):
			return cmd
	return null

## Tries to find a command whose name or alias match the given value.
## If no match is found, tries to find the best name or alias starting with the value.
## Returns the list of candidates.
static func find_command(command_name: String, source: Array[Command]) -> Array[Command]:
	# no source or empty
	if source == null || source.size() == 0:
		return []
	# if command_name is empty, just send back all commands
	if command_name == null || command_name.is_empty():
		return source

	# if we have an exact match, return it
	var _cmd: Command = get_command_or_alias(command_name, source)
	if _cmd != null:
		return [_cmd]

	var candidates: Array[Command] = []

	# otherwise, get a list of close match from name and aliases
	for cmd: Command in source:
		if cmd.name.begins_with(command_name):
			candidates.append(cmd)
			continue
		for alias: String in cmd.aliases:
			if alias.begins_with(command_name):
				candidates.append(cmd)
				continue

	return candidates

## Returns the longest common prefix of all items in the list.
## This does not edit the given list. A copy is made for the operations.
static func find_common_prefix(list: PackedStringArray) -> String:
	if list == null || list.size() == 0:
		return ""
	if list.size() == 1:
		return list.get(0)

	# following this beautiful solution: https://stackoverflow.com/questions/1336207/finding-common-prefix-of-array-of-strings
	var copy: PackedStringArray = list.duplicate()
	copy.sort()
	# get first and last string
	var a: String = copy.get(0)
	var b: String = copy.get(copy.size() - 1)
	var length: int = mini(a.length(), b.length())

	var i: int = 0
	while i < length && a.unicode_at(i) == b.unicode_at(i):
		i += 1

	return a.substr(0, i)
