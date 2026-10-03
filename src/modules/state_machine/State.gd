## A state in a state machine.[br]
## Virtual base class for all states.
@abstract class_name StateMachineState extends RefCounted

## Flag at the startup. If set to true, the state will be removed from the
## state machine. Should be set at the initialization.
var disabled: bool = false

## Call the initialize function on startup.
func _init() -> void:
	initialiaze()

## Define here what happens when the class is created.
@abstract func initialiaze() -> void

## Get the name of the state. Should be unique in a machine.
@abstract func get_state_name() -> StringName

## Emitted when the state finishes and wants to transition to another state.
@warning_ignore("unused_signal")
signal finished(next_state_path: StringName, data: Dictionary)

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_previous_state_path: StringName, _data: Dictionary = {}) -> void:
	pass

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass

## Called when the machine is getting destroyed.
## Used for long term clean up, such as residual nodes.
func destroy() -> void:
	pass

func free() -> void:
	destroy()
	super.free()
