## Only contains constant to fetch
class_name ConstantManager

## Contains all item names in the game.
var ITEM_NAMES: PackedStringArray = PackedStringArray()
## Contains all building names in the game.
var BUILDING_NAMES: PackedStringArray = PackedStringArray()

## Folder containing all the item resources.
const ITEM_FOLDER: String = "res://src/modules/inventory/item/item_resource/"
const BUILDING_FOLDER: String = "res://src/modules/building/build_resource/"

func _init() -> void:
	_load_resources()

func _load_resources() -> void:
	# load all items name from folder
	_scan_directory(ITEM_FOLDER, _scan_item_file)
	print("Checked " + str(ITEM_NAMES.size()) + " items")
	# load all building name from folder
	_scan_directory(BUILDING_FOLDER, _scan_building_file)
	print("Checked " + str(BUILDING_NAMES.size()) + " buildings")

func _scan_directory(path: String, file_check: Callable) -> void:
	# opens the folder
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		printerr("An error occurred when trying to access the " + path + " folder.")
		return
	# start reading every file in the folder
	dir.list_dir_begin()
	while true:
		# get the file element name
		var file_name: String = dir.get_next()
		# end of the folder
		if file_name == "":
			break
		# special name files symlink
		if file_name == "." or file_name == "..":
			continue
		# get the current full path to the file
		var full_path: String = path.path_join(file_name)
		# if it's a folder, look deeper
		if dir.current_is_dir():
			_scan_directory(full_path, file_check)
		else:
			# call the file check
			file_check.call(path, file_name)
	# close the folder stream
	dir.list_dir_end()

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
