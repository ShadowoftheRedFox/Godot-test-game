## An interface class used to load things and keep exterior actors updated.
## All loading task are done in a separate thread.
@abstract class_name AbstractLoader extends RefCounted

@warning_ignore_start("unused_signal")
## Signal emitted when the loading is starting.
signal loading_started()

## Signal emitted when the loading has ended, with the result.
signal loading_ended(result: Variant)

## Signals something has gone wrong, and the loading has stoppe, with the associated error.
signal loading_failed(error: String)
@warning_ignore_restore("unused_signal")

## Return the current progress. It must be a value between 0 and 1.
@abstract func get_progress() -> float

## Get the amount of object to load.
@abstract func get_amount_to_load() -> int

## Get the amount of object to loaded.
@abstract func get_amount_loaded() -> int

## Starts the loading.
@abstract func load() -> void
