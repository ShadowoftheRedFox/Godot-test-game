## Holds the game buildings definition.
class_name BuildingRegistry extends ElementRegistry

var _buildings: Dictionary[StringName, BuildingDefinition] = {}

## The constant name of this registry.
const NAME: StringName = "BuildingRegistry"

## Shortcut to get itself from the main registry.
static func get_self() -> BuildingRegistry:
	return Global.REGISTRIES.get_registry(NAME)

func get_name() -> StringName:
	return NAME

func _get_dictionary() -> Dictionary[StringName, ElementDefinition]:
	return _buildings as Dictionary[StringName, ElementDefinition]

## Add a building in the registered building list.
## Return true on success, false otherwise.
func add_building(building: BuildingDefinition) -> bool:
	ModLoaderLog.debug.call_deferred("Registered building %s" % building.get_id(), ConstantManager.CORE_MOD_NAME)
	return add_element(building)

## Remove a building from the building list.
## Return true on success, false otherwise.
func remove_building(building: BuildingDefinition) -> bool:
	return remove_element(building)

## Remove a building from the building list by its name.
## Return true on success, false otherwise.
func remove_building_name(name: StringName) -> bool:
	return remove_element_name(name)

## Get the registred building matching the name.
## Return the building if it is registred, null otherwise.
func get_building(name: StringName) -> BuildingDefinition:
	return get_element(name)

## Check if the building is registered.
## Return true if it registered, false otherwise.
func has_building(building: BuildingDefinition) -> bool:
	return has_element_name(building.get_id())

## Check if the building name is registered.
## Return true if it registered, false otherwise.
func has_building_name(name: StringName) -> bool:
	return has_element_name(name)

## Get the list of registered building names.
func get_building_name_list() -> Array[StringName]:
	return get_element_name_list()
