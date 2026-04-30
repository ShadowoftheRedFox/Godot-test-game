class_name Player extends CharacterBody3D

@onready var input_component: InputComponent = $InputComponent
@onready var move_component: MoveComponent = %MoveComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var camera_component: CameraComponent = %CameraComponent

func _ready() -> void:
	camera_component.character = self

func _physics_process(delta: float) -> void:
	input_component.update()
	
	if input_component.backs:
		get_tree().quit()
	
	move_component.direction = input_component.direction
	move_component.wants_jump = input_component.jumps
	move_component.wants_crouch = input_component.crouches
	move_component.wants_fly_up = input_component.fly_up
	move_component.wants_fly_down = input_component.fly_down
	
	# TEMP shoot
	if input_component.special_up or input_component.special_down:
		shoot(-5 if input_component.special_up else 5)
	
	# show mouse if interaction
	if input_component.interacts:
		input_component.hide_mouse = not input_component.hide_mouse
	
	move_component.update(delta)

# shoot a ray from the middle of the screen in the direction of the camera
func shoot(damage: int) -> void:
	var camera: Camera3D = camera_component.camera
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var window_half_size: Vector2 = (get_viewport() as Window).size / 2.0

	var from: Vector3 = camera.project_ray_origin(window_half_size)
	var to: Vector3 = from + camera.project_ray_normal(window_half_size) * 1000

	var result: Dictionary = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 
		0xFFFFFFFF,		# all masks
		[get_rid()])	# ignore self
	)

	if result:
		@warning_ignore("unsafe_cast")
		(result.collider as CollisionObject3D).emit_signal("hit", damage)
