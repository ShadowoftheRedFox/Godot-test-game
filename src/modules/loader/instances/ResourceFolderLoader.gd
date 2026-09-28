## Load a folder of the given resource.
## Will return the array of resource loaded.
class_name ResourceFolderLoader extends ThreadLoader

## The path of the folder where to load the resource
var _folder_path: String = ""
## The type it to give to the resource loader.
var _type_hint: String = ""
## The pattern that the full file path to load must match.
var _file_path_pattern: FolderReader.FilePattern = null
## Whether to check the inner folders or not.
var _check_inner_folders: bool = false

var _get_amount_loaded: int = 0
var _get_amount_loaded_mutex: Mutex = Mutex.new()

var _get_amount_to_load: int = 1
var _get_amount_to_load_mutex: Mutex = Mutex.new()

## Create a new ResourceFolderLoader.
## folder_path: The absolute path to the folder to load.
## type_hint: The name of the resource class for the ResourceLoader. Can be empty.
func _init(folder_path: String, file_path_pattern: FolderReader.FilePattern = null, check_inner_folders: bool = false, type_hint: String = "") -> void:
	assert(folder_path != null, ErrorList.ERR_V_IS_NULL % "folder_path")
	assert(type_hint != null, ErrorList.ERR_V_IS_NULL % "type_hint")
	assert(DirAccess.dir_exists_absolute(folder_path), ErrorList.ERR_V_MUST_BE_FOLDER_PATH % "folder_path")

	_folder_path = folder_path
	_file_path_pattern = file_path_pattern
	_check_inner_folders = check_inner_folders

	if Utils.is_blank(type_hint):
		type_hint = ""
	_type_hint = type_hint

	# no lock because it runs before the thread
	_get_amount_loaded = 0
	_get_amount_to_load = 1

	set_callable(_load_folder)

func get_amount_loaded() -> int:
	var v: int = 0
	_get_amount_loaded_mutex.lock()
	v = _get_amount_loaded
	_get_amount_loaded_mutex.unlock()
	return v if _thread != null && _thread.is_started() && !_thread.is_alive() else 0

func get_amount_to_load() -> int:
	var v: int = 0
	_get_amount_to_load_mutex.lock()
	v = _get_amount_to_load
	_get_amount_to_load_mutex.unlock()
	return v

## The thread function.
func _load_folder() -> Array[Resource]:
	var result: Array[Resource] = []

	var list: PackedStringArray = FolderReader.get_directory_file_list(_folder_path, _file_path_pattern, _check_inner_folders)
	# upate the amount to load by the amount of items found (+1 because this search action count as 1)
	_get_amount_to_load_mutex.lock()
	_get_amount_to_load = list.size() + 1
	_get_amount_to_load_mutex.unlock()
	# update the amount loaded to 1 (the search action is done)
	_get_amount_loaded_mutex.lock()
	_get_amount_loaded = 1
	_get_amount_loaded_mutex.unlock()

	for p: String in list:
		var r: Resource = ResourceLoader.load(p, _type_hint)
		if r == null:
			_thread_error = "Failed to load " + p
			return []

		result.append(r)
		_get_amount_loaded_mutex.lock()
		_get_amount_loaded += 1
		_get_amount_loaded_mutex.unlock()

	return result
