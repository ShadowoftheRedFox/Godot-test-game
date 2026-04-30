class_name GravityProp extends RigidBody3D

@onready var move_component: MoveComponent = %MoveComponent
@onready var health_component: HealthComponent = %HealthComponent

func _physics_process(delta: float) -> void:
	move_component.update(delta)
