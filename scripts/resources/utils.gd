## Has static functions to call from anywhere for general purpose
class_name Utils

## Check if the given string is not blank, meaning contains only whitespace (space, \n and \r) or is empty
static func _is_blank(str_value: String) -> bool:
	return str_value.remove_chars(" \n\r").is_empty()
