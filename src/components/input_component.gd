class_name InputComponent extends Node

var direction: Vector2 = Vector2.ZERO
var jumps: bool = false
var crouches: bool = false
var sprints: bool = false

var fly_up: bool = false
var fly_down: bool = false

var interacts: bool = false

var special_up: bool = false
var special_down: bool = false

func update() -> void:
	# for quick quit in dev mode
	if Input.is_action_pressed("action_pause") && Input.is_key_pressed(KEY_CTRL):
		Global.quit_game()
		return

	# if in GUI, don't get inputs and reset their values
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		_reset()
		return

	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	jumps = Input.is_action_just_pressed("move_jump")
	crouches = Input.is_action_just_pressed("move_crouch")
	fly_up = Input.is_action_pressed("move_jump")
	fly_down = Input.is_action_pressed("move_crouch")
	#special_up = Input.is_action_just_pressed("action_special_up")
	#special_down = Input.is_action_just_pressed("action_special_down")
	interacts = Input.is_action_just_pressed("action_interact")
	# TODO option to toggle sprint in settings
	# for now it's just hold
	sprints = Input.is_action_pressed("move_sprint")

func _reset() -> void:
	# set all inputs to their "default" value
	# prevent actions happening when there is a menu open
	direction = Vector2.ZERO
	jumps = false
	crouches = false
	fly_up = false
	fly_down = false
	special_up = false
	special_down = false
