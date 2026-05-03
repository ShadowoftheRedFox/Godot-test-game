class_name DeathAnimationComponent extends Node

enum DeathAnimations {
	NONE,
	DESINTEGRATION
} 

@export var health_component: HealthComponent
@export var mesh: MeshInstance3D
@export var animation: DeathAnimations

func _ready() -> void:
	health_component.died.connect(_on_death)

func _on_death() -> void:
	if mesh == null:
		_finalize()
		return
	
	match animation:
		DeathAnimations.NONE:
			_finalize()

func animate_desintegration() -> void:
	pass

func _finalize() -> void:
	queue_free()
