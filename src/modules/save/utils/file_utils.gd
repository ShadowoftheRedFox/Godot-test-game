## Usefull manager to manage a folder.
class_name FileUtils

## The base folder path under where to look for files.
var base_path: String = "user://"
## The encryption provided at the initialisation. Must be 32 bytes long.
var encryption_key: PackedByteArray = PackedByteArray()
## Whether or not to write/read file as encrypted.
var encrypted: bool = false

## Create a new file utils.
## The base_path is the root folder this class will check into.
## If make_dir is true, it will create the base_path directory. Otherwise, it must already exists.
## If key is provided and is 32 bytes long, any file read or cerate will be handled as encrypted.
func _init(_base_path: String = "user://", _make_dir: bool = false, _key: PackedByteArray = PackedByteArray()) -> void:
	base_path = _base_path
	# make sure the end path ends with a /
	if !base_path.ends_with("/"):
		base_path += "/"

	# check if the dir exsist
	if !_make_dir:
		assert(DirAccess.dir_exists_absolute(base_path), "The folder " + base_path + " doesn't exists")
	else:
		assert(_make_directory(""), "Could not make directory " + base_path)

	# if the encryption is the correct size, set as encrypted
	if _key.size() == 32:
		encrypted = true
		encryption_key = _key

## Check if the given file exixts.
## If the path begins with a /, removes it.
## Otherwise, returns if the file exists.
func exists(file_path: String) -> bool:
	return FileAccess.file_exists(base_path + _check_path(file_path))

## Read the file and return its content as string.
## If file does not exists, or an error occured, return an empty string.
func read(file_path: String) -> String:
	file_path = _check_path(file_path)
	if !exists(file_path):
		printerr(file_path + " doesn't exists")
		return ""

	var file: FileAccess = _open(file_path, FileAccess.READ)
	if file == null:
		printerr(file_path + ": error while trying to open")
		return ""
	return file.get_as_text()

## Create the file from the path, and write the given content inside.
## If the file already exists, abort.
## Returns true if the file has been created and written successfully.
func create(file_path: String, content: String) -> bool:
	file_path = _check_path(file_path)
	if exists(file_path):
		return false

	# TEST since FileAccess.READ_WRITE doesn't say the directory needs to exists
	# if !_make_directory(file_path):
	# 	return false

	var file: FileAccess = _open(file_path, FileAccess.READ_WRITE)
	if file == null:
		return false
	var result: bool = file.store_string(content)
	file.close()
	return result

## Append content given to the already existing file at the given path.
## The content is added as-is to the end of the file. If it needs a \n at the start, you should add it yourself.
## If the file doesn't exists, abort.
## Returns true if the file has been edited and written successfully.
func append(file_path: String, content: String) -> bool:
	file_path = _check_path(file_path)
	if !exists(file_path):
		return false

	var file: FileAccess = _open(file_path, FileAccess.ModeFlags.READ_WRITE)
	if file == null:
		return false

	# move to the end of the file
	file.seek_end()
	## append content
	var result: bool = file.store_string(content)
	file.close()
	return result

## Overwrite the content of the given file, and replace it with the given content.
## If the file doesn't exists, abort.
## Returns true if the file has been edited and written successfully.
func overwrite(file_path: String, content: String) -> bool:
	file_path = _check_path(file_path)
	if !exists(file_path):
		return false

	var file: FileAccess = _open(file_path, FileAccess.ModeFlags.WRITE)
	if file == null:
		return false

	var result: bool = file.store_string(content)
	file.close()
	return result

## Delete the given file.
## Returns true if the file hs been deleted successfully.
## Also returns true if the file doesn't already exists.
func delete(file_path: String) -> bool:
	file_path = _check_path(file_path)
	if !exists(file_path):
		return true

	# open the dire to the file
	var dir: DirAccess = DirAccess.open(base_path)
	if dir == null:
		printerr("error \"" + error_string(DirAccess.get_open_error()) + "\" while trying to delete file " + base_path + file_path)
		return false

	var result: int = dir.remove(file_path)
	if result != Error.OK:
		printerr("error \"" + error_string(result) + "\" while deleting file " + base_path + file_path)
	return result == Error.OK

## Check if the path to the file is structurally correct.
func _check_path(file_path: String) -> String:
	assert(!file_path.ends_with("/"), "The path given (" + file_path + ") is for a folder, not a file.")
	# remove the / if it begins with it
	if file_path.begins_with("/"):
		file_path = file_path.substr(1)
	return file_path

## Open the given file with the given flags.
## Manages opening whether it should be encrypted of not.
## Return the FileAccess to it.
## Returns null if there is an error.
func _open(file_path: String, flags: int) -> FileAccess:
	file_path = _check_path(file_path)

	var file: FileAccess
	if encrypted:
		file = FileAccess.open_encrypted(base_path + file_path, flags, encryption_key)
	else:
		file = FileAccess.open(base_path + file_path, flags)

	if file == null:
		printerr("error \"" + error_string(FileAccess.get_open_error()) + "\" while opening the file " + base_path + file_path)

	return file

## Create the directory to the file. Retturn true on success.
func _make_directory(file_path: String) -> bool:
	file_path = _check_path(file_path)
	var result: int = DirAccess.open(base_path).make_dir_recursive(file_path)
	if result != Error.OK:
		printerr("error \"" + error_string(result) + "\" while creating the directory to " + base_path + file_path)
	return result == Error.OK
