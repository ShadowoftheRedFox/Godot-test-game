## Holds the game items definition.
class_name ItemRegistry extends ElementRegistry

var _items: Dictionary[StringName, ItemDefinition] = {}

## The constant name of this registry.
const NAME: StringName = &"ItemRegistry"

## Shortcut to get itself from the main registry.
static func get_self() -> ItemRegistry:
	return Global.REGISTRIES.get_registry(NAME)

func get_name() -> StringName:
	return NAME

func _get_dictionary() -> Dictionary[StringName, ElementDefinition]:
	return _items as Dictionary[StringName, ElementDefinition]

## Add a item in the registered item list.
## Return true on success, false otherwise.
func add_item(item: ItemDefinition) -> bool:
	ModLoaderLog.debug.call_deferred("Registered item %s" % item.get_id(), ConstantManager.CORE_MOD_NAME)
	return add_element(item)

## Remove an item from the item list.
## Return true on success, false otherwise.
func remove_item(item: ItemDefinition) -> bool:
	return remove_element(item)

## Remove an item from the item list by its name.
## Return true on success, false otherwise.
func remove_item_name(name: StringName) -> bool:
	return remove_element_name(name)

## Get the registred item matching the name.
## Return the item if it is registred, null otherwise.
func get_item(name: StringName) -> ItemDefinition:
	return get_element(name)

## Check if the item is registered.
## Return true if it registered, false otherwise.
func has_item(item: ItemDefinition) -> bool:
	return has_element_name(item.get_id())

## Check if the item name is registered.
## Return true if it registered, false otherwise.
func has_item_name(name: StringName) -> bool:
	return has_element_name(name)

## Get the list of registered item names.
func get_item_name_list() -> Array[StringName]:
	return get_element_name_list()
