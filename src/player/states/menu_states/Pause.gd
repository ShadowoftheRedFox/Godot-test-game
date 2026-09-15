## The pause menu UI.
class_name PlayerMenuPauseState extends MenuMachineState

const PAUSE: PackedScene = preload("uid://b30nyqm72dwjv")
var pause_menu: PlayerPauseMenu = null

func get_state_name() -> StringName:
    return "pause"

func setup_menu() -> void:
    var temp: Node = PAUSE.instantiate()
    if temp == null:
        printerr("Failed to load the pause menu")
        disabled = true
        return
    if temp is not PlayerPauseMenu:
        printerr("The provided scene is not a PlayerPauseMenu")
        disabled = true
        return
    pause_menu = temp
    pause_menu.visible = false
    # listen for visibility changes, because the pause menu can close itself
    # when pressing the resume button
    pause_menu.visibility_changed.connect(_close_menu)
    Global.MAIN.pause_root.add_child(pause_menu)

func remove_menu() -> void:
    pause_menu.queue_free()

func enter(_previous_state_path: StringName, _data: Dictionary = {}) -> void:
    pause_menu.visible = true

func exit() -> void:
    if pause_menu.visible:
        pause_menu.visible = false
        _close_menu()

func handle_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("action_pause"):
        pause_menu.visible = false
        _close_menu()

func _close_menu() -> void:
    if !pause_menu.visible:
        finished.emit("idle")
