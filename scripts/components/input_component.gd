class_name  InputComponent extends Node

var direction := Vector2.ZERO
var mouse_direction := Vector2.ZERO
var jumps := false
var interacts := false
var backs := false

var hide_mouse := true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # FIXME not working?

func update() -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	jumps = Input.is_action_just_pressed("move_jump")
	interacts = Input.is_action_just_pressed("action_interact")
	backs = Input.is_action_just_pressed("action_back")
	
	if hide_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
