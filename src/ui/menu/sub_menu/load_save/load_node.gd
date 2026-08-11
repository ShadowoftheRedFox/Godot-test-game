class_name LoadNode extends Control

var _save: GameSave = null

@onready var label: Label = $VBoxContainer/Display/Label
@onready var load_button: Button = $VBoxContainer/Display/Load
@onready var info_button: Button = $VBoxContainer/Display/Info
@onready var delete: Button = $VBoxContainer/Display/Delete
@onready var infos: RichTextLabel = $VBoxContainer/Infos

func _ready() -> void:
	label.text = _save.name
	infos.text = "Created: " + Time.get_datetime_string_from_unix_time(int(_save.created_date), true) +\
		"\nLast played: " + Time.get_datetime_string_from_unix_time(int(_save.last_played), true)
	
	info_button.pressed.connect(on_infos_clicked)
	load_button.pressed.connect(on_load_clicked)
	infos.hide()

func on_load_clicked() -> void:
	_save.load()

func on_infos_clicked() -> void:
	if infos.visible:
		infos.hide()
	else:
		infos.show()
