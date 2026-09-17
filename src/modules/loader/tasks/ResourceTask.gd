class_name ResourceTask extends AbstractTask

var _path: String = ""
var _type_hint: String = ""
var _multiple_thread: bool = false

func _init(path: String, type_hint: String = "", multiple_thread: bool = false) -> void:
    assert(!Utils.is_blank(path), "Resource path can't be blank")
    _path = path
    _type_hint = type_hint
    _multiple_thread = multiple_thread

func load_start() -> void:
    # can only load once
    if ResourceLoader.load_threaded_get_status(_path) != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
        return

    ResourceLoader.load_threaded_request(_path, _type_hint, _multiple_thread, ResourceLoader.CACHE_MODE_REUSE)
    update_progress()

func update_progress() -> float:
    var progress: Array[float] = []
    match ResourceLoader.load_threaded_get_status(_path, progress):
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            return progress[0]
        ResourceLoader.THREAD_LOAD_FAILED:
            fail.emit("loading failed")
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            fail.emit("invalid resource")
        ResourceLoader.THREAD_LOAD_LOADED:
            result.emit(get_result())
            return 1.0
    return 0.0

func get_result() -> Variant:
    match ResourceLoader.load_threaded_get_status(_path):
        ResourceLoader.THREAD_LOAD_LOADED:
            return ResourceLoader.load_threaded_get(_path)
        _:
            return null
