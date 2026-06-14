class_name Player extends Entity

@onready var input_component: InputComponent = %InputComponent
@onready var camera_component: CameraComponent = %CameraComponent

@onready var inventory: Inventory = %Inventory

@onready var player_gui: MarginContainer = %InventoryGui
@onready var main_menu: MarginContainer = %MainMenu
@onready var console_menu: MarginContainer = %ConsoleMenu

func _ready() -> void:
	GameState.player = self
	camera_component.character = self
	# listen for signal for UI
	input_component.UIChanged.connect(_on_ui_changed)

func _on_ui_changed() -> void:
	# TODO pause menu process when hidden?
	player_gui.visible = input_component.in_inventory
	main_menu.visible = input_component.in_main_menu
	console_menu.visible = input_component.in_console

func _physics_process(delta: float) -> void:
	move_component.direction = input_component.direction
	move_component.wants_jump = input_component.jumps
	move_component.wants_crouch = input_component.crouches
	move_component.wants_fly_up = input_component.fly_up
	move_component.wants_fly_down = input_component.fly_down

	# TODO better shoot
	if input_component.special_up or input_component.special_down:
		_shoot(-5 if input_component.special_up else 5)

	move_component.update(delta)

## Quit main menu and resume the game. Called from other scripts.
func resume_main_menu() -> void:
	input_component.in_main_menu = false
	input_component.update()

# shoot a ray from the middle of the screen in the direction of the camera
func _shoot(value: int) -> void:
	var camera: Camera3D = camera_component.camera
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var window_half_size: Vector2 = (get_viewport() as Window).size / 2.0

	var from: Vector3 = camera.project_ray_origin(window_half_size)
	var to: Vector3 = from + camera.project_ray_normal(window_half_size) * 1000

	var result: Dictionary = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to,
		0xFFFFFFFF, # all masks
		[get_rid()]) # ignore self
	)

	if result:
		@warning_ignore("unsafe_cast")
		(result.collider as CollisionObject3D).emit_signal("hit", value)

func _on_damage(value: int) -> void:
	health_component.damage(value)

func _on_heal(value: int) -> void:
	health_component.heal(value)

func _on_effect() -> void:
	print("Got effect")
