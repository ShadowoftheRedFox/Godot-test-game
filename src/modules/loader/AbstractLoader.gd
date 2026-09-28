## An interface class used to load things and keep exterior actors updated.
## All loading task are done in a separate thread.
@abstract class_name AbstractLoader extends RefCounted

@warning_ignore_start("unused_signal")
## Signal emitted when the loading is starting.
signal loading_started()

## Signal emitted when the loading has ended, with the result.
signal loading_ended(result: Variant)

## Signals something has gone wrong, and the loading has stoppe, with the
## associated error.
signal loading_failed(error: String)
@warning_ignore_restore("unused_signal")

## Return the current progress. It must be a value between 0 and 1.
func get_progress() -> float:
	if get_amount_to_load() == 0:
		return 0.0
	return float(get_amount_loaded()) / float(get_amount_to_load())

## Get the amount of object to load. Must be a value greater or equal to 1.
@abstract func get_amount_to_load() -> int

## Get the amount of object to loaded. Must be between 0 and `get_amount_to_load()`.
@abstract func get_amount_loaded() -> int

## Starts the loading.
@abstract func load() -> void

## Gets the result once the loading is finished, even after the event has been
## emitted.
## Returns null if the loading is not finished.
## **NOTE:** The return value of the loading could be null, so use is_finished
## for a more reliable way to know if the loading is done.
@abstract func get_result() -> Variant

## Return true if the loader has not yet ended, even if it has not started yet.
func is_loading() -> bool:
	return get_progress() < 1.0

## Return true when the loading has ended.
func is_finished() -> bool:
	return !is_loading()
