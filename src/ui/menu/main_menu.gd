class_name MainMenu extends MarginContainer

@onready var continue_button: Button = %Continue
@onready var new_game_button: Button = %"New Game"
@onready var settings_button: Button = %Settings
@onready var load_button: Button = %Load
@onready var quit_button: Button = %Quit

@onready var settings_menu: Control = %SettingsMenu
@onready var load_menu: Control = %LoadMenu
@onready var create_menu: Control = %CreateMenu

func _ready() -> void:
	# disable the button if the last played save is null
	continue_button.disabled = Global.SM.last_played == null
	
	continue_button.pressed.connect(on_continue_button_clicked)
	new_game_button.pressed.connect(on_new_game_button_clicked)
	settings_button.pressed.connect(on_settings_button_clicked)
	load_button.pressed.connect(on_load_button_clicked)
	quit_button.pressed.connect(on_quit_button_clicked)

func _reset() -> void:
	settings_menu.hide()
	load_menu.hide()
	create_menu.hide()

func on_continue_button_clicked() -> void:
	pass

func on_new_game_button_clicked() -> void:
	if !create_menu.visible:
		_reset()
		create_menu.show()

func on_settings_button_clicked() -> void:
	if !settings_menu.visible:
		_reset()
		settings_menu.show()

func on_load_button_clicked() -> void:
	if !load_menu.visible:
		_reset()
		load_menu.show()

func on_quit_button_clicked() -> void:
	Global.quit_game()
