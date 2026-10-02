## The base of all items, and their associated informations.
class_name ItemDefinition extends ElementDefinition

const ERR_ITEM_STACK_INVALID: String = "The item \"%s\" stack must be greater or equal to 1, found %d"

#TODO recipes

## Value emitted to the behavior when the item is used a certain way.
enum Interaction {
	UNKNOWN,

	PICKED_UP,
	DROPPED,
	USED,
}

## The size a stack of this item can get at most. Must be greater or equal to 1.
var _stack_size: int = 100

## The 3D mesh of this item.
var _mesh: Mesh = null

func _init(id: StringName, display_name: String, stack_size: int = 100, behaviors: Array[ElementBehavior] = []) -> void:
	assert(!Utils.is_blank(id), ErrorList.ERR_V_NOT_BLANK % "id")
	assert(stack_size > 0, ERR_ITEM_STACK_INVALID % [id, stack_size])
	_id = id
	_display_name = display_name
	_stack_size = stack_size
	_add_behaviors(behaviors)

## The the value of the maximum stack size possible. Always greater or equal to 1.
func get_stack_size() -> int:
	return _stack_size

## Get the item's mesh for 3D Representation in the world.
func get_mesh() -> Mesh:
	return _mesh

## Get the list of behavior on this item.
func get_item_behaviors() -> Array[ItemBehavior]:
	return _behaviors.values()

func _behavior_checks(behavior: ElementBehavior) -> bool:
	assert(behavior is ItemBehavior, "%s is not an ItemBehavior" % behavior.get_behavior_name())

	return true

## Parse the JSON definition to the definition instance.[br]
## Must follow the ItemDefinition JSON schema. Returns null if there is an error.
static func parse(mod: String, json_string: String) -> ItemDefinition:
	var json: Dictionary = _element_parse(mod, json_string, ConstantManager.ITEM_SCHEMA)

	@warning_ignore("unsafe_call_argument")
	return ItemDefinition.new(json.get("id", ""), json.get("display_name", ""), json.get("stack_size", 100), _parse_behaviors(json, ItemBehaviorRegistry.get_self()))

## Transform the item definition to the JSON string.[br]
## All JSON generated must be parsed back by `ItemDefinition.parse()`.
func to_json() -> String:
	var stringified_behaviors: PackedStringArray = []
	for b: ItemBehavior in _behaviors.values():
		stringified_behaviors.append(b.to_json())

	return JSON.stringify({
		"id": _id,
		"display_name": _display_name,
		"stack_size": _stack_size,
		"behaviors": ",".join(stringified_behaviors)
	})
