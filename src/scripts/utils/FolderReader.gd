## Utilities around a folder.
class_name FolderReader extends RefCounted

## Check if a file_name match a pattern, that can include a prefix, suffis or a regexp.
class FilePattern:
	## Prefix to match in the file name.
	var _prefix: String = ""
	## Suffix to match in the file name.
	var _suffix: String = ""
	## Regexp to match the file_name, can be null if no pattern.
	var _pattern: RegEx = null

	func _init(prefix: String = "", suffix: String = "", pattern: RegEx = null) -> void:
		_prefix = prefix
		_suffix = suffix
		_pattern = pattern

	func match(file_name: String) -> bool:
		var _match: bool = file_name.begins_with(_prefix) && file_name.ends_with(_suffix)

		if _pattern != null:
			_match = _match && _pattern.search(file_name) != null

		return _match

var _recursive: bool = false

## Read each file of a directory and call the file_check callable, with two
## arguments: the path of the containing folder, and the file name.
static func scan_directory(folder_path: String, file_check: Callable, recursive: bool = false) -> void:
	var reader: FolderReader = FolderReader.new()
	reader._recursive = recursive
	reader._scan_directory(folder_path, file_check)

## Read the files in the given directory, and return the list of file absolute path matching the pattern.
## The pattern will be applied on the full path pattern.
## Recursive will make the discovery search inner directories.
static func get_directory_file_list(folder_path: String, file_path_pattern: FilePattern = null, recursive: bool = false) -> PackedStringArray:
	var reader: FolderReader = FolderReader.new()
	var result: PackedStringArray = []
	reader._recursive = recursive
	reader._scan_directory(folder_path, reader._get_directory_file_list_checker.bind(result, file_path_pattern))
	return result

## Inner function of get_directory_file_list.
func _get_directory_file_list_checker(folder_path: String, file_name: String, list: PackedStringArray, file_path_pattern: FilePattern) -> void:
	var file: String = folder_path + file_name
	if file_path_pattern == null || file_path_pattern.match(file):
		list.append(file)

## Read the files in the given directory, and return the list of file absolute path matching the pattern, with the folder and the file name separated.
## The file pattern will be applied on the file name, and the path pattern on the folder path.
## Recursive will make the discovery search inner directories.
## The result is a dictionnary such as `{folders: PackedStringArray, files: PackedStringArray}`, with both array of the same size.
static func get_directory_file_list_separated(folder_path: String, file_pattern: FilePattern = null, path_pattern: FilePattern = null, recursive: bool = false) -> Dictionary:
	var reader: FolderReader = FolderReader.new()
	var result: Dictionary = {}
	result.set("folders", PackedStringArray())
	result.set("files", PackedStringArray())
	reader._recursive = recursive
	reader._scan_directory(folder_path, reader._get_directory_file_list_spearated_checker.bind(result, file_pattern, path_pattern))
	return result

## Inner function of get_directory_file_list_separated.
func _get_directory_file_list_spearated_checker(folder_path: String, file_name: String, result: Dictionary, file_pattern: FilePattern, path_pattern: FilePattern) -> void:
	var file: String = folder_path + file_name
	if (file_pattern == null || file_pattern.match(file)) && (path_pattern == null || path_pattern.match(folder_path)):
		@warning_ignore_start("unsafe_cast")
		(result.get("folders") as PackedStringArray).append(folder_path)
		(result.get("files") as PackedStringArray).append(file_name)
		@warning_ignore_restore("unsafe_cast")


## Inner function of scan_directory.
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
		# special name files
		if file_name == "." or file_name == "..":
			continue
		# get the current full path to the file
		var full_path: String = path.path_join(file_name)
		# call the file check
		if !dir.current_is_dir():
			file_check.call(path, file_name)
		# if it's a folder, look deeper
		elif _recursive:
			_scan_directory(full_path, file_check)
	# close the folder stream
	dir.list_dir_end()
