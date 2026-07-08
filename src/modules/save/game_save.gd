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

## Path to this saved file. Can be empty if not saved yet.
## Not saved inside the
var file_path: String = ""

### BEGIN SAVE STRUCTURE ###

const SECTION_MAIN: String = "Main"
## Name of this save file.
var name: String = ""
## Timestamp when this save has been created.
var created_date: float = 0.0
## Timestamp when the save has been last played.
var last_played: float = 0.0

### END SAVE STRUCTURE ###

## Parse a save file to get the GameSave object saved within.
static func parseConfig(path: String) -> GameSave:
	var local: GameSave = GameSave.new()
	local.file_path = path + "/" + SAVE_FILE

	var config: ConfigFile = ConfigFile.new()
	var result: int = config.load(local.file_path)
	if result != Error.OK:
		printerr("Failed to load " + local.file_path + ": " + error_string(result))
		return

	if !local._valid_config(config):
		printerr("The save file " + local.file_path + " is not correct")
		return

	# load datas
	local.name = config.get_value(SECTION_MAIN, "name")
	local.created_date = config.get_value(SECTION_MAIN, "created_date", Time.get_unix_time_from_system())
	local.last_played = config.get_value(SECTION_MAIN, "last_played", Time.get_unix_time_from_system())

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

	# TODO world save

	# save the config
	var path: String = file_path
	# path is empty, so create a new path
	if path.length() == 0:
		path = SaveModule.SYSTEM_SAVE_PATH + "/" + str(int(Time.get_unix_time_from_system())) + "/" + SAVE_FILE
		file_path = path

	var result: int = config.save(path)
	if result != Error.OK:
		printerr("Couldn't save to path \"" + path + "\": " + error_string(result))
	return result == Error.OK

## Load the current save to be played.
func load() -> void:
	# set the load time of the save to now
	last_played = Time.get_unix_time_from_system()

## check if the current save has the minimal informations required.
func _valid_config(config: ConfigFile) -> bool:
	# must have a main section
	if !config.has_section(SECTION_MAIN):
		return false
	# must have name
	if config.get_value(SECTION_MAIN, "name") == null:
		return false

	return true
