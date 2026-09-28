## Holds the game items behavior call for parsing.
class_name ItemBehaviorRegistry extends AbstractRegistry

var _behaviors: Dictionary[StringName, Callable] = {}

#TODO mod compatible with prefixes, and can ignore prefix if name is unique

## The constant name of this registry.
const NAME: StringName = "ItemBehaviorRegistry"

func _init() -> void:
	add_behavior(TestItemBehavior.new())

## Shortcut to get itself from the main registry.
static func get_self() -> ItemBehaviorRegistry:
	return Global.REGISTRIES.get_registry(NAME)

func get_name() -> StringName:
	return NAME

func _freeze() -> void:
	_behaviors.make_read_only()

func add_object(obj: Object) -> bool:
	if obj == null || obj is not ItemBehavior:
		return false
	return add_behavior(obj as ItemBehavior)

@warning_ignore_start("unsafe_call_argument")
func get_object(id: Variant) -> Variant:
	return get_behavior(type_convert(id, TYPE_STRING_NAME))

func has_object(id: Variant) -> bool:
	return has_behavior_name(type_convert(id, TYPE_STRING_NAME))

func remove_object(id: Variant) -> bool:
	return remove_behavior_name(type_convert(id, TYPE_STRING_NAME))
@warning_ignore_restore("unsafe_call_argument")

func size() -> int:
	return _behaviors.size()

## Add a behavior in the registered behavior list.
## Return true on success, false otherwise.
func add_behavior(behavior: ItemBehavior) -> bool:
	assert(!behavior.get_factory().is_null(), ErrorList.ERR_V_IS_NULL % "behavior factory")
	return _behaviors.set(behavior.get_behavior_name(), behavior.get_factory())

## Remove a behavior from the behavior list.
## Return true on success, false otherwise.
func remove_behavior(behavior: ItemBehavior) -> bool:
	if behavior == null || !has_behavior(behavior):
		return true
	return remove_behavior_name(behavior.get_behavior_name())

## Remove a behavior from the behavior list by its name.
## Return true on success, false otherwise.
func remove_behavior_name(name: StringName) -> bool:
	if name == null || !has_behavior_name(name):
		return true
	return _behaviors.erase(name)

## Get the registred behavior matching the name.
## Return the behavior if it is registred, null otherwise.
func get_behavior(name: StringName) -> Callable:
	return _behaviors.get(name)

## Check if the behavior is registered.
## Return true if it registered, false otherwise.
func has_behavior(behavior: ItemBehavior) -> bool:
	return has_behavior_name(behavior.get_behavior_name())

## Check if the behavior name is registered.
## Return true if it registered, false otherwise.
func has_behavior_name(name: StringName) -> bool:
	return _behaviors.has(name)

## Get the list of registered behavior names.
func get_behavior_name_list() -> Array[StringName]:
	return _behaviors.keys()
