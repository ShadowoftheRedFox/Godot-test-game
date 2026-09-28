class_name MainLoadingMenu extends LoadingMenu

@onready var global_label: Label = %GlobalLabel
@onready var global_progress: ProgressBar = %GlobalProgress
@onready var step_label: Label = %StepLabel
@onready var step_progress: ProgressBar = %StepProgress

var _loader: GameLoader = null

func _init() -> void:
	_loader = GameLoader.new()

func _ready() -> void:
	_loader.load()

func _process(_delta: float) -> void:
	global_label.text = _loader.get_current_step().get_name()
	global_progress.value = _loader.get_progress() * global_progress.max_value

	step_label.text = "Loading"
	global_progress.value = _loader.get_current_step().get_progress() * global_progress.max_value

func get_step_amount() -> int:
	return _loader.get_amount_to_load()

func get_step() -> int:
	return _loader.get_amount_loaded()

func get_progress() -> float:
	return _loader.get_progress()
