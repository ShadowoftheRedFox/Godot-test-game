## Instance of an element, with the general methods associated.
@abstract class_name ElementInstance extends RefCounted

var _definition_id: StringName = &""

func _init(definition_id: StringName) -> void:
	assert(!Utils.is_blank(definition_id), ErrorList.ERR_V_NOT_BLANK % "definition_id")
	assert(get_definition() != null, ErrorList.ERR_V_IS_NULL % (definition_id + " definition's"))
	_definition_id = definition_id

## Get the element's definition ID.
func get_definition_id() -> StringName:
	return _definition_id

## Get the element's definition object.[br]
## Returne null if the definition doesn't exists.
@abstract func get_definition() -> ElementDefinition

## Call a behavior of this element.
func call_behaviors(interaction: int = 0, data: Dictionary = {}) -> void:
	for b: ElementBehavior in get_definition().get_behaviors():
		b.behave(get_definition_id(), interaction, data)
