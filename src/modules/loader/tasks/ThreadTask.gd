@abstract class_name ThreadTaskLoader extends AbstractTask

var _thread: Thread = null

@abstract func _thread_method() -> void

func load_start() -> void:
    # can only load once
    if _thread != null:
        return

    _thread = Thread.new()
    var err: int = _thread.start(_thread_method)
    if err == ERR_CANT_CREATE:
        fail.emit("failed to create thread")

func update_progress() -> float:
    if _thread.is_alive():
        return 0.0
    result.emit(get_result())
    return 1.0

func get_result() -> Variant:
    if _thread.is_alive():
        return null
    return _thread.wait_to_finish()
