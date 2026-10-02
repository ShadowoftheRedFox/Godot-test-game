## Holds the game fluids definition.
class_name FluidRegistry extends ElementRegistry

var _fluids: Dictionary[StringName, FluidDefinition] = {}

## The constant name of this registry.
const NAME: StringName = &"FluidRegistry"

## Shortcut to get itself from the main registry.
static func get_self() -> FluidRegistry:
	return Global.REGISTRIES.get_registry(NAME)

func get_name() -> StringName:
	return NAME

func _get_dictionary() -> Dictionary[StringName, ElementDefinition]:
	return _fluids as Dictionary[StringName, ElementDefinition]

## Add a fluid in the registered fluid list.
## Return true on success, false otherwise.
func add_fluid(fluid: FluidDefinition) -> bool:
	ModLoaderLog.debug.call_deferred("Registered fluid %s" % fluid.get_id(), ConstantManager.CORE_MOD_NAME)
	return add_element(fluid)

## Remove a fluid from the fluid list.
## Return true on success, false otherwise.
func remove_fluid(fluid: FluidDefinition) -> bool:
	return remove_element(fluid)

## Remove a fluid from the fluid list by its name.
## Return true on success, false otherwise.
func remove_fluid_name(name: StringName) -> bool:
	return remove_element_name(name)

## Get the registred fluid matching the name.
## Return the fluid if it is registred, null otherwise.
func get_fluid(name: StringName) -> FluidDefinition:
	return get_element(name)

## Check if the fluid is registered.
## Return true if it registered, false otherwise.
func has_fluid(fluid: FluidDefinition) -> bool:
	return has_element_name(fluid.get_id())

## Check if the fluid name is registered.
## Return true if it registered, false otherwise.
func has_fluid_name(name: StringName) -> bool:
	return has_element_name(name)

## Get the list of registered fluid names.
func get_fluid_name_list() -> Array[StringName]:
	return get_element_name_list()
