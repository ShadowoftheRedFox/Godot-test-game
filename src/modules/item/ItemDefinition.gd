## The base of all items, and their associated informations.
class_name ItemDefinition extends Resource

# const ITEM_SCHEMA: Resource = preload("res://src/modules/item/ItemSchema.json")

const ERR_ITEM_STACK_INVALID: String = "The item \"%s\" stack must be greater or equal to 1, found %d"
const ERR_BEHAVIOR_ALREADY_REGISTERED: String = "The behavior \"%s\" is alregy registered"
const ERR_CANT_PARSE_V: String = "Could not parse the item's JSON: %s"

## Value emitted to the behavior when the item is used a certain way.
enum Interaction {
	UNKNOWN,

	PICKED_UP,
	DROPPED,
	USED,
}

## The unique name identifying the item.[br]
## If it comes from a mod, it is prefixed by the mod ID followed by `:`, e.g.:
## `mymodname:myitem`
var _id: StringName = ""

## The display name of the item.
var _display_name: String = ""

## The size a stack of this item can get at most. Must be greater or equal to 1.
var _stack_size: int = 100

## The 3D mesh of this item.
var _mesh: Mesh = null

## List of behaviors that an item can have, such as a tool, armor, etc...[br]
## A behavior can only be registered once.
var _behaviors: Dictionary[StringName, ItemBehavior] = {}

func _init(id: StringName, display_name: String, stack_size: int = 100, behaviors: Array[ItemBehavior] = []) -> void:
	assert(!Utils.is_blank(id), ErrorList.ERR_V_NOT_BLANK % "id")
	assert(stack_size > 0, ERR_ITEM_STACK_INVALID % [id, stack_size])
	_id = id
	_display_name = display_name
	_stack_size = stack_size
	_add_behaviors(behaviors)

## Get the unique ID of this item's definition.
func get_id() -> StringName:
	return _id

## Get the display name of this item.
func get_display_name() -> String:
	return _display_name

## The the value of the maximum stack size possible. Always greater or equal to 1.
func get_stack_size() -> int:
	return _stack_size

func get_mesh() -> Mesh:
	return _mesh

## Get the list of behavior on this item.
func get_behaviors() -> Array[ItemBehavior]:
	return _behaviors.values()

## Check if teh given behavior is applied on this item.
func has_behavior(name: StringName) -> bool:
	return _behaviors.has(name)

## Add a list of behaviors to this definition. Only add if the behavior is not already registered.
func _add_behaviors(behaviors: Array[ItemBehavior]) -> void:
	for b: ItemBehavior in behaviors:
		_add_behavior(b)

## Add a behavior to this definition. Only add if the behavior is not already registered.
func _add_behavior(behavior: ItemBehavior) -> void:
	assert(!Utils.is_blank(behavior.get_behavior_name()), "Behavior can't have a blank name")
	assert(!_behaviors.has(behavior.get_behavior_name()), ERR_BEHAVIOR_ALREADY_REGISTERED % behavior.get_behavior_name())

	_behaviors.set(behavior.get_behavior_name(), behavior)

## Parse the JSON definition to the definition instance.[br]
## Must follow the ItemDefinition JSON schema. Returns null if there is an error.
static func parse(mod: String, json_string: String) -> ItemDefinition:
	assert(!Utils.is_blank(mod), ErrorList.ERR_V_NOT_BLANK % "mod name")
	assert(!Utils.is_blank(json_string), ErrorList.ERR_V_NOT_BLANK % "json")
	var json_parser: JSON = JSON.new()
	var json_err: int = json_parser.parse(json_string)
	assert(json_err == OK, ERR_CANT_PARSE_V % (json_parser.get_error_message() + " in " + json_string + " at line " + str(json_parser.get_error_line())))
	var json: Dictionary = json_parser.data

	# parse the item following the schema
	var schema: JSONSchema = JSONSchema.new()
	var err: String = schema.validate(json_string, ConstantManager.ITEM_SCHEMA)
	if !err.is_empty():
		assert(false, ERR_CANT_PARSE_V % err)
		push_error(ERR_CANT_PARSE_V % err)
		return null

	@warning_ignore("unsafe_call_argument")
	return ItemDefinition.new(json.get("id", ""), json.get("display_name", ""), json.get("stack_size", 100), _parse_behaviors(json))

static func _parse_behaviors(json: Dictionary) -> Array[ItemBehavior]:
	var json_behaviors: Variant = json.get("behaviors", [])
	assert(json_behaviors is Array, "Parsed JSON behaviors is not an array")
	@warning_ignore_start("unsafe_cast")
	var json_behaviors_array: Array = json_behaviors as Array

	var result: Array[ItemBehavior] = []
	for i: int in range(json_behaviors_array.size()):
		var b: Variant = json_behaviors_array[i]
		assert(b is Dictionary, "Behavior %d is not a dictionnary" % (i + 1))
		var bd: Dictionary = b as Dictionary
		var bd_name: String = bd.get("name", "") as String
		assert(bd_name, "Behavior object %d has no name" % (i + 1))
		assert(ItemBehaviorRegistry.get_self().has_behavior_name(bd_name), "Behavior \"%s\" is unknown" % bd_name)
		var behavior: Variant = ItemBehaviorRegistry.get_self().get_behavior(bd_name).call()
		assert(behavior is ItemBehavior, "%s factory does not return an ItemBehavior" % bd_name)
		result.append(behavior)
	@warning_ignore_restore("unsafe_cast")

	return result

func _to_string() -> String:
	return to_json()

## Transform the item definition to the JSON string.[br]
## All JSON generated must be parsed back by `ItemDefinition.parse()`.
func to_json() -> String:
	var stringified_behaviors: PackedStringArray = []
	for b: ItemBehavior in _behaviors.values():
		stringified_behaviors.append(b.to_json())
	return '{"id":"%s","display_name":"%s","stack_size":%d,behaviors:[%s]}' % [_id, _display_name, _stack_size, ",".join(stringified_behaviors)]
