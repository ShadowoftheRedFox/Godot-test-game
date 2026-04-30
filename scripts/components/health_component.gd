class_name HealthComponent extends Node

signal health_changed(value: int, max: int)
signal died

@export var max_health: int = 100
@export var current_health: int = 100

func _ready() -> void:
	_emit()

func damage(value: int) -> void:
	assert(value >= 0, "Took damage but is negative, use heal instead?")
	current_health = clamp(current_health - value, 0, max_health)
	_emit()
	
	if current_health == 0:
		died.emit()
		
func heal(value: int) -> void:
	assert(value >= 0, "Took heal but is negative, use damage instead?")
	current_health = clamp(current_health + value, 0, max_health)
	_emit()

func _emit() -> void:
	#print("HP: %d / %d" % [current_health, max_health])
	health_changed.emit(current_health, max_health)
