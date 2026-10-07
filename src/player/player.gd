class_name Player extends Entity

@onready var input_component: InputComponent = %InputComponent
@onready var camera_component: CameraComponent = %CameraComponent

@onready var inventory: InventoryNode = %Inventory

var _state_machine: StateMachine = null
var _menu_state_machine: StateMachine = null

func _ready() -> void:
	Global.player = self
	camera_component.character = self
	# setup state machines
	_setup_character_machine()
	_setup_menu_machine()

func _setup_character_machine() -> void:
	var idle: StateMachineState = PlayerIdleState.new()
	_state_machine = StateMachine.new(idle, [
		PlayerCrouchingState.new(),
		PlayerDamageState.new(),
		PlayerDeathState.new(),
		PlayerFlyingState.new(),
		idle,
		PlayerJumpingState.new(),
		PlayerMovingState.new(),
		PlayerSlidingState.new(),
	])

func _setup_menu_machine() -> void:
	var idle: StateMachineState = PlayerMenuIdleState.new()
	_menu_state_machine = StateMachine.new(idle, [
		PlayerMenuBuildingState.new(),
		PlayerMenuBuildListState.new(),
		PlayerMenuConsoleState.new(),
		idle,
		PlayerMenuInventoryState.new(),
		PlayerMenuPauseState.new(),
	])

func _input(event: InputEvent) -> void:
	_menu_state_machine._input(event)
	_state_machine._input(event)

func _process(delta: float) -> void:
	_menu_state_machine._process(delta)
	_state_machine._process(delta)

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

	_menu_state_machine._physics_process(delta)
	_state_machine._physics_process(delta)

## Get the raycast result of the camera orientation, with the given length.[br]
## - `length`: the length of the ray. Must be positive. If not, it is set to
## `1`.[br]
## - `ray_collision_mask`: the collision mask to apply to the ray. Must be
## positive, default to `0xFFFFFFFF`[br]
## - `exclude_rids`: a list of RIDs to exclude when colliding. Always include
## this player RID.[br]
## [br]
## The returned object is the same as `PhysicsDirectSpaceState3D.intersect_ray`.
func get_camera_ray(length: int = 500, ray_collision_mask: int = 0xFFFFFFFF, exclude_rids: Array[RID] = []) -> Dictionary:
	if length < 1:
		assert(false, ErrorList.ERR_V_HIGHER_OR_EQ % ["length", 1, length])
		length = 1
	# since the collision mask is a 32 bit flag like number, it cannot be higher than 2^32-1, which is 0xFFFFFFFF in hexadecimal.
	if ray_collision_mask < 0 || ray_collision_mask > 0xFFFFFFFF:
		assert(false, ErrorList.ERR_V_BETWEEN % ["ray_collision_mask", 0, 0xFFFFFFFF, ray_collision_mask])
		ray_collision_mask = 0xFFFFFFFF

	# add this player to the exclusion, because the camera can be inside the collision shape
	exclude_rids.append(get_rid())

	var camera: Camera3D = camera_component.camera
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var window_half_size: Vector2 = (get_viewport() as Window).size / 2.0

	var from: Vector3 = camera.project_ray_origin(window_half_size)
	var to: Vector3 = from + camera.project_ray_normal(window_half_size) * length

	return space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to,
		ray_collision_mask,
		exclude_rids
	))

# shoot a ray from the middle of the screen in the direction of the camera
func _shoot(value: int) -> void:
	var result: Dictionary = get_camera_ray(1000)

	if !result.is_empty():
		@warning_ignore("unsafe_cast")
		(result.collider as CollisionObject3D).emit_signal("hit", value)

func _on_damage(value: int) -> void:
	health_component.damage(value)

func _on_heal(value: int) -> void:
	health_component.heal(value)

func _on_effect() -> void:
	print("Got effect")

func setup_ui() -> void:
	# handled by the menu state machine
	pass

func remove_ui() -> void:
	_menu_state_machine.destroy()
