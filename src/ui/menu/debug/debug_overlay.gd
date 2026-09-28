class_name DebugOverlay extends Control

const VERSION_SETTINGS: String = "application/config/version"

@onready var fps_label: Label = $MarginContainer/VBoxContainer/FpsLabel
@onready var version_info: Label = $MarginContainer/VBoxContainer/VersionInfo
@onready var debug_info: Label = $MarginContainer/VBoxContainer/DebugInfo

func _ready() -> void:
	_add_version()

func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _add_version() -> void:
	var version: String = ProjectSettings.get_setting(VERSION_SETTINGS)
	version_info.text = version
