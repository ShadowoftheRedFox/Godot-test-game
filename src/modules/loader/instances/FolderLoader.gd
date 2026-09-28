## Load a folder and call a filereader on each found instances.
## Will not return anything.
class_name FolderLoader extends ThreadLoader

## The path of the folder where to load the resource
var _folder_path: String = ""
## The type it to give to the resource loader.
var _type_hint: String = ""
## The pattern that the file name to load must match.
var _file_pattern: FolderReader.FilePattern = null
## Whether to check the inner folders or not.
var _check_inner_folders: bool = false
## The callable that will be called when we found a valid file.
var _file_reader: Callable

var _get_amount_loaded: int = 0
var _get_amount_loaded_mutex: Mutex = Mutex.new()

var _get_amount_to_load: int = 1
var _get_amount_to_load_mutex: Mutex = Mutex.new()

## Create a new ResourceFolderLoader.
## folder_path: The absolute path to the folder to load.
## type_hint: The name of the resource class for the ResourceLoader. Can be empty.
func _init(folder_path: String, file_reader: Callable, file_pattern: FolderReader.FilePattern = null, check_inner_folders: bool = false, type_hint: String = "") -> void:
	assert(folder_path != null, ErrorList.ERR_V_IS_NULL % "folder_path")
	assert(!file_reader.is_null(), ErrorList.ERR_V_IS_NULL % "filre_reader")
	assert(type_hint != null, ErrorList.ERR_V_IS_NULL % "type_hint")
	assert(DirAccess.dir_exists_absolute(folder_path), ErrorList.ERR_V_MUST_BE_FOLDER_PATH % "folder_path")

	_folder_path = folder_path
	_file_reader = file_reader
	_file_pattern = file_pattern
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
func _load_folder() -> void:
	var result: Dictionary = FolderReader.get_directory_file_list_separated(_folder_path, _file_pattern, null, _check_inner_folders)
	var files: PackedStringArray = result.get("files")
	var paths: PackedStringArray = result.get("folders")

	# upate the amount to load by the amount of items found (+1 because this search action count as 1)
	_get_amount_to_load_mutex.lock()
	_get_amount_to_load = files.size() + 1
	_get_amount_to_load_mutex.unlock()
	# update the amount loaded to 1 (the search action is done)
	_get_amount_loaded_mutex.lock()
	_get_amount_loaded = 1
	_get_amount_loaded_mutex.unlock()

	for i: int in range(files.size()):
		_file_reader.call_deferred(paths[i], files[i])

		_get_amount_loaded_mutex.lock()
		_get_amount_loaded += 1
		_get_amount_loaded_mutex.unlock()

	return
