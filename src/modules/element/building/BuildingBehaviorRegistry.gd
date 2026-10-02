## Holds the game buildings behavior call for parsing.
class_name BuildingBehaviorRegistry extends ElementBehaviorRegistry

## The constant name of this registry.
const NAME: StringName = &"BuildingBehaviorRegistry"

func _init() -> void:
	add_behavior(TestBuildingBehavior.new())

## Shortcut to get itself from the main registry.
static func get_self() -> BuildingBehaviorRegistry:
	return Global.REGISTRIES.get_registry(NAME)

func get_name() -> StringName:
	return NAME


## Add a behavior in the registered behavior list.
## Return true on success, false otherwise.
func add_building_behavior(behavior: BuildingBehavior) -> bool:
	return add_behavior(behavior)

## Remove a behavior from the behavior list.
## Return true on success, false otherwise.
func remove_building_behavior(behavior: BuildingBehavior) -> bool:
	return remove_behavior(behavior)

## Check if the behavior is registered.
## Return true if it registered, false otherwise.
func has_building_behavior(behavior: BuildingBehavior) -> bool:
	return has_behavior_name(behavior.get_behavior_name())
