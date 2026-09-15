## The main item. Holds other item
class_name ItemRegistry extends Registry

## Internal dictionary holding the registered items.
var _items: Dictionary[StringName, InventoryItem] = {}

func _init() -> void:
    # TODO load items
    pass

func get_name() -> StringName:
    return "ItemRegistry"

func add_object(obj: Object) -> bool:
    if obj == null || obj is not InventoryItem:
        return false
    return add_item(obj as InventoryItem)

func get_object(id: Variant) -> Object:
    @warning_ignore("unsafe_call_argument")
    return get_item(type_convert(id, TYPE_STRING_NAME))

func has_object(id: Variant) -> bool:
    @warning_ignore("unsafe_call_argument")
    return has_item_name(type_convert(id, TYPE_STRING_NAME))

func remove_object(id: Variant) -> bool:
    @warning_ignore("unsafe_call_argument")
    return remove_item_name(type_convert(id, TYPE_STRING_NAME))

func size() -> int:
    return _items.size()

## Add a item in the registered item list.
## Return true on success, false otherwise.
func add_item(item: InventoryItem) -> bool:
    if item == null || has_item(item):
        return false
    return _items.set(item.item_name, item)

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
    return _items.erase(name)

## Get the registred item matching the name.
## Return the item if it is registred, null otherwise.
func get_item(name: StringName) -> InventoryItem:
    return _items.get(name)

## Check if the item is registered.
## Return true if it registered, false otherwise.
func has_item(item: InventoryItem) -> bool:
    return has_item_name(item.item_name)

## Check if the item name is registered.
## Return true if it registered, false otherwise.
func has_item_name(name: StringName) -> bool:
    return _items.has(name)
