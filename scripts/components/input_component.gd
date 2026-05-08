class_name InputComponent extends Node

var direction: Vector2 = Vector2.ZERO
var mouse_direction: Vector2 = Vector2.ZERO
var jumps: bool = false
var crouches: bool = false

var fly_up: bool = false
var fly_down: bool = false

var interacts: bool = false
var backs: bool = false

var special_up: bool = false
var special_down: bool = false

var hide_mouse: bool = true

func update() -> void:
	# check if in GUI
	if hide_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if hide_mouse:
		# if not in GUI, get inputs
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		jumps = Input.is_action_just_pressed("move_jump")
		crouches = Input.is_action_just_pressed("move_crouch")
		fly_up = Input.is_action_pressed("move_jump")
		fly_down = Input.is_action_pressed("move_crouch")
		special_up = Input.is_action_just_pressed("action_special_up")
		special_down = Input.is_action_just_pressed("action_special_down")
	else:
		# set all inputs to their "default" value
		direction = Vector2.ZERO
		jumps = false
		crouches = false
		fly_up = false
		fly_down = false
		special_up = false
		special_down = false

	interacts = Input.is_action_just_pressed("action_interact")
	backs = Input.is_action_just_pressed("action_back")
