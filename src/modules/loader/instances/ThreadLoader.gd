## Wrapper around a thread to load a callback.
class_name ThreadLoader extends AbstractLoader

## The thread callable function. Variant because it can be null or a callable.
var _callable: Variant = null
var _thread: Thread = null
var _result: Variant = null
var _result_sent: bool = false

func _init(callable: Callable) -> void:
    _callable = callable

func get_amount_loaded() -> int:
    return 1 if _thread != null && _thread.is_started() && !_thread.is_alive() else 0

func get_amount_to_load() -> int:
    return 1

func load() -> void:
    # can only load once
    if _thread != null:
        return

    _thread = Thread.new()
    @warning_ignore("unsafe_cast")
    var err: int = _thread.start(_callable as Callable)
    if err == ERR_CANT_CREATE:
        loading_failed.emit("failed to create thread")

    # start loading
    loading_started.emit()

func get_progress() -> float:
    if !_thread.is_started() || _thread.is_alive():
        return 0.0

    if !_result_sent:
        loading_ended.emit(get_result())
        _result_sent = true

    return 1.0

func get_result() -> Variant:
    if _thread.is_alive():
        return null

    if !_result_sent:
        _result = _thread.wait_to_finish()
        _result_sent = true

    return _result

# handle freeing this object when the thread is still running
func free() -> void:
    if _thread.is_alive():
        _result = _thread.wait_to_finish()
        loading_ended.emit(_result)
    super.free()
