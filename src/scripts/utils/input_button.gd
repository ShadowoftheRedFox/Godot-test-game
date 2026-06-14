## Button used in settings.
## It will listen to input event when clicked and update the InputMap accordingly.
class_name InputButton extends Button

## Emitted when the key changed
signal key_changed(ew_key: Key)

## The action to edit on input
@export var action: StringName
## If multipled keys are available on the action, this value tells which key to edit.
@export var key_id: int = 0
## True when listening fora key
var _listening: bool = false

const UNASSIGNED_ACTION: String = "Unassigned"
const NOT_IMPLEMENTED: String = "Not yet implemented"
const INPUT_NONE: String = "None"
const LISTENING_TEXT: String = "Press a key..."

func _init(input_action: StringName, input_key_id: int = 0) -> void:
	action = input_action
	key_id = input_key_id

func _ready() -> void:
	text = _get_key_name()
	# listen for button press
	pressed.connect(_on_pressed)
	# listen for input map reset
	InputMap.project_settings_loaded.connect(_update_text)

func _gui_input(event: InputEvent) -> void:
	if not _listening or disabled or event is InputEventMouse:
		return

	if event is InputEventKey:
		_update_input_map((event as InputEventKey).physical_keycode)
		get_viewport().set_input_as_handled()

	_listening = false

func _on_pressed() -> void:
	_listening = true
	text = LISTENING_TEXT

func _update_text() -> void:
	text = _get_key_name()

## Update the current action.
## To update an action, we need to delete the old action and add a new one.
func _update_input_map(key: Key, location: KeyLocation = KeyLocation.KEY_LOCATION_UNSPECIFIED) -> void:
	InputMap.action_erase_event(action, InputMap.action_get_events(action)[key_id])

	# create the event
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = key
	event.location = location

	# if key is escape, set unassigned
	if key == Key.KEY_ESCAPE:
		event.physical_keycode = KEY_NONE

	InputMap.action_add_event(action, event)
	_update_text()
	key_changed.emit(event.physical_keycode)
	# save changes
	Global.SM.save_parameters()

## Display the name if the action's key
func _get_key_name() -> String:
	# check if this action has our action's key
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	if events.size() <= key_id:
		return UNASSIGNED_ACTION

	# get the right event key
	var event: InputEvent = events[key_id]

	# we only handle InputEventKey for now
	if event is not InputEventKey:
		return NOT_IMPLEMENTED

	var event_key: InputEventKey = event

	# handle position (i.e. left or right ctrl)
	var key_position: String = ""
	if event_key.location != KeyLocation.KEY_LOCATION_UNSPECIFIED:
		key_position = "Left " if event_key.location == KeyLocation.KEY_LOCATION_LEFT else "Right "

	# if both key are none, display none
	if event_key.physical_keycode == Key.KEY_NONE && event_key.keycode == Key.KEY_NONE:
		return INPUT_NONE

	# get the key name, if physical, get the actual key label on the keyboard
	if event_key.keycode != Key.KEY_NONE:
		return key_position + OS.get_keycode_string(event_key.keycode)
	else:
		return key_position + OS.get_keycode_string(
			DisplayServer.keyboard_get_label_from_physical(event_key.physical_keycode)
		)
