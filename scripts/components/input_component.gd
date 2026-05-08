class_name InputComponent extends Node

var direction: Vector2 = Vector2.ZERO
var mouse_direction: Vector2 = Vector2.ZERO
var jumps: bool = false
var crouches: bool = false

var fly_up: bool = false
var fly_down: bool = false

var interacts: bool = false

var special_up: bool = false
var special_down: bool = false

var in_inventory: bool = false
var in_main_menu: bool = false

func update() -> void:
	# toggle with the input
	in_main_menu = not in_main_menu if  Input.is_action_just_pressed("action_menu") else in_main_menu
	in_inventory = not in_inventory if Input.is_action_just_pressed("action_inventory") else in_inventory
	
	# can't be both menu at same time, so if both are open, main menu takes precedence
	if in_inventory and in_main_menu:
		in_inventory = false
	
	# check if in GUI
	if in_main_menu or in_inventory:
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

func _reset()->void:
	# set all inputs to their "default" value
	direction = Vector2.ZERO
	mouse_direction = Vector2.ZERO
	jumps = false
	crouches = false
	fly_up = false
	fly_down = false
	special_up = false
	special_down = false
