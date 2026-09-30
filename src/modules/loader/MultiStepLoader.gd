## Class loading having multiple step during the loading.
class_name MultiStepLoader extends AbstractLoader

## Signal emitted when the step starts.
signal step_started(step: int)

## Signal emitted when the step at the given index has ended.
signal step_ended(step: int)

var _has_failed: bool = false
var _has_finished: bool = false
var _has_started: bool = false

var _steps: Array[Step] = []
var _steps_loaded: int = 0

## The step used in a MultiStepLoader.
## It is a wrapper around an AbstractLoader.
class Step extends AbstractLoader:
	## The inner loader of the step.
	var _loader: AbstractLoader = null
	## The name of the step to identify it.
	var _name: String = ""

	func _init(name: String, loader: AbstractLoader) -> void:
		assert(!Utils.is_blank(name), "name is blank")
		assert(loader != null, ErrorList.ERR_V_IS_NULL % "loader")
		_name = name
		_loader = loader
		_loader.loading_started.connect(_on_loading_started)
		_loader.loading_ended.connect(_on_loading_ended)
		_loader.loading_failed.connect(_on_loading_failed)

	func get_progress() -> float:
		return _loader.get_progress()

	func get_amount_loaded() -> int:
		return _loader.get_amount_loaded()

	func get_amount_to_load() -> int:
		return _loader.get_amount_to_load()

	func load() -> void:
		_loader.load()

	func get_result() -> Variant:
		return _loader.get_result()

	func _on_loading_started() -> void:
		loading_started.emit()

	func _on_loading_ended(result: Variant = null) -> void:
		loading_ended.emit(result)

	func _on_loading_failed(err: String = "") -> void:
		loading_failed.emit(err)

	## Get the name of this step.
	func get_name() -> String:
		return _name

## Return the current step progress. It must be a value between 0 and 1.
func get_step_progress() -> float:
	return get_current_step().get_progress()

## Return the total amount of step. Must be greater or equal to 1.
func get_step_amount_to_load() -> int:
	return get_current_step().get_amount_to_load()

## Return the amount of step finished. Must be a value between 0 and `get_amount_step_to_load()`.
func get_step_amount_loaded() -> int:
	return get_current_step().get_amount_loaded()

## Get the current step loading. If the loading is finished, return the last step in the list.
func get_current_step() -> Step:
	if _steps.size() > 0 && _steps.size() == _steps_loaded:
		return _steps[_steps.size() - 1]
	return _steps[_steps_loaded]

func get_amount_loaded() -> int:
	return _steps_loaded

func get_amount_to_load() -> int:
	return _steps.size()

func load() -> void:
	_steps.make_read_only()
	loading_started.emit()

	_has_started = true
	_step_start()

func get_progress() -> float:
	if !_has_started || _has_failed:
		return 0.0
	if _has_finished:
		return 1.0

	# update the current step
	get_current_step().get_progress()

	if get_amount_to_load() == 0:
		return 0.0
	return float(get_amount_loaded()) / float(get_amount_to_load())

## Return the list of result of each steps, in the same order of the steps.
## Return null if the loading isn't finished or failed.
func get_result() -> Variant:
	if !_has_started || _has_failed:
		return null

	var result: Array[Variant] = []
	for s: Step in _steps:
		result.append(s.get_result())

	if !_has_finished:
		loading_ended.emit(result)
		_has_finished = true

	return result

func _step_start() -> void:
	if _steps_loaded == _steps.size():
		get_result()
		return
	step_started.emit(_steps_loaded)
	get_current_step().loading_failed.connect(_step_fail, ConnectFlags.CONNECT_ONE_SHOT)
	get_current_step().loading_ended.connect(_step_end, ConnectFlags.CONNECT_ONE_SHOT)
	get_current_step().load()

func _step_fail(err: String) -> void:
	_has_failed = true
	loading_failed.emit("Step %s has failed: %s" % [get_current_step().get_name(), err])

func _step_end(_result: Variant) -> void:
	step_ended.emit(_steps_loaded)
	_steps_loaded += 1
	_step_start()
