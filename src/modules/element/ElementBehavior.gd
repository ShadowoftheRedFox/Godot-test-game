## Adds functionnality to an element. Called everytime an element is used.
@abstract class_name ElementBehavior extends Resource

## The factory that will create the instance of this behavior.[br]
## It will be given the parsed data from the JSON in a dictionary.[br]
## It must return an instance of `ElementBehavior`.
@abstract func get_factory() -> Callable
## Get a unique name for this behavior to be found by the element definition.
@abstract func get_behavior_name() -> StringName
## Called everytime an element is used or interacted with, described by the `interaction`.
## Additional data can be added via the `data` dictionary.
@abstract func behave(element_definition_id: StringName, interaction: int = 0, data: Dictionary = {}) -> void
## A JSON version of this behavior.[br]
## Must declare all value that needs to be parsed to get the behavior back when stringified.
@abstract func _to_json() -> String

func _to_string() -> String:
	return to_json()

## Get the behavior JSON representation.[br]
## All behavior must be of the form `{"type": String, "data": JSON}`.
func to_json() -> String:
	var json: String = _to_json()
	assert(JSON.parse_string(json) != null, ErrorList.INVALID_JSON)
	return '{"type":"%s","data":%s}' % [get_behavior_name(), json]
