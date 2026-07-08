class_name MainMenu extends MarginContainer

@onready var continue_button: Button = %Continue
@onready var new_game_button: Button = %"New Game"
@onready var settings_button: Button = %Settings
@onready var load_button: Button = %Load
@onready var quit_button: Button = %Quit
@onready var settings_menu: Control = %SettingsMenu
@onready var save_menu: Control = %SaveMenu
@onready var load_menu: Control = %LoadMenu

func _ready() -> void:
	# disable the button if the last played save is null
	continue_button.disabled = Global.SM.last_played == null
	
