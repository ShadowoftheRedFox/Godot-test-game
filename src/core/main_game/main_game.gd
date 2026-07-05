class_name MainGame extends Node

# Main menu and test level references
const PLAYER_SCENE_UID:		String = "uid://26srdfxbxw6k"
const TEST_SCENE_UID:		String = "uid://b8brfdyr57ked"
const MAIN_MENU_SCENE_UID: 	String = "uid://de2bged6t63hi"

const DEBUG_OVERLAY_UID: 		String = "uid://gwa7n875db7o"
const DEBUG_OVERLAY_CHILD_NAME: String = "DEBUG_OVERLAY"

var player: Player = null
var _current_scene: BaseScene = null

# world root nodes
@onready var level_root: Node3D = %LevelRoot
@onready var entity_root: Node3D = %EntityRoot

# UI root nodes
@onready var hud_root: Control = %HudRoot
@onready var pause_root: Control = %PauseRoot
@onready var transition_root: Control = %TransitionRoot
@onready var debug_root: Control = %DebugRoot

func _ready() -> void:
	_init_player()
	load_scene(TEST_SCENE_UID)
	_init_systems()

## Instantiate a new player in the entity root
func _init_player() -> void:
	var player_scene: PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_UID)
		return
	
	player = player_scene.instantiate() as Player
	if player == null:
		push_error("Loaded player scene does not extend player or DNE: " + PLAYER_SCENE_UID)
	
	entity_root.add_child(player)

## Called for loading a scene
## NOTE: the scene must extends BaseScene
func load_scene(scene_uid: String) -> void:
	# call when idle
	_deferred_load_scene.call_deferred(scene_uid)

## Set on or off the debug overlay
func set_debug_overlay(toggle: bool = true) -> void:
	# get the child node from its unique name
	var overlay_child: Node2D = debug_root.get_node("./" + DEBUG_OVERLAY_CHILD_NAME) as Node2D
	# if we want to hide it, and the child exists, remove it
	if toggle == false:
		if overlay_child != null:
			overlay_child.queue_free()
		return
	
	# we want to show it, but the child already exists, so skip
	if overlay_child != null:
		return
	
	# instantiate a new overlay
	var new_scene_packed : PackedScene =\
	ResourceLoader.load(DEBUG_OVERLAY_UID, "PackedScene") as PackedScene
	if new_scene_packed == null:
		push_error("Could not load debug overlay as a packed scene: " + DEBUG_OVERLAY_UID)
		return

	overlay_child = new_scene_packed.instantiate() as Node2D
	if overlay_child == null:
		push_error("Loaded debug overlay is not of type Node2D or does not exist")
		return

	debug_root.add_child(overlay_child)

# Handles internal change and loading of new scene
func _deferred_load_scene(scene_uid: String) -> void:
	if _current_scene != null:
		_current_scene.queue_free()
		_current_scene = null
	
	# wait for the tree to finish updating
	await get_tree().process_frame

	var new_scene_packed : PackedScene =\
		ResourceLoader.load(scene_uid, "PackedScene") as PackedScene
	if new_scene_packed == null:
		push_error("Could not load scene as a packed scene: " + scene_uid)
		return

	_current_scene = new_scene_packed.instantiate() as BaseScene
	if _current_scene == null:
		push_error("Loaded scene is not of type BaseScene or does not exist")
		return

	level_root.add_child(_current_scene)

	# Allow level to fully process before accessing it
	await get_tree().process_frame
	_place_player_at_level_spawn()

# Finds the default spawn location in currently loaded scene, and places
# the Player at that position.
func _place_player_at_level_spawn() -> void:
	if player == null:
		push_error("Cannot place player in level because it is null")
		return
	if _current_scene == null:
		push_error("Cannot place player into scene because scene is null")
		return

	player.global_position = _current_scene.get_default_player_spawn()

func _init_systems() -> void:
	# TODO (systems): Will be called to set up high level systems
	pass 
