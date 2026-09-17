## The task to load in a TaskLoader.
@abstract class_name AbstractTask extends RefCounted

@warning_ignore_start("unused_signal")
## Must be emitted when the loading has finished, with the attached result.
signal result(value: Variant)
## Emitted to inform the loader on the progress. The value must be between 0 and 1.
## Emitted when the task fails.
signal fail(error: String)
@warning_ignore_restore("unused_signal")

## Called when we want to start the loading task.
@abstract func load_start() -> void
## Update the current task progress, and get the current loading progreess, between 0 and 1.
## Must be called to check regurlarly on the state of the loading.
@abstract func update_progress() -> float
## Get the result, or return null if the result is not loaded yet.
@abstract func get_result() -> Variant
