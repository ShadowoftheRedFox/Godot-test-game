class_name HealthComponent extends Node

## Emitted whn the health change (with heal or damage).
signal health_changed(value: int, max: int)
## Emitted when the current_health reaches 0.
signal died

## The maximum health of the entity.
@export var max_health: int = 100
## The current health between 0 and max_health.
@export var current_health: int = 100
## If invincible, the entity is not able to take damage.
@export var invincible: bool = false

func _ready() -> void:
	assert(max_health > 0, "Max health is 0! Use invinsible or use a static object.")
	current_health = clamp(current_health, 0, max_health)
	_emit()

func damage(value: int) -> void:
	if invincible:
		return
	
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
	health_changed.emit(current_health, max_health)
