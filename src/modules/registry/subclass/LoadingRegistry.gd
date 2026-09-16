## A registry with signal and amount of items to load.
@abstract class_name LoadingRegistry extends Registry

@warning_ignore_start("unused_signal")
## Signal emitted when the loading is starting.
signal loading_started()

## Signal emitted when the loading has ended.
signal loading_ended()

## Signals something has been loaded, with the current progress, between 0 and 1.
signal loading_progress(progress: float)
@warning_ignore_restore("unused_signal")

## Return the current progress. It must be a value between 0 and 1.
@abstract func get_progress() -> float

## Get the amount of object to load.
@abstract func get_amount_to_load() -> int

## Get the amount of object to loaded.
@abstract func get_amount_loaded() -> int

## Starts the loading.
@abstract func load() -> void

## Remove the prefix from the given value and return the trimmed value.
## Prefix are separated from their value by a ":"
static func _trim_prefix(mod_name: StringName, value: StringName) -> StringName:
    # remove the mod prefix if there is one
    var prefix: String = mod_name + ":"
    if value.begins_with(prefix):
        value = value.trim_prefix(prefix) as StringName
    return value
