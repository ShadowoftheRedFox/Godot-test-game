class_name PlayerPauseMenu extends MarginContainer

# Main menu button
@onready var resume: Button = %Resume
@onready var settings: Button = %Settings
@onready var save: Button = %Save
@onready var to_main_menu: Button = %ToMainMenu
@onready var quit: Button = %Quit

# Main submenu container
@onready var settings_menu: Control = %SettingsMenu
@onready var save_menu: Control = %SaveMenu

func _ready() -> void:
	_reset()
	resume.pressed.connect(_on_resume_button)
	settings.pressed.connect(_on_settings_button)
	save.pressed.connect(_on_save_button)
	to_main_menu.pressed.connect(_on_main_menu_button)
	quit.pressed.connect(_on_quit_button)

	visibility_changed.connect(_game_pause)

## Pause the tree when this menu is visible
func _game_pause() -> void:
	_reset()
	get_tree().paused = visible

func _reset() -> void:
	settings_menu.hide()
	settings.flat = false
	save_menu.hide()
	save.flat = false

func _on_settings_button() -> void:
	_reset()
	settings_menu.show()
	settings.flat = true

func _on_save_button() -> void:
	_reset()
	save_menu.show()
	save.flat = true

func _on_main_menu_button() -> void:
	Global.MAIN.remove_player()
	Global.MAIN.remove_current_scene()
	Global.MAIN.load_menu(MainGame.MAIN_MENU_SCENE_UID, MainGame.MenuLayer.HUD)
	get_tree().paused = false

func _on_quit_button() -> void:
	Global.quit_game()

func _on_resume_button() -> void:
	_reset()
	visible = false
	Global.player.resume_main_menu()
