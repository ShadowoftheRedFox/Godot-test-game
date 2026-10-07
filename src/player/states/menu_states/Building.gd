## The player building UI.
class_name PlayerMenuBuildingState extends MenuMachineState

const NAME: StringName = &"building"

## The maximum building distance before we hide the building.
const BUILDING_DISTANCE: int = 25

## The building "preview" we're currently placing.
var _choosen_building: BuildingInstance = null

func get_state_name() -> StringName:
	return NAME

func setup_menu() -> void:
	pass

func remove_menu() -> void:
	pass

func enter(_previous_state_path: StringName, _data: Dictionary = {}) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	@warning_ignore("unsafe_call_argument")
	_choosen_building = BuildingInstance.new(_data.get("building", ""))
	# TODO get the mesh from the definition
	var mesh: BoxMesh = BoxMesh.new()
	var mesh3d: MeshInstance3D = MeshInstance3D.new()
	mesh3d.mesh = mesh
	_choosen_building.add_child(mesh3d)

	# add the building to the scene
	Global.MAIN.level_root.add_child(_choosen_building)

	"""
	TODO:
	click to put it in the world permanently (somehow)
	maybe add a free place and a grid place
	rotate
	"""

func exit() -> void:
	_choosen_building.queue_free()

func handle_input(_event: InputEvent) -> void:
	var c: bool = Input.is_action_just_pressed("action_build")
	var p: bool = Input.is_action_just_pressed("action_pause")

	if p || c:
		finished.emit(PlayerMenuIdleState.NAME)
		return

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	_update_building_position()

func _update_building_position() -> void:
	if _choosen_building == null:
		return
	# get the camera direction and place the building on the first surface available
	var result: Dictionary = Global.player.get_camera_ray(BUILDING_DISTANCE)
	# if no collisions happened, hide the building
	var collider: Node = result.get("collider", null)
	if collider == null:
		_hide_building()
		return

	_show_building()
	# move the building to the intersected position
	_choosen_building.position = result.get("position", _choosen_building.position)
	# TODO need to displace the building again depending on the shape and grid

## Hide the building being placed.
func _hide_building() -> void:
	_choosen_building.hide()

## Show the building being placed.
func _show_building() -> void:
	_choosen_building.show()
