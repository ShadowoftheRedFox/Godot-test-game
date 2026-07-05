## Handle file IO for saves and loads
class_name SaveModule

## Folder where to save system data, not related to a player or a saved world.
const SYSTEM_SAVE_PATH: String = "user://system/"
## Folder where to save player data related, such as world save.
const USER_SAVE_PATH: String = "user://save/"

## Path to where is saved the parameters file.
const PARAMETERS_SAVE_PATH: String = SYSTEM_SAVE_PATH + "parameters"

## Load saved parameters
func load_parameters() -> void:
	# if no save file, abort loading
	if not FileAccess.file_exists(PARAMETERS_SAVE_PATH):
		return

	# load the file
	var config: ConfigFile = ConfigFile.new()
	if config.load(PARAMETERS_SAVE_PATH) != Error.OK:
		printerr("Couldn't load parameters")
		return

	# TODO

## Save the paramters of the game
func save_parameters() -> void:
	pass

## Save the current game in the given file name
## Returns true if the save was successfull
func save_game(save_file_name: String) -> bool:
	# fail if save file is empty
	if Utils._is_blank(save_file_name):
		return false

	# From the godot documentation
	# all nodes in the group "Persist" willl have a save_state function to call to save their state
	var save_nodes: Array[Node] = Global.get_tree().get_nodes_in_group("Persist")
	var save_file: FileAccess = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	for node: Node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data: String = node.call_deferred("save")

		# JSON provides a static method to serialized JSON string.
		var json_string: String = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

	return true

## Load the given file name and restore the state
## Returns true if the save was successfull
func load_game(save_file_name: String) -> bool:
	# TODO test if it works, and probably improve it
	# fail if save file is empty
	if Utils._is_blank(save_file_name):
		return false

	# TODO normalize save name? as file name are numbers and the actual save name is stored inside?
	if not FileAccess.file_exists(USER_SAVE_PATH + save_file_name + ".save"):
		return false # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes: Array[Node] = Global.get_tree().get_nodes_in_group("Persist")
	for i: Node in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file: FileAccess = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string: String = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json: JSON = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		if json.parse(json_string) == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data: Dictionary[String, String] = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object: Node = (load(node_data["filename"]) as PackedScene).instantiate()
		Global.get_node(node_data["parent"]).add_child(new_object)
		@warning_ignore("unsafe_property_access")
		new_object.position = Vector2(int(node_data["pos_x"]), int(node_data["pos_y"]))

		# Now we set the remaining variables.
		for i: String in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue

	return true
