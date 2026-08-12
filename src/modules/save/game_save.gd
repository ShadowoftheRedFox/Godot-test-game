## Object referening to a saved game data.
class_name GameSave

# NOTE: This file does not follow the code_layout.gd documentation
# Each section is divided by a constant prefixed by SECTION_, between the SAVE
# STRUCTURE.
#
# The variables under those constants will be saved/loaded under the same
# section in the ConfigFile.

## File name where the worlds data are saved.
const WORLD_FILE: String = "world.sav"
## File name for the config file where this data will be saved into.
const SAVE_FILE: String = "save.cfg"

## Path to the save folder. Can be empty if not saved yet.
var folder_path: String = ""

### BEGIN SAVE STRUCTURE ###

const SECTION_MAIN: String = "Main"
## Name of this save file.
var name: String = ""
## Timestamp when this save has been created.
## Should never be edited outside of the class file.
var created_date: float = 0.0
## Timestamp when the save has been last played.
## Should never be edited outside of the class file.
var last_played: float = 0.0
## The seed for the random generation
var world_seed: String = ""

### END SAVE STRUCTURE ###

## Parse a save file to get the GameSave object saved within.
static func parseConfig(path: String) -> GameSave:
	var local: GameSave = GameSave.new()
	# make sure there is a / at the end of the path
	local.folder_path = path.trim_suffix("/") + "/"
	var file_path: String = local.folder_path + SAVE_FILE

	var config: ConfigFile = ConfigFile.new()
	var result: int = config.load(file_path)
	if result != Error.OK:
		printerr("Failed to load " + file_path + ": " + error_string(result))
		return

	if !local._valid_config(config):
		printerr("The save file " + file_path + " is not correct")
		return

	# load datas
	local.name = config.get_value(SECTION_MAIN, "name")
	local.created_date = config.get_value(SECTION_MAIN, "created_date", Time.get_unix_time_from_system())
	local.last_played = config.get_value(SECTION_MAIN, "last_played", Time.get_unix_time_from_system())
	local.world_seed = config.get_value(SECTION_MAIN, "world_seed", Time.get_unix_time_from_system())

	return local

## Save the current data. Return true on success.
func save() -> bool:
	# set the created time if it isn't done
	if created_date == 0.0:
		created_date = Time.get_unix_time_from_system()

	# save data to the cnfig
	var config: ConfigFile = ConfigFile.new()
	config.set_value(SECTION_MAIN, "name", name)
	config.set_value(SECTION_MAIN, "created_date", created_date)
	config.set_value(SECTION_MAIN, "last_played", last_played)
	config.set_value(SECTION_MAIN, "world_seed", world_seed)

	# TODO world save

	# path is empty, so create a new path
	if folder_path.length() == 0:
		folder_path = SaveModule.SYSTEM_SAVE_PATH + "/" + str(int(Time.get_unix_time_from_system())) + "/"
		# create the folder if is not created
		if !DirAccess.dir_exists_absolute(folder_path):
			DirAccess.make_dir_recursive_absolute(folder_path)

	var result: int = config.save(folder_path + SAVE_FILE)
	if result != Error.OK:
		printerr("Couldn't save to path \"" + folder_path + SAVE_FILE + "\": " + error_string(result))
	return result == Error.OK

## Load the current save to be played.
func load() -> void:
	# set the load time of the save to now
	last_played = Time.get_unix_time_from_system()

	# load the world seed in the random generator
	seed(world_seed.hash())

	Global.MAIN.load_scene(MainGame.TEST_SCENE_UID)
	Global.MAIN.remove_menu(MainGame.MAIN_MENU_SCENE_UID, MainGame.MenuLayer.HUD)

## check if the current save has the minimal informations required.
func _valid_config(config: ConfigFile) -> bool:
	# must have a main section
	if !config.has_section(SECTION_MAIN):
		return false
	# must have name
	if config.get_value(SECTION_MAIN, "name") == null:
		return false

	return true
