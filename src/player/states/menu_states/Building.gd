## The player building UI.
class_name PlayerMenuBuildingState extends MenuMachineState

const NAME: StringName = &"building"

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
	"""
	TODO add the building to the scene tree
	When moving the mouse, the building move on the ground, if it's in range
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
