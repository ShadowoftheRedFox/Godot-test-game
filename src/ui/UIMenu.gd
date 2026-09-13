## A class used as UI with some more function to  manage multiples UIs together.
class_name UIMenu extends MarginContainer

signal changed()

var _action: String = ""
var _is_open: bool = false
func _init(action: String) -> void:
    _action = action

func update() -> void:
    var menu_pressed: bool = Input.is_action_just_pressed(_action)
    if menu_pressed:
        _is_open = !_is_open
        changed.emit()
