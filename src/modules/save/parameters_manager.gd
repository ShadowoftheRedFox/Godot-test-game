class_name ParametersManager

## Path to where is saved the parameters file.
const PARAMETERS_SAVE_PATH: String = SaveModule.SYSTEM_SAVE_PATH + "parameters.cfg"

func _init() -> void:
	load_parameters()

## Load saved parameters
func load_parameters() -> void:
	# if no save file, abort loading
	if not FileAccess.file_exists(PARAMETERS_SAVE_PATH):
		return

	# load the file
	var config: ConfigFile = ConfigFile.new()
	var result: int = config.load(PARAMETERS_SAVE_PATH)
	if result != Error.OK:
		printerr("Couldn't load parameters: " + error_string(result))
		return

	# TODO

## Save the paramters of the game
func save_parameters() -> void:
	pass
