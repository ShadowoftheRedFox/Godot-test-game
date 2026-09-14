class_name SettingsSubMenu extends Control

# Submenu button
@onready var settings_general: Button = %SettingsGeneral
@onready var settings_sound: Button = %SettingsSound
@onready var settings_graphic: Button = %SettingsGraphic
@onready var settings_control: Button = %SettingsControl

# Submenu containes
@onready var settings_general_menu: Control = %SettingsGeneralMenu
@onready var settings_sound_menu: Control = %SettingsSoundMenu
@onready var settings_graphic_menu: Control = %SettingsGraphicMenu
@onready var settings_control_menu: Control = %SettingsControlMenu

func _ready() -> void:
    _reset()
    settings_general.pressed.connect(_on_general_button)
    settings_sound.pressed.connect(_on_sound_button)
    settings_graphic.pressed.connect(_on_graphic_button)
    settings_control.pressed.connect(_on_control_button)

func _reset() -> void:
    settings_general_menu.hide()
    settings_general.flat = false
    settings_sound_menu.hide()
    settings_sound.flat = false
    settings_graphic_menu.hide()
    settings_graphic.flat = false
    settings_control_menu.hide()
    settings_control.flat = false

func _on_general_button() -> void:
    _reset()
    settings_general_menu.show()
    settings_general.flat = true

func _on_sound_button() -> void:
    _reset()
    settings_sound_menu.show()
    settings_sound.flat = true

func _on_graphic_button() -> void:
    _reset()
    settings_graphic_menu.show()
    settings_graphic.flat = true

func _on_control_button() -> void:
    _reset()
    settings_control_menu.show()
    settings_control.flat = true
