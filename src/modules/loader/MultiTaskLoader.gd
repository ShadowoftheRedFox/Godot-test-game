## Class loading a set a task in a specific order, either one after another or in parralel.
@abstract class_name MultiTaskLoader extends TaskLoader

@warning_ignore_start("unused_signal")
## Signal emitted when the task at the given index is starting.
signal task_started(index: int)

## Signal emitted when the task at the given index has ended.
signal task_ended(index: int)

## Signals something has been loaded on the given task index, with the current progress, between 0 and 1.
signal task_progress(index: int, progress: float)
@warning_ignore_restore("unused_signal")

# TODO everything
