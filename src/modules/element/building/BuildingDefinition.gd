## The base of all buildings, and their associated informations.
class_name BuildingDefinition extends ElementDefinition

#TODO recipes

## Value emitted to the behavior when the building is used a certain way.
enum Interaction {
	UNKNOWN,

	OPEN_INTERFACE,
	CLOSE_INTERFACE,
	BUILD,
	DESTROY,
}

## The category of the building.
## Some category will call specific functions and/or do specific actions.
enum Category {
	## No specific category. The default value.
	UNCATEGORIZED,
	## Proction building (resources, electricity...)
	PRODUCTION,
	## Storage building (items, fluids...)
	STORAGE,
	## Base buildings (walls, floors, doors...)
	BUILDING,
	## Decoration buildings
	DECORATION,
	## Transportation buildings (trains, conveyor, pipes...)
	TRANSPORTATION,
}

## The category where this building belong.[br]
## Example: A conveyor goes into "Transportation", but a furnace goes into "Production".
var _category: Category = Category.UNCATEGORIZED

## The group where this building belong inside its category.[br]
## Example: A conveyor goes into "Conveyor" in "Transportation", a furnace goes into "Smelter" in "Production".
var _group: String = ""

## Mesh of the building.
var building_mesh: Mesh = null

## Whether or not this building must be hidden from the build menu.[br]
## An example of a hidden building can be building that spawn naturally but cannot be crafted, such as ruins.
var _hidden: bool = false

func _init(
		id: StringName,
		display_name: String,
		category: Category = Category.UNCATEGORIZED,
		group: String = "",
		behaviors: Array[ElementBehavior] = [],
		hidden: bool = false
	) -> void:
	assert(!Utils.is_blank(id), ErrorList.ERR_V_NOT_BLANK % "id")
	assert(category != null, ErrorList.ERR_V_IS_NULL % "category")
	_id = id
	_display_name = display_name
	_category = category
	_group = group
	_hidden = hidden
	_add_behaviors(behaviors)

## Get the list of behavior on this building.
func get_building_behaviors() -> Array[BuildingBehavior]:
	return get_behaviors() as Array[BuildingBehavior]

func _behavior_checks(behavior: ElementBehavior) -> bool:
	assert(behavior is BuildingBehavior, "%s is not a BuildingBehavior" % behavior.get_behavior_name())

	return true

## Parse the JSON definition to the definition instance.[br]
## Must follow the BuildingDefinition JSON schema. Returns null if there is an error.
static func parse(mod: String, json_string: String) -> BuildingDefinition:
	var json: Dictionary = _element_parse(mod, json_string, ConstantManager.BUILDING_SCHEMA)

	@warning_ignore("unsafe_call_argument")
	return BuildingDefinition.new(\
		json.get("id", ""),
		json.get("display_name", ""),
		Category.get(json.get("category", Category.keys()[Category.UNCATEGORIZED])),
		json.get("group", ""),
		_parse_behaviors(json, BuildingBehaviorRegistry.get_self()),
		json.get("hidden", false)
	)

## Transform the building definition to the JSON string.[br]
## All JSON generated must be parsed back by `BuildingDefinition.parse()`.
func to_json() -> String:
	var stringified_behaviors: PackedStringArray = []
	for b: BuildingBehavior in _behaviors.values():
		stringified_behaviors.append(b.to_json())

	return JSON.stringify({
		"id": _id,
		"display_name": _display_name,
		"category": Category.keys()[_category],
		"group": _group,
		"behaviors": ",".join(stringified_behaviors)
	})
