class_name GravityProp extends RigidBody3D

signal hit(damage: int)

@onready var move_component: MoveComponent = %MoveComponent
@onready var health_component: HealthComponent = %HealthComponent

func _ready() -> void:
	health_component.died.connect(_on_death)
	hit.connect(_on_hit)

func _physics_process(delta: float) -> void:
	move_component.update(delta)

func _on_death() -> void:
	queue_free()

func _on_hit(damage: int) -> void:
	if damage <= 0:
		health_component.damage(-damage)
	else:
		health_component.heal(damage)
