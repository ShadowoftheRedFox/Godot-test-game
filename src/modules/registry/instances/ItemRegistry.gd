## The main item. Holds the main game items, but also the entry point for mod items.
class_name ItemRegistry extends AbstractRegistry

var _items: Dictionary[StringName, InventoryItem] = {}

#TODO mod compatible with prefixes

## The constant name of this registry.
const NAME: StringName = "ItemRegistry"

func get_name() -> StringName:
    return NAME

func _freeze() -> void:
    _items.make_read_only()

func add_object(obj: Object) -> bool:
    if obj == null || obj is not InventoryItem:
        return false
    return add_item(obj as InventoryItem)

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

## Transform the name before using it to store of fetch something.
func _trasnform_item_name(item_name: StringName) -> StringName:
    return item_name

## Add a item in the registered item list.
## Return true on success, false otherwise.
func add_item(item: InventoryItem) -> bool:
    return _items.set(_trasnform_item_name(item.item_name), item)

## Remove an item from the item list.
## Return true on success, false otherwise.
func remove_item(item: InventoryItem) -> bool:
    if item == null || !has_item(item):
        return true
    return remove_item_name(item.item_name)

## Remove an item from the item list by its name.
## Return true on success, false otherwise.
func remove_item_name(name: StringName) -> bool:
    if name == null || !has_item_name(name):
        return true
    return _items.erase(_trasnform_item_name(name))

## Get the registred item matching the name.
## Return the item if it is registred, null otherwise.
func get_item(name: StringName) -> InventoryItem:
    return _items.get(_trasnform_item_name(name))

## Check if the item is registered.
## Return true if it registered, false otherwise.
func has_item(item: InventoryItem) -> bool:
    return has_item_name(item.item_name)

## Check if the item name is registered.
## Return true if it registered, false otherwise.
func has_item_name(name: StringName) -> bool:
    return _items.has(_trasnform_item_name(name))
