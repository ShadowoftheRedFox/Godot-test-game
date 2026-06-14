## Only contains constant to fetch
class_name ConstantManager

func _init() -> void:
	# load all items name from folder
	var dir: DirAccess = DirAccess.open(ITEM_FOLDER)
	if dir == null:
		printerr("An error occurred when trying to access the item folder.")
		return

	for file_name: String in dir.get_files():
		print(file_name)
		var parts: PackedStringArray = file_name.split(".", false, 1)
		if !parts[0].begins_with("Item") || len(parts) < 2 || parts[1] != "tres":
			printerr("File " + file_name + " does not have the correct item name format")
			continue

		ITEM_NAMES.push_back(StringName(parts[0]))

## Number of chars max that can be displayed on the console.
const CONSOLE_MAX_LENGTH: int = 10000

## Contains all item names in the game.
var ITEM_NAMES: Array[StringName] = []

## Folder containing all the item resources.
const ITEM_FOLDER: String = "res://src/modules/inventory/item/item_resource/"

# The length of the day.
const DAY_LENGTH: int = 2400
