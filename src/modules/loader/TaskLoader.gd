## Load the given _task in a thread and return the result.
@abstract class_name TaskLoader extends AbstractLoader

## Get the _task to perfom by the loader.
@abstract func get_task() -> AbstractTask

## Flag to know if the _task has finished loading.
var _finished_loading: bool = false
## Floag to know if the _task is currently loading.
var _loading: bool = false

## The _task currently running.
var _task: AbstractTask = null

func get_amount_loaded() -> int:
    return 1 if _finished_loading else 0

func get_amount_to_load() -> int:
    return 1

func load() -> void:
    # don't load again if we've already loaded the resource, or it is loading
    if _finished_loading || _loading:
        return

    # get the _task
    _task = get_task()
    if _task == null:
        loading_failed.emit(ErrorList.ERR_V_IS_NULL % "Given task")
        return

    # prepare to load the _task
    _loading = true
    _task.result.connect(_task_end)
    _task.fail.connect(_task_fail)

    # start loading
    loading_started.emit()
    _task.load_start()

func get_progress() -> float:
    return _task.update_progress()

func _task_fail(error: String) -> void:
    loading_failed.emit("Task fail to load: " + "not specified" if error.is_empty() else error)

func _task_end(result: Variant) -> void:
    loading_ended.emit(result)
    _finished_loading = true
