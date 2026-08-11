class_name MainGame extends Node

enum MenuLayer {
	HUD,
	PAUSE,
	TRANSITION,
	DEBUG,
}

enum WorldLayer {
	LEVEL,
	ENTITY,
}

# Main menu and test level references
const PLAYER_SCENE_UID: String = "uid://26srdfxbxw6k"
const TEST_SCENE_UID: String = "uid://b8brfdyr57ked"
const MAIN_MENU_SCENE_UID: String = "uid://de2bged6t63hi"

const DEBUG_OVERLAY_UID: String = "uid://gwa7n875db7o"

var player: Player = null
var _current_scene: BaseScene = null

@onready var systems_root: Node = %Systems

# world root nodes
@onready var level_root: Node3D = %LevelRoot
@onready var entity_root: Node3D = %EntityRoot

# UI root nodes
@onready var hud_root: Control = %HudRoot
@onready var pause_root: Control = %PauseRoot
@onready var transition_root: Control = %TransitionRoot
@onready var debug_root: Control = %DebugRoot

func _ready() -> void:
	load_menu(MAIN_MENU_SCENE_UID, MenuLayer.HUD)
	_init_systems()


## Called for loading a scene
## NOTE: the scene must extends BaseScene
func load_scene(scene_uid: String) -> void:
	# call when idle
	_deferred_load_scene.call_deferred(scene_uid)

## Remove the current scene
func remove_current_scene() -> void:
	# check if we can remove the scene, and if it's not already queued
	if _current_scene == null || _current_scene.is_queued_for_deletion():
		return

	_current_scene.queue_free()

## Remove the current scene
func remove_menu(menu_uid: String, layer: MenuLayer = MenuLayer.HUD) -> void:
	# get the root for the given layer
	var root: Control = _get_menu_root(layer)
	if root == null:
		return

	var menu: Node = root.get_node_or_null(Utils.get_raw_uid(menu_uid))
	if menu == null || menu.is_queued_for_deletion():
		return

	root.remove_child(menu)
	menu.queue_free()

## Called for loading a menu
## NOTE: the menu must extends Control
func load_menu(menu_uid: String, layer: MenuLayer = MenuLayer.HUD) -> void:
	# call when idle
	_deferred_load_menu.call_deferred(menu_uid, layer)

## Set on or off the debug overlay
func toggle_debug_overlay() -> void:
	# get the child node from its unique name
	var overlay_child: Control = debug_root.get_node("./" + DEBUG_OVERLAY_UID) as Control
	# if we want to hide it, and the child exists, remove it
	if overlay_child != null:
		overlay_child.queue_free()
		return

	# instantiate a new overlay
	var new_scene_packed: PackedScene = \
	ResourceLoader.load(DEBUG_OVERLAY_UID, "PackedScene") as PackedScene
	if new_scene_packed == null:
		push_error("Could not load debug overlay as a packed scene: " + DEBUG_OVERLAY_UID)
		return

	overlay_child = new_scene_packed.instantiate() as Control
	if overlay_child == null:
		push_error("Loaded debug overlay is not of type Control or does not exist")
		return

	overlay_child.name = DEBUG_OVERLAY_UID
	debug_root.add_child(overlay_child)

# Handles internal change and loading of new scene
func _deferred_load_scene(scene_uid: String) -> void:
	if _current_scene != null:
		_current_scene.queue_free()
		_current_scene = null
		# wait for the tree to finish updating
		await get_tree().process_frame

	var new_scene_packed: PackedScene = \
		ResourceLoader.load(scene_uid, "PackedScene") as PackedScene
	if new_scene_packed == null:
		push_error("Could not load scene as a packed scene: " + scene_uid)
		return

	var _new_scene: Node = new_scene_packed.instantiate()
	if _new_scene == null:
		push_error("Loaded scene does not exist")
		return
	if _new_scene is not BaseScene:
		_new_scene.free()
		push_error("Loaded scene is not of type BaseScene")
		return

	_current_scene = _new_scene as BaseScene
	level_root.add_child(_current_scene)
	_place_player_at_level_spawn()

# Handles internal change and loading of new menu
func _deferred_load_menu(menu_uid: String, layer: MenuLayer) -> void:
	var new_menu_packed: PackedScene = \
		ResourceLoader.load(menu_uid, "PackedScene") as PackedScene
	if new_menu_packed == null:
		push_error("Could not load menu as a packed scene: " + menu_uid)
		return

	var _new_menu: Control = new_menu_packed.instantiate()
	if _new_menu == null:
		push_error("Loaded scene does not exist")
		return
	if _new_menu is not Control:
		_new_menu.free()
		push_error("Loaded scene is not of type Control")
		return

	var new_menu: Control = _new_menu as Control

	# get the root for the given layer
	var root: Control = _get_menu_root(layer)
	if root == null:
		return

	# if the scene already exists, push error
	if !root.has_node(menu_uid) && root.get_node_or_null(menu_uid) != null:
		push_error(menu_uid + " is alreay in the " + root.name)
		return

	# put the uid as the name of the child
	new_menu.name = Utils.get_raw_uid(menu_uid)
	root.add_child(new_menu)

## Return the given menu root. Return null on error.
func _get_menu_root(layer: MenuLayer = MenuLayer.HUD) -> Control:
	match layer:
		MenuLayer.HUD:
			return hud_root
		MenuLayer.PAUSE:
			return pause_root
		MenuLayer.DEBUG:
			return debug_root
		MenuLayer.TRANSITION:
			return transition_root
		_:
			push_error("Given menu layer does not exists:" + str(layer))
			return null

## Return the given world root. Return null on error.
func _get_world_root(layer: WorldLayer = WorldLayer.LEVEL) -> Node3D:
	match layer:
		WorldLayer.LEVEL:
			return level_root
		WorldLayer.ENTITY:
			return entity_root
		_:
			push_error("Given world layer does not exists:" + str(layer))
			return null


## Instantiate a new player in the entity root
func _init_player() -> void:
	var player_scene: PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_UID)
		return

	player = player_scene.instantiate() as Player
	if player == null:
		push_error("Loaded player scene does not extend player or DNE: " + PLAYER_SCENE_UID)

	# for future if multiplayer ever happens
	player.name = "Host"
	entity_root.add_child(player)

# Finds the default spawn location in currently loaded scene, and places
# the Player at that position.
func _place_player_at_level_spawn() -> void:
	_init_player()
	if player == null:
		push_error("Cannot place player in level because it is null")
		return
	if _current_scene == null:
		push_error("Cannot place player into scene because scene is null")
		return

	player.global_position = _current_scene.get_default_player_spawn()

func _init_systems() -> void:
	# set itself on global to be globally accessible
	Global.MAIN = self
	# TODO (systems): Will be called to set up high level systems
