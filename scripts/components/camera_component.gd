class_name CameraComponent extends Node

@export var camera: Camera3D
@export_range(0.0, 1.0, 0.01, "Mouse sensitivity") var mouse_sensitivity := 0.01
var mouse_input := Vector2.ZERO
var input_rotation := Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input.x = -event.relative.x * mouse_sensitivity
		mouse_input.y = -event.relative.y * mouse_sensitivity

func move_camera(character: CharacterBody3D) -> void:
	if camera == null:
		return
	
	# up and down max movement
	input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	# left and right
	input_rotation.y += mouse_input.x
	
	# rotate camera
	camera.global_transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0, 0))
	
	# rotate character
	if character != null:
		#character.global_transform.basis = Basis.from_euler(Vector3(0, input_rotation.y, 0))
		character.rotation.y += input_rotation.y
	
	mouse_input = Vector2.ZERO
