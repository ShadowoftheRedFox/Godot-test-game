## The console UI.
class_name PlayerMenuConsoleState extends MenuMachineState

const CONSOLE: PackedScene = preload("uid://fgfsequli1l4")
var console_menu: ConsoleMenu = null

func get_state_name() -> StringName:
    return "console"

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
    Global.MAIN.hud_root.add_child(console_menu)

func remove_menu() -> void:
    console_menu.queue_free()

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
    console_menu.visible = true

func exit() -> void:
    console_menu.visible = false

func handle_input(_event: InputEvent) -> void:
    var c: bool = Input.is_action_just_pressed("action_console")
    var p: bool = Input.is_action_just_pressed("action_pause")

    if p || c:
        finished.emit("idle")
