## Only contains constant to fetch
class_name ConstantManager

## The game name.
const GAME_NAME: StringName = "WTFisTHIS"

## Contains all item names in the game.
var ITEM_NAMES: PackedStringArray = []
## Contains all building names in the game.
var BUILDING_NAMES: PackedStringArray = []

## Folder containing all the item resources.
const ITEM_FOLDER: String = "res://src/modules/inventory/item/item_resource/"
const BUILDING_FOLDER: String = "res://src/modules/building/build_resource/"

func _init() -> void:
    _load_resources()

func _load_resources() -> void:
    var pattern: FolderReader.FilePattern = FolderReader.FilePattern.new()
    pattern.suffix = ".tres"
    pattern.prefix = "Item"

    # load all items name from folder
    FolderReader.scan_directory(ITEM_FOLDER, _scan_item_file)
    print("Checked " + str(ITEM_NAMES.size()) + " items")
    # load all building name from folder
    FolderReader.scan_directory(BUILDING_FOLDER, _scan_building_file)
    print("Checked " + str(BUILDING_NAMES.size()) + " buildings")

func _scan_item_file(path: String, file_name: String) -> void:
    # check the name and type are valid
    var parts: PackedStringArray = file_name.split(".", false, 1)
    assert(
        parts.size() == 2
        && parts[0].begins_with("Item")
        && parts[1] == "tres",
        "File " + file_name + " does not have the correct item name format"
    )
    var item_resource: Resource = load(path + file_name)
    assert(item_resource != null, "couldn't load " + path + file_name)
    assert(
        item_resource is InventoryItem
        && (item_resource as InventoryItem).item_name == parts[0],
        "Item " + (item_resource as InventoryItem).item_name
        +" doesn't match its file name: " + path + file_name
    )

    ITEM_NAMES.push_back((item_resource as InventoryItem).item_name)

func _scan_building_file(path: String, file_name: String) -> void:
    # check the name and type are valid
    var parts: PackedStringArray = file_name.split(".", false, 1)
    assert(
        parts.size() == 2
        && parts[0].begins_with("Building")
        && parts[1] == "tres",
        "File " + file_name + " does not have the correct building name format"
    )
    var building_resource: Resource = load(path + file_name)
    assert(building_resource != null, "couldn't load " + path + file_name)
    assert(
        building_resource is Building
        && (building_resource as Building).building_name == parts[0],
        "Building " + (building_resource as Building).building_name
        +" doesn't match its file name: " + path + file_name
    )

    BUILDING_NAMES.push_back((building_resource as Building).building_name)
