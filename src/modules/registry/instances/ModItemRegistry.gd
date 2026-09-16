## Registry to load items for a specific mod.
class_name ModItemRegistry extends LoadingRegistry

var _name: StringName = ""
var _mod_name: StringName = ""
var _folder: StringName = ""

func _init(mod_name: StringName, registry_name: StringName, folder: StringName) -> void:
    assert(!Utils.is_blank(mod_name), "Mod name cannot be blank")
    assert(!Utils.is_blank(registry_name), "Registry name cannot be blank")
    assert(!Utils.is_blank(folder), "Folder cannot be blank")
    _name = mod_name + ":" + registry_name
    _mod_name = mod_name
    _folder = folder

func get_name() -> StringName:
    return _name

func get_progress() -> float:
    return 0.0

func get_amount_to_load() -> int:
    return 0

func get_amount_loaded() -> int:
    return 0

func load() -> void:
    # TODO read the folder and start loading items
    pass

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
    return Global.REGISTRIES.get_registry(ItemRegistry.NAME).size()

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
    return _items.erase(_trim_prefix(_mod_name, name))

## Get the registred item matching the name.
## Return the item if it is registred, null otherwise.
func get_item(name: StringName) -> InventoryItem:
    return _items.get(_trim_prefix(_mod_name, name))

## Check if the item is registered.
## Return true if it registered, false otherwise.
func has_item(item: InventoryItem) -> bool:
    return has_item_name(item.item_name)

## Check if the item name is registered.
## Return true if it registered, false otherwise.
func has_item_name(name: StringName) -> bool:
    return _items.has(_trim_prefix(_mod_name, name))
