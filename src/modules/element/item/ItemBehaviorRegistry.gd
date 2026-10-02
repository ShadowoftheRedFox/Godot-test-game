## Holds the game items behavior call for parsing.
class_name ItemBehaviorRegistry extends ElementBehaviorRegistry

## The constant name of this registry.
const NAME: StringName = &"ItemBehaviorRegistry"

func _init() -> void:
	add_behavior(TestItemBehavior.new())

## Shortcut to get itself from the main registry.
static func get_self() -> ItemBehaviorRegistry:
	return Global.REGISTRIES.get_registry(NAME)

func get_name() -> StringName:
	return NAME

## Add a behavior in the registered behavior list.
## Return true on success, false otherwise.
func add_item_behavior(behavior: ItemBehavior) -> bool:
	return add_behavior(behavior)

## Remove a behavior from the behavior list.
## Return true on success, false otherwise.
func remove_item_behavior(behavior: ItemBehavior) -> bool:
	return remove_behavior(behavior)

## Check if the behavior is registered.
## Return true if it registered, false otherwise.
func has_item_behavior(behavior: ItemBehavior) -> bool:
	return has_behavior_name(behavior.get_behavior_name())
