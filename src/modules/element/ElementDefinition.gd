## The base of all elements, and their associated informations.
## Elements are the base of all elements, entity, fluids and buildings.
@abstract class_name ElementDefinition extends Resource

const ERR_BEHAVIOR_ALREADY_REGISTERED: String = "The behavior \"%s\" is alregy registered"
const ERR_CANT_PARSE_V: String = "Could not parse the element's JSON: %s"

## The unique name identifying the element.[br]
## If it comes from a mod, it is prefixed by the mod ID followed by `:`, e.g.:
## `mymodname:myelement`
var _id: StringName = ""

## The display name of the element.
var _display_name: String = ""

## List of behaviors that an element can have, such as a tool, armor, food, etc...[br]
## A behavior can only be registered once.
var _behaviors: Dictionary[StringName, ElementBehavior] = {}

## Get the unique ID of this element's definition.
func get_id() -> StringName:
	return _id

## Get the display name of this element.
func get_display_name() -> String:
	return _display_name

## Get the list of behavior on this element.
func get_behaviors() -> Array[ElementBehavior]:
	return _behaviors.values()

## Check if the given behavior is applied on this element.
func has_behavior(name: StringName) -> bool:
	return _behaviors.has(name)

## Add a list of behaviors to this definition. Only add if the behavior is not already registered.
func _add_behaviors(behaviors: Array[ElementBehavior]) -> void:
	for b: ElementBehavior in behaviors:
		_add_behavior(b)

## Add a behavior to this definition. Only add if the behavior is not already registered.
func _add_behavior(behavior: ElementBehavior) -> void:
	assert(!Utils.is_blank(behavior.get_behavior_name()), "Behavior can't have a blank name")
	assert(!_behaviors.has(behavior.get_behavior_name()), ERR_BEHAVIOR_ALREADY_REGISTERED % behavior.get_behavior_name())

	if !_behavior_checks(behavior):
		return

	_behaviors.set(behavior.get_behavior_name(), behavior)

## Checks the behavior by the lass before being added.
## Returns `True` if the behavior should be added.
@abstract func _behavior_checks(behavior: ElementBehavior) -> bool

## Parse the JSON definition of the definition instance, and returns the parsed dictionary.[br]
## Must follow the given `element_schema` JSON schema.[br]
## Returns an empty dictionary if there is an error.
static func _element_parse(mod: String, json_string: String, element_schema: String) -> Dictionary:
	assert(!Utils.is_blank(mod), ErrorList.ERR_V_NOT_BLANK % "mod name")
	assert(!Utils.is_blank(json_string), ErrorList.ERR_V_NOT_BLANK % "json")
	var json_parser: JSON = JSON.new()
	var json_err: int = json_parser.parse(json_string)
	assert(json_err == OK, ERR_CANT_PARSE_V % (json_parser.get_error_message() + " in " + json_string + " at line " + str(json_parser.get_error_line())))
	var json: Dictionary = json_parser.data

	# parse the element following the schema
	var schema: JSONSchema = JSONSchema.new()
	var err: String = schema.validate(json_string, element_schema)
	if !err.is_empty():
		assert(false, ERR_CANT_PARSE_V % err)
		push_error(ERR_CANT_PARSE_V % err)
		return {}

	@warning_ignore("unsafe_call_argument")
	return json

## Parse the JSON definition to the definition instance.[br]
## Must follow the class definition JSON schema. Returns null if there is an error.
static func parse(_mod: String, _json_string: String) -> ElementDefinition:
	assert(false, "The extending class must override this function")
	return null

static func _parse_behaviors(json: Dictionary, behavior_registry: ElementBehaviorRegistry) -> Array[ElementBehavior]:
	var json_behaviors: Variant = json.get("behaviors", [])
	assert(json_behaviors is Array, "Parsed JSON behaviors is not an array")
	@warning_ignore_start("unsafe_cast")
	var json_behaviors_array: Array = json_behaviors as Array

	var result: Array[ElementBehavior] = []
	for i: int in range(json_behaviors_array.size()):
		var b: Variant = json_behaviors_array[i]
		assert(b is Dictionary, "Behavior %d is not a dictionnary" % (i + 1))
		var bd: Dictionary = b as Dictionary
		var bd_name: String = bd.get("name", "") as String
		assert(bd_name, "Behavior object %d has no name" % (i + 1))
		assert(behavior_registry.has_behavior_name(bd_name), "Behavior \"%s\" is unknown" % bd_name)
		var behavior: Variant = behavior_registry.get_behavior(bd_name).call()
		assert(behavior is ElementBehavior, "%s factory does not return an ElementBehavior" % bd_name)
		result.append(behavior)
	@warning_ignore_restore("unsafe_cast")

	return result

func _to_string() -> String:
	return to_json()

## Transform the element definition to the JSON string.[br]
## All JSON generated must be parsed back by `ElementDefinition.parse()`.
func to_json() -> String:
	var stringified_behaviors: PackedStringArray = []
	for b: ElementBehavior in _behaviors.values():
		stringified_behaviors.append(b.to_json())
	return '{"id":"%s","display_name":"%s",behaviors:[%s]}' % [_id, _display_name, ",".join(stringified_behaviors)]
