## Implementation of the state machine pattern.
class_name StateMachine

## The current state of the machine.
var state: StateMachineState = null

## Map of registered states in the machine.
var _possible_states: Dictionary[StringName, StateMachineState] = {}

func _init(initial_state: StateMachineState, possible_state: Array[StateMachineState]) -> void:
    assert(initial_state != null, "Initial state machine's state can't be null")
    for s: StateMachineState in possible_state:
        if s.disabled:
            continue
        add_state(s)

    initialize()
    assert(_possible_states.size() != 0, "No states given")
    _ready(initial_state)

## Called when the state machine is created.
## Add states to the _possible_states array here.
func initialize() -> void:
    pass

## Fire up the machine. Any new more states will be ignored.
func _ready(initial_state: StateMachineState) -> void:
    state = initial_state
    _possible_states.make_read_only()

    for s: StateMachineState in _possible_states.values():
        s.finished.connect(_transition_to_next_state)

    state.enter(state.get_state_name())

## Add a new state to the list, only if the name is not already taken.
func add_state(added_state: StateMachineState) -> void:
    if added_state.disabled:
        return
    if has_state(added_state.get_state_name()):
        push_error("State \"", added_state.get_state_name(), "\" is already registered in the state list")
        return
    _possible_states.set(added_state.get_state_name(), added_state)

## Check if the machine has a state of this name.
func has_state(name: StringName) -> bool:
    return _possible_states.has(name)

## Get the state with the matching name. Null if it does not exists.
func get_state(name: StringName) -> StateMachineState:
    return _possible_states.get(name)

## Send inputs to the state.
func _input(event: InputEvent) -> void:
    state.handle_input(event)

## Make the state process.
func _process(delta: float) -> void:
    state.update(delta)

## Make the state process on physics.
func _physics_process(delta: float) -> void:
    state.physics_update(delta)

## Change to a new state.
func _transition_to_next_state(target_state: StringName, data: Dictionary = {}) -> void:
    if !has_state(target_state):
        push_error("Trying to transition to state " + target_state + " but it does not exist.")
        return

    var previous_state: StringName = state.get_state_name()
    state.exit()
    state = get_state(target_state)
    state.enter(previous_state, data)

## Clean the machine state before it is freed.
func destroy() -> void:
    for s: StateMachineState in _possible_states.values():
        s.destroy()
