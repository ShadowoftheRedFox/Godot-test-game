## Holds the game items definition.
class_name ItemRegistry extends AbstractRegistry

var _items: Dictionary[StringName, ItemDefinition] = {}

#TODO mod compatible with prefixes, and can ignore prefix if name is unique

## The constant name of this registry.
const NAME: StringName = "ItemRegistry"

## Shortcut to get itself from the main registry.
static func get_self() -> ItemRegistry:
	return Global.REGISTRIES.get_registry(NAME)

## TODO Shortcuts for the main functions.

func get_name() -> StringName:
	return NAME

func _freeze() -> void:
	_items.make_read_only()

func add_object(obj: Object) -> bool:
	if obj == null || obj is not ItemDefinition:
		return false
	return add_item(obj as ItemDefinition)

@warning_ignore_start("unsafe_call_argument")
func get_object(id: Variant) -> Object:
	return get_item(type_convert(id, TYPE_STRING_NAME))

func has_object(id: Variant) -> bool:
	return has_item_name(type_convert(id, TYPE_STRING_NAME))

func remove_object(id: Variant) -> bool:
	return remove_item_name(type_convert(id, TYPE_STRING_NAME))
@warning_ignore_restore("unsafe_call_argument")

func size() -> int:
	return _items.size()

## Add a item in the registered item list.
## Return true on success, false otherwise.
func add_item(item: ItemDefinition) -> bool:
	ModLoaderLog.debug.call_deferred("Registered item %s" % item.get_id(), ConstantManager.CORE_MOD_NAME)
	return _items.set(item.get_id(), item)

## Remove an item from the item list.
## Return true on success, false otherwise.
func remove_item(item: ItemDefinition) -> bool:
	if item == null || !has_item(item):
		return true
	return remove_item_name(item.get_id())

## Remove an item from the item list by its name.
## Return true on success, false otherwise.
func remove_item_name(name: StringName) -> bool:
	if name == null || !has_item_name(name):
		return true
	return _items.erase(name)

## Get the registred item matching the name.
## Return the item if it is registred, null otherwise.
func get_item(name: StringName) -> ItemDefinition:
	return _items.get(name)

## Check if the item is registered.
## Return true if it registered, false otherwise.
func has_item(item: ItemDefinition) -> bool:
	return has_item_name(item.get_id())

## Check if the item name is registered.
## Return true if it registered, false otherwise.
func has_item_name(name: StringName) -> bool:
	return _items.has(name)

## Get the list of registered item names.
func get_item_name_list() -> Array[StringName]:
	return _items.keys()
