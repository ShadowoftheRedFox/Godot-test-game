@abstract class_name Entity extends CharacterBody3D

## Received when the entity got damaged.
signal damage(value: int)
## Received when the entity got healed.
signal heal(value: int)
## Received when the entity got an effect.
signal effect

@export var move_component: MoveComponent
@export var health_component: HealthComponent

func _ready() -> void:
	assert(move_component != null, "An entity needs to have a MoveComponent! If it does not move, use a prop instead")
	assert(health_component != null, "An entity needs to have a HealthComponent! If it's invincible, check \"invincible\" on the health component")
	
	damage.connect(_on_damage)
	heal.connect(_on_heal)
	effect.connect(_on_effect)

## Fired when the damage signal is received.
@abstract func _on_damage(value: int) -> void
## Fired when the heal signal is received.
@abstract func _on_heal(value: int) -> void
## Fired when the effect signal is received.
@abstract func _on_effect() -> void
