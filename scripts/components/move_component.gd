class_name MoveComponent extends Node

@export var body: CharacterBody3D
@export var model: Node3D
@export var camera: Camera3D

@export var move_speed: float = 10.0
@export var jump_force: float = 10.0

var direction: Vector2 = Vector2.ZERO
var wants_jump: bool = false
var flying: bool = false

func update(delta: float) -> void:
	if body == null:
		return
	
	# jump and gravity
	if wants_jump && body.is_on_floor():
		body.velocity.y = jump_force
	elif not body.is_on_floor():
		if wants_jump:
			# TODO raise and lower when flying
			flying = not flying
		if not flying:
			body.velocity.y += body.get_gravity().y * delta
	wants_jump = false
	
	# move in the direction of the camera (body rotation)
	var camera_basis: Basis = camera.global_transform.basis
	
	var up_down: Vector3 = camera_basis.z
	up_down.y = 0 # we walk on a flat plane, not on walls
	up_down = up_down.normalized()
	
	var left_right: Vector3 = camera_basis.x
	left_right.y = 0 # we walk on a flat plane, not on walls
	left_right = left_right.normalized()
	
	var move_direction: Vector3 = (direction.x * left_right + direction.y * up_down).normalized()
	
	body.velocity.x = move_direction.x * move_speed
	body.velocity.z = move_direction.z * move_speed
	
	body.move_and_slide()
