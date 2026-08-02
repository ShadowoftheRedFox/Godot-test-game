## Handle file IO for saves and loads
class_name SaveModule

## Folder where to save system data, not related to a player or a saved world.
const SYSTEM_SAVE_PATH: String = "user://system/"
## Folder where to save player data related, such as world save.
const USER_SAVE_PATH: String = "user://save/"

## Manager for the parameters of the game.
var parameters: ParametersManager = ParametersManager.new()

## List of found saves.
var saves: Array[GameSave] = []
## The last game played. Null if none.
var last_played: GameSave = null
## The currently loaded save.
var current_save: GameSave = null

func _init() -> void:
	find_saves()

## Find any save files to display in the load menu.
func find_saves() -> void:
	# each save is under a folder with a unique random name
	# under the SYSTEM_SAVE_PATH
	#
	# check if this folder exists, otherwise create it
	if !DirAccess.dir_exists_absolute(SYSTEM_SAVE_PATH):
		var result: int = DirAccess.make_dir_recursive_absolute(SYSTEM_SAVE_PATH)
		if result != Error.OK:
			printerr("Could not create the save system folder: " + error_string(result))
		return

	# if the dir exists, read all folder in it
	var dir: DirAccess = DirAccess.open(SYSTEM_SAVE_PATH)
	if dir == null:
		printerr("Error opening " + SYSTEM_SAVE_PATH + ": " + error_string((DirAccess.get_open_error())))
		return
	var dirs: PackedStringArray = dir.get_directories()
	# no sub folder, so end here
	if dirs.size() == 0:
		return

	# read all folder for a file called GameSave.SAVE_FILE
	for dir_name: String in dir:
		# abnormal file, skip
		if !dir_name.begins_with('save'):
			continue
		var subdir: DirAccess = DirAccess.open(SYSTEM_SAVE_PATH + dir_name)
		if subdir == null:
			## failed to open, skip
			printerr("Error opening " + SYSTEM_SAVE_PATH + dir_name + ": " + error_string((DirAccess.get_open_error())))
			continue
		if subdir.get_files().has(GameSave.SAVE_FILE):
			saves.push_back(GameSave.parseConfig(SYSTEM_SAVE_PATH + dir_name))

	# once all saves has been found, get the most recently played as the last played

	# no saves found, no last played
	if saves.size() == 0:
		return
	last_played = saves[0]
	# only one found, the currently set, so return
	if saves.size() == 1:
		return
	# more than one, get the most recently played
	for save: GameSave in saves:
		if last_played.last_played < save.last_played:
			last_played = save

## Create a new save.
## Return true if the save has been created.
func create_save(save: GameSave) -> bool:
	return save.save()

## Save the current game in the given file name
## Returns true if the save was successfull
func save_game(save_name: String) -> bool:
	# fail if save name is empty
	if save_name.length() == 0:
		return false

	# get the save if it exists, or create it
	var save: GameSave = _get_save(save_name)
	if save == null:
		save = GameSave.new()

	return save.save()

## Load the given file name and restore the state.
## Returns true if the loading was successfull.
func load_game(save_name: String) -> bool:
	var save: GameSave = _get_save(save_name)
	if save == null:
		return false

	save.load()

	return true

## Get the save by its name.
func _get_save(save_name: String) -> GameSave:
	if save_name.length() == 0:
		return null

	for save: GameSave in saves:
		if save_name == save_name:
			return save

	return null

func save_parameters() -> void:
	pass
