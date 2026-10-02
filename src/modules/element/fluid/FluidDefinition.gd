## The base of all fluids, and their associated informations.
class_name FluidDefinition extends ElementDefinition

## Value emitted to the behavior when the fluid is used a certain way.
enum Interaction {
	UNKNOWN,
}

func _init(id: StringName, display_name: String, behaviors: Array[ElementBehavior] = []) -> void:
	assert(!Utils.is_blank(id), ErrorList.ERR_V_NOT_BLANK % "id")
	_id = id
	_display_name = display_name
	_add_behaviors(behaviors)

## Get the list of behavior on this fluid.
func get_fluid_behaviors() -> Array[FluidBehavior]:
	return get_behaviors() as Array[FluidBehavior]

func _behavior_checks(behavior: ElementBehavior) -> bool:
	assert(behavior is FluidBehavior, "%s is not a FluidBehavior" % behavior.get_behavior_name())

	return true

## Parse the JSON definition to the definition instance.[br]
## Must follow the FluidDefinition JSON schema. Returns null if there is an error.
static func parse(mod: String, json_string: String) -> FluidDefinition:
	var json: Dictionary = _element_parse(mod, json_string, ConstantManager.FLUID_SCHEMA)

	@warning_ignore("unsafe_call_argument")
	return FluidDefinition.new(json.get("id", ""), json.get("display_name", ""), _parse_behaviors(json, FluidBehaviorRegistry.get_self()))

## Transform the fluid definition to the JSON string.[br]
## All JSON generated must be parsed back by `FluidDefinition.parse()`.
func to_json() -> String:
	var stringified_behaviors: PackedStringArray = []
	for b: FluidBehavior in _behaviors.values():
		stringified_behaviors.append(b.to_json())
	return '{"id":"%s","display_name":"%s",behaviors:[%s]}' % [_id, _display_name, ",".join(stringified_behaviors)]
