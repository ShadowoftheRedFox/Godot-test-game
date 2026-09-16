## A loading registry that can load multiple steps.
@abstract class_name MultipleLoadingRegistry extends LoadingRegistry

@warning_ignore_start("unused_signal")
## Signal emitted when the step is starting, with the given step.
signal step_started(step: int)

## Signal emitted when the step has ended, with the given step.
signal step_ended(step: int)

## Signals something ing the step has been loaded, with the current progress, between 0 and 1.
signal loading_step_progress(progress: float)
@warning_ignore_restore("unused_signal")

## Return the number of loading steps to do. Must be greater or equal to 0.
@abstract func get_step_size() -> int

## Get the value of the current step. Must be greater or equal to 0.
@abstract func get_step() -> int

## Return the current step progress. It must be a value between 0 and 1.
@abstract func get_step_progress() -> float
