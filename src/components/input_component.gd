class_name InputComponent extends Node

var direction: Vector2 = Vector2.ZERO
var mouse_direction: Vector2 = Vector2.ZERO
var jumps: bool = false
var crouches: bool = false
var sprints: bool = false

var fly_up: bool = false
var fly_down: bool = false

var interacts: bool = false

var special_up: bool = false
var special_down: bool = false

var in_inventory: bool = false
var in_main_menu: bool = false
var in_console: bool = false

## Sent when a UI is opened of closed.
signal UIChanged()

func update() -> void:
	# toggle with the input
	var menu_pressed: bool = Input.is_action_just_pressed("action_menu")
	var inventory_pressed: bool = Input.is_action_just_pressed("action_inventory")
	var console_pressed: bool = Input.is_action_just_pressed("action_console")
	in_main_menu = not in_main_menu if menu_pressed else in_main_menu
	in_inventory = not in_inventory if inventory_pressed else in_inventory
	in_console = not in_console if console_pressed else in_console
	
	# can't be both menu at same time, so if both are open, main menu takes precedence
	if in_main_menu:
		in_inventory = false
		in_console = false
	# same deal with console, but only takes precedence over inventory
	if in_console:
		in_inventory = false

	# send signal if any UI related keys are pressed
	if menu_pressed || inventory_pressed || console_pressed:
		UIChanged.emit()

	# for quick quit in dev mode
	if in_main_menu && Input.is_key_pressed(KEY_CTRL):
		Global.quit_game()

	# check if in GUI
	if in_main_menu || in_inventory || in_console:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# if in GUI, don't get inputs and reset their values
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		_reset()
		return

	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	jumps = Input.is_action_just_pressed("move_jump")
	crouches = Input.is_action_just_pressed("move_crouch")
	fly_up = Input.is_action_pressed("move_jump")
	fly_down = Input.is_action_pressed("move_crouch")
	special_up = Input.is_action_just_pressed("action_special_up")
	special_down = Input.is_action_just_pressed("action_special_down")
	interacts = Input.is_action_just_pressed("action_interact")
	# TODO option to toggle sprint in settings
	# for now it's just hold
	sprints = Input.is_action_pressed("move_sprint")

func _reset() -> void:
	# set all inputs to their "default" value
	# prevent actions happening when there is a menu open
	direction = Vector2.ZERO
	mouse_direction = Vector2.ZERO
	jumps = false
	crouches = false
	fly_up = false
	fly_down = false
	special_up = false
	special_down = false
