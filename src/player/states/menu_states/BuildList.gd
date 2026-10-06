## The player build list menu UI.
class_name PlayerMenuBuildListState extends MenuMachineState

const BUILDING_LIST: PackedScene = preload("uid://cxjgnbvyt6eix")
const NAME: StringName = &"buildingList"

var building_list_menu: BuildingMenuList = null

func get_state_name() -> StringName:
	return NAME

func setup_menu() -> void:
	var temp: Node = BUILDING_LIST.instantiate()
	if temp == null:
		printerr("Failed to load the building list menu")
		disabled = true
		return
	if temp is not BuildingMenuList:
		printerr("The provided scene is not a BuildingMenuList")
		disabled = true
		return
	building_list_menu = temp
	building_list_menu.visible = false
	Global.MAIN.ui_root.add_child(building_list_menu)

	building_list_menu.building_clicked.connect(_on_building_choosen)

func remove_menu() -> void:
	building_list_menu.building_clicked.disconnect(_on_building_choosen)
	building_list_menu.remove()

func enter(_previous_state_path: StringName, _data: Dictionary = {}) -> void:
	building_list_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func exit() -> void:
	building_list_menu.visible = false

func handle_input(_event: InputEvent) -> void:
	var c: bool = Input.is_action_just_pressed("action_build")
	var p: bool = Input.is_action_just_pressed("action_pause")

	if p || c:
		finished.emit(PlayerMenuIdleState.NAME)
		return

func _on_building_choosen(id: StringName) -> void:
	finished.emit(PlayerMenuBuildingState.NAME, {"building": id})
