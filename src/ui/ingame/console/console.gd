class_name ConsoleMenu extends MarginContainer

@onready var console: RichTextLabel = %Console
@onready var edit: LineEdit = %ConsoleEdit

func _ready() -> void:
	_reset()
	visibility_changed.connect(on_visibility_changed)
	edit.text_submitted.connect(_on_submitted)
	Global.CONSOLE.output.connect(_on_print)
	Global.CONSOLE.suggest.connect(_on_complete)

func _input(event: InputEvent) -> void:
	# don't trigger when the menu is not visible or not focused on the edit
	if !visible || !edit.has_focus():
		return
	# trigger command autocomplete when pressing tab
	if event is InputEventKey && (event as InputEventKey).keycode == KEY_TAB && (event as InputEventKey).is_released():
		Global.CONSOLE.complete(edit.text)

func on_visibility_changed() -> void:
	_reset()
	edit.grab_focus()

func _reset() -> void:
	edit.clear()

## send the text to the console to parse the command
func _on_submitted(text: String) -> void:
	Global.CONSOLE.run(text);
	# TODO history of inputted text
	edit.text = ""

## listen to console response and display it
func _on_print(text: String) -> void:
	var length: int = console.text.length() + text.length() + 1 # +1 for \n
	if length <= Global.CONSOLE.CONSOLE_MAX_LENGTH:
		console.append_text("\n" + text)
		return
	# trim the start of the text if too long
	console.text = (console.text + "\n" + text).substr(length - Global.CONSOLE.CONSOLE_MAX_LENGTH, -1)

## Replace last word when we can autocomplete the value
func _on_complete(text: String) -> void:
	edit.text = text
	# edit caret position
	edit.caret_column = edit.text.length()
