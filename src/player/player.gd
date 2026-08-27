class_name Player extends Entity

const CONSOLE: PackedScene = preload("uid://fgfsequli1l4")
const INVENTORY: PackedScene = preload("uid://b50byu54aqqsv")
const TOOLBAR: PackedScene = preload("uid://l5xxtvcovajb")
const PAUSE: PackedScene = preload("uid://b30nyqm72dwjv")

@onready var input_component: InputComponent = %InputComponent
@onready var camera_component: CameraComponent = %CameraComponent

@onready var inventory: Inventory = %Inventory

@onready var inventory_menu: PlayerInventory = null
@onready var toolbar_menu: PlayerInventory = null
@onready var pause_menu: PlayerPauseMenu = null
@onready var console_menu: ConsoleMenu = null

func _ready() -> void:
	Global.player = self
	camera_component.character = self
	# listen for signal for UI
	input_component.UIChanged.connect(_on_ui_changed)

func _on_ui_changed() -> void:
	console_menu.visible = input_component.in_console
	inventory_menu.visible = input_component.in_inventory
	pause_menu.visible = input_component.in_main_menu

func _physics_process(delta: float) -> void:
	input_component.update()
	move_component.direction = input_component.direction
	move_component.wants_jump = input_component.jumps
	move_component.wants_crouch = input_component.crouches
	move_component.wants_fly_up = input_component.fly_up
	move_component.wants_fly_down = input_component.fly_down
	move_component.update(delta)
	# since input update on input event, a held key can stay true
	# for a long time, even if using 'pressed_once"
	# so reset jump when the move is done
	input_component.jumps = false

	# TODO better shoot
	if input_component.special_up or input_component.special_down:
		_shoot(-5 if input_component.special_up else 5)

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

func setup_ui() -> void:
	# we do not pass by the load_menu function from main_gale
	# because we want to have a reference of our node
	console_menu = CONSOLE.instantiate()
	inventory_menu = INVENTORY.instantiate()
	toolbar_menu = TOOLBAR.instantiate()
	inventory_menu.inventory = inventory
	toolbar_menu.inventory = inventory
	pause_menu = PAUSE.instantiate()

	Global.MAIN.hud_root.add_child(console_menu)
	Global.MAIN.hud_root.add_child(inventory_menu)
	Global.MAIN.hud_root.add_child(toolbar_menu)
	Global.MAIN.pause_root.add_child(pause_menu)

	_on_ui_changed()

func remove_ui() -> void:
	console_menu.queue_free()
	inventory_menu.queue_free()
	toolbar_menu.queue_free()
	pause_menu.queue_free()
