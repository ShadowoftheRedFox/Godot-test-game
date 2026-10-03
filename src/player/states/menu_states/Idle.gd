## The normal player UI. Mainly show the toolbar.
class_name PlayerMenuIdleState extends MenuMachineState

const TOOLBAR: PackedScene = preload("uid://l5xxtvcovajb")
const NAME: StringName = &"idle"

var toolbar_menu: PlayerToolbar = null

func get_state_name() -> StringName:
	return NAME

func setup_menu() -> void:
	var temp: Node = TOOLBAR.instantiate()
	if temp == null:
		printerr("Failed to load the toolbar menu")
		disabled = true
		return
	if temp is not PlayerToolbar:
		printerr("The provided scene is not a PlayerToolbar")
		disabled = true
		return
	toolbar_menu = temp
	toolbar_menu.visible = true
	toolbar_menu.inventory = Global.player.inventory._inventory
	Global.MAIN.ui_root.add_child(toolbar_menu)

func remove_menu() -> void:
	toolbar_menu.remove()

func enter(_previous_state_path: StringName, _data: Dictionary = {}) -> void:
	toolbar_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func exit() -> void:
	toolbar_menu.visible = false

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("action_pause"):
		finished.emit(PlayerMenuPauseState.NAME)
		return
	if Input.is_action_just_pressed("action_console"):
		finished.emit(PlayerMenuConsoleState.NAME)
		return
	if Input.is_action_just_pressed("action_inventory"):
		finished.emit(PlayerMenuInventoryState.NAME)
		return
	if Input.is_action_just_pressed("action_build"):
		finished.emit(PlayerMenuBuildListState.NAME)
		return
