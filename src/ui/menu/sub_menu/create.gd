extends Control

@onready var name_edit: LineEdit = %NameEdit

@onready var seed_edit: LineEdit = %SeedEdit
@onready var random_seed: Button = %RandomSeed

@onready var create: Button = %Create
@onready var error: Label = $MarginContainer/VBoxContainer/Error

func _ready() -> void:
	create.pressed.connect(on_create_pressed)
	name_edit.text_changed.connect(on_name_edit)
	name_edit.focus_exited.connect(on_name_focus_exited)

	seed_edit.text_changed.connect(on_seed_edit)
	seed_edit.focus_exited.connect(on_seed_focus_exited)

	random_seed.pressed.connect(on_random_pressed)

	# disable on start because no name has been given
	_check_create_can_enable()
	# generate a random seed
	on_random_pressed()

func on_random_pressed() -> void:
	seed_edit.text = Utils.get_random_string(64)

func on_name_edit(_text: String) -> void:
	_check_create_can_enable()

func on_name_focus_exited() -> void:
	name_edit.text = name_edit.text.strip_edges()

func on_seed_edit(_text: String) -> void:
	_check_create_can_enable()

func on_seed_focus_exited() -> void:
	seed_edit.text = seed_edit.text.strip_edges()

## Disable the create button if either the name or the seed is empty
func _check_create_can_enable() -> void:
	var save_name: String = name_edit.text.strip_edges()
	create.disabled = save_name.is_empty() || seed_edit.text.strip_edges().is_empty()

	# we don't need to check if the name is unique, because the save is in a
	# folder with the name of the current time

func on_create_pressed() -> void:
	var save: GameSave = GameSave.new()
	save.name = name_edit.text
	save.world_seed = seed_edit.text

	if !save.save():
		error.text = "Error while creating your save"
		return

	save.load()
