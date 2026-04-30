class_name MoveComponent extends Node

@export var body: CharacterBody3D
@export var model: Node3D
@export var camera: Camera3D

@export var is_able_to_fly: bool = false

@export var move_speed: float = 10.0
@export var fly_speed: float = 20.0
@export var jump_force: float = 10.0

var direction: Vector2 = Vector2.ZERO
var wants_jump: bool = false
var wants_crouch: bool = false

var wants_fly: bool = false
var flying: bool = false
var wants_fly_up: bool = false
var wants_fly_down: bool = false

var wants_fly_timer: Timer = Timer.new()
var wants_fly_counter: int = 0

func _ready() -> void:
	if not is_able_to_fly:
		return

	wants_fly_timer.wait_time = 0.2
	wants_fly_timer.one_shot = true
	wants_fly_timer.timeout.connect(wants_fly_timeout)
	add_child(wants_fly_timer)
	
func wants_fly_timeout() -> void:
	if wants_fly_counter >= 2:
		wants_fly = true
		print("Flying!")
	wants_fly_counter = 0

func update(delta: float) -> void:
	if body == null:
		return
		
	# detects wants_fly as two short spaced jumps
	if is_able_to_fly and wants_jump:
		if wants_fly_timer.is_stopped():
			wants_fly_timer.start()
		if not wants_fly_timer.is_stopped():
			wants_fly_counter += 1
	
	# fly AND jump and gravity
	if is_able_to_fly and wants_fly:
		flying = not flying
		body.velocity.y = 0

	if is_able_to_fly and flying:
		if wants_fly_up:
			body.velocity.y = fly_speed
		elif wants_fly_down:
			body.velocity.y = - fly_speed
		else:
			body.velocity.y = 0
	elif wants_jump and body.is_on_floor():
		body.velocity.y = jump_force
	elif not body.is_on_floor():
		body.velocity.y += body.get_gravity().y * delta
	wants_jump = false
	wants_fly = false
	
	# move in the direction of the camera (body rotation)
	if camera != null:
		var camera_basis: Basis = camera.global_transform.basis
		
		var up_down: Vector3 = camera_basis.z
		up_down.y = 0 # we walk on a flat plane, not on walls
		up_down = up_down.normalized()
		
		var left_right: Vector3 = camera_basis.x
		left_right.y = 0 # we walk on a flat plane, not on walls
		left_right = left_right.normalized()
		
		var move_direction: Vector3 = (direction.x * left_right + direction.y * up_down).normalized()
		
		var speed: float = fly_speed if flying else move_speed
		body.velocity.x = move_direction.x * speed
		body.velocity.z = move_direction.z * speed
	
	body.move_and_slide()
