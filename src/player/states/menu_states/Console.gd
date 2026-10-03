## The console UI.
class_name PlayerMenuConsoleState extends MenuMachineState

const CONSOLE: PackedScene = preload("uid://fgfsequli1l4")
const NAME: StringName = &"console"

var console_menu: ConsoleMenu = null

func get_state_name() -> StringName:
	return NAME

func setup_menu() -> void:
	var temp: Node = CONSOLE.instantiate()
	if temp == null:
		printerr("Failed to load the console menu")
		disabled = true
		return
	if temp is not ConsoleMenu:
		printerr("The provided scene is not a ConsoleMenu")
		disabled = true
		return
	console_menu = temp
	console_menu.visible = false
	Global.MAIN.ui_root.add_child(console_menu)

func remove_menu() -> void:
	console_menu.remove()

func enter(_previous_state_path: StringName, _data: Dictionary = {}) -> void:
	console_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func exit() -> void:
	console_menu.visible = false

func handle_input(_event: InputEvent) -> void:
	var c: bool = Input.is_action_just_pressed("action_console")
	var p: bool = Input.is_action_just_pressed("action_pause")

	if p || c:
		finished.emit(PlayerMenuIdleState.NAME)
