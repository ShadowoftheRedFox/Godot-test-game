@tool
@icon("res://path/to/icon.svg")
class_name PascalCase extends Node
## Brief description of the class
##
## Longer docutmentation here

# signals
@warning_ignore("unused_signal")
signal something_happened(value: Variant)

# enums (PascalCase, members are CONSTANT_CASE
enum EnumCase {
	VALUE_1,
	VALUE_2
}

# constants
const CONSTANT_VARIABLE: float = 3.14

# exported variables
@export var exported_variable: float = 9.8

# public variable (not prefixed by an underscore, snake_case)
var is_public_variable: bool = true

# private variables (prefixed by an underscore, snake_case)
@warning_ignore("unused_private_class_variable")
var _is_private_variable: bool = true

# onready variables
@onready var on_ready_variable: Node = $Node

# export tool button
@export_tool_button("Tool button", "Button") var button_action: Callable = _on_button_action

# optional built in virtual methods
# _init()
# _enter_tree()
# _ready()
# All other virtual methods

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

# public methods (not prefixed by an underscore, snake_case)
@warning_ignore("unused_parameter")
func do_something(something: InnerSomething) -> void:
	pass

# export tool button function
func _on_button_action() -> void:
	pass

# private methods (prefixed by an underscore, snake_case)
func _do_something_private() -> String:
	return "Secret"

# callback
func _on_something_happened() -> void:
	pass

# inner class
class InnerSomething:
	pass
