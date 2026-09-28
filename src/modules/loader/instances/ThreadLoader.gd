## Wrapper around a thread to load a callback.
class_name ThreadLoader extends AbstractLoader

## The thread callable function. Variant because it can be null or a callable.
var _callable: Variant = null
## The thread used to load.
var _thread: Thread = null
## Stored result when teh thread has finished.
var _result: Variant = null

var _has_failed: bool = false
var _has_finished: bool = false
var _has_started: bool = false

## A string where the thread can put an error during its runtime, then the thread must stop.
## If the string is not empty, the loading will stop, emitting this error.
var _thread_error: String = ""

## Set the callable of the thread before the loading is started.
## The callable given should be thread safe.
func set_callable(callable: Callable) -> void:
	_callable = callable

func get_amount_loaded() -> int:
	return 1 if _thread != null && _thread.is_started() && !_thread.is_alive() else 0

func get_amount_to_load() -> int:
	return 1

func load() -> void:
	# stop loading more than once
	if _has_failed || _has_finished || _has_started:
		return

	if _callable != null && _callable is not Callable:
		_has_failed = true
		loading_failed.emit("callable is null or not a Callable")
		return

	_thread = Thread.new()

	# start loading
	_has_started = true
	@warning_ignore("unsafe_cast")
	var err: int = _thread.start(_callable as Callable)
	if err == ERR_CANT_CREATE:
		_has_failed = true
		loading_failed.emit("failed to create thread")
		return

	loading_started.emit()

func get_progress() -> float:
	if !_has_started || _has_failed:
		return 0.0
	if _has_finished:
		return 1.0

	if _thread.is_started() && !_thread.is_alive():
		_get_result()
		return 1.0 if _has_finished else 0.0

	var to_load: int = get_amount_to_load()
	if to_load <= 0:
		return 0.0

	return float(get_amount_loaded()) / float(to_load)

func get_result() -> Variant:
	_get_result()

	return _result

## Inner get_result, which has a force parameter to directly call the `Thread.wait_to_finish()` if true.
func _get_result(force: bool = false) -> void:
	if !force && (_thread.is_alive() || _has_finished || !_has_started || _has_failed):
		return

	_result = _thread.wait_to_finish()
	if !_thread_error.is_empty():
		_has_failed = true
		loading_failed.emit.call_deferred(_thread_error)
	else:
		_has_finished = true
		loading_ended.emit.call_deferred(_result)

# handle freeing this object when the thread is still running
func free() -> void:
	if _thread.is_alive():
		# force the result to wait for the thread to finish
		_get_result(true)
	super.free()
