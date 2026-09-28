## Generic class for menu loading something.
@abstract class_name LoadingMenu extends UIMenu

@warning_ignore_start("unused_signal")
## Signal emitted when the loading is starting.
signal loading_started()

## Signal emitted when the loading has ended.
signal loading_ended()

## Signal emitted when the step is starting, with the given step.
signal setp_started(step: int)

## Signal emitted when the step has ended, with the given step.
signal setp_ended(step: int)
@warning_ignore_restore("unused_signal")

## Return the number of loading steps to do. Must be greater or equal to 1.
@abstract func get_step_amount() -> int

## Get the currently loading step index. Must be greater or equal to 0, and less than `get_step_amount()`.
@abstract func get_step() -> int

## Return the progress of the current step. It must be a value between 0 and 1.
@abstract func get_progress() -> float
