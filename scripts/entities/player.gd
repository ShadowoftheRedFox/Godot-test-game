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
	
	# show mouse if interaction
	if input_component.interacts:
		input_component.hide_mouse = not input_component.hide_mouse
	
	move_component.update(delta)
