## Holds the game fluids behavior call for parsing.
class_name FluidBehaviorRegistry extends ElementBehaviorRegistry

## The constant name of this registry.
const NAME: StringName = &"FluidBehaviorRegistry"

func _init() -> void:
	add_behavior(TestFluidBehavior.new())

## Shortcut to get itself from the main registry.
static func get_self() -> FluidBehaviorRegistry:
	return Global.REGISTRIES.get_registry(NAME)

func get_name() -> StringName:
	return NAME


## Add a behavior in the registered behavior list.
## Return true on success, false otherwise.
func add_fluid_behavior(behavior: FluidBehavior) -> bool:
	return add_behavior(behavior)

## Remove a behavior from the behavior list.
## Return true on success, false otherwise.
func remove_fluid_behavior(behavior: FluidBehavior) -> bool:
	return remove_behavior(behavior)

## Check if the behavior is registered.
## Return true if it registered, false otherwise.
func has_fluid_behavior(behavior: FluidBehavior) -> bool:
	return has_behavior_name(behavior.get_behavior_name())
